//
//  TabViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import WebKit
import Core
import Combine
import StoreKit
import LocalAuthentication
import BrowserServicesKit
import SwiftUI
import Bookmarks
import Persistence
import Common
import DDGSync
import PrivacyDashboard
import UserScript
import ContentBlocking
import TrackerRadarKit
import Networking
import SecureStorage
import History
import ContentScopeScripts
import SpecialErrorPages
import NetworkProtection
import Onboarding
import os.log
import Navigation
import Subscription

class TabViewController: UIViewController {

    private struct Constants {
        static let frameLoadInterruptedErrorCode = 102
        static let trackerNetworksAnimationDelay: TimeInterval = 0.7
        static let secGPCHeader = "Sec-GPC"
        static let navigationExpectationInterval = 3.0
    }
    
    @IBOutlet private(set) weak var error: UIView!
    @IBOutlet private(set) weak var errorInfoImage: UIImageView!
    @IBOutlet private(set) weak var errorHeader: UILabel!
    @IBOutlet private(set) weak var errorMessage: UILabel!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var webViewContainer: UIView!
    var webViewBottomAnchorConstraint: NSLayoutConstraint?
    var daxContextualOnboardingController: UIViewController?
    
    /// Stores the visual state of the web view
    /// Used by DuckPlayer to save and restore view appearance when switching between normal browsing and fullscreen (portrail/landscape) video modes.
    private struct ViewSettings {
        
        let viewBackground: UIColor?
        let webViewBackground: UIColor?
        let webViewOpaque: Bool
        let scrollViewBackground: UIColor?
        
        /// Default view settings        
        static var `default`: ViewSettings {
            ViewSettings(
                viewBackground: .systemBackground,
                webViewBackground: nil,
                webViewOpaque: true,
                scrollViewBackground: .systemBackground
            )
        }
    }
    private var savedViewSettings: ViewSettings?

    @IBOutlet var showBarsTapGestureRecogniser: UITapGestureRecognizer!

    private let instrumentation = TabInstrumentation()
    let tabInteractionStateSource: TabInteractionStateSource?

    var isLinkPreview = false

    // A workaround for an issue when in some cases webview reports `isLoading == true` when it was stoppped.
    var isLoading: Bool {
        webView.isLoading && !wasLoadingStoppedExternally
    }

    var openedByPage = false
    weak var openingTab: TabViewController? {
        didSet {
            delegate?.tabLoadingStateDidChange(tab: self)
        }
    }
    
    weak var delegate: TabDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?

    var findInPage: FindInPage? {
        get { return findInPageScript?.findInPage }
        set { findInPageScript?.findInPage = newValue }
    }

    let favicons = Favicons.shared
    let progressWorker = WebProgressWorker()

    private(set) var webView: WKWebView!
    private lazy var appRatingPrompt: AppRatingPrompt = AppRatingPrompt()
    public weak var privacyDashboard: PrivacyDashboardViewController?
    
    private var storageCache: StorageCache = AppDependencyProvider.shared.storageCache
    let appSettings: AppSettings

    var featureFlagger: FeatureFlagger
    let subscriptionCookieManager: SubscriptionCookieManaging
    private lazy var internalUserDecider = AppDependencyProvider.shared.internalUserDecider

    private lazy var autofillNeverPromptWebsitesManager = AppDependencyProvider.shared.autofillNeverPromptWebsitesManager
    private lazy var autofillWebsiteAccountMatcher = AutofillWebsiteAccountMatcher(autofillUrlMatcher: AutofillDomainNameUrlMatcher(),
                                                                                   tld: TabViewController.tld)
    private(set) var tabModel: Tab
    private(set) var privacyInfo: PrivacyInfo?
    private var previousPrivacyInfosByURL: [URL: PrivacyInfo] = [:]
    
    private let requeryLogic = RequeryLogic()

    private static let tld = AppDependencyProvider.shared.storageCache.tld
    private let adClickAttributionDetection = ContentBlocking.shared.makeAdClickAttributionDetection(tld: tld)
    let adClickAttributionLogic = ContentBlocking.shared.makeAdClickAttributionLogic(tld: tld)

    private var httpsForced: Bool = false
    private var lastUpgradedURL: URL?
    private var lastError: Error?
    private var lastHttpStatusCode: Int?
    private var shouldReloadOnError = false
    private var failingUrls = Set<String>()
    private var urlProvidedBasicAuthCredential: (credential: URLCredential, url: URL)?
    private var emailProtectionSignOutCancellable: AnyCancellable?

    public var inferredOpenerContext: BrokenSiteReport.OpenerContext?
    private var refreshCountSinceLoad: Int = 0
    private var performanceMetrics: PerformanceMetricsSubfeature?

    private var detectedLoginURL: URL?
    private var fireproofingWorker: FireproofingWorking?

    private var trackersInfoWorkItem: DispatchWorkItem?
    
    private var tabURLInterceptor: TabURLInterceptor
    private var currentlyLoadedURL: URL?

    private let netPConnectionObserver: ConnectionStatusObserver = AppDependencyProvider.shared.connectionObserver
    private var netPConnectionObserverCancellable: AnyCancellable?
    private var netPConnectionStatus: ConnectionStatus = .default
    private var netPConnected: Bool {
        switch netPConnectionStatus {
        case .connected:
            return true
        default:
            break
        }

        return false
    }

    let privacyProDataReporter: PrivacyProDataReporting

    // Required to know when to disable autofill, see SaveLoginViewModel for details
    // Stored in memory on TabViewController for privacy reasons
    private var domainSaveLoginPromptLastShownOn: String?
    // Required to prevent fireproof prompt presenting before autofill save login prompt
    private var saveLoginPromptLastDismissed: Date?
    private var saveLoginPromptIsPresenting: Bool = false

    private var cachedRuntimeConfigurationForDomain: [String: String?] = [:]

    // If no trackers dax dialog was shown recently in this tab, ie without the user navigating somewhere else, e.g. backgrounding or tab switcher
    private var woShownRecently = false

    // Temporary to gather some data.  Fire a follow up if no trackers dax dialog was shown and then trackers appear.
    private var fireWoFollowUp = false

    // Indicates if there was an external call to stop loading current request. Resets on new load request, refresh and failures.
    private var wasLoadingStoppedExternally = false

    // In certain conditions we try to present a dax dialog when one is already showing, so check to ensure we don't
    var isShowingFullScreenDaxDialog = false
    
    var temporaryDownloadForPreviewedFile: Download?
    var mostRecentAutoPreviewDownloadID: UUID?
    private var blobDownloadTargetFrame: WKFrameInfo?

    // Recent request's URL if its WKNavigationAction had shouldPerformDownload set to true
    private var recentNavigationActionShouldPerformDownloadURL: URL?

    let userAgentManager: UserAgentManager = DefaultUserAgentManager.shared
    
    let bookmarksDatabase: CoreDataDatabase
    lazy var faviconUpdater = FireproofFaviconUpdater(bookmarksDatabase: bookmarksDatabase,
                                                      tab: tabModel,
                                                      favicons: Favicons.shared)

    private let refreshControl = UIRefreshControl()

    private let certificateTrustEvaluator: CertificateTrustEvaluating
    var storedSpecialErrorPageUserScript: SpecialErrorPageUserScript?
    let syncService: DDGSyncing

    private let daxDialogsDebouncer = Debouncer(mode: .common)

    public var url: URL? {
        willSet {
            if newValue != url {
                delegate?.closeFindInPage(tab: self)
            }
        }
        didSet {
            updateTabModel()
            delegate?.tabLoadingStateDidChange(tab: self)
            checkLoginDetectionAfterNavigation()
        }
    }
    
    override var title: String? {
        didSet {
            updateTabModel()
            delegate?.tabLoadingStateDidChange(tab: self)
            if let url {
                let finalURL = duckPlayerNavigationHandler?.getDuckURLFor(url)
                historyCapture.titleDidChange(title, forURL: finalURL)
            }
        }
    }

    public var isError: Bool {
        return !error.isHidden
    }
    
    public var errorText: String? {
        return errorMessage.text
    }
    
    public var link: Core.Link? {
        if isError {
            if let url = url ?? webView.url ?? URL(string: "") {
                return Link(title: errorText, url: url)
            }
        }
        
        guard let url = url else {
            return tabModel.link
        }
                        
        let finalURL = duckPlayerNavigationHandler?.getDuckURLFor(url) ?? url
        let activeLink = Link(title: title, url: finalURL)
        guard let storedLink = tabModel.link else {
            return activeLink
        }
        
        return activeLink.merge(with: storedLink)
    }

    var emailManager: EmailManager? {
        return (parent as? MainViewController)?.emailManager
    }

    lazy var vaultManager: SecureVaultManager = {
        let manager = SecureVaultManager(shouldAllowPartialFormSaves: featureFlagger.isFeatureOn(.autofillPartialFormSaves),
                                         tld: AppDependencyProvider.shared.storageCache.tld)
        manager.delegate = self
        return manager
    }()

    private lazy var credentialIdentityStoreManager: AutofillCredentialIdentityStoreManager = {
        return AutofillCredentialIdentityStoreManager(reporter: SecureVaultReporter(),
                                                      tld: AppDependencyProvider.shared.storageCache.tld)
    }()

    private static let debugEvents = EventMapping<AMPProtectionDebugEvents> { event, _, _, onComplete in
        let domainEvent: Pixel.Event
        switch event {
        case .ampBlockingRulesCompilationFailed:
            domainEvent = .ampBlockingRulesCompilationFailed
            Pixel.fire(pixel: domainEvent,
                       withAdditionalParameters: [:],
                       onComplete: onComplete)
        }
    }
    
    private lazy var linkProtection: LinkProtection = {
        LinkProtection(privacyManager: ContentBlocking.shared.privacyConfigurationManager,
                       contentBlockingManager: ContentBlocking.shared.contentBlockingManager,
                       errorReporting: Self.debugEvents)

    }()
    
    private lazy var referrerTrimming: ReferrerTrimming = {
        ReferrerTrimming(privacyManager: ContentBlocking.shared.privacyConfigurationManager,
                         contentBlockingManager: ContentBlocking.shared.contentBlockingManager,
                         tld: AppDependencyProvider.shared.storageCache.tld)
    }()
        
    private var canDisplayJavaScriptAlert: Bool {
        return presentedViewController == nil
            && delegate?.tabCheckIfItsBeingCurrentlyPresented(self) ?? false
            && !self.jsAlertController.isShown
    }

    func present(_ alert: WebJSAlert) {
        self.jsAlertController.present(alert)
    }

    private func dismissJSAlertIfNeeded() {
        if jsAlertController.isShown {
            jsAlertController.dismiss(animated: false)
        }
    }

    private let rulesCompilationMonitor = RulesCompilationMonitor.shared
    
    private var lastRenderedURL: URL?

    static func loadFromStoryboard(model: Tab,
                                   appSettings: AppSettings = AppDependencyProvider.shared.appSettings,
                                   bookmarksDatabase: CoreDataDatabase,
                                   historyManager: HistoryManaging,
                                   syncService: DDGSyncing,
                                   duckPlayer: DuckPlayerControlling?,
                                   privacyProDataReporter: PrivacyProDataReporting,
                                   contextualOnboardingPresenter: ContextualOnboardingPresenting,
                                   contextualOnboardingLogic: ContextualOnboardingLogic,
                                   onboardingPixelReporter: OnboardingCustomInteractionPixelReporting,
                                   featureFlagger: FeatureFlagger,
                                   subscriptionCookieManager: SubscriptionCookieManaging,
                                   textZoomCoordinator: TextZoomCoordinating,
                                   websiteDataManager: WebsiteDataManaging,
                                   fireproofing: Fireproofing,
                                   tabInteractionStateSource: TabInteractionStateSource?,
                                   specialErrorPageNavigationHandler: SpecialErrorPageManaging) -> TabViewController {
        let storyboard = UIStoryboard(name: "Tab", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "TabViewController", creator: { coder in
            TabViewController(coder: coder,
                              tabModel: model,
                              appSettings: appSettings,
                              bookmarksDatabase: bookmarksDatabase,
                              historyManager: historyManager,
                              syncService: syncService,
                              duckPlayer: duckPlayer,
                              privacyProDataReporter: privacyProDataReporter,
                              contextualOnboardingPresenter: contextualOnboardingPresenter,
                              contextualOnboardingLogic: contextualOnboardingLogic,
                              onboardingPixelReporter: onboardingPixelReporter,
                              featureFlagger: featureFlagger,
                              subscriptionCookieManager: subscriptionCookieManager,
                              textZoomCoordinator: textZoomCoordinator,
                              fireproofing: fireproofing,
                              websiteDataManager: websiteDataManager,
                              tabInteractionStateSource: tabInteractionStateSource,
                              specialErrorPageNavigationHandler: specialErrorPageNavigationHandler
            )
        })
        return controller
    }

    private var userContentController: UserContentController {
        (webView.configuration.userContentController as? UserContentController)!
    }


    let historyManager: HistoryManaging
    let historyCapture: HistoryCapture
    weak var duckPlayer: DuckPlayerControlling?
    var duckPlayerNavigationHandler: DuckPlayerNavigationHandling?

    let contextualOnboardingPresenter: ContextualOnboardingPresenting
    let contextualOnboardingLogic: ContextualOnboardingLogic
    let onboardingPixelReporter: OnboardingCustomInteractionPixelReporting
    let textZoomCoordinator: TextZoomCoordinating
    let fireproofing: Fireproofing
    let websiteDataManager: WebsiteDataManaging
    let specialErrorPageNavigationHandler: SpecialErrorPageManaging

    required init?(coder aDecoder: NSCoder,
                   tabModel: Tab,
                   appSettings: AppSettings,
                   bookmarksDatabase: CoreDataDatabase,
                   historyManager: HistoryManaging,
                   syncService: DDGSyncing,
                   certificateTrustEvaluator: CertificateTrustEvaluating = CertificateTrustEvaluator(),
                   duckPlayer: DuckPlayerControlling?,
                   privacyProDataReporter: PrivacyProDataReporting,
                   contextualOnboardingPresenter: ContextualOnboardingPresenting,
                   contextualOnboardingLogic: ContextualOnboardingLogic,
                   onboardingPixelReporter: OnboardingCustomInteractionPixelReporting,
                   urlCredentialCreator: URLCredentialCreating = URLCredentialCreator(),
                   featureFlagger: FeatureFlagger,
                   subscriptionCookieManager: SubscriptionCookieManaging,
                   textZoomCoordinator: TextZoomCoordinating,
                   fireproofing: Fireproofing,
                   websiteDataManager: WebsiteDataManaging,
                   tabInteractionStateSource: TabInteractionStateSource?,
                   specialErrorPageNavigationHandler: SpecialErrorPageManaging) {
        self.tabModel = tabModel
        self.appSettings = appSettings
        self.bookmarksDatabase = bookmarksDatabase
        self.historyManager = historyManager
        self.historyCapture = HistoryCapture(historyManager: historyManager)
        self.syncService = syncService
        self.certificateTrustEvaluator = certificateTrustEvaluator
        self.duckPlayer = duckPlayer
        if let duckPlayer {
            self.duckPlayerNavigationHandler = DuckPlayerNavigationHandler(duckPlayer: duckPlayer,
                                                                           appSettings: appSettings)
        }
        self.privacyProDataReporter = privacyProDataReporter
        self.contextualOnboardingPresenter = contextualOnboardingPresenter
        self.contextualOnboardingLogic = contextualOnboardingLogic
        self.onboardingPixelReporter = onboardingPixelReporter
        self.featureFlagger = featureFlagger
        self.subscriptionCookieManager = subscriptionCookieManager
        self.textZoomCoordinator = textZoomCoordinator
        self.fireproofing = fireproofing
        self.websiteDataManager = websiteDataManager
        self.tabInteractionStateSource = tabInteractionStateSource
        self.specialErrorPageNavigationHandler = specialErrorPageNavigationHandler

        self.tabURLInterceptor = TabURLInterceptorDefault(featureFlagger: featureFlagger) {
            return AppDependencyProvider.shared.subscriptionManager.canPurchase
        }

        super.init(coder: aDecoder)
        
        // Assign itself as tabNavigationHandler for DuckPlayer
        duckPlayerNavigationHandler?.tabNavigationHandler = self

        // Assign itself as specialErrorPageNavigationDelegate for SpecialErrorPages
        specialErrorPageNavigationHandler.delegate  = self

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fireproofingWorker = FireproofingWorking(controller: self, fireproofing: fireproofing)
        initAttributionLogic()
        decorate()
        addTextZoomObserver()
        subscribeToEmailProtectionSignOutNotification()
        registerForDownloadsNotifications()
        registerForAddressBarLocationNotifications()
        registerForAutofillNotifications()
        
        if #available(iOS 16.4, *) {
            registerForInspectableWebViewNotifications()
        }

        observeNetPConnectionStatusChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        registerForResignActive()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unregisterFromResignActive()
        tabInteractionStateSource?.saveState(webView.interactionState, for: tabModel)
    }

    private func registerForAddressBarLocationNotifications() {
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(onAddressBarPositionChanged),
                                               name: AppUserDefaults.Notifications.addressBarPositionChanged,
                                               object: nil)
    }

    @available(iOS 16.4, *)
    private func registerForInspectableWebViewNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWebViewInspectability),
                                               name: AppUserDefaults.Notifications.inspectableWebViewsToggled,
                                               object: nil)
    }

    @available(iOS 16.4, *) @objc
    private func updateWebViewInspectability() {
#if DEBUG
        webView.isInspectable = true
#else
        webView.isInspectable = AppUserDefaults().inspectableWebViewEnabled
#endif
    }

    @objc
    private func onAddressBarPositionChanged() {
        updateWebViewBottomAnchor()
    }

    private func updateWebViewBottomAnchor() {
        let targetHeight = chromeDelegate?.barsMaxHeight ?? 0.0
        webViewBottomAnchorConstraint?.constant = appSettings.currentAddressBarPosition == .bottom ? -targetHeight : 0
    }

    private func observeNetPConnectionStatusChanges() {
        netPConnectionObserverCancellable = netPConnectionObserver.publisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.netPConnectionStatus, onWeaklyHeld: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The email manager is pulled from the main view controller, so reconnect it now, otherwise, it's nil
        userScripts?.autofillUserScript.emailDelegate = emailManager

        woShownRecently = false // don't fire if the user goes somewhere else first
        updateWebViewBottomAnchor()
        resetNavigationBar()
        delegate?.tabDidRequestShowingMenuHighlighter(tab: self)
        tabModel.viewed = true
        
        // Link DuckPlayer to current Tab
        duckPlayerNavigationHandler?.setHostViewController(self)
    }

    override func buildActivities() -> [UIActivity] {
        let viewModel = MenuBookmarksViewModel(bookmarksDatabase: bookmarksDatabase, syncService: syncService)
        viewModel.favoritesDisplayMode = appSettings.favoritesDisplayMode

        var activities: [UIActivity] = [SaveBookmarkActivity(controller: self,
                                                             viewModel: viewModel)]

        activities.append(SaveBookmarkActivity(controller: self,
                                               isFavorite: true,
                                               viewModel: viewModel))
        activities.append(FindInPageActivity(controller: self))

        return activities
    }
    
    func initAttributionLogic() {
        adClickAttributionLogic.delegate = self
        adClickAttributionDetection.delegate = adClickAttributionLogic
    }
    
    func updateTabModel() {
        if let url = url {
            let link = Link(title: title, url: url)
            tabModel.link = link
        } else {
            tabModel.link = nil
        }
    }
        
    @objc func onApplicationWillResignActive() {
        shouldReloadOnError = true

        tabInteractionStateSource?.saveState(webView.interactionState, for: tabModel)
    }
    
    func applyInheritedAttribution(_ attribution: AdClickAttributionLogic.State?) {
        adClickAttributionLogic.applyInheritedAttribution(state: attribution)
    }

    // The `consumeCookies` is legacy behaviour from the previous Fireproofing implementation. Cookies no longer need to be consumed after invocations
    // of the Fire button, but the app still does so in the event that previously persisted cookies have not yet been consumed.
    func attachWebView(configuration: WKWebViewConfiguration,
                       interactionStateData: Data? = nil,
                       andLoadRequest request: URLRequest?,
                       consumeCookies: Bool,
                       loadingInitiatedByParentTab: Bool = false,
                       customWebView: ((WKWebViewConfiguration) -> WKWebView)? = nil) {
        instrumentation.willPrepareWebView()

        let userContentController = UserContentController()
        configuration.userContentController = userContentController
        userContentController.delegate = self

        if let customWebView {
            webView = customWebView(configuration)
            view.layoutIfNeeded()
        } else {
            webView = WKWebView(frame: view.bounds, configuration: configuration)
        }
        textZoomCoordinator.onWebViewCreated(applyToWebView: webView)
        specialErrorPageNavigationHandler.attachWebView(webView)

        webView.allowsLinkPreview = true
        webView.allowsBackForwardNavigationGestures = true

        addObservers()

        webView.navigationDelegate = self
        webView.uiDelegate = self

        webViewContainer.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webViewBottomAnchorConstraint = webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webViewBottomAnchorConstraint!,
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor)
        ])

        webView.scrollView.refreshControl = refreshControl
        // Be sure to set `tintColor` after the control is attached to ScrollView otherwise haptics are gone.
        // We don't have to care about it for this control instance the next time `setRefreshControlEnabled`
        // is called. Looks like a bug introduced in iOS 17.4 (https://github.com/facebook/react-native/issues/43388)
        configureRefreshControl(refreshControl)

        updateContentMode()

        if #available(iOS 16.4, *) {
            updateWebViewInspectability()
        }

        let didRestoreWebViewState = restoreInteractionStateToWebView(interactionStateData)

        instrumentation.didPrepareWebView()

        // Initialize DuckPlayerNavigationHandler
        if let handler = duckPlayerNavigationHandler,
            let webView = webView {
            handler.handleAttach(webView: webView)
        }
        
        if consumeCookies {
            consumeCookiesThenLoadRequest(request)
        } else if !didRestoreWebViewState, let urlRequest = request {
            var loadingStopped = false
            linkProtection.getCleanURLRequest(from: urlRequest, onStartExtracting: { [weak self] in
                if loadingInitiatedByParentTab {
                    // stop parent-initiated URL loading only if canonical URL extraction process has started
                    loadingStopped = true
                    self?.webView.stopLoading()
                }
                self?.showProgressIndicator()
            }, onFinishExtracting: {}, completion: { [weak self] cleanURLRequest in
                // restart the cleaned-up URL loading here if:
                //   link protection provided an updated URL
                //   OR if loading was stopped for a popup loaded by its parent
                //   OR for any other navigation which is not a popup loaded by its parent
                // the check is here to let an (about:blank) popup which has its loading
                // initiated by its parent to keep its active request, otherwise we would
                // break a js-initiated popup request such as printing from a popup
                guard self?.url != cleanURLRequest.url || loadingStopped || !loadingInitiatedByParentTab else { return }
                self?.load(urlRequest: cleanURLRequest)

            })
        }

#if DEBUG
        webView.onDeinit { [weak self] in
            self?.assertObjectDeallocated(after: 4.0)
        }
        webView.configuration.processPool.onDeinit { [weak userContentController] in
            userContentController?.assertObjectDeallocated(after: 1.0)
        }
#endif
    }

    private func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }

    private func configureRefreshControl(_ control: UIRefreshControl) {
        refreshControl.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            reload()
            delegate?.tabDidRequestRefresh(tab: self)
            Pixel.fire(pixel: .pullToRefresh)
            if let url = webView.url {
                AppDependencyProvider.shared.pageRefreshMonitor.register(for: url)
            }
        }, for: .valueChanged)

        refreshControl.backgroundColor = .systemBackground
        refreshControl.tintColor = .label
    }

    private func consumeCookiesThenLoadRequest(_ request: URLRequest?) {

        func doLoad() {
            if let request = request {
                load(urlRequest: request)
            }

            if request != nil {
                delegate?.tabLoadingStateDidChange(tab: self)
                onWebpageDidStartLoading(httpsForced: false)
            }
        }

        Task { @MainActor in
            await webView.configuration.websiteDataStore.dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            await websiteDataManager.consumeCookies(into: cookieStore)
            subscriptionCookieManager.resetLastRefreshDate()
            await subscriptionCookieManager.refreshSubscriptionCookie()
            doLoad()
        }
    }
    
    public func executeBookmarklet(url: URL) {
        if let js = url.toDecodedBookmarklet() {
            webView.evaluateJavaScript(js)
        }
    }

    public func load(url: URL) {
        wasLoadingStoppedExternally = false
        webView.stopLoading()
        dismissJSAlertIfNeeded()

        load(url: url, didUpgradeURL: false)
    }
    
    public func load(backForwardListItem: WKBackForwardListItem) {
        webView.stopLoading()
        dismissJSAlertIfNeeded()

        updateContentMode()
        webView.go(to: backForwardListItem)
    }
    
    private func load(url: URL, didUpgradeURL: Bool) {
        if !didUpgradeURL {
            lastUpgradedURL = nil
            privacyInfo?.connectionUpgradedTo = nil
        }

        var url = url
        if let credential = url.basicAuthCredential {
            url = url.removingBasicAuthCredential()
            self.urlProvidedBasicAuthCredential = (credential, url)
        }

        if !url.isBookmarklet() {
            self.url = url
        }
        
        lastError = nil
        updateContentMode()
        linkProtection.getCleanURL(from: url,
                                   onStartExtracting: { showProgressIndicator() },
                                   onFinishExtracting: { },
                                   completion: { [weak self] url in
            self?.load(urlRequest: .userInitiated(url))
        })
    }

    func prepareForDataClearing() {
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        delegate = nil
        
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
    }
    
    private func load(urlRequest: URLRequest) {
        loadViewIfNeeded()
        
        if let url = urlRequest.url, !shouldReissueSearch(for: url) {
            requeryLogic.onNewNavigation(url: url)
        }

        assert(urlRequest.attribution == .user, "WebView requests should be user attributed")

        refreshCountSinceLoad = 0

        webView.stopLoading()
        dismissJSAlertIfNeeded()
        webView.load(urlRequest)
    }
    
    // swiftlint:disable block_based_kvo
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        // swiftlint:enable block_based_kvo

        guard let keyPath = keyPath,
              let webView = webView else { return }

        switch keyPath {
            
        case #keyPath(WKWebView.estimatedProgress):
            progressWorker.progressDidChange(webView.estimatedProgress)
            
        case #keyPath(WKWebView.url):
        // A short delay is required here, because the URL takes some time
        // to propagate to the webView.url property accessor and might not
        // be immediately available in the observer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.webViewUrlHasChanged()
        }
            
        case #keyPath(WKWebView.canGoBack):
            delegate?.tabLoadingStateDidChange(tab: self)
            
        case #keyPath(WKWebView.canGoForward):
            delegate?.tabLoadingStateDidChange(tab: self)

        case #keyPath(WKWebView.title):
            title = webView.title

        default:
            Logger.general.debug("Unhandled keyPath \(keyPath)")
        }
    }
    
    func webViewUrlHasChanged() {
        
        // Handle DuckPlayer Navigation URL changes
        if let handler = duckPlayerNavigationHandler,
           let currentURL = webView.url {
            _ = handler.handleURLChange(webView: webView)
        }
            
        if url == nil {
            url = webView.url
        } else if let currentHost = url?.host, let newHost = webView.url?.host, currentHost == newHost {
            url = webView.url
        }
    }
    
    func enableFireproofingForDomain(_ domain: String) {
        FireproofingAlert.showConfirmFireproofWebsite(usingController: self, forDomain: domain) { [weak self] in
            Pixel.fire(pixel: .browsingMenuFireproof)
            self?.fireproofingWorker?.handleUserEnablingFireproofing(forDomain: domain)
        }
    }
    
    func disableFireproofingForDomain(_ domain: String) {
        fireproofingWorker?.handleUserDisablingFireproofing(forDomain: domain)
    }

    func dismissContextualDaxFireDialog() {
        guard contextualOnboardingLogic.isShowingFireDialog else { return }
        contextualOnboardingPresenter.dismissContextualOnboardingIfNeeded(from: self)
    }

    private func checkForReloadOnError() {
        guard shouldReloadOnError else { return }
        shouldReloadOnError = false
        reload()
    }
    
    private func shouldReissueDDGStaticNavigation(for url: URL) -> Bool {
        guard url.isDuckDuckGoStatic else { return false }
        return !url.hasCorrectSearchHeaderParams
    }
    
    private func reissueNavigationWithSearchHeaderParams(for url: URL) {
        load(url: url.applyingSearchHeaderParams())
    }
    
    private func shouldReissueSearch(for url: URL) -> Bool {
        guard url.isDuckDuckGoSearch else { return false }
        return !url.hasCorrectMobileStatsParams || !url.hasCorrectSearchHeaderParams
    }
    
    private func reissueSearchWithRequiredParams(for url: URL) {
        let mobileSearch = url.applyingStatsParams()
        reissueNavigationWithSearchHeaderParams(for: mobileSearch)
    }
    
    private func showProgressIndicator() {
        progressWorker.didStartLoading()
    }
    
    private func hideProgressIndicator() {
        progressWorker.didFinishLoading()
        webView.scrollView.refreshControl?.endRefreshing()
    }

    public func reload() {
        wasLoadingStoppedExternally = false
        updateContentMode()
        cachedRuntimeConfigurationForDomain = [:]
        if let handler = duckPlayerNavigationHandler {
            duckPlayerNavigationHandler?.handleReload(webView: webView)
        } else {
            webView.reload()
        }
        delegate?.tabLoadingStateDidChange(tab: self)
        privacyDashboard?.dismiss(animated: true)
    }
    
    func updateContentMode() {
        webView.configuration.defaultWebpagePreferences.preferredContentMode = tabModel.isDesktop ? .desktop : .mobile
    }

    func goBack() {
        dismissJSAlertIfNeeded()
        
        if let url = url, url.isDuckPlayer {
            webView.stopLoading()
            if webView.canGoBack {
                duckPlayerNavigationHandler?.handleGoBack(webView: webView)
                chromeDelegate?.omniBar.resignFirstResponder()
                return
            }
            if openingTab != nil {
                delegate?.tabDidRequestClose(self)
                return
            }
        }

        if isError {
            hideErrorMessage()
            url = webView.url
            onWebpageDidStartLoading(httpsForced: false)
            onWebpageDidFinishLoading()
            return
        }

        if webView.canGoBack {
            webView.goBack()
            chromeDelegate?.omniBar.resignFirstResponder()
            return
        }

        if openingTab != nil {
            delegate?.tabDidRequestClose(self)
        }
        
    }
    
    func goForward() {
        dismissJSAlertIfNeeded()

        if webView.goForward() != nil {
            chromeDelegate?.omniBar.resignFirstResponder()
        }
    }
    
    private func showError(message: String) {
        webView.isHidden = true
        error.isHidden = false
        errorMessage.text = message
        error.layoutIfNeeded()
    }
    
    private func hideErrorMessage() {
        error.isHidden = true
        webView.isHidden = false
    }

    private func isDuckDuckGoUrl() -> Bool {
        guard let url = url else { return false }
        return url.isDuckDuckGo
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let chromeDelegate = chromeDelegate else { return }

        if let controller = segue.destination as? PrivacyDashboardViewController {
            controller.popoverPresentationController?.delegate = controller

            if let iconView = chromeDelegate.omniBar.privacyInfoContainer.privacyIcon {
                controller.popoverPresentationController?.sourceView = iconView
                controller.popoverPresentationController?.sourceRect = iconView.bounds
            }
            privacyDashboard = controller
        }
        
        if let controller = segue.destination as? FullscreenDaxDialogViewController {
            controller.spec = sender as? DaxDialogs.BrowsingSpec
            controller.woShown = woShownRecently
            controller.delegate = self
            
            if controller.spec?.highlightAddressBar ?? false {
                chromeDelegate.omniBar.cancelAllAnimations()
            }
        }
    }

    private var jsAlertController: JSAlertController!
    @IBSegueAction
    func createJSAlertController(coder: NSCoder, sender: Any?, segueIdentifier: String?) -> JSAlertController? {
        self.jsAlertController = JSAlertController(coder: coder)!
        return self.jsAlertController
    }

    @IBSegueAction
    private func makePrivacyDashboardViewController(coder: NSCoder) -> PrivacyDashboardViewController? {
        return PrivacyDashboardViewController(coder: coder,
                                       privacyInfo: privacyInfo,
                                       entryPoint: .dashboard,
                                       privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
                                       contentBlockingManager: ContentBlocking.shared.contentBlockingManager,
                                       breakageAdditionalInfo: makeBreakageAdditionalInfo())
    }
    
    private func addTextZoomObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onTextZoomChange),
                                               name: AppUserDefaults.Notifications.textZoomChange,
                                               object: nil)
    }


    private func subscribeToEmailProtectionSignOutNotification() {
        emailProtectionSignOutCancellable = NotificationCenter.default.publisher(for: .emailDidSignOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onDuckDuckGoEmailSignOut(notification)
            }
    }

    @objc func onTextZoomChange() {
        textZoomCoordinator.onTextZoomChange(applyToWebView: webView)
    }

    @objc func onDuckDuckGoEmailSignOut(_ notification: Notification) {
        guard let url = webView.url else { return }
        if url.isDuckDuckGoEmailProtection {
            webView.evaluateJavaScript("window.postMessage({ emailProtectionSignedOut: true }, window.origin);")
        }
    }

    private func resetNavigationBar() {
        chromeDelegate?.setNavigationBarHidden(false)
    }

    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars()
    }

    private func showBars(animated: Bool = true) {
        chromeDelegate?.setBarsHidden(false, animated: animated, customAnimationDuration: nil)
    }

    func showPrivacyDashboard() {
        Pixel.fire(pixel: .privacyDashboardOpened)
        performSegue(withIdentifier: "PrivacyDashboard", sender: self)
    }

    func setRefreshControlEnabled(_ isEnabled: Bool) {
        webView.scrollView.refreshControl = isEnabled ? refreshControl : nil
    }

    private var didGoBackForward: Bool = false {
        didSet {
            if didGoBackForward {
                contextualOnboardingPresenter.dismissContextualOnboardingIfNeeded(from: self)
            }
        }
    }

    private func resetDashboardInfo() {
        if let url = url {
            if didGoBackForward, let privacyInfo = previousPrivacyInfosByURL[url] {
                self.privacyInfo = privacyInfo
                didGoBackForward = false
            } else {
                privacyInfo = makePrivacyInfo(url: url, shouldCheckServerTrust: true)
            }
        } else {
            privacyInfo = nil
        }
        onPrivacyInfoChanged()
    }
    
    public func makePrivacyInfo(url: URL, shouldCheckServerTrust: Bool = false) -> PrivacyInfo? {
        guard let host = url.host else { return nil }
        
        let entity = ContentBlocking.shared.trackerDataManager.trackerData.findParentEntityOrFallback(forHost: host)

        let privacyInfo = PrivacyInfo(url: url,
                                      parentEntity: entity,
                                      protectionStatus: makeProtectionStatus(for: host),
                                      malicousSiteThreatKind: specialErrorPageNavigationHandler.currentThreatKind,
                                      shouldCheckServerTrust: shouldCheckServerTrust)
        let isValid = certificateTrustEvaluator.evaluateCertificateTrust(trust: webView.serverTrust)
        if let isValid {
            privacyInfo.serverTrust = isValid ? webView.serverTrust : nil
        }
        privacyInfo.isSpecialErrorPageVisible = specialErrorPageNavigationHandler.isSpecialErrorPageVisible

        previousPrivacyInfosByURL[url] = privacyInfo
        
        return privacyInfo
    }
    
    private func makeProtectionStatus(for host: String) -> ProtectionStatus {
        let config = ContentBlocking.shared.privacyConfigurationManager.privacyConfig
        
        let isTempUnprotected = config.isTempUnprotected(domain: host)
        let isAllowlisted = config.isUserUnprotected(domain: host)
        
        var enabledFeatures: [String] = []
        
        if !config.isInExceptionList(domain: host, forFeature: .contentBlocking) {
            enabledFeatures.append(PrivacyFeature.contentBlocking.rawValue)
        }
        
        return ProtectionStatus(unprotectedTemporary: isTempUnprotected,
                                enabledFeatures: enabledFeatures,
                                allowlisted: isAllowlisted,
                                denylisted: false)
    }
 
    private func onPrivacyInfoChanged() {
        delegate?.tab(self, didChangePrivacyInfo: privacyInfo)
        privacyDashboard?.updatePrivacyInfo(privacyInfo)
    }
    
    func didLaunchBrowsingMenu() {
        DaxDialogs.shared.resumeRegularFlow()
    }

    private func openExternally(url: URL) {
        self.url = webView.url
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.open(url) { opened in
            if !opened {
                let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
                ActionMessageView.present(message: UserText.failedToOpenExternally,
                                          presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom))
            }

            // just showing a blank tab at this point, so close it
            if self.webView.url == nil {
                self.delegate?.tabDidRequestClose(self)
            }
        }
    }
    
    func presentOpenInExternalAppAlert(url: URL) {
        let title = UserText.customUrlSchemeTitle
        let message = UserText.customUrlSchemeMessage
        let open = UserText.customUrlSchemeOpen
        let dontOpen = UserText.customUrlSchemeDontOpen
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dontOpen, style: .cancel, handler: { _ in
            if self.webView.url == nil {
                self.delegate?.tabDidRequestClose(self)
            } else {
                self.url = self.webView.url
            }
        }))
        alert.addAction(UIAlertAction(title: open, style: .destructive, handler: { _ in
            self.openExternally(url: url)
        }))
        delegate?.tab(self, didRequestPresentingAlert: alert)
    }

    func dismiss() {
        privacyDashboard?.dismiss(animated: true)
        progressWorker.progressBar = nil
        chromeDelegate?.omniBar.cancelAllAnimations()
        cancelTrackerNetworksAnimation()
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    private func removeObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }

    public func makeBreakageAdditionalInfo() -> PrivacyDashboardViewController.BreakageAdditionalInfo? {
        
        guard let currentURL = url else {
            return nil
        }

        return PrivacyDashboardViewController.BreakageAdditionalInfo(currentURL: currentURL,
                                                                     httpsForced: httpsForced,
                                                                     ampURLString: linkProtection.lastAMPURLString ?? "",
                                                                     urlParametersRemoved: linkProtection.urlParametersRemoved,
                                                                     isDesktop: tabModel.isDesktop,
                                                                     error: lastError,
                                                                     httpStatusCode: lastHttpStatusCode,
                                                                     openerContext: inferredOpenerContext,
                                                                     vpnOn: netPConnected,
                                                                     userRefreshCount: refreshCountSinceLoad,
                                                                     performanceMetrics: performanceMetrics)
    }

    public func print() {
        let printFormatter = webView.viewPrintFormatter()

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "DuckDuckGo"
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printFormatter = printFormatter
        printController.present(animated: true, completionHandler: nil)
    }
    
    func onCopyAction(forUrl url: URL) {
        let copyText: String
        if url.isDuckDuckGo {
            let cleanURL = url.removingInternalSearchParameters()
            copyText = cleanURL.absoluteString
        } else {
            copyText = url.absoluteString
        }
        
        onCopyAction(for: copyText)
    }
    
    func onCopyAction(for text: String) {
        UIPasteboard.general.string = text
    }

    func stopLoading() {
        webView.stopLoading()
        wasLoadingStoppedExternally = true

        hideProgressIndicator()
        delegate?.tabLoadingStateDidChange(tab: self)
    }

    private func cleanUpBeforeClosing() {
        let job = { [weak webView, userContentController] in
            userContentController.cleanUpBeforeClosing()

            webView?.assertObjectDeallocated(after: 4.0)
        }
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: job)
            return
        }
        job()
    }

    deinit {
        rulesCompilationMonitor.tabWillClose(tabModel.uid)
        removeObservers()
        temporaryDownloadForPreviewedFile?.cancel()
        cleanUpBeforeClosing()
    }
}

// MARK: - LoginFormDetectionDelegate
extension TabViewController: LoginFormDetectionDelegate {
    
    func loginFormDetectionUserScriptDetectedLoginForm(_ script: LoginFormDetectionUserScript) {
        detectedLoginURL = webView.url
    }
    
}

// MARK: - WKNavigationDelegate
extension TabViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            performBasicHTTPAuthentication(protectionSpace: challenge.protectionSpace, completionHandler: completionHandler)
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            // Handle SSL challenge and present Special Error page if issues with SSL certificates are detected
            specialErrorPageNavigationHandler.handleWebView(webView, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    func performBasicHTTPAuthentication(protectionSpace: URLProtectionSpace,
                                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let urlProvidedBasicAuthCredential,
           urlProvidedBasicAuthCredential.url.matches(protectionSpace) {

            completionHandler(.useCredential, urlProvidedBasicAuthCredential.credential)
            self.urlProvidedBasicAuthCredential = nil
            return
        }

        // Update the address bar instantly when page presents a dialog to prevent spoofing attacks
        // https://app.asana.com/0/414709148257752/1208060693227754/f
        self.url = webView.url
        let isHttps = protectionSpace.protocol == "https"
        let alert = BasicAuthenticationAlert(host: protectionSpace.host,
                                             isEncrypted: isHttps,
                                             logInCompletion: { (login, password) in
            completionHandler(.useCredential, URLCredential(user: login, password: password, persistence: .forSession))
        }, cancelCompletion: {
            completionHandler(.rejectProtectionSpace, nil)
        })

        delegate?.tab(self, didRequestPresentingAlert: alert)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

        if let url = webView.url {
            let finalURL = duckPlayerNavigationHandler?.getDuckURLFor(url) ?? url
            historyCapture.webViewDidCommit(url: finalURL)
            instrumentation.willLoad(url: url)
        }

        url = webView.url
        let tld = storageCache.tld
        let httpsForced = tld.domain(lastUpgradedURL?.host) == tld.domain(webView.url?.host)
        onWebpageDidStartLoading(httpsForced: httpsForced)
        textZoomCoordinator.onNavigationCommitted(applyToWebView: webView)
    }

    private func onWebpageDidStartLoading(httpsForced: Bool) {
        Logger.general.debug("webpageLoading started")

        // Only fire when on the same page that the without trackers Dax Dialog was shown
        self.fireWoFollowUp = false

        self.httpsForced = httpsForced
        delegate?.showBars()

        resetDashboardInfo()

        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)

        appRatingPrompt.registerUsage()

        if let scene = self.view.window?.windowScene,
           webView.url?.isDuckDuckGoSearch == true,
           appRatingPrompt.shouldPrompt() {
            SKStoreReviewController.requestReview(in: scene)
            appRatingPrompt.shown()
        }
        
        duckPlayerNavigationHandler?.handleDidStartLoading(webView: webView)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        let httpResponse = navigationResponse.response as? HTTPURLResponse
        let didMarkAsInternal = internalUserDecider.markUserAsInternalIfNeeded(forUrl: webView.url, response: httpResponse)
        if didMarkAsInternal {
            Pixel.fire(pixel: .featureFlaggingInternalUserAuthenticated)
            NotificationCenter.default.post(Notification(name: AppUserDefaults.Notifications.didVerifyInternalUser))
        }

        // If the navigation has been handled by the special error page handler, cancel navigating to the new content as the special error page will be shown.
        if !specialErrorPageNavigationHandler.isSpecialErrorPageRequest, await specialErrorPageNavigationHandler.handleDecidePolicy(for: navigationResponse, webView: webView) {
            return .cancel
        } else {
            return await handleNavigationResponse(navigationResponse)
        }
    }

    private func handleNavigationResponse(_ navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        let httpResponse = navigationResponse.response as? HTTPURLResponse
        let mimeType = MIMEType(from: navigationResponse.response.mimeType, fileExtension: navigationResponse.response.url?.pathExtension)
        let urlSchemeType = navigationResponse.response.url.map { SchemeHandler.schemeType(for: $0) } ?? .unknown
        let urlNavigationalScheme = navigationResponse.response.url?.scheme.map { URL.NavigationalScheme(rawValue: $0) }

        let isSuccessfulResponse = httpResponse?.isSuccessfulResponse ?? false
        lastHttpStatusCode = httpResponse?.statusCode

        // Important: Order of these checks matter!
        if urlSchemeType == .blob {
            // 1. To properly handle BLOB we need to trigger its download, if temporaryDownloadForPreviewedFile is set we allow its load in the web view
            if let temporaryDownloadForPreviewedFile, temporaryDownloadForPreviewedFile.url == navigationResponse.response.url {
                // BLOB already has a temporary downloaded so and we can allow loading it
                blobDownloadTargetFrame = nil
                return .allow
            } else {
                // First we need to trigger download to handle it then in webView:navigationAction:didBecomeDownload
                return .download
            }
        } else if FilePreviewHelper.canAutoPreviewMIMEType(mimeType) {
            // 2. For this MIME type we are able to provide a better custom preview via FilePreviewHelper so it takes priority
            let (policy, download) = await startDownload(with: navigationResponse)
            mostRecentAutoPreviewDownloadID = download?.id
            Pixel.fire(pixel: .downloadStarted,
                       withAdditionalParameters: [PixelParameters.canAutoPreviewMIMEType: "1"])
            return policy
        } else if shouldTriggerDownloadAction(for: navigationResponse),
                  let downloadMetadata = AppDependencyProvider.shared.downloadManager.downloadMetaData(for: navigationResponse.response) {
            // 3a. We know it is a download, but allow WebKit handle the "data" scheme natively
            if urlNavigationalScheme == .data {
                return .download
            }

            // 3b. We know the response should trigger the file download prompt
            switch await presentSaveToDownloadsAlert(with: downloadMetadata) {
            case .success:
                let (policy, _) = await startDownload(with: navigationResponse)
                return policy
            case .cancelled:
                return .cancel
            }
        } else if navigationResponse.canShowMIMEType {
            // 4. WebView can preview the MIME type and it is not to be handled by our custom FilePreviewHelper
            url = webView.url
            if navigationResponse.isForMainFrame, let decision = setupOrClearTemporaryDownload(for: navigationResponse.response) {
                // Loading a file preview in web view
                return decision
            } else {
                // Loading HTML
                if navigationResponse.isForMainFrame && isSuccessfulResponse {
                    adClickAttributionDetection.on2XXResponse(url: url)
                }
                await adClickAttributionLogic.onProvisionalNavigation()

                return .allow
            }
        } else {
            // Fallback
            return .allow
        }
    }

    private func shouldTriggerDownloadAction(for navigationResponse: WKNavigationResponse) -> Bool {
        let mimeType = MIMEType(from: navigationResponse.response.mimeType, fileExtension: navigationResponse.response.url?.pathExtension)
        let httpResponse = navigationResponse.response as? HTTPURLResponse

        // HTTP response has "Content-Disposition: attachment" header
        let hasContentDispositionAttachment = httpResponse?.shouldDownload ?? false

        // If preceding WKNavigationAction requested to start the download (e.g. link `download` attribute or BLOB object)
        let hasNavigationActionRequestedDownload = (recentNavigationActionShouldPerformDownloadURL != nil) && recentNavigationActionShouldPerformDownloadURL == navigationResponse.response.url

        // File can be rendered by web view or in custom preview handled by FilePreviewHelper
        let canLoadOrPreviewTheFile = navigationResponse.canShowMIMEType || FilePreviewHelper.canAutoPreviewMIMEType(mimeType)

        return hasContentDispositionAttachment || hasNavigationActionRequestedDownload || !canLoadOrPreviewTheFile
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        lastError = nil
        lastRenderedURL = webView.url
        cancelTrackerNetworksAnimation()
        shouldReloadOnError = false
        hideErrorMessage()
        showProgressIndicator()
        linkProtection.cancelOngoingExtraction()
        linkProtection.setMainFrameUrl(webView.url)
        referrerTrimming.onBeginNavigation(to: webView.url)
        adClickAttributionDetection.onStartNavigation(url: webView.url)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.currentlyLoadedURL = webView.url
        onTextZoomChange()
        adClickAttributionDetection.onDidFinishNavigation(url: webView.url)
        adClickAttributionLogic.onDidFinishNavigation(host: webView.url?.host)
        hideProgressIndicator()
        onWebpageDidFinishLoading()
        instrumentation.didLoadURL()
        checkLoginDetectionAfterNavigation()
        trackSecondSiteVisitIfNeeded(url: webView.url)

        // definitely finished with any potential login cycle by this point, so don't try and handle it any more
        detectedLoginURL = nil
        updatePreview()
        linkProtection.setMainFrameUrl(nil)
        referrerTrimming.onFinishNavigation()
        urlProvidedBasicAuthCredential = nil

        if webView.url?.isDuckDuckGoSearch == true, case .connected = netPConnectionStatus {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionEnabledOnSearch,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                         includedParameters: [.appVersion, .atb])
        }

        // Notify Special Error Page Navigation handler that webview successfully finished loading
        specialErrorPageNavigationHandler.handleWebView(webView, didFinish: navigation)
    }

    var specialErrorPageUserScript: SpecialErrorPageUserScript? {
        get {
            return storedSpecialErrorPageUserScript ?? userScripts?.specialErrorPageUserScript
        }
        set {
            storedSpecialErrorPageUserScript = newValue
        }
    }

    func preparePreview(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let webView = self?.webView,
                  webView.bounds.height > 0 && webView.bounds.width > 0 else { completion(nil); return }
            
            let size = CGSize(width: webView.frame.size.width,
                              height: webView.frame.size.height - webView.scrollView.contentInset.top - webView.scrollView.contentInset.bottom)
            
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { context in
                context.cgContext.translateBy(x: 0, y: -webView.scrollView.contentInset.top)
                webView.drawHierarchy(in: webView.bounds, afterScreenUpdates: true)
                if let jsAlertController = self?.jsAlertController {
                    jsAlertController.view.drawHierarchy(in: jsAlertController.view.bounds, afterScreenUpdates: false)
                }
            }

            completion(image)
        }
    }
    
    private func updatePreview() {
        preparePreview { image in
            if let image = image {
                self.delegate?.tab(self, didUpdatePreview: image)
            }
        }
    }
    
    private func onWebpageDidFinishLoading() {
        Logger.general.debug("webpageLoading finished")

        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)

        // Present the Dax dialog with a delay to mitigate issue where user script detec trackers after the dialog is show to the user
        // Debounce to avoid showing multiple animations on redirects. e.g. !image baby ducklings
        daxDialogsDebouncer.debounce(for: 0.8) { [weak self] in
            self?.showDaxDialogOrStartTrackerNetworksAnimationIfNeeded()
        }
        
        // DuckPlayer finish loading actions
        if let handler = duckPlayerNavigationHandler {
            handler.handleDidFinishLoading(webView: webView)
        }

        Task { @MainActor in
            if await webView.isCurrentSiteReferredFromDuckDuckGo {
                inferredOpenerContext = .serp
            }
        }
        
        tabInteractionStateSource?.saveState(webView.interactionState, for: tabModel)
    }

    func trackSecondSiteVisitIfNeeded(url: URL?) {
        // Track second non-SERP webpage visit
        guard url?.isDuckDuckGoSearch == false else { return }
        onboardingPixelReporter.trackSecondSiteVisit()
    }

    func showDaxDialogOrStartTrackerNetworksAnimationIfNeeded() {
        guard !isLinkPreview else { return }

        if DaxDialogs.shared.isAddFavoriteFlow {
            delegate?.tabDidRequestShowingMenuHighlighter(tab: self)
            return
        }
              
        /// Never show onboarding Dax on Youtube or DuckPlayer, unless DuckPlayer is disabled
        guard let url = link?.url,
              !url.isDuckPlayer,
              !(url.isYoutube && duckPlayer?.settings.mode != .disabled) else {
            scheduleTrackerNetworksAnimation(collapsing: true)
            return
        }

        guard let privacyInfo = self.privacyInfo,
              !isShowingFullScreenDaxDialog else {

            scheduleTrackerNetworksAnimation(collapsing: true)
            return
        }
        
        if let url = link?.url, url.isDuckDuckGoEmailProtection {
            scheduleTrackerNetworksAnimation(collapsing: true)
            return
        }
        guard let spec = DaxDialogs.shared.nextBrowsingMessageIfShouldShow(for: privacyInfo) else {

            // Dismiss Contextual onboarding if there's no message to show.
            contextualOnboardingPresenter.dismissContextualOnboardingIfNeeded(from: self)
            // Dismiss privacy dashbooard pulse animation when no browsing dialog to show.
            delegate?.tabDidRequestPrivacyDashboardButtonPulse(tab: self, animated: false)

            if DaxDialogs.shared.shouldShowFireButtonPulse {
                delegate?.tabDidRequestFireButtonPulse(tab: self)
            }
            
            scheduleTrackerNetworksAnimation(collapsing: true)
            return
        }
        
        scheduleTrackerNetworksAnimation(collapsing: !spec.highlightAddressBar)
        let daxDialogSourceURL = self.url
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            // https://app.asana.com/0/414709148257752/1201620790053163/f
            if self.url != daxDialogSourceURL && self.url?.isSameDuckDuckGoSearchURL(other: daxDialogSourceURL) == false {
                DaxDialogs.shared.overrideShownFlagFor(spec, flag: false)
                self.isShowingFullScreenDaxDialog = false
                return
            }

            self.chromeDelegate?.omniBar.resignFirstResponder()
            self.chromeDelegate?.setBarsHidden(false, animated: true, customAnimationDuration: nil)

            // Present the contextual onboarding
            contextualOnboardingPresenter.presentContextualOnboarding(for: spec, in: self)

            if spec == DaxDialogs.BrowsingSpec.withoutTrackers {
                self.woShownRecently = true
                self.fireWoFollowUp = true
            }
        }
    }

    private func scheduleTrackerNetworksAnimation(collapsing: Bool) {
        let trackersWorkItem = DispatchWorkItem {
            guard let privacyInfo = self.privacyInfo else { return }
            self.delegate?.tab(self, didRequestPresentingTrackerAnimation: privacyInfo, isCollapsing: collapsing)
        }
        trackersInfoWorkItem = trackersWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.trackerNetworksAnimationDelay,
                                      execute: trackersWorkItem)
    }
    
    private func cancelTrackerNetworksAnimation() {
        trackersInfoWorkItem?.cancel()
        trackersInfoWorkItem = nil
    }
    
    private func checkLoginDetectionAfterNavigation() {
        if fireproofingWorker?.handleLoginDetection(detectedURL: detectedLoginURL,
                                                    currentURL: url,
                                                    isAutofillEnabled: AutofillSettingStatus.isAutofillEnabledInSettings,
                                                    saveLoginPromptLastDismissed: saveLoginPromptLastDismissed,
                                                    saveLoginPromptIsPresenting: saveLoginPromptIsPresenting) ?? false {

            detectedLoginURL = nil
            saveLoginPromptLastDismissed = nil
            saveLoginPromptIsPresenting = false
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.general.debug("didFailNavigation; error: \(error)")
        adClickAttributionDetection.onDidFailNavigation()
        hideProgressIndicator()
        webpageDidFailToLoad()
        checkForReloadOnError()
        scheduleTrackerNetworksAnimation(collapsing: true)
        linkProtection.setMainFrameUrl(nil)
        referrerTrimming.onFailedNavigation()
    }

    private func webpageDidFailToLoad() {
        Logger.general.debug("webpageLoading failed")

        wasLoadingStoppedExternally = false

        if isError {
            showBars(animated: true)
            privacyInfo = nil
            onPrivacyInfoChanged()
        }
        
        self.delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.general.debug("didFailProvisionalNavigation; error: \(error)")
        adClickAttributionDetection.onDidFailNavigation()
        hideProgressIndicator()
        linkProtection.setMainFrameUrl(nil)
        referrerTrimming.onFailedNavigation()
        urlProvidedBasicAuthCredential = nil
        lastError = error
        let error = error as NSError

        // Ignore Frame Load Interrupted that will be caused when a download starts
        if error.code == 102 && error.domain == "WebKitErrorDomain" {
            return
        }

        if let url = url,
           let domain = url.host,
           error.code == Constants.frameLoadInterruptedErrorCode {
            // prevent loops where a site keeps redirecting to itself (e.g. bbc)
            failingUrls.insert(domain)

            // Reset the URL, e.g if opened externally
            self.url = webView.url
        }

        // Bail out before showing error when navigation was cancelled by the user
        if error.code == NSURLErrorCancelled && error.domain == NSURLErrorDomain {
            webpageDidFailToLoad()

            // Reset url to current one, as navigation was not successful
            self.url = webView.url
            return
        }

        // wait before showing errors in case they recover automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showErrorNow()
        }

        // Notify Special Error page that webview navigation failed and show special error page if needed.
        specialErrorPageNavigationHandler.handleWebView(webView, didFailProvisionalNavigation: navigation, withError: error)
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        self.url = url
        
        self.privacyInfo = makePrivacyInfo(url: url)
        onPrivacyInfoChanged()
        
        checkLoginDetectionAfterNavigation()
    }
    
    private func requestForDoNotSell(basedOn incomingRequest: URLRequest) -> URLRequest? {
        let config = ContentBlocking.shared.privacyConfigurationManager.privacyConfig
        guard var request = GPCRequestFactory().requestForGPC(basedOn: incomingRequest,
                                                              config: config,
                                                              gpcEnabled: appSettings.sendDoNotSell) else {
            return nil
        }
        
        request.attribution = .user

        return request
    }

    // swiftlint:disable cyclomatic_complexity

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        if let url = navigationAction.request.url {
            if !tabURLInterceptor.allowsNavigatingTo(url: url) {
                decisionHandler(.cancel)
                // If there is history or a page loaded keep the tab open
                if self.currentlyLoadedURL == nil {
                    delegate?.tabDidRequestClose(self)
                }
                return
            }
        }
        
        // Ask DuckPlayer to handle navigation if possible
        if let handler = duckPlayerNavigationHandler {
                                    
            if handler.handleDelegateNavigation(navigationAction: navigationAction, webView: webView) {
                decisionHandler(.cancel)
                return
            }
        }
        
        if let url = navigationAction.request.url,
           !url.isDuckDuckGoSearch,
           true == shouldWaitUntilContentBlockingIsLoaded({ [weak self, webView /* decision handler must be called */] in
               guard let self = self else {
                   decisionHandler(.cancel)
                   return
               }
               self.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
           }) {
            // will wait for Content Blocking to load and re-call on completion
            return
        }
        

        didGoBackForward = (navigationAction.navigationType == .backForward)

        if navigationAction.navigationType != .reload && navigationAction.navigationType != .other {
            // Ignore .other actions because refresh can cause a redirect
            // This is also handled in loadRequest(_:)
            refreshCountSinceLoad = 0
        }

        if navigationAction.navigationType != .reload, webView.url != navigationAction.request.mainDocumentURL {
            delegate?.tabDidRequestNavigationToDifferentSite(tab: self)
        }

        // This check needs to happen before GPC checks. Otherwise the navigation type may be rewritten to `.other`
        // which would skip link rewrites.
        if navigationAction.navigationType != .backForward,
           navigationAction.isTargetingMainFrame(),
           !(navigationAction.request.url?.isDuckDuckGoSearch ?? false) {
            let didRewriteLink = linkProtection.requestTrackingLinkRewrite(initiatingURL: webView.url,
                                                                           navigationAction: navigationAction,
                                                                           onStartExtracting: { showProgressIndicator() },
                                                                           onFinishExtracting: { },
                                                                           onLinkRewrite: { [weak self] newRequest, _ in
                guard let self = self else { return }
                self.load(urlRequest: newRequest)
            },
                                                                           policyDecisionHandler: decisionHandler)

            if didRewriteLink {
                return
            }
        }

        if navigationAction.isTargetingMainFrame(),
           !(navigationAction.request.url?.isCustomURLScheme() ?? false),
           navigationAction.navigationType != .backForward,
           let newRequest = referrerTrimming.trimReferrer(forNavigation: navigationAction,
                                                          originUrl: webView.url ?? navigationAction.sourceFrame.webView?.url) {
            decisionHandler(.cancel)
            load(urlRequest: newRequest)
            return
        }

        if navigationAction.isTargetingMainFrame(),
           !navigationAction.isSameDocumentNavigation,
           !navigationAction.shouldDownload,
           !(navigationAction.request.url?.isCustomURLScheme() ?? false),
           navigationAction.navigationType != .backForward,
           let request = requestForDoNotSell(basedOn: navigationAction.request) {

            decisionHandler(.cancel)
            load(urlRequest: request)
            return
        }

        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           let modifierFlags = delegate?.tabWillRequestNewTab(self) {

            if modifierFlags.contains(.command) {
                if modifierFlags.contains(.shift) {
                    decisionHandler(.cancel)
                    delegate?.tab(self,
                                  didRequestNewTabForUrl: url,
                                  openedByPage: false,
                                  inheritingAttribution: adClickAttributionLogic.state)
                    return
                } else {
                    decisionHandler(.cancel)
                    delegate?.tab(self, didRequestNewBackgroundTabForUrl: url, inheritingAttribution: adClickAttributionLogic.state)
                    return
                }
            }
        }

        decidePolicyFor(navigationAction: navigationAction) { [weak self] decision in
            if let self = self,
               let url = navigationAction.request.url,
               decision != .cancel,
               navigationAction.isTargetingMainFrame() {
                if url.isDuckDuckGoSearch {
                    StatisticsLoader.shared.refreshSearchRetentionAtb()
                    privacyProDataReporter.saveSearchCount()
                }

                self.delegate?.closeFindInPage(tab: self)
            }
            // If navigating to the URL is allowed and we're not sideloading a special error page, forward the event to
            // the SpecialErrorPageNavigationHandler.
            if let self, decision == .allow, !self.specialErrorPageNavigationHandler.isSpecialErrorPageRequest {
                self.specialErrorPageNavigationHandler.handleDecidePolicy(for: navigationAction, webView: webView)
            }
            decisionHandler(decision)
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func shouldWaitUntilContentBlockingIsLoaded(_ completion: @Sendable @escaping @MainActor () -> Void) -> Bool {
        // Ensure Content Blocking Assets (WKContentRuleList&UserScripts) are installed
        if userContentController.contentBlockingAssetsInstalled
            || !ContentBlocking.shared.privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .contentBlocking) {

            rulesCompilationMonitor.reportNavigationDidNotWaitForRules()
            return false
        }

        Task {
            rulesCompilationMonitor.tabWillWaitForRulesCompilation(tabModel.uid)
            showProgressIndicator()
            await userContentController.awaitContentBlockingAssetsInstalled()
            rulesCompilationMonitor.reportTabFinishedWaitingForRules(tabModel.uid)

            await MainActor.run(body: completion)
        }
        return true
    }

    private func decidePolicyFor(navigationAction: WKNavigationAction, completion: @escaping (WKNavigationActionPolicy) -> Void) {
        let allowPolicy = determineAllowPolicy()

        let tld = storageCache.tld
        
        // If WKNavigationAction requests to shouldPerformDownload prepare for handling it in decidePolicyFor:navigationResponse:
        recentNavigationActionShouldPerformDownloadURL = navigationAction.shouldPerformDownload ? navigationAction.request.url : nil

        if navigationAction.isTargetingMainFrame()
            && tld.domain(navigationAction.request.mainDocumentURL?.host) != tld.domain(lastUpgradedURL?.host) {
            lastUpgradedURL = nil
            privacyInfo?.connectionUpgradedTo = nil
        }

        guard navigationAction.request.mainDocumentURL != nil else {
            completion(allowPolicy)
            return
        }

        guard let url = navigationAction.request.url else {
            completion(allowPolicy)
            return
        }

        if navigationAction.isTargetingMainFrame(), navigationAction.navigationType == .backForward {
            adClickAttributionLogic.onBackForwardNavigation(mainFrameURL: webView.url)
        }

        let schemeType = SchemeHandler.schemeType(for: url)
        self.blobDownloadTargetFrame = nil
        switch schemeType {
        case .allow:
            completion(.allow)
            return
            
        case .navigational:
            performNavigationFor(url: url,
                                 navigationAction: navigationAction,
                                 allowPolicy: allowPolicy,
                                 completion: completion)

        case .external(let action):
            performExternalNavigationFor(url: url, action: action)
            completion(.cancel)

        case .blob:
            performBlobNavigation(navigationAction, completion: completion)
        
        case .duck:
            if navigationAction.isTargetingMainFrame() {
                duckPlayerNavigationHandler?.handleDuckNavigation(navigationAction, webView: webView)
                completion(.cancel)
                return
            }

        case .unknown:
            if navigationAction.navigationType == .linkActivated {
                openExternally(url: url)
            } else {
                presentOpenInExternalAppAlert(url: url)
            }
            completion(.cancel)
        }
    }

    private func inferLoadContext(for navigationAction: WKNavigationAction) -> BrokenSiteReport.OpenerContext? {
        guard navigationAction.navigationType != .reload else { return nil }
        guard let currentUrl = webView.url, let newUrl = navigationAction.request.url else { return nil }

        if currentUrl.isDuckDuckGoSearch && !newUrl.isDuckDuckGoSearch {
            return .serp
        } else {
            switch navigationAction.navigationType {
            case .linkActivated, .other, .formSubmitted:
                return .navigation
            default:
                return nil
            }
        }
    }

    private func performNavigationFor(url: URL,
                                      navigationAction: WKNavigationAction,
                                      allowPolicy: WKNavigationActionPolicy,
                                      completion: @escaping (WKNavigationActionPolicy) -> Void) {

        // when navigating to a request with basic auth username/password, cache it and redirect to a trimmed URL
        if navigationAction.isTargetingMainFrame(),
           let credential = url.basicAuthCredential {
            var newRequest = navigationAction.request
            newRequest.url = url.removingBasicAuthCredential()
            self.urlProvidedBasicAuthCredential = (credential, newRequest.url!)

            completion(.cancel)
            self.load(urlRequest: newRequest)
            return

        } else if let urlProvidedBasicAuthCredential,
                  url != urlProvidedBasicAuthCredential.url {
            self.urlProvidedBasicAuthCredential = nil
        }

        inferredOpenerContext = inferLoadContext(for: navigationAction)

        if shouldReissueSearch(for: url) {
            reissueSearchWithRequiredParams(for: url)
            completion(.cancel)
            return
        }

        if shouldReissueDDGStaticNavigation(for: url) {
            reissueNavigationWithSearchHeaderParams(for: url)
            completion(.cancel)
            return
        }

        if isNewTargetBlankRequest(navigationAction: navigationAction) {
            // This will fallback to native WebView handling through webView(_:createWebViewWith:for:windowFeatures:)
            completion(allowPolicy)
            return
        }

        if allowPolicy != WKNavigationActionPolicy.cancel && navigationAction.isTargetingMainFrame() {
            userAgentManager.update(webView: webView, isDesktop: tabModel.isDesktop, url: url)
        }

        if !ContentBlocking.shared.privacyConfigurationManager.privacyConfig.isProtected(domain: url.host) {
            completion(allowPolicy)
            return
        }

        if shouldUpgradeToHttps(url: url, navigationAction: navigationAction) {
            upgradeToHttps(url: url, allowPolicy: allowPolicy, completion: completion)
        } else {
            completion(allowPolicy)
        }
    }

    private func upgradeToHttps(url: URL,
                                allowPolicy: WKNavigationActionPolicy,
                                completion: @escaping (WKNavigationActionPolicy) -> Void) {
        Task {
            let result = await PrivacyFeatures.httpsUpgrade.upgrade(url: url)
            switch result {
            case let .success(upgradedUrl):
                if lastUpgradedURL != upgradedUrl {
                    lastUpgradedURL = upgradedUrl
                    privacyInfo?.connectionUpgradedTo = upgradedUrl
                    load(url: upgradedUrl, didUpgradeURL: true)
                    completion(.cancel)
                } else {
                    completion(allowPolicy)
                }
            case .failure:
                completion(allowPolicy)
            }
        }
    }

    private func shouldUpgradeToHttps(url: URL, navigationAction: WKNavigationAction) -> Bool {
        return !failingUrls.contains(url.host ?? "") && navigationAction.isTargetingMainFrame()
    }

    private func performExternalNavigationFor(url: URL, action: SchemeHandler.Action) {
        switch action {
        case .open:
            openExternally(url: url)
        case .askForConfirmation:
            presentOpenInExternalAppAlert(url: url)
        case .cancel:
            break
        }
    }
    
    private func isNewTargetBlankRequest(navigationAction: WKNavigationAction) -> Bool {
        return navigationAction.navigationType == .linkActivated && navigationAction.targetFrame == nil
    }

    private func determineAllowPolicy() -> WKNavigationActionPolicy {
        let allowWithoutUniversalLinks = WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2) ?? .allow
        return AppUserDefaults().allowUniversalLinks ? .allow : allowWithoutUniversalLinks
    }
    
    private func showErrorNow() {
        guard let error = lastError as NSError? else { return }
        hideProgressIndicator()
        ViewHighlighter.hideAll()

        if !(error.failedUrl?.isCustomURLScheme() ?? false) {
            url = error.failedUrl
            showError(message: error.localizedDescription)
            Pixel.fire(pixel: .webViewErrorPageShown)
        }

        webpageDidFailToLoad()
        checkForReloadOnError()
    }
    
    private func showLoginDetails(with account: SecureVaultModels.WebsiteAccount) {
        delegate?.tab(self, didRequestSettingsToLogins: account)
    }
    
    @objc private func dismissLoginDetails() {
        dismiss(animated: true)
    }

    private func registerForAutofillNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(autofillBreakageReport),
                                               name: .autofillFailureReport,
                                               object: nil)
    }

    private func registerForResignActive() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onApplicationWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    private func unregisterFromResignActive() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func autofillBreakageReport(_ notification: Notification) {
        guard let tabUid = notification.userInfo?[AutofillLoginListViewModel.UserInfoKeys.tabUid] as? String,
              tabUid == tabModel.uid,
              let url = webView.url?.normalized() else {
            return
        }

        let parameters: [String: String] = [
            "website": url.absoluteString,
            "language": Locale.current.languageCode ?? "en",
            "autofill_enabled": appSettings.autofillCredentialsEnabled ? "true" : "false",
            "privacy_protection": (privacyInfo?.isFor(self.url) ?? false) ? "true" : "false",
            "email_protection": (emailManager?.isSignedIn ?? false) ? "true" : "false",
            "never_prompt": autofillNeverPromptWebsitesManager.hasNeverPromptWebsitesFor(domain: url.host ?? url.absoluteString) ? "true" : "false"
        ]

        Pixel.fire(pixel: .autofillLoginsReportFailure, withAdditionalParameters: parameters)

        ActionMessageView.present(message: UserText.autofillSettingsReportNotWorkingSentConfirmation)
    }
}

// MARK: - Downloads
extension TabViewController {

    private func performBlobNavigation(_ navigationAction: WKNavigationAction,
                                       completion: @escaping (WKNavigationActionPolicy) -> Void) {
        self.blobDownloadTargetFrame = navigationAction.targetFrame
        completion(.allow)
    }

    private func startDownload(with navigationResponse: WKNavigationResponse) async -> (responsePolicy: WKNavigationResponsePolicy, download: Download?) {
        let downloadManager = AppDependencyProvider.shared.downloadManager
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let url = navigationResponse.response.url!

        if case .blob = SchemeHandler.schemeType(for: url) {
            return (.download, nil)
        } else if let download = downloadManager.makeDownload(navigationResponse: navigationResponse, cookieStore: cookieStore) {
            downloadManager.startDownload(download)
            return (.cancel, download)
        }

        return (.cancel, nil)
    }

    /**
     Some files might be previewed by webkit but in order to share them
     we need to download them first.
     This method stores the temporary download or clears it if necessary
     
     - Returns: Navigation policy or nil if it is not a download
     */
    private func setupOrClearTemporaryDownload(for response: URLResponse) -> WKNavigationResponsePolicy? {
        let downloadManager = AppDependencyProvider.shared.downloadManager
        guard response.url != nil,
              let downloadMetaData = downloadManager.downloadMetaData(for: response),
              !downloadMetaData.mimeType.isHTML
        else {
            temporaryDownloadForPreviewedFile?.cancel()
            temporaryDownloadForPreviewedFile = nil
            return nil
        }

        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        temporaryDownloadForPreviewedFile = downloadManager.makeDownload(response: response,
                                                                         cookieStore: cookieStore,
                                                                         temporary: true)
        return .allow
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        let delegate = InlineWKDownloadDelegate()
        // temporary delegate held strongly in callbacks
        // after destination decision WKDownload delegate will be set
        // to a WKDownloadSession and passed to Download Manager
        delegate.decideDestinationCallback = { [weak self] _, _, suggestedFilename, callback in
            withExtendedLifetime(delegate) {
                let downloadManager = AppDependencyProvider.shared.downloadManager
                guard let self = self,
                      let downloadMetadata = downloadManager.downloadMetaData(for: navigationResponse.response,
                                                                              suggestedFilename: suggestedFilename)
                else {
                    callback(nil)
                    return
                }

                if self.shouldTriggerDownloadAction(for: navigationResponse) && !FilePreviewHelper.canAutoPreviewMIMEType(downloadMetadata.mimeType) {
                    // Show alert to the file download
                    self.presentSaveToDownloadsAlert(with: downloadMetadata) {
                        callback(self.transfer(download,
                                               to: downloadManager,
                                               with: navigationResponse.response,
                                               suggestedFilename: suggestedFilename,
                                               isTemporary: false))
                    } cancelHandler: {
                        callback(nil)
                    }

                    self.temporaryDownloadForPreviewedFile = nil
                } else {
                    // Showing file in the webview or in preview view
                    if FilePreviewHelper.canAutoPreviewMIMEType(downloadMetadata.mimeType) {
                        // If FilePreviewHelper can handle format we do not need to load as it will be handled by setting
                        // temporaryDownloadForPreviewedFile and mostRecentAutoPreviewDownloadID
                    } else if navigationResponse.canShowMIMEType {
                        // To load BLOB in web view we need to restart the request loading as it was interrupted by .download callback
                        self.webView.load(navigationResponse.response.url!, in: self.blobDownloadTargetFrame)
                    }
                    callback(self.transfer(download,
                                           to: downloadManager,
                                           with: navigationResponse.response,
                                           suggestedFilename: suggestedFilename,
                                           isTemporary: true))
                }

                delegate.decideDestinationCallback = nil
                delegate.downloadDidFailCallback = nil
                self.blobDownloadTargetFrame = nil
            }
        }
        delegate.downloadDidFailCallback = { _, _, _ in
            withExtendedLifetime(delegate) {
                delegate.decideDestinationCallback = nil
                delegate.downloadDidFailCallback = nil
            }
        }
        download.delegate = delegate
    }

    private func transfer(_ download: WKDownload,
                          to downloadManager: DownloadManager,
                          with response: URLResponse,
                          suggestedFilename: String,
                          isTemporary: Bool) -> URL? {

        let downloadSession = WKDownloadSession(download)
        let download = downloadManager.makeDownload(response: response,
                                                    suggestedFilename: suggestedFilename,
                                                    downloadSession: downloadSession,
                                                    cookieStore: nil,
                                                    temporary: isTemporary)

        self.temporaryDownloadForPreviewedFile = isTemporary ? download : nil
        self.mostRecentAutoPreviewDownloadID = isTemporary ? download?.id : nil
        if let download = download {
            downloadManager.startDownload(download)
        }

        return downloadSession.localURL
    }

    private func presentSaveToDownloadsAlert(with downloadMetadata: DownloadMetadata,
                                             saveToDownloadsHandler: @escaping () -> Void,
                                             cancelHandler: @escaping (() -> Void)) {
        let alert = SaveToDownloadsAlert.makeAlert(downloadMetadata: downloadMetadata) {
            Pixel.fire(pixel: .downloadStarted,
                       withAdditionalParameters: [PixelParameters.canAutoPreviewMIMEType: "0"])

            if downloadMetadata.mimeType != .octetStream {
                let mimeType = downloadMetadata.mimeTypeSource
                Pixel.fire(pixel: .downloadStartedDueToUnhandledMIMEType,
                           withAdditionalParameters: [PixelParameters.mimeType: mimeType])
            }

            saveToDownloadsHandler()
        } cancelHandler: {
            cancelHandler()
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

    enum SaveToDownloadsResult {
        case success
        case cancelled
    }

    private func presentSaveToDownloadsAlert(with downloadMetadata: DownloadMetadata) async -> SaveToDownloadsResult {
        await withCheckedContinuation { continuation in
            presentSaveToDownloadsAlert(
                with: downloadMetadata,
                saveToDownloadsHandler: {
                    continuation.resume(returning: .success)
                }, cancelHandler: {
                    continuation.resume(returning: .cancelled)
                }
            )
        }
    }

    private func registerForDownloadsNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadDidStart),
                                               name: .downloadStarted,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(downloadDidFinish),
                                               name: .downloadFinished,
                                               object: nil)
    }

    @objc private func downloadDidStart(_ notification: Notification) {
        guard let download = notification.userInfo?[DownloadManager.UserInfoKeys.download] as? Download,
              !download.temporary
        else { return }

        let attributedMessage = DownloadActionMessageViewHelper.makeDownloadStartedMessage(for: download)

        DispatchQueue.main.async {
            ActionMessageView.present(message: attributedMessage, numberOfLines: 2, actionTitle: UserText.actionGenericShow,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: self.appSettings.currentAddressBarPosition.isBottom),
                                      onAction: {
                Pixel.fire(pixel: .downloadsListOpened,
                           withAdditionalParameters: [PixelParameters.originatedFromMenu: "0"])
                self.delegate?.tabDidRequestDownloads(tab: self)
            })
        }
    }

    @objc private func downloadDidFinish(_ notification: Notification) {
        if let error = notification.userInfo?[DownloadManager.UserInfoKeys.error] as? Error {
            let nserror = error as NSError
            let downloadWasCancelled = nserror.domain == "NSURLErrorDomain" && nserror.code == -999

            if !downloadWasCancelled {
                let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
                ActionMessageView.present(message: UserText.messageDownloadFailed,
                                          presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom))
            }

            return
        }

        guard let download = notification.userInfo?[DownloadManager.UserInfoKeys.download] as? Download else { return }

        DispatchQueue.main.async {
            if !download.temporary {
                let attributedMessage = DownloadActionMessageViewHelper.makeDownloadFinishedMessage(for: download)
                let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
                ActionMessageView.present(message: attributedMessage, numberOfLines: 2, actionTitle: UserText.actionGenericShow,
                                          presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom),
                                          onAction: {
                    Pixel.fire(pixel: .downloadsListOpened,
                               withAdditionalParameters: [PixelParameters.originatedFromMenu: "0"])
                    self.delegate?.tabDidRequestDownloads(tab: self)
                })
            } else {
                self.previewDownloadedFileIfNecessary(download)
            }
        }
    }

    private func previewDownloadedFileIfNecessary(_ download: Download) {
        guard let delegate = self.delegate,
              delegate.tabCheckIfItsBeingCurrentlyPresented(self),
              FilePreviewHelper.canAutoPreviewMIMEType(download.mimeType),
              let fileHandler = FilePreviewHelper.fileHandlerForDownload(download, viewController: self)
        else { return }

        if mostRecentAutoPreviewDownloadID == download.id {
            fileHandler.preview()
        } else {
            let pixelParameters = [PixelParameters.mimeType: download.mimeType.rawValue,
                                   PixelParameters.downloadListCount: "\(AppDependencyProvider.shared.downloadManager.downloadList.count)"]
            Pixel.fire(pixel: .downloadTriedToPresentPreviewWithoutTab, withAdditionalParameters: pixelParameters)
        }
    }
}

// MARK: - WKUIDelegate
extension TabViewController: WKUIDelegate {

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        return delegate?.tab(self,
                             didRequestNewWebViewWithConfiguration: configuration,
                             for: navigationAction,
                             inheritingAttribution: adClickAttributionLogic.state)
    }

    func webViewDidClose(_ webView: WKWebView) {
        if openedByPage {
            delegate?.tabDidRequestClose(self)
        }
    }

    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        Pixel.fire(pixel: .webKitDidTerminate)
        delegate?.tabContentProcessDidTerminate(tab: self)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        guard canDisplayJavaScriptAlert else {
            completionHandler()
            return
        }
        
        let alert = WebJSAlert(domain: frame.safeRequest?.url?.host
                               // in case the web view is navigating to another host
                               ?? webView.backForwardList.currentItem?.url.host
                               ?? self.url?.absoluteString
                               ?? "",
                               message: message,
                               alertType: .alert(handler: completionHandler))
        self.present(alert)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        guard canDisplayJavaScriptAlert else {
            completionHandler(false)
            return
        }
        
        let alert = WebJSAlert(domain: frame.safeRequest?.url?.host
                               // in case the web view is navigating to another host
                               ?? webView.backForwardList.currentItem?.url.host
                               ?? self.url?.absoluteString
                               ?? "",
                               message: message,
                               alertType: .confirm(handler: completionHandler))
        self.present(alert)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        guard canDisplayJavaScriptAlert else {
            completionHandler(nil)
            return
        }
        
        let alert = WebJSAlert(domain: frame.request.url?.host
                               // in case the web view is navigating to another host
                               ?? webView.backForwardList.currentItem?.url.host
                               ?? self.url?.absoluteString
                               ?? "",
                               message: prompt,
                               alertType: .text(handler: completionHandler,
                                                defaultText: defaultText))
        self.present(alert)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension TabViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isShowBarsTap(gestureRecognizer) {
            return true
        }
        return false
    }

    private func isShowBarsTap(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let y = gestureRecognizer.location(in: self.view).y
        return gestureRecognizer == showBarsTapGestureRecogniser && chromeDelegate?.isToolbarHidden == true && isBottom(yPosition: y)
    }

    private func isBottom(yPosition y: CGFloat) -> Bool {
        let webViewFrameInTabView = webView.convert(webView.bounds, to: view)
        let bottomOfWebViewInTabView = webViewFrameInTabView.maxY - webView.scrollView.contentInset.bottom

        return y > bottomOfWebViewInTabView
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == showBarsTapGestureRecogniser else {
            return false
        }

        if gestureRecognizer == showBarsTapGestureRecogniser,
            otherRecognizer is UITapGestureRecognizer {
            return true
        }

        return false
    }

    func requestFindInPage() {
        guard findInPage == nil else { return }
        findInPage = FindInPage(webView: webView)
        delegate?.tabDidRequestFindInPage(tab: self)
    }

    func refresh() {
        let url: URL?
        if isError || webView.url == nil {
            url = self.url
        } else {
            url = webView.url
        }
        
        requeryLogic.onRefresh()
        if isError || webView.url == nil, let url = url {
            load(url: url)
        } else {
            reload()
        }

        refreshCountSinceLoad += 1
        if let url {
            AppDependencyProvider.shared.pageRefreshMonitor.register(for: url)
        }
    }

}

// MARK: - UserContentControllerDelegate
extension TabViewController: UserContentControllerDelegate {

    var userScripts: UserScripts? {
        userContentController.contentBlockingAssets?.userScripts as? UserScripts
    }
    private var findInPageScript: FindInPageUserScript? {
        userScripts?.findInPageScript
    }
    private var contentBlockerUserScript: ContentBlockerRulesUserScript? {
        userScripts?.contentBlockerUserScript
    }
    private var autofillUserScript: AutofillUserScript? {
        userScripts?.autofillUserScript
    }

    func userContentController(_ userContentController: UserContentController,
                               didInstallContentRuleLists contentRuleLists: [String: WKContentRuleList],
                               userScripts: UserScriptsProvider,
                               updateEvent: ContentBlockerRulesManager.UpdateEvent) {
        guard let userScripts = userScripts as? UserScripts else { fatalError("Unexpected UserScripts") }

        userScripts.debugScript.instrumentation = instrumentation
        userScripts.surrogatesScript.delegate = self
        userScripts.contentBlockerUserScript.delegate = self
        userScripts.autofillUserScript.emailDelegate = emailManager
        userScripts.autofillUserScript.vaultDelegate = vaultManager
        userScripts.faviconScript.delegate = faviconUpdater
        userScripts.printingUserScript.delegate = self
        userScripts.loginFormDetectionScript?.delegate = self
        userScripts.autoconsentUserScript.delegate = self

        // Special Error Page (SSL, Malicious Site protection)
        specialErrorPageNavigationHandler.setUserScript(userScripts.specialErrorPageUserScript)

        // Setup DuckPlayer
        userScripts.duckPlayer = duckPlayerNavigationHandler?.duckPlayer
        userScripts.youtubeOverlayScript?.webView = webView
        userScripts.youtubePlayerUserScript?.webView = webView
        
        performanceMetrics = PerformanceMetricsSubfeature(targetWebview: webView)
        userScripts.contentScopeUserScriptIsolated.registerSubfeature(delegate: performanceMetrics!)

        adClickAttributionLogic.onRulesChanged(latestRules: ContentBlocking.shared.contentBlockingManager.currentRules)
        
        let tdsKey = DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName
        let notificationsTriggeringReload = [
            UserDefaultsFireproofing.Notifications.loginDetectionStateChanged,
            AppUserDefaults.Notifications.doNotSellStatusChange
        ]
        if updateEvent.changes[tdsKey]?.contains(.unprotectedSites) == true
            || notificationsTriggeringReload.contains(where: {
                updateEvent.changes[$0.rawValue]?.contains(.notification) == true
            }) {

            reload()
        }
    }

}

// MARK: - ContentBlockerRulesUserScriptDelegate
extension TabViewController: ContentBlockerRulesUserScriptDelegate {
    
    func contentBlockerRulesUserScriptShouldProcessTrackers(_ script: ContentBlockerRulesUserScript) -> Bool {
        return privacyInfo?.isFor(self.url) ?? false
    }
    
    func contentBlockerRulesUserScriptShouldProcessCTLTrackers(_ script: ContentBlockerRulesUserScript) -> Bool {
        return false
    }

    func contentBlockerRulesUserScript(_ script: ContentBlockerRulesUserScript,
                                       detectedTracker tracker: DetectedRequest) {
        userScriptDetectedTracker(tracker)
    }
    
    func contentBlockerRulesUserScript(_ script: ContentBlockerRulesUserScript,
                                       detectedThirdPartyRequest request: DetectedRequest) {
        privacyInfo?.trackerInfo.add(detectedThirdPartyRequest: request)
    }

    fileprivate func userScriptDetectedTracker(_ tracker: DetectedRequest) {
        guard let url = url else { return }
        
        adClickAttributionLogic.onRequestDetected(request: tracker)
        
        if tracker.isBlocked && fireWoFollowUp {
            fireWoFollowUp = false
            Pixel.fire(pixel: .daxDialogsWithoutTrackersFollowUp)
        }

        privacyInfo?.trackerInfo.addDetectedTracker(tracker, onPageWithURL: url)
    }
}

// MARK: - SurrogatesUserScriptDelegate
extension TabViewController: SurrogatesUserScriptDelegate {

    func surrogatesUserScriptShouldProcessTrackers(_ script: SurrogatesUserScript) -> Bool {
        return privacyInfo?.isFor(self.url) ?? false
    }

    func surrogatesUserScriptShouldProcessCTLTrackers(_ script: SurrogatesUserScript) -> Bool {
        false
    }

    func surrogatesUserScript(_ script: SurrogatesUserScript,
                              detectedTracker tracker: DetectedRequest,
                              withSurrogate host: String) {
        guard let url = url else { return }
        
        privacyInfo?.trackerInfo.addInstalledSurrogateHost(host, for: tracker, onPageWithURL: url)
        userScriptDetectedTracker(tracker)
    }

}

// MARK: - PrintingUserScriptDelegate
extension TabViewController: PrintingUserScriptDelegate {

    func printingUserScriptDidRequestPrintController(_ script: PrintingUserScript) {
        let controller = UIPrintInteractionController.shared
        controller.printFormatter = webView.viewPrintFormatter()
        controller.present(animated: true, completionHandler: nil)
    }

}

// MARK: - AutoconsentUserScriptDelegate
extension TabViewController: AutoconsentUserScriptDelegate {
    
    func autoconsentUserScript(_ script: AutoconsentUserScript, didUpdateCookieConsentStatus cookieConsentStatus: PrivacyDashboard.CookieConsentInfo) {
        privacyInfo?.cookieConsentManaged = cookieConsentStatus
    }
}

// MARK: - AdClickAttributionLogicDelegate
extension TabViewController: AdClickAttributionLogicDelegate {

    func attributionLogic(_ logic: AdClickAttributionLogic,
                          didRequestRuleApplication rules: ContentBlockerRulesManager.Rules?,
                          forVendor vendor: String?) {
        let attributedTempListName = AdClickAttributionRulesProvider.Constants.attributedTempRuleListName

        guard ContentBlocking.shared.privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .contentBlocking)
        else {
            userContentController.removeLocalContentRuleList(withIdentifier: attributedTempListName)
            contentBlockerUserScript?.currentAdClickAttributionVendor = nil
            contentBlockerUserScript?.supplementaryTrackerData = []
            return
        }

        contentBlockerUserScript?.currentAdClickAttributionVendor = vendor
        if let rules = rules {

            let globalListName = DefaultContentBlockerRulesListsSource.Constants.trackerDataSetRulesListName
            let globalAttributionListName = AdClickAttributionRulesSplitter.blockingAttributionRuleListName(forListNamed: globalListName)

            if vendor != nil {
                userContentController.installLocalContentRuleList(rules.rulesList, identifier: attributedTempListName)
                try? userContentController.disableGlobalContentRuleList(withIdentifier: globalAttributionListName)
            } else {
                userContentController.removeLocalContentRuleList(withIdentifier: attributedTempListName)
                try? userContentController.enableGlobalContentRuleList(withIdentifier: globalAttributionListName)
            }

            contentBlockerUserScript?.supplementaryTrackerData = [rules.trackerData]
        } else {
            contentBlockerUserScript?.supplementaryTrackerData = []
        }
    }

}

// MARK: - Themable
extension TabViewController {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.backgroundColor
        error?.backgroundColor = theme.backgroundColor
        errorHeader.textColor = theme.barTintColor
        errorMessage.textColor = theme.barTintColor
        
        if let webView {
            webView.scrollView.refreshControl?.backgroundColor = theme.mainViewBackgroundColor
            webView.scrollView.refreshControl?.tintColor = .secondaryLabel
        }
    }
    
}

// MARK: - NSError+failedUrl
extension NSError {

    var failedUrl: URL? {
        return userInfo[NSURLErrorFailingURLErrorKey] as? URL
    }
    
}

extension TabViewController: SecureVaultManagerDelegate {

    private func presentSavePasswordModal(with vault: SecureVaultManager, credentials: SecureVaultModels.WebsiteCredentials, backfilled: Bool) {
        guard AutofillSettingStatus.isAutofillEnabledInSettings,
              featureFlagger.isFeatureOn(.autofillCredentialsSaving),
              let autofillUserScript = autofillUserScript else { return }

        let manager = SaveAutofillLoginManager(credentials: credentials, vaultManager: vault, autofillScript: autofillUserScript)
        manager.prepareData { [weak self] in
            guard let self = self else { return }
            
            let saveLoginController = SaveLoginViewController(credentialManager: manager,
                                                              appSettings: self.appSettings,
                                                              domainLastShownOn: self.domainSaveLoginPromptLastShownOn,
                                                              backfilled: backfilled)
            self.domainSaveLoginPromptLastShownOn = self.url?.host
            saveLoginController.delegate = self

            if let presentationController = saveLoginController.presentationController as? UISheetPresentationController {
                if #available(iOS 16.0, *) {
                    presentationController.detents = [.custom(resolver: { _ in
                        saveLoginController.viewModel?.minHeight
                    })]
                } else {
                    presentationController.detents = [.medium()]
                }
                presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            }

            self.present(saveLoginController, animated: true, completion: nil)
        }
    }
    
    func secureVaultError(_ error: SecureStorageError) {
        SecureVaultReporter().secureVaultError(error)
    }

    func secureVaultKeyStoreEvent(_ event: SecureStorageKeyStoreEvent) {
        SecureVaultReporter().secureVaultKeyStoreEvent(event)
    }

    func secureVaultManagerIsEnabledStatus(_ manager: SecureVaultManager, forType type: AutofillType?) -> Bool {
        let isEnabled = AutofillSettingStatus.isAutofillEnabledInSettings &&
                        featureFlagger.isFeatureOn(.autofillCredentialInjecting) &&
                        !isLinkPreview
        let isDataProtected = !UIApplication.shared.isProtectedDataAvailable
        if isEnabled && isDataProtected {
            DailyPixel.fire(pixel: .secureVaultIsEnabledCheckedWhenEnabledAndDataProtected,
                       withAdditionalParameters: [PixelParameters.isDataProtected: "true"])
        }
        return isEnabled
    }

    func secureVaultManagerShouldSaveData(_ manager: SecureVaultManager) -> Bool {
        return secureVaultManagerIsEnabledStatus(manager, forType: nil)
    }

    func secureVaultManager(_ vault: SecureVaultManager,
                            promptUserToStoreAutofillData data: AutofillData,
                            withTrigger trigger: AutofillUserScript.GetTriggerType?) {
        
        if let credentials = data.credentials,
            AutofillSettingStatus.isAutofillEnabledInSettings,
            featureFlagger.isFeatureOn(.autofillCredentialsSaving) {
            if data.automaticallySavedCredentials, let trigger = trigger {
                if trigger == AutofillUserScript.GetTriggerType.passwordGeneration {
                    return
                } else if trigger == AutofillUserScript.GetTriggerType.formSubmission {
                    guard let accountID = credentials.account.id,
                          let accountIdInt = Int64(accountID) else { return }
                    confirmSavedCredentialsFor(credentialID: accountIdInt, message: UserText.autofillLoginSavedToastMessage)
                    return
                }
            }

            saveLoginPromptIsPresenting = true

            // Add a delay to allow propagation of pointer events to the page
            // see https://app.asana.com/0/1202427674957632/1202532842924584/f
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentSavePasswordModal(with: vault, credentials: credentials, backfilled: data.backfilled)
            }
        }
    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserToAutofillCredentialsForDomain domain: String,
                            withAccounts accounts: [SecureVaultModels.WebsiteAccount],
                            withTrigger trigger: AutofillUserScript.GetTriggerType,
                            onAccountSelected: @escaping (SecureVaultModels.WebsiteAccount?) -> Void,
                            completionHandler: @escaping (SecureVaultModels.WebsiteAccount?) -> Void) {
  
        if !AutofillSettingStatus.isAutofillEnabledInSettings, featureFlagger.isFeatureOn(.autofillCredentialInjecting) {
            completionHandler(nil)
            return
        }

        // if user is interacting with the searchBar, don't show the autofill prompt since it will overlay the keyboard
        if let parent = parent as? MainViewController, parent.viewCoordinator.omniBar.textField.isFirstResponder {
            completionHandler(nil)
            return
        }

        if accounts.count > 0 {
            let accountMatches = autofillWebsiteAccountMatcher.findDeduplicatedSortedMatches(accounts: accounts, for: domain)

            presentAutofillPromptViewController(accountMatches: accountMatches, domain: domain, trigger: trigger, useLargeDetent: false) { [weak self] account in
                onAccountSelected(account)

                guard let domain = account?.domain else { return }
                Task {
                    await self?.credentialIdentityStoreManager.updateCredentialStore(for: domain)
                }
            } completionHandler: { account in
                if account != nil {
                    NotificationCenter.default.post(name: .autofillFillEvent, object: nil)
                }
                completionHandler(account)
            }
        } else {
            completionHandler(nil)
        }
    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserWithGeneratedPassword password: String,
                            completionHandler: @escaping (Bool) -> Void) {

        var responseSent: Bool = false

        let sendResponse: (Bool) -> Void = { useGeneratedPassword in
            guard !responseSent else { return }
            responseSent = true
            completionHandler(useGeneratedPassword)
        }

        let passwordGenerationPromptViewController = PasswordGenerationPromptViewController(generatedPassword: password) { useGeneratedPassword in
            sendResponse(useGeneratedPassword)
        }

        if let presentationController = passwordGenerationPromptViewController.presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                presentationController.detents = [.custom(resolver: { _ in
                    AutofillViews.passwordGenerationMinHeight
                })]
            } else {
                presentationController.detents = [.medium()]
            }
        }

        self.present(passwordGenerationPromptViewController, animated: true)
    }

    /// Using Bool for detent size parameter to be backward compatible with iOS 14
    func presentAutofillPromptViewController(accountMatches: AccountMatches,
                                             domain: String,
                                             trigger: AutofillUserScript.GetTriggerType,
                                             useLargeDetent: Bool,
                                             onAccountSelected: @escaping (SecureVaultModels.WebsiteAccount?) -> Void,
                                             completionHandler: @escaping (SecureVaultModels.WebsiteAccount?) -> Void) {

        var responseSent: Bool = false

        let sendResponse: (SecureVaultModels.WebsiteAccount?) -> Void = { account in
            guard !responseSent else { return }
            responseSent = true
            completionHandler(account)
        }

        let autofillPromptViewController = AutofillLoginPromptViewController(accounts: accountMatches,
                                                                             domain: domain,
                                                                             trigger: trigger,
                                                                             onAccountSelected: { account in
            onAccountSelected(account)
        }, completion: { account, showExpanded in
            if showExpanded {
                self.presentAutofillPromptViewController(accountMatches: accountMatches,
                                                         domain: domain,
                                                         trigger: trigger,
                                                         useLargeDetent: showExpanded,
                                                         onAccountSelected: { account in
                    onAccountSelected(account)
                },
                                                         completionHandler: { account in
                    sendResponse(account)
                })
            } else {
                sendResponse(account)
            }
        })

        if let presentationController = autofillPromptViewController.presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                presentationController.detents = [.custom(resolver: { _ in
                    AutofillViews.loginPromptMinHeight
                })]
            } else {
                presentationController.detents = useLargeDetent ? [.large()] : [.medium()]
            }
        }

        self.present(autofillPromptViewController, animated: true, completion: nil)
    }

    // Used on macOS to request authentication for individual autofill items
    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager,
                            isAuthenticatedFor type: BrowserServicesKit.AutofillType,
                            completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }

    func secureVaultManager(_: SecureVaultManager, didAutofill type: AutofillType, withObjectId objectId: String) {
        // No-op, don't need to do anything here
    }

    func secureVaultManager(_: SecureVaultManager, didRequestAuthenticationWithCompletionHandler: @escaping (Bool) -> Void) {
        // We don't have auth yet
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestCreditCardsManagerForDomain domain: String) {
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestIdentitiesManagerForDomain domain: String) {
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestPasswordManagerForDomain domain: String) {
    }

    func secureVaultManager(_: SecureVaultManager, didRequestRuntimeConfigurationForDomain domain: String, completionHandler: @escaping (String?) -> Void) {
        // didRequestRuntimeConfigurationForDomain fires for every iframe loaded on a website
        // so caching the runtime configuration for the domain to prevent unnecessary re-building of the configuration
        if let runtimeConfigurationForDomain = cachedRuntimeConfigurationForDomain[domain] as? String {
            completionHandler(runtimeConfigurationForDomain)
            return
        }

        let runtimeConfiguration =
                DefaultAutofillSourceProvider.Builder(privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
                                                                         properties: buildContentScopePropertiesForDomain(domain))
                                                                .build()
                                                                .buildRuntimeConfigResponse()

        cachedRuntimeConfigurationForDomain = [domain: runtimeConfiguration]
        completionHandler(runtimeConfiguration)
    }

    private func buildContentScopePropertiesForDomain(_ domain: String) -> ContentScopeProperties {
        var supportedFeatures = ContentScopeFeatureToggles.supportedFeaturesOniOS

        if AutofillSettingStatus.isAutofillEnabledInSettings,
           featureFlagger.isFeatureOn(.autofillCredentialsSaving),
           autofillNeverPromptWebsitesManager.hasNeverPromptWebsitesFor(domain: domain) {
            supportedFeatures.passwordGeneration = false
        }

        return ContentScopeProperties(gpcEnabled: appSettings.sendDoNotSell,
                                      sessionKey: autofillUserScript?.sessionKey ?? "",
                                      messageSecret: autofillUserScript?.messageSecret ?? "",
                                      featureToggles: supportedFeatures)
    }

    func secureVaultManager(_: SecureVaultManager, didReceivePixel pixel: AutofillUserScript.JSPixel) {
        guard !pixel.isEmailPixel else {
            // The iOS app uses a native email autofill UI, and sends its pixels separately. Ignore pixels sent from the JS layer.
            return
        }

        Pixel.fire(pixel: .autofillJSPixelFired(pixel))
    }
    
}

extension TabViewController: SaveLoginViewControllerDelegate {

    private func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, withSuccessMessage message: String) {
        saveLoginPromptLastDismissed = Date()
        saveLoginPromptIsPresenting = false

        do {
            let credentialID = try SaveAutofillLoginManager.saveCredentials(credentials,
                                                                            with: AutofillSecureVaultFactory)
            confirmSavedCredentialsFor(credentialID: credentialID, message: message)
            syncService.scheduler.notifyDataChanged()

            NotificationCenter.default.post(name: .autofillSaveEvent, object: nil)
        } catch {
            Logger.general.error("failed to store credentials: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func confirmSavedCredentialsFor(credentialID: Int64, message: String) {
        do {
            let vault = try AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter())
            
            if let newCredential = try vault.websiteCredentialsFor(accountId: credentialID) {
                DispatchQueue.main.async {
                    let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
                    ActionMessageView.present(message: message,
                                              actionTitle: UserText.autofillLoginSaveToastActionButton,
                                              presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom),
                                              onAction: {

                        self.showLoginDetails(with: newCredential.account)
                    })
                    Favicons.shared.loadFavicon(forDomain: newCredential.account.domain, intoCache: .fireproof, fromCache: .tabs)
                }

                guard let domain = newCredential.account.domain else { return }
                Task {
                    await credentialIdentityStoreManager.updateCredentialStore(for: domain)
                }
            }
        } catch {
            Logger.general.error("failed to fetch credentials: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func saveLoginViewController(_ viewController: SaveLoginViewController, didSaveCredentials credentials: SecureVaultModels.WebsiteCredentials) {
        viewController.dismiss(animated: true)
        saveCredentials(credentials, withSuccessMessage: UserText.autofillLoginSavedToastMessage)
    }
    
    func saveLoginViewController(_ viewController: SaveLoginViewController, didUpdateCredentials credentials: SecureVaultModels.WebsiteCredentials) {
        viewController.dismiss(animated: true)
        saveCredentials(credentials, withSuccessMessage: UserText.autofillLoginUpdatedToastMessage)
    }
    
    func saveLoginViewControllerDidCancel(_ viewController: SaveLoginViewController) {
        viewController.dismiss(animated: true)
        saveLoginPromptLastDismissed = Date()
        saveLoginPromptIsPresenting = false
    }

    func saveLoginViewController(_ viewController: SaveLoginViewController, didRequestNeverPromptForWebsite domain: String) {
        viewController.dismiss(animated: true)
        saveLoginPromptLastDismissed = Date()
        saveLoginPromptIsPresenting = false

        do {
            _ = try autofillNeverPromptWebsitesManager.saveNeverPromptWebsite(domain)
        } catch {
            Logger.general.error("failed to save never prompt for website: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func saveLoginViewControllerConfirmKeepUsing(_ viewController: SaveLoginViewController) {
        Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisableSnackbarShown)
        DispatchQueue.main.async {
            let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
            ActionMessageView.present(message: UserText.autofillDisablePromptMessage,
                                      actionTitle: UserText.autofillDisablePromptAction,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom),
                                      duration: 4.0,
                                      onAction: { [weak self] in
                Pixel.fire(pixel: .autofillLoginsFillLoginInlineDisableSnackbarOpenSettings)
                guard let mainVC = self?.view.window?.rootViewController as? MainViewController else { return }
                mainVC.launchAutofillLogins(source: .saveLoginDisablePrompt)
            })
        }
    }
}

extension TabViewController: OnboardingNavigationDelegate {

    func searchFromOnboarding(for query: String) {
        delegate?.tab(self, didRequestLoadQuery: query)
    }

    func navigateFromOnboarding(to url: URL) {
        delegate?.tab(self, didRequestLoadURL: url)
    }

}

extension TabViewController: ContextualOnboardingEventDelegate {

    func didAcknowledgeContextualOnboardingSearch() {
        contextualOnboardingLogic.setSearchMessageSeen()
    }

    func didAcknowledgeContextualOnboardingTrackersDialog() {
        // Store when Fire contextual dialog is shown to decide if final dialog needs to be shown.
        contextualOnboardingLogic.setFireEducationMessageSeen()
        delegate?.tabDidRequestFireButtonPulse(tab: self)
    }

    func didShowContextualOnboardingTrackersDialog() {
        guard contextualOnboardingLogic.shouldShowPrivacyButtonPulse else { return }
        
        delegate?.tabDidRequestPrivacyDashboardButtonPulse(tab: self, animated: true)
    }

    func didTapDismissContextualOnboardingAction() {
        // Reset last visited onboarding site and last dax dialog shown.
        contextualOnboardingLogic.setDaxDialogDismiss()

        contextualOnboardingPresenter.dismissContextualOnboardingIfNeeded(from: self)
    }

}

extension WKWebView {

    func load(_ url: URL, in frame: WKFrameInfo?) {
        evaluateJavaScript("window.location.href='" + url.absoluteString + "'", in: frame, in: .page)
    }

}

extension UserContentController {

    @MainActor
    public convenience init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager) {
        self.init(assetsPublisher: ContentBlocking.shared.contentBlockingUpdating.userContentBlockingAssets,
                  privacyConfigurationManager: privacyConfigurationManager)
    }

}

// MARK: - SpecialErrorPageNavigationDelegate

extension TabViewController: SpecialErrorPageNavigationDelegate {

    func closeSpecialErrorPageTab(shouldCreateNewEmptyTab: Bool) {
        delegate?.tabDidRequestClose(self, shouldCreateEmptyTabAtSamePosition: shouldCreateNewEmptyTab)
    }

}

// MARK: - DuckPlayerTabNavigationHandling

// This Protocol allows DuckPlayerHandler access tabs
extension TabViewController: DuckPlayerTabNavigationHandling {
    
    func openTab(for url: URL) {
        delegate?.tab(self,
                      didRequestNewTabForUrl: url,
                      openedByPage: true,
                      inheritingAttribution: adClickAttributionLogic.state)
        
    }
    
    func closeTab() {
        if openingTab != nil {
            delegate?.tabDidRequestClose(self)
            return
        }
    }
    
}

private extension TabViewController {

    func restoreInteractionStateToWebView(_ interactionStateData: Data?) -> Bool {
        var didRestoreWebViewState = false
        if let interactionStateData {
            let startTime = CFAbsoluteTimeGetCurrent()
            webView.interactionState = interactionStateData
            if webView.url != nil {
                self.url = tabModel.link?.url
                didRestoreWebViewState = true
                tabInteractionStateSource?.saveState(webView.interactionState, for: tabModel)
            } else {
                Pixel.fire(pixel: .tabInteractionStateFailedToRestore)
            }

            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
            Pixel.fire(pixel: .tabInteractionStateRestorationTime(Pixel.Event.BucketAggregation(number: timeElapsed)))
        }

        return didRestoreWebViewState
    }
}

// Landscape/Portrait mode customizations
extension TabViewController {
    
    /// Stores WebView settings and
    /// Updates its properties when displaying video in landscape mode
    // This is used by DuckPlayer when rotating to landscape
    func setupWebViewForLandscapeVideo() {
        guard let webView = webView else { return }
        
        // Store original settings
        savedViewSettings = ViewSettings(
            viewBackground: view.backgroundColor,
            webViewBackground: webView.backgroundColor,
            webViewOpaque: webView.isOpaque,
            scrollViewBackground: webView.scrollView.backgroundColor
        )
        
        // Apply landscape settings
        view.backgroundColor = .black
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .black
    }
    
    /// Resets the webview to its original settings
    /// This is used by DuckPlayer when rotating back to portrait
    func setupWebViewForPortraitVideo() {
        guard let webView = webView else { return }
        
        // Restore original settings if they were stored
        let settings = savedViewSettings ?? ViewSettings.default
        view.backgroundColor = settings.viewBackground
        webView.backgroundColor = settings.webViewBackground
        webView.isOpaque = settings.webViewOpaque
        webView.scrollView.backgroundColor = settings.scrollViewBackground
        
        // Clear stored settings
        savedViewSettings = nil
    }
}

extension TabViewController: Navigatable {
    public var canGoBack: Bool {
        let webViewCanGoBack = webView.canGoBack
        let navigatedToError = webView.url != nil && isError
        return webViewCanGoBack || navigatedToError || openingTab != nil
    }

    public var canGoForward: Bool {
        let webViewCanGoForward = webView.canGoForward
        return webViewCanGoForward && !isError
    }

}

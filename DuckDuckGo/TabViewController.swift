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
import Device
import StoreKit
import os.log

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class TabViewController: UIViewController {
// swiftlint:enable type_body_length

    private struct Constants {
        static let frameLoadInterruptedErrorCode = 102
    }

    private struct UserAgent {
        static let desktop = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15 " +
                             WKWebViewConfiguration.ddgNameForUserAgent
    }
    
    @IBOutlet private(set) weak var error: UIView!
    @IBOutlet private(set) weak var errorInfoImage: UIImageView!
    @IBOutlet private(set) weak var errorHeader: UILabel!
    @IBOutlet private(set) weak var errorMessage: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    
    @IBOutlet var showBarsTapGestureRecogniser: UITapGestureRecognizer!
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
    private let instrumentation = TabInstrumentation()

    var openedByPage = false
    
    weak var delegate: TabDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    
    var findInPage: FindInPage? {
        get { return findInPageScript.findInPage }
        set { findInPageScript.findInPage = newValue }
    }
    
    let progressWorker = WebProgressWorker()

    private(set) var webView: WKWebView!
    private lazy var appRatingPrompt: AppRatingPrompt = AppRatingPrompt()
    private weak var privacyController: PrivacyProtectionController?
    
    private(set) lazy var appUrls: AppUrls = AppUrls()
    private var storageCache: StorageCache = AppDependencyProvider.shared.storageCache.current
    private let contentBlockerConfiguration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()
    private var httpsUpgrade = HTTPSUpgrade.shared

    private(set) var siteRating: SiteRating?
    private(set) var tabModel: Tab
    private var httpsForced: Bool = false
    private var lastUpgradedURL: URL?
    private var lastError: Error?
    private var shouldReloadOnError = false
    private var failingUrls = Set<String>()
    
    private var trackerNetworksDetectedOnPage = Set<String>()
    private var pageHasTrackers = false
    
    private var tips: BrowsingTips?

    private var detectedLoginURL: URL?
    
    public var url: URL? {
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
        }
    }
    
    public var canGoBack: Bool {
        let webViewCanGoBack = webView.canGoBack
        let navigatedToError = webView.url != nil && isError
        return webViewCanGoBack || navigatedToError
    }
    
    public var canGoForward: Bool {
        let webViewCanGoForward = webView.canGoForward
        return webViewCanGoForward && !isError
    }
    
    public var isError: Bool {
        return !error.isHidden
    }
    
    public var errorText: String? {
        return errorMessage.text
    }
    
    public var link: Link? {
        if isError {
            if let url = url ?? webView.url ?? URL(string: "") {
                return Link(title: errorText, url: url)
            }
        }
        
        guard let url = url else {
            return tabModel.link
        }
        
        let activeLink = Link(title: title, url: url)
        guard let storedLink = tabModel.link else {
            return activeLink
        }
        
        return activeLink.merge(with: storedLink)
    }
    
    private var findInPageScript = FindInPageScript()
    private var userScripts: [UserScript] = []

    static func loadFromStoryboard(model: Tab) -> TabViewController {
        let storyboard = UIStoryboard(name: "Tab", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "TabViewController") as? TabViewController else {
            fatalError("Failed to instantiate controller as TabViewController")
        }
        controller.tabModel = model
        return controller
    }

    required init?(coder aDecoder: NSCoder) {
        tabModel = Tab(link: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userScripts = [
            findInPageScript
        ]
        
        applyTheme(ThemeManager.shared.currentTheme)
        addContentBlockerConfigurationObserver()
        addStorageCacheProviderObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        installBrowsingTips()
        resetNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeBrowsingTips()
    }
    
    func updateTabModel() {
        if let url = url {
            tabModel.link = Link(title: title, url: url)
        } else {
            tabModel.link = nil
        }
    }
    
    func installBrowsingTips() {
        tips = BrowsingTips(delegate: self)
    }
    
    func removeBrowsingTips() {
        tips = nil
    }
    
    @objc func onApplicationWillResignActive() {
        shouldReloadOnError = true
    }
    
    func attachWebView(configuration: WKWebViewConfiguration, andLoadRequest request: URLRequest?, consumeCookies: Bool) {
        instrumentation.willPrepareWebView()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if #available(iOS 13, *) {
            webView.allowsLinkPreview = true
        } else {
            attachLongPressHandler(webView: webView)
            webView.allowsLinkPreview = false
        }
        
        webView.allowsBackForwardNavigationGestures = true
        
        addObservers()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webViewContainer.addSubview(webView)

        removeMessageHandlers() // incoming config might be a copy of an existing confg with handlers
        addMessageHandlers()

        reloadScripts()
        updateUserAgent()
        
        instrumentation.didPrepareWebView()

        if consumeCookies {
            consumeCookiesThenLoadRequest(request)
        } else if let request = request {
            load(urlRequest: request)
        }
    }

    private func addMessageHandlers() {
        let controller = webView.configuration.userContentController
        userScripts.forEach { script in
            controller.addUserScript(WKUserScript(source: script.source,
                                                  injectionTime: script.injectionTime,
                                                  forMainFrameOnly: script.forMainFrameOnly))
            
            script.messageNames.forEach { messageName in
                controller.add(script, name: messageName)
            }
            
        }
        
//        controller.add(self, name: MessageHandlerNames.trackerDetected)
//        controller.add(self, name: MessageHandlerNames.loginFormDetected)
//        controller.add(self, name: MessageHandlerNames.signpost)
//        controller.add(self, name: MessageHandlerNames.log)
//        controller.add(self, name: MessageHandlerNames.findInPageHandler)
    }

    private func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    
    private func attachLongPressHandler(webView: WKWebView) {
        let gestrueRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        gestrueRecognizer.delegate = self
        webView.scrollView.addGestureRecognizer(gestrueRecognizer)
        longPressGestureRecognizer = gestrueRecognizer
    }
    
    private func consumeCookiesThenLoadRequest(_ request: URLRequest?) {
        webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { _ in
            WebCacheManager.shared.consumeCookies { [weak self] in
                guard let strongSelf = self else { return }
                
                if let request = request {
                    strongSelf.load(urlRequest: request)
                }
                
                if request != nil {
                    strongSelf.delegate?.tabLoadingStateDidChange(tab: strongSelf)
                    strongSelf.onWebpageDidStartLoading(httpsForced: false)
                }
            }
        }
    }
    
    public func load(url: URL) {
        self.url = url
        lastError = nil
        updateUserAgent()
        load(urlRequest: URLRequest(url: url))
    }
    
    private func load(urlRequest: URLRequest) {
        loadViewIfNeeded()
        webView.stopLoading()
        webView.load(urlRequest)
    }
    
    // swiftlint:disable block_based_kvo
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        // swiftlint:enable block_based_kvo

        guard let keyPath = keyPath else { return }
        
        switch keyPath {
            
        case #keyPath(WKWebView.estimatedProgress):
            progressWorker.progressDidChange(webView.estimatedProgress)
            
        case #keyPath(WKWebView.hasOnlySecureContent):
            hasOnlySecureContentChanged(hasOnlySecureContent: webView.hasOnlySecureContent)
            
        case #keyPath(WKWebView.url):
            self.url = self.webView.url
            
        case #keyPath(WKWebView.canGoBack):
            delegate?.tabLoadingStateDidChange(tab: self)
            
        case #keyPath(WKWebView.canGoForward):
            delegate?.tabLoadingStateDidChange(tab: self)

        case #keyPath(WKWebView.title):
            title = webView.title

        default:
            os_log("Unhandled keyPath %s", log: generalLog, type: .debug, keyPath)
        }
    }
    
    func hasOnlySecureContentChanged(hasOnlySecureContent: Bool) {
        guard webView.url?.host == siteRating?.url.host else { return }
        siteRating?.hasOnlySecureContent = hasOnlySecureContent
        updateSiteRating()
    }
    
    func fireproofWebsite(domain: String) {
        
        PreserveLoginsAlert.showConfirmFireproofWebsite(usingController: self) {
            Pixel.fire(pixel: .browsingMenuFireproof)
            PreserveLogins.shared.addToAllowed(domain: domain)
            self.view.showBottomToast(UserText.preserveLoginsToast.format(arguments: domain))
        }
        
    }
    
    private func checkForReloadOnError() {
        guard shouldReloadOnError else { return }
        shouldReloadOnError = false
        reload(scripts: false)
    }
    
    private func shouldReissueSearch(for url: URL) -> Bool {
        return appUrls.isDuckDuckGoSearch(url: url) && !appUrls.hasCorrectMobileStatsParams(url: url)
    }
    
    private func reissueSearchWithStatsParams(for url: URL) {
        let mobileSearch = appUrls.applyStatsParams(for: url)
        load(url: mobileSearch)
    }
    
    private func showProgressIndicator() {
        progressWorker.didStartLoading()
    }
    
    private func hideProgressIndicator() {
        progressWorker.didFinishLoading()
    }
    
    public func reload(scripts: Bool) {
        if scripts {
            reloadScripts()
        }
        updateUserAgent()
        webView.reload()
    }
    
    func updateUserAgent() {
        webView.customUserAgent = tabModel.isDesktop ? UserAgent.desktop : nil
        if #available(iOS 13, *) {
            webView.configuration.defaultWebpagePreferences.preferredContentMode = tabModel.isDesktop ? .desktop : .mobile
        }
    }
    
    func goBack() {
        if isError {
            hideErrorMessage()
            url = webView.url
            onWebpageDidStartLoading(httpsForced: false)
            onWebpageDidFinishLoading()
        } else {
            webView.goBack()
        }
    }
    
    func goForward() {
        webView.goForward()
    }
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let x = Int(sender.location(in: webView).x)
        let y = Int(sender.location(in: webView).y)
        let offsetY = y
        
        webView.getUrlAtPoint(x: x, y: offsetY) { [weak self] (url) in
            guard let url = url else { return }
            let point = Point(x: x, y: y)
            self?.launchLongPressMenu(atPoint: point, forUrl: url)
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
    
    private func reloadScripts() {
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.loadScripts(storageCache: storageCache, contentBlockingEnabled: !isDuckDuckGoUrl())
    }
    
    private func isDuckDuckGoUrl() -> Bool {
        guard let url = url else { return false }
        return appUrls.isDuckDuckGo(url: url)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let chromeDelegate = chromeDelegate else { return }

        if let controller = segue.destination as? PrivacyProtectionController {
            controller.popoverPresentationController?.delegate = controller

            if let siteRatingView = chromeDelegate.omniBar.siteRatingView {
                controller.popoverPresentationController?.sourceView = siteRatingView
                controller.popoverPresentationController?.sourceRect = siteRatingView.bounds
            }

            controller.privacyProtectionDelegate = self
            privacyController = controller
            controller.omniDelegate = chromeDelegate.omniBar.omniDelegate
            controller.omniBarText = chromeDelegate.omniBar.textField.text
            controller.siteRating = siteRating
            controller.errorText = isError ? errorText : nil
        }
    }
    
    private func addContentBlockerConfigurationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onContentBlockerConfigurationChanged),
                                               name: ContentBlockerConfigurationChangedNotification.name,
                                               object: nil)
    }

    private func addStorageCacheProviderObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onStorageCacheChange),
                                               name: StorageCacheProvider.didUpdateStorageCacheNotification,
                                               object: nil)
    }
    
    @objc func onContentBlockerConfigurationChanged() {
        reload(scripts: true)
    }

    @objc func onStorageCacheChange() {
        DispatchQueue.main.async {
            self.storageCache = AppDependencyProvider.shared.storageCache.current
            self.reload(scripts: true)
        }
    }

    private func resetNavigationBar() {
        chromeDelegate?.setNavigationBarHidden(false)
    }

    @IBAction func onBottomOfScreenTapped(_ sender: UITapGestureRecognizer) {
        showBars(animated: false)
    }

    private func showBars(animated: Bool = true) {
        chromeDelegate?.setBarsHidden(false, animated: animated)
    }

    func showPrivacyDashboard() {
        Pixel.fire(pixel: .privacyDashboardOpened)
        performSegue(withIdentifier: "PrivacyProtection", sender: self)
    }

    private func resetSiteRating() {
        if let url = url {
            siteRating = makeSiteRating(url: url)
        } else {
            siteRating = nil
        }
        onSiteRatingChanged()
    }
    
    private func makeSiteRating(url: URL) -> SiteRating {
        let entityMapping = EntityMapping()
        let privacyPractices = PrivacyPractices(tld: storageCache.tld,
                                                termsOfServiceStore: storageCache.termsOfServiceStore,
                                                entityMapping: entityMapping)
        
        return SiteRating(url: url,
                          httpsForced: httpsForced,
                          entityMapping: entityMapping,
                          privacyPractices: privacyPractices)
    }

    private func updateSiteRating() {
        if isError {
            siteRating = nil
        }
        onSiteRatingChanged()
    }

    private func onSiteRatingChanged() {
        delegate?.tab(self, didChangeSiteRating: siteRating)
        privacyController?.updateSiteRating(siteRating)
    }
    
    func launchBrowsingMenu() {
        Pixel.fire(pixel: .browsingMenuOpened)
        guard let button = chromeDelegate?.omniBar.menuButton else { return }
        let alert = buildBrowsingMenu()
        present(controller: alert, fromView: button)
    }
    
    private func launchLongPressMenu(atPoint point: Point, forUrl url: URL) {
        Pixel.fire(pixel: .longPressMenuOpened)
        let alert = buildLongPressMenu(atPoint: point, forUrl: url)
        present(controller: alert, fromView: webView, atPoint: point)
    }
    
    private func openExternally(url: URL) {
        UIApplication.shared.open(url, options: [:]) { opened in
            if !opened {
                self.view.showBottomToast(UserText.failedToOpenExternally)
            }
        }
    }

    private func isExternallyHandled(url: URL, for navigationAction: WKNavigationAction) -> Bool {
        let schemeType = ExternalSchemeHandler.schemeType(for: url)
        
        switch schemeType {
        case .external(let action):
            guard navigationAction.navigationType == .linkActivated else {
                // Ignore extrnal URLs if not triggered by the User.
                return true
            }
            switch action {
            case .open:
                openExternally(url: url)
            case .askForConfirmation:
                presentOpenInExternalAppAlert(url: url)
            case .cancel:
                break
            }
            
            return true
        case .other:
            return false
        }
    }
    
    func presentOpenInExternalAppAlert(url: URL) {
        let title = UserText.customUrlSchemeTitle
        let message = UserText.forCustomUrlSchemePrompt(url: url)
        let open = UserText.customUrlSchemeOpen
        let dontOpen = UserText.customUrlSchemeDontOpen
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle()
        alert.addAction(UIAlertAction(title: dontOpen, style: .cancel))
        alert.addAction(UIAlertAction(title: open, style: .destructive, handler: { _ in
            self.openExternally(url: url)
        }))
        show(alert, sender: self)   
    }

    func dismiss() {
        progressWorker.progressBar = nil
        //        chromeDelegate = nil
        //        webView.scrollView.delegate = nil
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
//    private func tearDown() {
//        removeObservers()
//        webView.removeFromSuperview()
//        removeMessageHandlers()
//    }

    private func removeMessageHandlers() {
        let controller = webView.configuration.userContentController
        userScripts.forEach { script in
            script.messageNames.forEach { messageName in
                controller.removeScriptMessageHandler(forName: messageName)
            }
        }
        
//        controller.removeScriptMessageHandler(forName: MessageHandlerNames.trackerDetected)
//        controller.removeScriptMessageHandler(forName: MessageHandlerNames.loginFormDetected)
//        controller.removeScriptMessageHandler(forName: MessageHandlerNames.signpost)
//        controller.removeScriptMessageHandler(forName: MessageHandlerNames.log)
//        controller.removeScriptMessageHandler(forName: MessageHandlerNames.findInPageHandler)
    }
    
    private func removeObservers() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.hasOnlySecureContent))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }
    
    deinit {
        print("*** deinit TVC")
        removeMessageHandlers()
        removeObservers()
    }
    
}   

extension TabViewController: WKScriptMessageHandler {
    
    struct TrackerDetectedKey {
        static let protectionId = "protectionId"
        static let blocked = "blocked"
        static let networkName = "networkName"
        static let url = "url"
        static let isSurrogate = "isSurrogate"
    }

    private struct MessageHandlerNames {
        static let trackerDetected = "trackerDetectedMessage"
        static let signpost = "signpostMessage"
        static let log = "log"
        static let findInPageHandler = "findInPageHandler"
        static let loginFormDetected = "loginFormDetected"
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        switch message.name {

        case MessageHandlerNames.signpost:
            handleSignpost(message: message)
            
        case MessageHandlerNames.trackerDetected:
            handleTrackerDetected(message: message)

        case MessageHandlerNames.loginFormDetected:
            handleLoginFormDetected(message: message)

        case MessageHandlerNames.log:
            handleLog(message: message)

        default:
            assertionFailure("Unhandled message: \(message.name)")
        }
    }
    
    private func handleLoginFormDetected(message: WKScriptMessage) {
        print("***", #function, webView.url as Any)
        detectedLoginURL = webView.url
    }
    
    private func possibleLogin(forDomain domain: String?, source: String) {
        guard #available(iOS 13, *) else {
            // We can't be sure about leaking cookies before iOS 13 so don't allow logins to be saved
            return
        }
                
        guard let domain = domain else { return }
        if isDebugBuild {
            view.showBottomToast("Login detected for \(domain) via \(source)")
        }
        
        if PreserveLogins.shared.userDecision == .preserveLogins {
            PreserveLogins.shared.addToAllowed(domain: domain)
        } else {
            PreserveLogins.shared.addToDetected(domain: domain)
        }
    }

    private func handleLog(message: WKScriptMessage) {
        os_log("%s", log: generalLog, type: .debug, String(describing: message.body))
    }
    
    private func handleSignpost(message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any],
        let event = dict["event"] as? String else { return }
        
        if event == "Request Allowed" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String {
                instrumentation.request(url: url, allowedIn: elapsedTimeInMs)
            }
        } else if event == "Tracker Allowed" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String,
                let reason = dict["reason"] as? String? {
                instrumentation.tracker(url: url, allowedIn: elapsedTimeInMs, reason: reason)
            }
        } else if event == "Tracker Blocked" {
            if let elapsedTimeInMs = dict["time"] as? Double,
                let url = dict["url"] as? String {
                instrumentation.tracker(url: url, blockedIn: elapsedTimeInMs)
            }
        } else if event == "Generic" {
            if let name = dict["name"] as? String,
                let elapsedTimeInMs = dict["time"] as? Double {
                instrumentation.jsEvent(name: name, executedIn: elapsedTimeInMs)
            }
        }

    }

    private func handleTrackerDetected(message: WKScriptMessage) {
        os_log("%s %s", log: generalLog, type: .debug, MessageHandlerNames.trackerDetected, String(describing: message.body))

        guard let siteRating = siteRating else { return }
        guard let dict = message.body as? [String: Any] else { return }
        guard let blocked = dict[TrackerDetectedKey.blocked] as? Bool else { return }
        guard let urlString = dict[TrackerDetectedKey.url] as? String else { return }
        
        guard siteRating.isFor(self.url) else {
            os_log("mismatching domain %s vs %s", log: generalLog, type: .debug, self.url?.absoluteString ?? "nil", siteRating.domain ?? "nil")
            return
        }
        
        if let isSurrogate = dict[TrackerDetectedKey.isSurrogate] as? Bool, isSurrogate, let host = URL(string: urlString)?.host {
            siteRating.surrogateInstalled(host)
        }

        let tracker = trackerFromUrl(urlString.trimWhitespace(), blocked)
        
        siteRating.trackerDetected(tracker)
        onSiteRatingChanged()
        
        if !pageHasTrackers {
            NetworkLeaderboard.shared.incrementPagesWithTrackers()
            pageHasTrackers = true
        }
  
        if let networkName = tracker.knownTracker?.owner?.name {
            if !trackerNetworksDetectedOnPage.contains(networkName) {
                trackerNetworksDetectedOnPage.insert(networkName)
                NetworkLeaderboard.shared.incrementDetectionCount(forNetworkNamed: networkName)
            }
            NetworkLeaderboard.shared.incrementTrackersCount(forNetworkNamed: networkName)
        }

    }

    private func trackerFromUrl(_ urlString: String, _ blocked: Bool) -> DetectedTracker {
        let knownTracker = TrackerDataManager.shared.findTracker(forUrl: urlString)
        let entity = TrackerDataManager.shared.findEntity(byName: knownTracker?.owner?.name ?? "")
        return DetectedTracker(url: urlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
    }
    
    public func getCurrentWebsiteInfo() -> BrokenSiteInfo {
        let blockedTrackerDomains = siteRating?.trackersBlocked.compactMap { $0.domain } ?? []
        
        return BrokenSiteInfo(url: url,
                              httpsUpgrade: httpsForced,
                              blockedTrackerDomains: blockedTrackerDomains,
                              installedSurrogates: siteRating?.installedSurrogates.map {$0} ?? [],
                              isDesktop: tabModel.isDesktop,
                              tdsETag: TrackerDataManager.shared.etag)
    }
    
}

extension TabViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            performBascHTTPAuthentication(protectionSpace: challenge.protectionSpace, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
            guard let serverTrust = challenge.protectionSpace.serverTrust else { return }
            ServerTrustCache.shared.put(serverTrust: serverTrust, forDomain: challenge.protectionSpace.host)
        }
    }
    
    func performBascHTTPAuthentication(protectionSpace: URLProtectionSpace,
                                       completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let isHttps = protectionSpace.protocol == "https"
        let alert = BasicAuthenticationAlert(host: protectionSpace.host,
                                             isEncrypted: isHttps,
                                             logInCompletion: { (login, password) in
            completionHandler(.useCredential, URLCredential(user: login, password: password, persistence: .forSession))
        }, cancelCompletion: {
            completionHandler(.rejectProtectionSpace, nil)
        })
        
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url {
            instrumentation.willLoad(url: url)
        }
                
        url = webView.url
        let tld = storageCache.tld
        let httpsForced = tld.domain(lastUpgradedURL?.host) == tld.domain(webView.url?.host)
        onWebpageDidStartLoading(httpsForced: httpsForced)
    }
    
    private func onWebpageDidStartLoading(httpsForced: Bool) {
        os_log("webpageLoading started", log: generalLog, type: .debug)
        
        // isLoginFormDetected = false
        
        self.httpsForced = httpsForced
        delegate?.showBars()
        
        // if host and scheme are the same, don't inject scripts, otherwise, reset and reload
        if let siteRating = siteRating, siteRating.url.host == url?.host, siteRating.url.scheme == url?.scheme {
            self.siteRating = makeSiteRating(url: siteRating.url)
        } else {
            resetSiteRating()
        }
        
        tabModel.link = link
        delegate?.tabLoadingStateDidChange(tab: self)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        trackerNetworksDetectedOnPage.removeAll()
        pageHasTrackers = false
        NetworkLeaderboard.shared.incrementPagesLoaded()
        
        if #available(iOS 10.3, *) {
            appRatingPrompt.registerUsage()
            if appRatingPrompt.shouldPrompt() {
                SKStoreReviewController.requestReview()
                appRatingPrompt.shown()
            }
        }
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        url = webView.url
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        lastError = nil
        shouldReloadOnError = false
        hideErrorMessage()
        showProgressIndicator()
        detectedNewNavigation()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        onWebpageDidFinishLoading()
        instrumentation.didLoadURL()
        checkLoginDetectionAfterNavigation()
        detectedLoginURL = nil
    }
    
    private func onWebpageDidFinishLoading() {
        os_log("webpageLoading finished", log: generalLog, type: .debug)
        siteRating?.finishedLoading = true
        updateSiteRating()
        tabModel.link = link
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        delegate?.tabLoadingStateDidChange(tab: self)
        tips?.onFinishedLoading(url: url, error: isError)
    }
    
    private func detectedNewNavigation() {
        Pixel.fire(pixel: .navigationDetected)
    }

    private func checkLoginDetectionAfterNavigation() {
        
        guard let url = detectedLoginURL else {
            print("*** NO SIGN IN: no form detected")
            return
        }

        if self.url?.host != url.host || self.url?.path != url.path {
            view.showBottomToast("You just logged in to " + (url.host ?? "<unknown>") + " from " + (self.url?.host ?? "<unknown>"))
            detectedLoginURL = nil
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webpageDidFailToLoad()
        checkForReloadOnError()
    }

    private func webpageDidFailToLoad() {
        os_log("webpageLoading failed", log: generalLog, type: .debug)
        if isError {
            showBars(animated: true)
        }
        siteRating?.finishedLoading = true
        updateSiteRating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.delegate?.tabLoadingStateDidChange(tab: self)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        lastError = error
        let error = error as NSError
        
        // prevent loops where a site keeps redirecting to itself (e.g. bbc)
        if let url = url,
            let domain = url.host,
            error.code == Constants.frameLoadInterruptedErrorCode {
            failingUrls.insert(domain)
        }
        
        // wait before showing errors in case they recover automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showErrorNow()
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        self.url = url
        self.siteRating = makeSiteRating(url: url)
        updateSiteRating()
        detectedNewNavigation()
        checkLoginDetectionAfterNavigation()
    }
            
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print("*** ",
              #function,
              navigationAction.request.httpMethod ?? "<unknown method>",
              navigationAction.request.url?.absoluteString ?? "<unknown url>")
        
        decidePolicyFor(navigationAction: navigationAction) { [weak self] decision in
            if let url = navigationAction.request.url, decision != .cancel {
                if let isDdg = self?.appUrls.isDuckDuckGoSearch(url: url), isDdg {
                    StatisticsLoader.shared.refreshSearchRetentionAtb()
                }
                
                self?.findInPage?.done()
            }
            decisionHandler(decision)
        }
    }
    
    private func decidePolicyFor(navigationAction: WKNavigationAction, completion: @escaping (WKNavigationActionPolicy) -> Void) {
        let allowPolicy = determineAllowPolicy()
        
        let tld = storageCache.tld
        
        if navigationAction.isTargetingMainFrame()
            && tld.domain(navigationAction.request.mainDocumentURL?.host) != tld.domain(lastUpgradedURL?.host) {
            lastUpgradedURL = nil
        }
        
        guard navigationAction.request.mainDocumentURL != nil else {
            completion(allowPolicy)
            return
        }
        
        guard let url = navigationAction.request.url else {
            completion(allowPolicy)
            return
        }
        
        if isExternallyHandled(url: url, for: navigationAction) {
            completion(.cancel)
            return
        }
        
        if shouldReissueSearch(for: url) {
            reissueSearchWithStatsParams(for: url)
            completion(.cancel)
            return
        }
        
        if isNewTargetBlankRequest(navigationAction: navigationAction) {
            delegate?.tab(self, didRequestNewTabForUrl: url, openedByPage: true)
            completion(.cancel)
            return
        }
        
        if let domain = url.host, contentBlockerConfiguration.whitelisted(domain: domain) {
            completion(allowPolicy)
            return
        }

        httpsUpgrade.isUgradeable(url: url) { [weak self] isUpgradable in
            
            if isUpgradable, let upgradedUrl = self?.upgradeUrl(url, navigationAction: navigationAction) {
                NetworkLeaderboard.shared.incrementHttpsUpgrades()
                self?.lastUpgradedURL = upgradedUrl
                self?.load(url: upgradedUrl)
                completion(.cancel)
                return
            }

            completion(allowPolicy)
        }
    }
    
    private func isNewTargetBlankRequest(navigationAction: WKNavigationAction) -> Bool {
        return navigationAction.navigationType == .linkActivated && navigationAction.targetFrame == nil
    }

    private func determineAllowPolicy() -> WKNavigationActionPolicy {
        let allowWithoutUniversalLinks = WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2) ?? .allow
        return AppUserDefaults().allowUniversalLinks ? .allow : allowWithoutUniversalLinks
    }
    
    private func upgradeUrl(_ url: URL, navigationAction: WKNavigationAction) -> URL? {
        guard !failingUrls.contains(url.host ?? ""), navigationAction.isTargetingMainFrame() else { return nil }
        
        if let upgradedUrl: URL = url.toHttps(), lastUpgradedURL != upgradedUrl {
            return upgradedUrl
        }
        
        return nil
    }
    
    private func showErrorNow() {
        guard let error = lastError else { return }
        hideProgressIndicator()

        if !((error as NSError).failedUrl?.isCustomURLScheme() ?? false) {
            showError(message: error.localizedDescription)
        }

        webpageDidFailToLoad()
        checkForReloadOnError()
    }
}

extension TabViewController: PrivacyProtectionDelegate {
    func omniBarTextTapped() {
        chromeDelegate?.omniBar.becomeFirstResponder()
    }
}

extension TabViewController: WKUIDelegate {

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        return delegate?.tab(self, didRequestNewWebViewWithConfiguration: configuration, for: navigationAction)
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

}

extension TabViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension TabViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if isShowBarsTap(gestureRecognizer) {
            return true
        }
        if gestureRecognizer == longPressGestureRecognizer {
            let x = Int(gestureRecognizer.location(in: webView).x)
            let y = Int(gestureRecognizer.location(in: webView).y)
            let url = webView.getUrlAtPointSynchronously(x: x, y: y)
            return url != nil
        }
        return false
    }

    private func isShowBarsTap(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let y = gestureRecognizer.location(in: webView).y
        return gestureRecognizer == showBarsTapGestureRecogniser && chromeDelegate?.isToolbarHidden == true && isBottom(yPosition: y)
    }

    private func isBottom(yPosition y: CGFloat) -> Bool {
        guard let chromeDelegate = chromeDelegate else { return false }
        return y > (view.frame.size.height - chromeDelegate.toolbarHeight)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == showBarsTapGestureRecogniser || gestureRecognizer == longPressGestureRecognizer else {
            return false
        }

        if gestureRecognizer == showBarsTapGestureRecogniser,
            otherRecognizer is UITapGestureRecognizer {
            return true
        } else if gestureRecognizer == longPressGestureRecognizer,
            otherRecognizer is UILongPressGestureRecognizer || String(describing: otherRecognizer).contains("action=_highlightLongPressRecognized:") {
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
        if isError {
            if let url = URL(string: chromeDelegate?.omniBar.textField.text ?? "") {
                load(url: url)
            }
        } else {
            reload(scripts: false)
        }
    }
    
    // Prevents rare accidental display of preview previous to iOS 12
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return false
    }
    
}

extension TabViewController: Themable {

    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
        error?.backgroundColor = theme.backgroundColor
        errorHeader.textColor = theme.barTintColor
        errorMessage.textColor = theme.barTintColor
        
        switch theme.currentImageSet {
        case .light:
            errorInfoImage?.image = UIImage(named: "ErrorInfoLight")
        case .dark:
            errorInfoImage?.image = UIImage(named: "ErrorInfoDark")
        }
    }
    
}

extension NSError {

    var failedUrl: URL? {
        return userInfo[NSURLErrorFailingURLErrorKey] as? URL
    }

}

// swiftlint:enable file_length

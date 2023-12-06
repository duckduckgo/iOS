//
//  MainViewController.swift
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

import UIKit
import WebKit
import WidgetKit
import Combine
import Common
import Core
import DDGSync
import Kingfisher
import BrowserServicesKit
import Bookmarks
import Persistence
import PrivacyDashboard
import Networking

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class MainViewController: UIViewController {
// swiftlint:enable type_body_length

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        return isIPad ? [.left, .right] : []
    }

    weak var findInPageView: FindInPageView!
    weak var findInPageHeightLayoutConstraint: NSLayoutConstraint!
    weak var findInPageBottomLayoutConstraint: NSLayoutConstraint!

    weak var notificationView: NotificationView?

    var chromeManager: BrowserChromeManager!

    var allowContentUnderflow = false {
        didSet {
            viewCoordinator.constraints.contentContainerTop.constant = allowContentUnderflow ? contentUnderflow : 0
        }
    }
    
    var contentUnderflow: CGFloat {
        return 3 + (allowContentUnderflow ? -viewCoordinator.navigationBarContainer.frame.size.height : 0)
    }

    lazy var emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.aliasPermissionDelegate = self
        emailManager.requestDelegate = self
        return emailManager
    }()

    var homeController: HomeViewController?
    var tabsBarController: TabsBarViewController?
    var suggestionTrayController: SuggestionTrayViewController?

    var tabManager: TabManager!
    let previewsSource = TabPreviewsSource()
    let appSettings: AppSettings
    private var launchTabObserver: LaunchTabNotification.Observer?

#if APP_TRACKING_PROTECTION
    private let appTrackingProtectionDatabase: CoreDataDatabase
#endif

    let bookmarksDatabase: CoreDataDatabase
    private weak var bookmarksDatabaseCleaner: BookmarkDatabaseCleaner?
    private var favoritesViewModel: FavoritesListInteracting
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    private var localUpdatesCancellable: AnyCancellable?
    private var syncUpdatesCancellable: AnyCancellable?
    private var favoritesDisplayModeCancellable: AnyCancellable?
    private var emailCancellables = Set<AnyCancellable>()

    lazy var menuBookmarksViewModel: MenuBookmarksInteracting = {
        let viewModel = MenuBookmarksViewModel(bookmarksDatabase: bookmarksDatabase, syncService: syncService)
        viewModel.favoritesDisplayMode = appSettings.favoritesDisplayMode
        return viewModel
    }()

    weak var tabSwitcherController: TabSwitcherViewController?
    let tabSwitcherButton = TabSwitcherButton()
    
    /// Do not reference directly, use `presentedMenuButton`
    let menuButton = MenuButton()
    var presentedMenuButton: MenuButton {
        AppWidthObserver.shared.isLargeWidth ? viewCoordinator.omniBar.menuButtonContent : menuButton
    }
    
    let gestureBookmarksButton = GestureToolbarButton()
    
    private lazy var fireButtonAnimator: FireButtonAnimator = FireButtonAnimator(appSettings: appSettings)
    
    let bookmarksCachingSearch: BookmarksCachingSearch

    lazy var tabSwitcherTransition = TabSwitcherTransitionDelegate()
    var currentTab: TabViewController? {
        return tabManager?.current
    }

    var searchBarRect: CGRect {
        let view = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController?.view
        return viewCoordinator.omniBar.searchContainer.convert(viewCoordinator.omniBar.searchContainer.bounds, to: view)
    }

    var keyModifierFlags: UIKeyModifierFlags?
    var showKeyboardAfterFireButton: DispatchWorkItem?
    
    // Skip SERP flow (focusing on autocomplete logic) and prepare for new navigation when selecting search bar
    private var skipSERPFlow = true

    required init?(coder: NSCoder) {
        fatalError("Use init?(code:")
    }

    var viewCoordinator: MainViewCoordinator!

#if APP_TRACKING_PROTECTION
    init(
        bookmarksDatabase: CoreDataDatabase,
        bookmarksDatabaseCleaner: BookmarkDatabaseCleaner,
        appTrackingProtectionDatabase: CoreDataDatabase,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appSettings: AppSettings = AppUserDefaults()
    ) {
        self.appTrackingProtectionDatabase = appTrackingProtectionDatabase
        self.bookmarksDatabase = bookmarksDatabase
        self.bookmarksDatabaseCleaner = bookmarksDatabaseCleaner
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.favoritesViewModel = FavoritesListViewModel(bookmarksDatabase: bookmarksDatabase, favoritesDisplayMode: appSettings.favoritesDisplayMode)
        self.bookmarksCachingSearch = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: bookmarksDatabase))
        self.appSettings = appSettings

        super.init(nibName: nil, bundle: nil)

        bindFavoritesDisplayMode()
        bindSyncService()
    }
#else
    init(
        bookmarksDatabase: CoreDataDatabase,
        bookmarksDatabaseCleaner: BookmarkDatabaseCleaner,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appSettings: AppSettings
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.bookmarksDatabaseCleaner = bookmarksDatabaseCleaner
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.favoritesViewModel = FavoritesListViewModel(bookmarksDatabase: bookmarksDatabase, favoritesDisplayMode: appSettings.favoritesDisplayMode)
        self.bookmarksCachingSearch = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: bookmarksDatabase))
        self.appSettings = appSettings
        
        super.init(nibName: nil, bundle: nil)

        bindSyncService()
    }
#endif

    fileprivate var tabCountInfo: TabCountInfo?

    func loadFindInPage() {

        let view = FindInPageView.loadFromXib()
        self.view.addSubview(view)

        // Avoids coercion swiftlint warnings
        let superview = self.view!

        let height = view.constrainAttribute(.height, to: view.frame.height)
        let bottom = superview.constrainView(view, by: .bottom, to: .bottom)

        NSLayoutConstraint.activate([
            bottom,
            superview.constrainView(view, by: .width, to: .width),
            height,
            superview.constrainView(view, by: .centerX, to: .centerX)
        ])

        findInPageView = view
        findInPageBottomLayoutConstraint = bottom
        findInPageHeightLayoutConstraint = height
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewCoordinator = MainViewFactory.createViewHierarchy(self.view)
        viewCoordinator.moveAddressBarToPosition(appSettings.currentAddressBarPosition)

        viewCoordinator.toolbarBackButton.action = #selector(onBackPressed)
        viewCoordinator.toolbarForwardButton.action = #selector(onForwardPressed)
        viewCoordinator.toolbarFireButton.action = #selector(onFirePressed)

        loadSuggestionTray()
        loadTabsBarIfNeeded()
        loadFindInPage()
        attachOmniBar()

        view.addInteraction(UIDropInteraction(delegate: self))
        
        chromeManager = BrowserChromeManager()
        chromeManager.delegate = self
        initTabButton()
        initMenuButton()
        initBookmarksButton()
        configureTabManager()
        loadInitialView()
        previewsSource.prepare()
        addLaunchTabNotificationObserver()
        subscribeToEmailProtectionStatusNotifications()

        findInPageView.delegate = self
        findInPageBottomLayoutConstraint.constant = 0
        registerForKeyboardNotifications()
        registerForSyncPausedNotifications()

        applyTheme(ThemeManager.shared.currentTheme)

        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)

        _ = AppWidthObserver.shared.willResize(toWidth: view.frame.width)
        applyWidth()
        
        registerForApplicationEvents()
        registerForCookiesManagedNotification()
        registerForSettingsChangeNotifications()

        tabManager.cleanupTabsFaviconCache()

        refreshViewsBasedOnAddressBarPosition(appSettings.currentAddressBarPosition)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startOnboardingFlowIfNotSeenBefore()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        
        _ = AppWidthObserver.shared.willResize(toWidth: view.frame.width)
        applyWidth()

        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        assertionFailure()
        super.performSegue(withIdentifier: identifier, sender: sender)
    }

    func loadSuggestionTray() {
        let storyboard = UIStoryboard(name: "SuggestionTray", bundle: nil)

        guard let controller = storyboard.instantiateInitialViewController(creator: { coder in
            SuggestionTrayViewController(coder: coder,
                                         favoritesViewModel: self.favoritesViewModel,
                                         bookmarksSearch: self.bookmarksCachingSearch)
        }) else {
            assertionFailure()
            return
        }

        controller.view.frame = viewCoordinator.suggestionTrayContainer.bounds
        viewCoordinator.suggestionTrayContainer.addSubview(controller.view)

        controller.dismissHandler = dismissSuggestionTray
        controller.autocompleteDelegate = self
        controller.favoritesOverlayDelegate = self
        suggestionTrayController = controller
    }

    func loadTabsBarIfNeeded() {
        guard isPad else { return }

        let storyboard = UIStoryboard(name: "TabSwitcher", bundle: nil)
        let controller: TabsBarViewController = storyboard.instantiateViewController(identifier: "TabsBar")
        controller.view.frame = viewCoordinator.tabBarContainer.bounds
        controller.delegate = self
        viewCoordinator.tabBarContainer.addSubview(controller.view)
        tabsBarController = controller
    }

    func startAddFavoriteFlow() {
        DaxDialogs.shared.enableAddFavoriteFlow()
        if DefaultTutorialSettings().hasSeenOnboarding {
            newTab()
        }
    }
    
    func startOnboardingFlowIfNotSeenBefore() {
        
        guard ProcessInfo.processInfo.environment["ONBOARDING"] != "false" else {
            // explicitly skip onboarding, e.g. for integration tests
            return
        }
        
        let settings = DefaultTutorialSettings()
        let showOnboarding = !settings.hasSeenOnboarding ||
            // explicitly show onboarding, can be set in the scheme > Run > Environment Variables
            ProcessInfo.processInfo.environment["ONBOARDING"] == "true"
        guard showOnboarding else { return }

        segueToDaxOnboarding()

    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    private func registerForSyncPausedNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSyncPausedError),
            name: SyncBookmarksAdapter.bookmarksSyncLimitReached,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSyncPausedError),
            name: SyncCredentialsAdapter.credentialsSyncLimitReached,
            object: nil)
    }

    @objc private func showSyncPausedError(_ notification: Notification) {
        Task {
            await MainActor.run {
                var title = UserText.syncBookmarkPausedAlertTitle
                var description = UserText.syncBookmarkPausedAlertDescription
                if notification.name == SyncCredentialsAdapter.credentialsSyncLimitReached {
                    title = UserText.syncCredentialsPausedAlertTitle
                    description = UserText.syncCredentialsPausedAlertDescription
                }
                if self.presentedViewController is SyncSettingsViewController {
                    return
                }
                self.presentedViewController?.dismiss(animated: true)
                let alert = UIAlertController(title: title,
                                              message: description,
                                              preferredStyle: .alert)
                let learnMoreAction = UIAlertAction(title: UserText.syncPausedAlertLearnMoreButton, style: .default) { _ in
                    self.segueToSettingsSync()
                }
                let okAction = UIAlertAction(title: UserText.syncPausedAlertOkButton, style: .cancel)
                alert.addAction(learnMoreAction)
                alert.addAction(okAction)
                self.present(alert, animated: true)
            }
        }
    }

    func registerForSettingsChangeNotifications() {
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(onAddressBarPositionChanged),
                                               name: AppUserDefaults.Notifications.addressBarPositionChanged,
                                               object: nil)
    }

    @objc func onAddressBarPositionChanged() {
        viewCoordinator.moveAddressBarToPosition(appSettings.currentAddressBarPosition)
        refreshViewsBasedOnAddressBarPosition(appSettings.currentAddressBarPosition)
    }

    func refreshViewsBasedOnAddressBarPosition(_ position: AddressBarPosition) {
        switch position {
        case .top:
            viewCoordinator.omniBar.moveSeparatorToBottom()
            viewCoordinator.showToolbarSeparator()

        case .bottom:
            viewCoordinator.omniBar.moveSeparatorToTop()
            // If this is called before the toolbar has shown it will not re-add the separator when moving to the top position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewCoordinator.hideToolbarSeparator()
            }
        }

        let theme = ThemeManager.shared.currentTheme
        self.decorate(with: theme)
    }

    @objc func onShowFullSiteAddressChanged() {
        refreshOmniBar()
    }

    /// Based on https://stackoverflow.com/a/46117073/73479
    ///  Handles iPhone X devices properly.
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        var height = keyboardFrame.size.height

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        height = intersection.height

        findInPageBottomLayoutConstraint.constant = height
        currentTab?.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)

        if let suggestionsTray = suggestionTrayController {
            let suggestionsFrameInView = suggestionsTray.view.convert(suggestionsTray.contentFrame, to: view)
            
            let overflow = suggestionsFrameInView.size.height + suggestionsFrameInView.origin.y - keyboardFrameInView.origin.y + 10
            if overflow > 0 {
                suggestionTrayController?.applyContentInset(UIEdgeInsets(top: 0, left: 0, bottom: overflow, right: 0))
            } else {
                suggestionTrayController?.applyContentInset(.zero)
            }
        }

        let y = self.view.frame.height - height
        let frame = self.findInPageView.frame
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.findInPageView.frame = CGRect(x: 0, y: y - frame.height, width: frame.width, height: frame.height)
        }, completion: nil)

        if self.appSettings.currentAddressBarPosition.isBottom {
            let navBarOffset = min(0, self.toolbarHeight - intersection.height)
            self.viewCoordinator.constraints.omniBarBottom.constant = navBarOffset
            UIView.animate(withDuration: duration, delay: 0, options: animationCurve) {
                self.viewCoordinator.navigationBarContainer.superview?.layoutIfNeeded()
            }
        }

    }

    private func initTabButton() {
        tabSwitcherButton.delegate = self
        viewCoordinator.toolbarTabSwitcherButton.customView = tabSwitcherButton
        viewCoordinator.toolbarTabSwitcherButton.isAccessibilityElement = true
        viewCoordinator.toolbarTabSwitcherButton.accessibilityTraits = .button
    }
    
    private func initMenuButton() {
        viewCoordinator.lastToolbarButton.customView = menuButton
        viewCoordinator.lastToolbarButton.isAccessibilityElement = true
        viewCoordinator.lastToolbarButton.accessibilityTraits = .button
        
        menuButton.delegate = self
    }
    
    private func initBookmarksButton() {
        viewCoordinator.omniBar.bookmarksButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                                  action: #selector(quickSaveBookmarkLongPress(gesture:))))
        gestureBookmarksButton.delegate = self
        gestureBookmarksButton.image = UIImage(named: "Bookmarks")
    }

    private func bindFavoritesDisplayMode() {
        favoritesDisplayModeCancellable = NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.favoritesDisplayModeChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                self.menuBookmarksViewModel.favoritesDisplayMode = self.appSettings.favoritesDisplayMode
                self.favoritesViewModel.favoritesDisplayMode = self.appSettings.favoritesDisplayMode
                self.homeController?.collectionView.reloadData()
                WidgetCenter.shared.reloadAllTimelines()
            }
    }

    private func bindSyncService() {
        localUpdatesCancellable = favoritesViewModel.localUpdates
            .sink { [weak self] in
                self?.syncService.scheduler.notifyDataChanged()
            }

        syncUpdatesCancellable = syncDataProviders.bookmarksAdapter.syncDidCompletePublisher
            .sink { [weak self] _ in
                self?.favoritesViewModel.reloadData()
                DispatchQueue.main.async {
                    self?.homeController?.collectionView.reloadData()
                }
            }
    }

    @objc func quickSaveBookmarkLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            quickSaveBookmark()
        }
    }

    @objc func quickSaveBookmark() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        guard currentTab != nil else {
            ActionMessageView.present(message: UserText.webSaveBookmarkNone,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: appSettings.currentAddressBarPosition.isBottom))
            return
        }
        
        Pixel.fire(pixel: .tabBarBookmarksLongPressed)
        currentTab?.saveAsBookmark(favorite: true, viewModel: menuBookmarksViewModel)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            ThemeManager.shared.refreshSystemTheme()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedViewController {
            return presentedViewController.supportedInterfaceOrientations
        }
        return DefaultTutorialSettings().hasSeenOnboarding ? [.allButUpsideDown] : [.portrait]
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    @objc func dismissSuggestionTray() {
        dismissOmniBar()
    }

    private func configureTabManager() {

        let isPadDevice = UIDevice.current.userInterfaceIdiom == .pad

        let tabsModel: TabsModel
        let shouldClearTabsModelOnStartup = AutoClearSettingsModel(settings: appSettings) != nil
        if shouldClearTabsModelOnStartup {
            tabsModel = TabsModel(desktop: isPadDevice)
            tabsModel.save()
            previewsSource.removeAllPreviews()
        } else {
            if let storedModel = TabsModel.get() {
                // Save new model in case of migration
                storedModel.save()
                tabsModel = storedModel
            } else {
                tabsModel = TabsModel(desktop: isPadDevice)
            }
        }
        tabManager = TabManager(model: tabsModel,
                                previewsSource: previewsSource,
                                bookmarksDatabase: bookmarksDatabase,
                                syncService: syncService,
                                delegate: self)
    }

    private func addLaunchTabNotificationObserver() {
        launchTabObserver = LaunchTabNotification.addObserver(handler: { [weak self] urlString in
            guard let self = self else { return }
            if let url = URL(string: urlString) {
                self.loadUrlInNewTab(url, inheritedAttribution: nil)
            } else {
                self.loadQuery(urlString)
            }
        })
    }

    private func loadInitialView() {
        if let tab = currentTab, tab.link != nil {
            addToView(tab: tab)
            refreshControls()
        } else {
            attachHomeScreen()
        }
    }

    func handlePressEvent(event: UIPressesEvent?) {
        keyModifierFlags = event?.modifierFlags
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        handlePressEvent(event: event)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        handlePressEvent(event: event)
    }

    private func attachOmniBar() {
        viewCoordinator.omniBar.omniDelegate = self
        viewCoordinator.omniBar.menuButtonContent.delegate = self
    }
    
    fileprivate func attachHomeScreen() {
        viewCoordinator.logoContainer.isHidden = false
        findInPageView.isHidden = true
        chromeManager.detach()
        
        currentTab?.dismiss()
        removeHomeScreen()
        AppDependencyProvider.shared.homePageConfiguration.refresh()

        let tabModel = currentTab?.tabModel

#if APP_TRACKING_PROTECTION
        let controller = HomeViewController.loadFromStoryboard(model: tabModel!,
                                                               favoritesViewModel: favoritesViewModel,
                                                               appSettings: appSettings,
                                                               syncService: syncService,
                                                               syncDataProviders: syncDataProviders,
                                                               appTPDatabase: appTrackingProtectionDatabase)
#else
        let controller = HomeViewController.loadFromStoryboard(model: tabModel!,
                                                               favoritesViewModel: favoritesViewModel,
                                                               appSettings: appSettings,
                                                               syncService: syncService,
                                                               syncDataProviders: syncDataProviders)
#endif

        homeController = controller

        controller.chromeDelegate = self
        controller.delegate = self

        addToView(controller: controller)

        refreshControls()
        syncService.scheduler.requestSyncImmediately()
    }

    fileprivate func removeHomeScreen() {
        homeController?.willMove(toParent: nil)
        homeController?.dismiss()
        homeController = nil
    }

    @IBAction func onFirePressed() {
        Pixel.fire(pixel: .forgetAllPressedBrowsing)
        
        wakeLazyFireButtonAnimator()
        
        if let spec = DaxDialogs.shared.fireButtonEducationMessage() {
            segueToActionSheetDaxDialogWithSpec(spec)
        } else {
            let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
                self?.forgetAllWithAnimation {}
            })
            self.present(controller: alert, fromView: self.viewCoordinator.toolbar)
        }
    }
    
    func onQuickFirePressed() {
        wakeLazyFireButtonAnimator()
        
        forgetAllWithAnimation {}
        dismiss(animated: true)
        if KeyboardSettings().onAppLaunch {
            enterSearch()
        }
    }
    
    private func wakeLazyFireButtonAnimator() {
        DispatchQueue.main.async {
            _ = self.fireButtonAnimator
        }
    }

    @IBAction func onBackPressed() {
        Pixel.fire(pixel: .tabBarBackPressed)
        currentTab?.goBack()
        refreshOmniBar()
    }

    @IBAction func onForwardPressed() {
        Pixel.fire(pixel: .tabBarForwardPressed)
        currentTab?.goForward()
    }
    
    func didReturnFromBackground() {
        skipSERPFlow = true
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    func loadQueryInNewTab(_ query: String, reuseExisting: Bool = false) {
        dismissOmniBar()
        guard let url = URL.makeSearchURL(query: query) else {
            os_log("Couldn‘t form URL for query “%s”", log: .lifecycleLog, type: .error, query)
            return
        }
        loadUrlInNewTab(url, reuseExisting: reuseExisting, inheritedAttribution: nil)
    }

    func loadUrlInNewTab(_ url: URL, reuseExisting: Bool = false, inheritedAttribution: AdClickAttributionLogic.State?) {
        allowContentUnderflow = false
        viewCoordinator.navigationBarContainer.alpha = 1
        loadViewIfNeeded()
        if reuseExisting, let existing = tabManager.first(withUrl: url) {
            selectTab(existing)
            return
        } else if reuseExisting, let existing = tabManager.firstHomeTab() {
            tabManager.selectTab(existing)
            loadUrl(url)
        } else {
            addTab(url: url, inheritedAttribution: inheritedAttribution)
        }
        refreshOmniBar()
        refreshTabIcon()
        refreshControls()
        tabsBarController?.refresh(tabsModel: tabManager.model)
    }
    
    func enterSearch() {
        if presentedViewController == nil {
            showBars()
            viewCoordinator.omniBar.becomeFirstResponder()
        }
    }

    fileprivate func loadQuery(_ query: String) {
        guard let url = URL.makeSearchURL(query: query, queryContext: currentTab?.url) else {
            os_log("Couldn‘t form URL for query “%s” with context “%s”",
                   log: .lifecycleLog,
                   type: .error,
                   query,
                   currentTab?.url?.absoluteString ?? "<nil>")
            return
        }
        loadUrl(url)
    }

    func loadUrl(_ url: URL) {
        prepareTabForRequest {
            currentTab?.load(url: url)
        }
    }

    func executeBookmarklet(_ url: URL) {
        if url.isBookmarklet() {
            currentTab?.executeBookmarklet(url: url)
        }
    }
    
    private func loadBackForwardItem(_ item: WKBackForwardListItem) {
        prepareTabForRequest {
            currentTab?.load(backForwardListItem: item)
        }
    }
    
    private func prepareTabForRequest(request: () -> Void) {
        viewCoordinator.navigationBarContainer.alpha = 1
        allowContentUnderflow = false
        request()
        guard let tab = currentTab else { fatalError("no tab") }
        dismissOmniBar()
        select(tab: tab)
    }

    private func addTab(url: URL?, inheritedAttribution: AdClickAttributionLogic.State?) {
        let tab = tabManager.add(url: url, inheritedAttribution: inheritedAttribution)
        dismissOmniBar()
        addToView(tab: tab)
    }

    func select(tabAt index: Int) {
        viewCoordinator.navigationBarContainer.alpha = 1
        allowContentUnderflow = false
        let tab = tabManager.select(tabAt: index)
        select(tab: tab)
    }

    fileprivate func select(tab: TabViewController) {
        if tab.link == nil {
            attachHomeScreen()
        } else {
            addToView(tab: tab)
            refreshControls()
        }
        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    private func addToView(tab: TabViewController) {
        removeHomeScreen()
        updateFindInPage()
        currentTab?.progressWorker.progressBar = nil
        currentTab?.chromeDelegate = nil
        addToView(controller: tab)
        tab.progressWorker.progressBar = viewCoordinator.progress
        chromeManager.attach(to: tab.webView.scrollView)
        tab.chromeDelegate = self
    }

    private func addToView(controller: UIViewController) {
        addChild(controller)
        viewCoordinator.contentContainer.subviews.forEach { $0.removeFromSuperview() }
        viewCoordinator.contentContainer.addSubview(controller.view)
        controller.view.frame = viewCoordinator.contentContainer.bounds
        controller.didMove(toParent: self)

    }

    fileprivate func updateCurrentTab() {
        if let currentTab = currentTab {
            select(tab: currentTab)
            viewCoordinator.omniBar.resignFirstResponder()
        } else {
            attachHomeScreen()
        }
    }

    fileprivate func refreshControls() {
        refreshTabIcon()
        refreshMenuButtonState()
        refreshOmniBar()
        refreshBackForwardButtons()
        refreshBackForwardMenuItems()
    }

    private func refreshTabIcon() {
        viewCoordinator.toolbarTabSwitcherButton.accessibilityHint = UserText.numberOfTabs(tabManager.count)
        tabSwitcherButton.tabCount = tabManager.count
        tabSwitcherButton.hasUnread = tabManager.hasUnread
    }

    private func refreshOmniBar() {
        guard let tab = currentTab, tab.link != nil else {
            viewCoordinator.omniBar.stopBrowsing()
            return
        }

        viewCoordinator.omniBar.refreshText(forUrl: tab.url)

        if tab.isError {
            viewCoordinator.omniBar.hidePrivacyIcon()
        } else if let privacyInfo = tab.privacyInfo, privacyInfo.url.host == tab.url?.host {
            viewCoordinator.omniBar.updatePrivacyIcon(for: privacyInfo)
        } else {
            viewCoordinator.omniBar.resetPrivacyIcon(for: tab.url)
        }
            
        viewCoordinator.omniBar.startBrowsing()
    }

    func dismissOmniBar() {
        viewCoordinator.omniBar.resignFirstResponder()
        hideSuggestionTray()
        refreshOmniBar()
    }

    fileprivate func refreshBackForwardButtons() {
        viewCoordinator.toolbarBackButton.isEnabled = currentTab?.canGoBack ?? false
        viewCoordinator.toolbarForwardButton.isEnabled = currentTab?.canGoForward ?? false
        
        viewCoordinator.omniBar.backButton.isEnabled = viewCoordinator.toolbarBackButton.isEnabled
        viewCoordinator.omniBar.forwardButton.isEnabled = viewCoordinator.toolbarForwardButton.isEnabled
    }
  
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if AppWidthObserver.shared.willResize(toWidth: size.width) {
            applyWidth()
        }

        self.showMenuHighlighterIfNeeded()
        
        coordinator.animate(alongsideTransition: nil) { _ in
            ViewHighlighter.updatePositions()
        }
    }
    
    private func applyWidth() {

        if AppWidthObserver.shared.isLargeWidth {
            applyLargeWidth()
        } else {
            applySmallWidth()
        }

        applyTheme(ThemeManager.shared.currentTheme)

        DispatchQueue.main.async {
            // Do this async otherwise the toolbar buttons skew to the right
            if self.viewCoordinator.constraints.navigationBarContainerTop.constant >= 0 {
                self.showBars()
            }
            // If tabs have been udpated, do this async to make sure size calcs are current
            self.tabsBarController?.refresh(tabsModel: self.tabManager.model)
            
            // Do this on the next UI thread pass so we definitely have the right width
            self.applyWidthToTrayController()
            
            self.refreshMenuButtonState()
        }
    }

    func refreshMenuButtonState() {
        let expectedState: MenuButton.State
        if homeController != nil {
            expectedState = .bookmarksImage
            viewCoordinator.lastToolbarButton.accessibilityLabel = UserText.bookmarksButtonHint
            viewCoordinator.omniBar.menuButton.accessibilityLabel = UserText.bookmarksButtonHint

        } else {
            if presentedViewController is BrowsingMenuViewController {
                expectedState = .closeImage
            } else {
                expectedState = .menuImage
            }
            viewCoordinator.lastToolbarButton.accessibilityLabel = UserText.menuButtonHint
            viewCoordinator.omniBar.menuButton.accessibilityLabel = UserText.menuButtonHint
        }

        presentedMenuButton.decorate(with: ThemeManager.shared.currentTheme)
        presentedMenuButton.setState(expectedState, animated: false)
    }

    private func applyWidthToTrayController() {
        if AppWidthObserver.shared.isLargeWidth {
            self.suggestionTrayController?.float(withWidth: self.viewCoordinator.omniBar.searchStackContainer.frame.width + 24)
        } else {
            self.suggestionTrayController?.fill()
        }
    }
    
    private func applyLargeWidth() {
        viewCoordinator.tabBarContainer.isHidden = false
        viewCoordinator.toolbar.isHidden = true
        viewCoordinator.omniBar.enterPadState()
    }

    private func applySmallWidth() {
        viewCoordinator.tabBarContainer.isHidden = true
        viewCoordinator.toolbar.isHidden = false
        viewCoordinator.omniBar.enterPhoneState()
    }

    @discardableResult
    func tryToShowSuggestionTray(_ type: SuggestionTrayViewController.SuggestionType) -> Bool {
        let canShow = suggestionTrayController?.canShow(for: type) ?? false
        if canShow {
            showSuggestionTray(type)
        }
        return canShow
    }
    
    private func showSuggestionTray(_ type: SuggestionTrayViewController.SuggestionType) {
        suggestionTrayController?.show(for: type)
        applyWidthToTrayController()
        if !AppWidthObserver.shared.isLargeWidth {
            if !DaxDialogs.shared.shouldShowFireButtonPulse {
                ViewHighlighter.hideAll()
            }
            if type.hideOmnibarSeparator() && appSettings.currentAddressBarPosition != .bottom {
                viewCoordinator.omniBar.hideSeparator()
            }
        }
        viewCoordinator.suggestionTrayContainer.isHidden = false
        currentTab?.webView.accessibilityElementsHidden = true
    }
    
    func hideSuggestionTray() {
        viewCoordinator.omniBar.showSeparator()
        viewCoordinator.suggestionTrayContainer.isHidden = true
        currentTab?.webView.accessibilityElementsHidden = false
        suggestionTrayController?.didHide()
    }
    
    func launchAutofillLogins(with currentTabUrl: URL? = nil) {
        let appSettings = AppDependencyProvider.shared.appSettings
        let autofillSettingsViewController = AutofillLoginSettingsListViewController(
            appSettings: appSettings,
            currentTabUrl: currentTabUrl,
            syncService: syncService,
            syncDataProviders: syncDataProviders
        )
        autofillSettingsViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: autofillSettingsViewController)
        autofillSettingsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: UserText.autofillNavigationButtonItemTitleClose,
                                                                                          style: .plain,
                                                                                          target: self,
                                                                                          action: #selector(closeAutofillModal))
        self.present(navigationController, animated: true, completion: nil)

        if let account = AppDependencyProvider.shared.autofillLoginSession.lastAccessedAccount {
            autofillSettingsViewController.showAccountDetails(account, animated: true)
        }
    }
    
    @objc private func closeAutofillModal() {
        dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notificationView?.layoutSubviews()
        let height = notificationView?.frame.size.height ?? 0
        viewCoordinator.constraints.notificationContainerHeight.constant = height
        ViewHighlighter.updatePositions()
    }

    func showNotification(title: String, message: String, dismissHandler: @escaping NotificationView.DismissHandler) {

        let notificationView = NotificationView.loadFromNib(dismissHandler: dismissHandler)

        notificationView.setTitle(text: title)
        notificationView.setMessage(text: message)
        viewCoordinator.notificationBarContainer.addSubview(notificationView)
        self.notificationView = notificationView

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.viewCoordinator.constraints.notificationContainerHeight.constant = notificationView.frame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }

    }

    func hideNotification() {

        viewCoordinator.constraints.notificationContainerHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            if let frame = self.notificationView?.frame {
                self.notificationView?.frame = frame.offsetBy(dx: 0, dy: -frame.height)
            }
            self.view.layoutSubviews()
        }, completion: { _ in
            self.notificationView?.removeFromSuperview()
        })

    }

    func showHomeRowReminder() {
        let feature = HomeRowReminder()
        if feature.showNow() {
            showNotification(title: UserText.homeRowReminderTitle, message: UserText.homeRowReminderMessage) { tapped in
                if tapped {
                    self.segueToHomeRow()
                }
                self.hideNotification()
            }
            feature.setShown()
        }
    }

    func animateBackgroundTab() {
        showBars()
        tabSwitcherButton.incrementAnimated()
        tabsBarController?.backgroundTabAdded()
    }

    func newTab(reuseExisting: Bool = false, allowingKeyboard: Bool = true) {
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        DaxDialogs.shared.fireButtonPulseCancelled()
        hideSuggestionTray()
        currentTab?.dismiss()

        if reuseExisting, let existing = tabManager.firstHomeTab() {
            tabManager.selectTab(existing)
        } else {
            tabManager.addHomeTab()
        }
        attachHomeScreen()
        homeController?.openedAsNewTab(allowingKeyboard: allowingKeyboard)
        tabsBarController?.refresh(tabsModel: tabManager.model)
    }
    
    func animateLogoAppearance() {
        viewCoordinator.logoContainer.alpha = 0
        viewCoordinator.logoContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.2) {
                self.viewCoordinator.logoContainer.alpha = 1
                self.viewCoordinator.logoContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func updateFindInPage() {
        currentTab?.findInPage?.delegate = self
        findInPageView.update(with: currentTab?.findInPage, updateTextField: true)
        // hide toolbar on iPhone
        viewCoordinator.toolbar.accessibilityElementsHidden = !AppWidthObserver.shared.isLargeWidth
    }
    
    private func showVoiceSearch() {
        // https://app.asana.com/0/0/1201408131067987
        UIMenuController.shared.hideMenu()
        viewCoordinator.omniBar.removeTextSelection()
        
        Pixel.fire(pixel: .openVoiceSearch)
        let voiceSearchController = VoiceSearchViewController()
        voiceSearchController.delegate = self
        voiceSearchController.modalTransitionStyle = .crossDissolve
        voiceSearchController.modalPresentationStyle = .overFullScreen
        present(voiceSearchController, animated: true, completion: nil)
    }
    
    private func showNoMicrophonePermissionAlert() {
        let alertController = NoMicPermissionAlert.buildAlert()
        present(alertController, animated: true, completion: nil)
    }
    
    private func subscribeToEmailProtectionStatusNotifications() {
        NotificationCenter.default.publisher(for: .emailDidSignIn)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onDuckDuckGoEmailSignIn(notification)
            }
            .store(in: &emailCancellables)

        NotificationCenter.default.publisher(for: .emailDidSignOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onDuckDuckGoEmailSignOut(notification)
            }
            .store(in: &emailCancellables)
    }

    @objc
    private func onDuckDuckGoEmailSignIn(_ notification: Notification) {
        fireEmailPixel(.emailEnabled, notification: notification)
        if let object = notification.object as? EmailManager,
           let emailManager = syncDataProviders.settingsAdapter.emailManager,
           object !== emailManager {

            syncService.scheduler.notifyDataChanged()
        }
    }
    
    @objc
    private func onDuckDuckGoEmailSignOut(_ notification: Notification) {
        fireEmailPixel(.emailDisabled, notification: notification)
        presentEmailProtectionSignInAlertIfNeeded(notification)
        if let object = notification.object as? EmailManager,
           let emailManager = syncDataProviders.settingsAdapter.emailManager,
           object !== emailManager {

            syncService.scheduler.notifyDataChanged()
        }
    }

    private func presentEmailProtectionSignInAlertIfNeeded(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String],
            userInfo[EmailManager.NotificationParameter.isForcedSignOut] != nil else {
            return
        }
        let alertController = CriticalAlerts.makeEmailProtectionSignInAlert()
        dismiss(animated: true) {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func fireEmailPixel(_ pixel: Pixel.Event, notification: Notification) {
        var pixelParameters: [String: String] = [:]
        
        if let userInfo = notification.userInfo as? [String: String], let cohort = userInfo[EmailManager.NotificationParameter.cohort] {
            pixelParameters[PixelParameters.emailCohort] = cohort
        }
        
        Pixel.fire(pixel: pixel, withAdditionalParameters: pixelParameters, includedParameters: [.atb])
    }
    
}

extension MainViewController: FindInPageDelegate {
    
    func updated(findInPage: FindInPage) {
        findInPageView.update(with: findInPage, updateTextField: false)
    }

}

extension MainViewController: FindInPageViewDelegate {
    
    func done(findInPageView: FindInPageView) {
        currentTab?.findInPage = nil
        viewCoordinator.toolbar.accessibilityElementsHidden = false
    }
    
}

extension MainViewController: BrowserChromeDelegate {

    struct ChromeAnimationConstants {
        static let duration = 0.1
    }

    var tabBarContainer: UIView {
        viewCoordinator.tabBarContainer
    }

    var omniBar: OmniBar {
        viewCoordinator.omniBar
    }

    private func hideKeyboard() {
        dismissOmniBar()
        _ = findInPageView.resignFirstResponder()
    }

    func setBarsHidden(_ hidden: Bool, animated: Bool) {
        if hidden { hideKeyboard() }

        setBarsVisibility(hidden ? 0 : 1.0, animated: animated)
    }
    
    func setBarsVisibility(_ percent: CGFloat, animated: Bool = false) {
        if percent < 1 {
            hideKeyboard()
            hideMenuHighlighter()
        } else {
            showMenuHighlighterIfNeeded()
        }
        
        let updateBlock = {
            self.updateToolbarConstant(percent)
            self.updateNavBarConstant(percent)
            
            self.view.layoutIfNeeded()
            
            self.viewCoordinator.omniBar.alpha = percent
            self.viewCoordinator.tabBarContainer.alpha = percent
            self.viewCoordinator.toolbar.alpha = percent
        }
        
        if animated {
            UIView.animate(withDuration: ChromeAnimationConstants.duration, animations: updateBlock)
        } else {
            updateBlock()
        }
    }

    func setNavigationBarHidden(_ hidden: Bool) {
        if hidden { hideKeyboard() }
        
        updateNavBarConstant(hidden ? 0 : 1.0)
        viewCoordinator.omniBar.alpha = hidden ? 0 : 1
        viewCoordinator.tabBarContainer.alpha = hidden ? 0 : 1
        viewCoordinator.statusBackground.alpha = hidden ? 0 : 1
    }
    
    var canHideBars: Bool {
        return !DaxDialogs.shared.shouldShowFireButtonPulse
    }

    var isToolbarHidden: Bool {
        return viewCoordinator.toolbar.alpha < 1
    }

    var toolbarHeight: CGFloat {
        return viewCoordinator.toolbar.frame.size.height
    }
    
    var barsMaxHeight: CGFloat {
        return max(toolbarHeight, viewCoordinator.omniBar.frame.size.height)
    }

    // 1.0 - full size, 0.0 - hidden
    private func updateToolbarConstant(_ ratio: CGFloat) {
        var bottomHeight = toolbarHeight
        bottomHeight += view.safeAreaInsets.bottom
        let multiplier = viewCoordinator.toolbar.isHidden ? 1.0 : 1.0 - ratio
        viewCoordinator.constraints.toolbarBottom.constant = bottomHeight * multiplier
        findInPageHeightLayoutConstraint.constant = findInPageView.container.frame.height + view.safeAreaInsets.bottom
    }

    // 1.0 - full size, 0.0 - hidden
    private func updateNavBarConstant(_ ratio: CGFloat) {
        let browserTabsOffset = (viewCoordinator.tabBarContainer.isHidden ? 0 : viewCoordinator.tabBarContainer.frame.size.height)
        let navBarTopOffset = viewCoordinator.navigationBarContainer.frame.size.height + browserTabsOffset
        if !viewCoordinator.tabBarContainer.isHidden {
            let topBarsConstant = -browserTabsOffset * (1.0 - ratio)
            viewCoordinator.constraints.tabBarContainerTop.constant = topBarsConstant
        }
        viewCoordinator.constraints.navigationBarContainerTop.constant = browserTabsOffset + -navBarTopOffset * (1.0 - ratio)
    }

}

extension MainViewController: OmniBarDelegate {

    func selectedSuggestion() -> Suggestion? {
        return suggestionTrayController?.selectedSuggestion
    }

    func onOmniSuggestionSelected(_ suggestion: Suggestion) {
        autocomplete(selectedSuggestion: suggestion)
    }

    func onOmniQueryUpdated(_ updatedQuery: String) {
        if updatedQuery.isEmpty {
            if homeController != nil {
                hideSuggestionTray()
            } else {
                let didShow = tryToShowSuggestionTray(.favorites)
                if !didShow {
                    hideSuggestionTray()
                }
            }
        } else {
            tryToShowSuggestionTray(.autocomplete(query: updatedQuery))
        }
        
    }

    func onOmniQuerySubmitted(_ query: String) {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        loadQuery(query)
        hideSuggestionTray()
        showHomeRowReminder()
    }

    func onPrivacyIconPressed() {
        guard !isSERPPresented else { return }

        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        hideSuggestionTray()
        currentTab?.showPrivacyDashboard()
    }

    func onMenuPressed() {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        hideSuggestionTray()
        ActionMessageView.dismissAllMessages()
        Task {
            await launchBrowsingMenu()
        }
    }

    @MainActor
    private func launchBrowsingMenu() async {
        guard let tab = currentTab else { return }

        let entries = tab.buildBrowsingMenu(with: menuBookmarksViewModel)
        let controller = BrowsingMenuViewController.instantiate(headerEntries: tab.buildBrowsingMenuHeaderContent(),
                                                                menuEntries: entries)

        controller.modalPresentationStyle = .custom
        self.present(controller, animated: true) {
            if self.canDisplayAddFavoriteVisualIndicator {
                controller.highlightCell(atIndex: IndexPath(row: tab.favoriteEntryIndex, section: 0))
            }
        }

        self.presentedMenuButton.setState(.closeImage, animated: true)
        tab.didLaunchBrowsingMenu()
    }
    
    @objc func onBookmarksPressed() {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        hideSuggestionTray()
        segueToBookmarks()
    }
    
    func onBookmarkEdit() {
        ViewHighlighter.hideAll()
        hideSuggestionTray()
        segueToEditCurrentBookmark()
    }
    
    func onEnterPressed() {
        guard !viewCoordinator.suggestionTrayContainer.isHidden else { return }
        
        suggestionTrayController?.willDismiss(with: viewCoordinator.omniBar.textField.text ?? "")
    }

    func onDismissed() {
        dismissOmniBar()
    }

    func onSettingsPressed() {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        segueToSettings()
    }
    
    func onCancelPressed() {
        dismissOmniBar()
        hideSuggestionTray()
        homeController?.omniBarCancelPressed()
        self.showMenuHighlighterIfNeeded()
    }
    
    private var isSERPPresented: Bool {
        guard let tabURL = currentTab?.url else { return false }
        return tabURL.isDuckDuckGoSearch
    }
    
    func onTextFieldWillBeginEditing(_ omniBar: OmniBar) {
        guard homeController == nil else { return }
        
        if !skipSERPFlow, isSERPPresented, let query = omniBar.textField.text {
            tryToShowSuggestionTray(.autocomplete(query: query))
        } else {
            tryToShowSuggestionTray(.favorites)
        }
    }

    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) -> Bool {
        let selectQueryText = !(isSERPPresented && !skipSERPFlow)
        skipSERPFlow = false
        
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        guard let homeController = homeController else {
            return selectQueryText
        }
        homeController.launchNewSearch()
        return selectQueryText
    }
    
    func onRefreshPressed() {
        hideSuggestionTray()
        currentTab?.refresh()
    }
    
    func onSharePressed() {
        hideSuggestionTray()
        guard let link = currentTab?.link else { return }
        currentTab?.onShareAction(forLink: link, fromView: viewCoordinator.omniBar.shareButton)
    }
    
    func onVoiceSearchPressed() {
        SpeechRecognizer.requestMicAccess { permission in
            if permission {
                self.showVoiceSearch()
            } else {
                self.showNoMicrophonePermissionAlert()
            }
        }
    }
}

extension MainViewController: FavoritesOverlayDelegate {
    
    func favoritesOverlay(_ overlay: FavoritesOverlay, didSelect favorite: BookmarkEntity) {
        guard let url = favorite.urlObject else { return }
        Pixel.fire(pixel: .homeScreenFavouriteLaunched)
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .fireproof, fromCache: .tabs)
        if url.isBookmarklet() {
            executeBookmarklet(url)
        } else {
            loadUrl(url)
        }
        showHomeRowReminder()
    }

}

extension MainViewController: AutocompleteViewControllerDelegate {

    func autocomplete(selectedSuggestion suggestion: Suggestion) {
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        if let url = suggestion.url {
            if url.isBookmarklet() {
                executeBookmarklet(url)
            } else {
                loadUrl(url)
            }
        } else if let url = URL.makeSearchURL(text: suggestion.suggestion) {
            loadUrl(url)
        } else {
            os_log("Couldn‘t form URL for suggestion “%s”", log: .lifecycleLog, type: .error, suggestion.suggestion)
            return
        }
        showHomeRowReminder()
    }

    func autocomplete(pressedPlusButtonForSuggestion suggestion: Suggestion) {
        if let url = suggestion.url {
            if url.isDuckDuckGoSearch {
                viewCoordinator.omniBar.textField.text = suggestion.suggestion
            } else if !url.isBookmarklet() {
                viewCoordinator.omniBar.textField.text = url.absoluteString
            }
        } else {
            viewCoordinator.omniBar.textField.text = suggestion.suggestion
        }
        viewCoordinator.omniBar.textDidChange()
    }
    
    func autocomplete(highlighted suggestion: Suggestion, for query: String) {
        if let url = suggestion.url {
            viewCoordinator.omniBar.textField.text = url.absoluteString
        } else {
            viewCoordinator.omniBar.textField.text = suggestion.suggestion
            if suggestion.suggestion.hasPrefix(query) {
                viewCoordinator.omniBar.selectTextToEnd(query.count)
            }
        }
    }

    func autocompleteWasDismissed() {
        dismissOmniBar()
    }

}

extension MainViewController: HomeControllerDelegate {
    
    func home(_ home: HomeViewController, didRequestQuery query: String) {
        loadQueryInNewTab(query)
    }

    func home(_ home: HomeViewController, didRequestUrl url: URL) {
        showKeyboardAfterFireButton?.cancel()
        
        if url.isBookmarklet() {
            executeBookmarklet(url)
        } else {
            loadUrl(url)
        }
    }
    
    func home(_ home: HomeViewController, didRequestEdit favorite: BookmarkEntity) {
        segueToEditBookmark(favorite)
    }
    
    func home(_ home: HomeViewController, didRequestContentOverflow shouldOverflow: Bool) -> CGFloat {
        allowContentUnderflow = shouldOverflow
        return contentUnderflow
    }

    func homeDidDeactivateOmniBar(home: HomeViewController) {
        hideSuggestionTray()
        dismissOmniBar()
    }
    
    func showSettings(_ home: HomeViewController) {
        segueToSettings()
    }
    
    func home(_ home: HomeViewController, didRequestHideLogo hidden: Bool) {
        viewCoordinator.logoContainer.isHidden = hidden
    }
    
    func homeDidRequestLogoContainer(_ home: HomeViewController) -> UIView {
        return viewCoordinator.logoContainer
    }
    
    func home(_ home: HomeViewController, searchTransitionUpdated percent: CGFloat) {
        viewCoordinator.statusBackground.alpha = percent
        viewCoordinator.navigationBarContainer.alpha = percent
    }
    
}

extension MainViewController: TabDelegate {
    
    func tab(_ tab: TabViewController,
             didRequestNewWebViewWithConfiguration configuration: WKWebViewConfiguration,
             for navigationAction: WKNavigationAction,
             inheritingAttribution: AdClickAttributionLogic.State?) -> WKWebView? {

        showBars()
        currentTab?.dismiss()

        let newTab = tabManager.addURLRequest(navigationAction.request,
                                              with: configuration,
                                              inheritedAttribution: inheritingAttribution)
        newTab.openedByPage = true
        newTab.openingTab = tab
        
        newTabAnimation {
            guard self.tabManager.model.tabs.contains(newTab.tabModel) else { return }

            self.dismissOmniBar()
            self.addToView(tab: newTab)
            self.refreshOmniBar()
        }

        return newTab.webView
    }

    func tabDidRequestClose(_ tab: TabViewController) {
        closeTab(tab.tabModel)
    }

    func tabLoadingStateDidChange(tab: TabViewController) {
        if currentTab == tab {
            refreshControls()
        }
        tabManager?.save()
        tabsBarController?.refresh(tabsModel: tabManager.model)
    }
    
    func tab(_ tab: TabViewController, didUpdatePreview preview: UIImage) {
        previewsSource.update(preview: preview, forTab: tab.tabModel)
    }

    func tabWillRequestNewTab(_ tab: TabViewController) -> UIKeyModifierFlags? {
        keyModifierFlags
    }

    func tabDidRequestNewTab(_ tab: TabViewController) {
        _ = findInPageView.resignFirstResponder()
        newTab()
    }

    func tab(_ tab: TabViewController,
             didRequestNewBackgroundTabForUrl url: URL,
             inheritingAttribution attribution: AdClickAttributionLogic.State?) {
        _ = tabManager.add(url: url, inBackground: true, inheritedAttribution: attribution)
        animateBackgroundTab()
    }

    func tab(_ tab: TabViewController,
             didRequestNewTabForUrl url: URL,
             openedByPage: Bool,
             inheritingAttribution attribution: AdClickAttributionLogic.State?) {
        _ = findInPageView.resignFirstResponder()

        if openedByPage {
            showBars()
            newTabAnimation {
                self.loadUrlInNewTab(url, inheritedAttribution: attribution)
                self.tabManager.current?.openedByPage = true
                self.tabManager.current?.openingTab = tab
            }
            tabSwitcherButton.incrementAnimated()
        } else {
            loadUrlInNewTab(url, inheritedAttribution: attribution)
            self.tabManager.current?.openingTab = tab
        }

    }

    func tab(_ tab: TabViewController, didChangePrivacyInfo privacyInfo: PrivacyInfo?) {
        if currentTab == tab {
            viewCoordinator.omniBar.updatePrivacyIcon(for: privacyInfo)
        }
    }

    func tabDidRequestReportBrokenSite(tab: TabViewController) {
        segueToReportBrokenSite()
    }
    
    func tabDidRequestBookmarks(tab: TabViewController) {
        Pixel.fire(pixel: .bookmarksButtonPressed,
                   withAdditionalParameters: [PixelParameters.originatedFromMenu: "1"])
        onBookmarksPressed()
    }
    
    func tabDidRequestEditBookmark(tab: TabViewController) {
        onBookmarkEdit()
    }
    
    func tabDidRequestDownloads(tab: TabViewController) {
        segueToDownloads()
    }
    
    func tabDidRequestAutofillLogins(tab: TabViewController) {
        launchAutofillLogins(with: currentTab?.url)
    }
    
    func tabDidRequestSettings(tab: TabViewController) {
        segueToSettings()
    }

    func tab(_ tab: TabViewController,
             didRequestSettingsToLogins account: SecureVaultModels.WebsiteAccount) {
        segueToSettingsLoginsWithAccount(account)
    }

    func tabContentProcessDidTerminate(tab: TabViewController) {
        findInPageView.done()
        tabManager.invalidateCache(forController: tab)
    }

    func showBars() {
        chromeManager.reset()
    }
    
    func tabDidRequestFindInPage(tab: TabViewController) {
        updateFindInPage()
        _ = findInPageView?.becomeFirstResponder()
    }

    func closeFindInPage(tab: TabViewController) {
        if tab === currentTab {
            findInPageView.done()
        } else {
            tab.findInPage?.done()
            tab.findInPage = nil
        }
    }
    
    func tabDidRequestForgetAll(tab: TabViewController) {
        forgetAllWithAnimation(showNextDaxDialog: true)
    }
    
    func tabDidRequestFireButtonPulse(tab: TabViewController) {
        showFireButtonPulse()
    }
    
    func tabDidRequestSearchBarRect(tab: TabViewController) -> CGRect {
        searchBarRect
    }

    func tab(_ tab: TabViewController,
             didRequestPresentingTrackerAnimation privacyInfo: PrivacyInfo,
             isCollapsing: Bool) {
        guard tabManager.current === tab else { return }
        viewCoordinator.omniBar?.startTrackersAnimation(privacyInfo, forDaxDialog: !isCollapsing)
    }
    
    func tabDidRequestShowingMenuHighlighter(tab: TabViewController) {
        showMenuHighlighterIfNeeded()
    }

    private func newTabAnimation(completion: @escaping () -> Void) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        let x = view.frame.midX
        let y = view.frame.midY
        
        let theme = ThemeManager.shared.currentTheme
        let view = UIView(frame: CGRect(x: x, y: y, width: 5, height: 5))
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.borderColor = theme.barTintColor.cgColor
        view.backgroundColor = theme.backgroundColor
        view.center = self.view.center
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = self.view.frame
            view.alpha = 0.9
        }, completion: { _ in
            view.removeFromSuperview()
            completion()
        })
    }
    
    func tab(_ tab: TabViewController, didRequestPresentingAlert alert: UIAlertController) {
        present(alert, animated: true)
    }

    func selectTab(_ tab: Tab) {
        guard let index = tabManager.model.indexOf(tab: tab) else { return }
        select(tabAt: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.onCancelPressed()
        }
    }

    func tabCheckIfItsBeingCurrentlyPresented(_ tab: TabViewController) -> Bool {
        return tabManager.current === tab
    }
}

extension MainViewController: TabSwitcherDelegate {

    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController) {
        newTab()
        animateLogoAppearance()
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTab tab: Tab) {
        selectTab(tab)
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTab tab: Tab) {
        if tabManager.count == 1 {
            // Make sure UI updates finish before dimissing the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tabSwitcher.dismiss()
            }
        }
        closeTab(tab)
        
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }
    
    func closeTab(_ tab: Tab) {
        guard let index = tabManager.model.indexOf(tab: tab) else { return }
        hideSuggestionTray()
        tabManager.remove(at: index)
        updateCurrentTab()
    }

    func tabSwitcherDidRequestForgetAll(tabSwitcher: TabSwitcherViewController) {
        self.forgetAllWithAnimation {
            tabSwitcher.dismiss(animated: false, completion: nil)
        }
    }
    
}

extension MainViewController: BookmarksDelegate {
    func bookmarksDidSelect(url: URL) {
        dismissOmniBar()
        if url.isBookmarklet() {
            executeBookmarklet(url)
        } else {
            loadUrl(url)
        }
    }
}

extension MainViewController: TabSwitcherButtonDelegate {
    
    func launchNewTab(_ button: TabSwitcherButton) {
        newTab()
    }

    func showTabSwitcher(_ button: TabSwitcherButton) {
        Pixel.fire(pixel: .tabBarTabSwitcherPressed)
        showTabSwitcher()
    }

    func showTabSwitcher() {
        if let currentTab = currentTab {
            currentTab.preparePreview(completion: { image in
                if let image = image {
                    self.previewsSource.update(preview: image,
                                               forTab: currentTab.tabModel)
                    
                }
                ViewHighlighter.hideAll()
                self.segueToTabSwitcher()
            })
        }
    }
}

extension MainViewController: MenuButtonDelegate {
    
    func showMenu(_ button: MenuButton) {
        onMenuPressed()
    }
    
    func showBookmarks(_ button: MenuButton) {
        Pixel.fire(pixel: .bookmarksButtonPressed,
                   withAdditionalParameters: [PixelParameters.originatedFromMenu: "0"])
        onBookmarksPressed()
    }
}

extension MainViewController: GestureToolbarButtonDelegate {
    
    func singleTapDetected(in sender: GestureToolbarButton) {
        Pixel.fire(pixel: .bookmarksButtonPressed,
                   withAdditionalParameters: [PixelParameters.originatedFromMenu: "0"])
        onBookmarksPressed()
    }
    
    func longPressDetected(in sender: GestureToolbarButton) {
        quickSaveBookmark()
    }
    
}

extension MainViewController: AutoClearWorker {
    
    func clearNavigationStack() {
        dismissOmniBar()

        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.clearNavigationStack()
            }
        }
    }

    func forgetTabs() {
        DaxDialogs.shared.resumeRegularFlow()
        findInPageView?.done()
        tabManager.removeAll()
        showBars()
        attachHomeScreen()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        Favicons.shared.clearCache(.tabs)
    }
    
    func forgetData() {
        findInPageView?.done()
        
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()

        let pixel = TimedPixel(.forgetAllDataCleared)
        WebCacheManager.shared.clear(tabCountInfo: tabCountInfo) {
            pixel.fire(withAdditionalParameters: [PixelParameters.tabCount: "\(self.tabManager.count)"])
        }
        
        AutoconsentManagement.shared.clearCache()
        DaxDialogs.shared.clearHeldURLData()

        if syncService.authState == .inactive {
            bookmarksDatabaseCleaner?.cleanUpDatabaseNow()
        }
    }
    
    func stopAllOngoingDownloads() {
        AppDependencyProvider.shared.downloadManager.cancelAllDownloads()
    }
    
    func forgetAllWithAnimation(transitionCompletion: (() -> Void)? = nil, showNextDaxDialog: Bool = false) {
        let spid = Instruments.shared.startTimedEvent(.clearingData)
        Pixel.fire(pixel: .forgetAllExecuted)
        
        self.tabCountInfo = tabManager.makeTabCountInfo()
        
        tabManager.prepareAllTabsExceptCurrentForDataClearing()
        
        fireButtonAnimator.animate {
            self.tabManager.prepareCurrentTabForDataClearing()
            
            self.stopAllOngoingDownloads()
            self.forgetData()
            DaxDialogs.shared.resumeRegularFlow()
            self.forgetTabs()
        } onTransitionCompleted: {
            ActionMessageView.present(message: UserText.actionForgetAllDone,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: self.appSettings.currentAddressBarPosition.isBottom))
            transitionCompletion?()
        } completion: {
            Instruments.shared.endTimedEvent(for: spid)
            if showNextDaxDialog {
                self.homeController?.showNextDaxDialog()
            } else if KeyboardSettings().onNewTab {
                let showKeyboardAfterFireButton = DispatchWorkItem {
                    self.enterSearch()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: showKeyboardAfterFireButton)
                self.showKeyboardAfterFireButton = showKeyboardAfterFireButton
            }
        }
    }
    
    private func showFireButtonPulse() {
        DaxDialogs.shared.fireButtonPulseStarted()
        guard let window = view.window else { return }
        
        let fireButtonView: UIView?
        if viewCoordinator.toolbar.isHidden {
            fireButtonView = tabsBarController?.fireButton
        } else {
            fireButtonView = viewCoordinator.toolbarFireButton.value(forKey: "view") as? UIView
        }
        guard let view = fireButtonView else { return }
        
        if !ViewHighlighter.highlightedViews.contains(where: { $0.view == view }) {
            ViewHighlighter.hideAll()
            ViewHighlighter.showIn(window, focussedOnView: view)
        }
    }
    
}

extension MainViewController: Themable {
    
    func decorate(with theme: Theme) {

        setNeedsStatusBarAppearanceUpdate()

        // Does not appear to get updated when setting changes.
        tabsBarController?.decorate(with: theme)

        if AppWidthObserver.shared.isLargeWidth {
            viewCoordinator.statusBackground.backgroundColor = theme.tabsBarBackgroundColor
        } else {
            viewCoordinator.statusBackground.backgroundColor = theme.omniBarBackgroundColor
        }

        view.backgroundColor = theme.mainViewBackgroundColor

        viewCoordinator.navigationBarContainer.backgroundColor = theme.barBackgroundColor
        viewCoordinator.navigationBarContainer.tintColor = theme.barTintColor
        
        viewCoordinator.omniBar.decorate(with: theme)

        viewCoordinator.progress.decorate(with: theme)
        
        viewCoordinator.toolbar.barTintColor = theme.barBackgroundColor
        viewCoordinator.toolbar.tintColor = theme.barTintColor

        tabSwitcherButton.decorate(with: theme)
        gestureBookmarksButton.decorate(with: theme)
        viewCoordinator.toolbarTabSwitcherButton.tintColor = theme.barTintColor
        
        presentedMenuButton.decorate(with: theme)
        
        tabManager.decorate(with: theme)

        findInPageView.decorate(with: theme)
        
        viewCoordinator.logoText.tintColor = theme.ddgTextTintColor

        if appSettings.currentAddressBarPosition == .bottom {
            viewCoordinator.statusBackground.backgroundColor = theme.backgroundColor
        }
    }

}

extension MainViewController: OnboardingDelegate {
        
    func onboardingCompleted(controller: UIViewController) {
        markOnboardingSeen()
        controller.modalTransitionStyle = .crossDissolve
        controller.dismiss(animated: true)
        homeController?.onboardingCompleted()
    }
    
    func markOnboardingSeen() {
        var settings = DefaultTutorialSettings()
        settings.hasSeenOnboarding = true
    }
    
}

extension MainViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: URL.self) || session.canLoadObjects(ofClass: String.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    // won't drop on to a web view - only works by dropping on to the tabs bar or home screen
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        if session.canLoadObjects(ofClass: URL.self) {
            _ = session.loadObjects(ofClass: URL.self) { urls in
                urls.forEach { self.loadUrlInNewTab($0, inheritedAttribution: nil) }
            }
            
        } else if session.canLoadObjects(ofClass: String.self) {
            _ = session.loadObjects(ofClass: String.self) { strings in
                self.loadQuery(strings[0])
            }
            
        }
        
    }
}

// MARK: - VoiceSearchViewControllerDelegate

extension MainViewController: VoiceSearchViewControllerDelegate {
    
    func voiceSearchViewController(_ controller: VoiceSearchViewController, didFinishQuery query: String?) {
        controller.dismiss(animated: true, completion: nil)
        if let query = query {
            Pixel.fire(pixel: .voiceSearchDone)
            loadQuery(query)
        }
    }
}

// MARK: - History UIMenu Methods

extension MainViewController {

    private func refreshBackForwardMenuItems() {
        guard let currentTab = currentTab else {
            return
        }
        
        let backMenu = historyMenu(with: currentTab.webView.backForwardList.backList.reversed())
        viewCoordinator.omniBar.backButton.menu = backMenu
        viewCoordinator.toolbarBackButton.menu = backMenu
        
        let forwardMenu = historyMenu(with: currentTab.webView.backForwardList.forwardList)
        viewCoordinator.omniBar.forwardButton.menu = forwardMenu
        viewCoordinator.toolbarForwardButton.menu = forwardMenu
    }

    private func historyMenu(with backForwardList: [WKBackForwardListItem]) -> UIMenu {
        let historyItemList = backForwardList.map { BackForwardMenuHistoryItem(backForwardItem: $0) }
        let actions = historyMenuButton(with: historyItemList)
        return UIMenu(title: "", children: actions)
    }
    
    private func historyMenuButton(with menuHistoryItemList: [BackForwardMenuHistoryItem]) -> [UIAction] {
        let menuItems: [UIAction] = menuHistoryItemList.compactMap { historyItem in
            
            if #available(iOS 15.0, *) {
                return UIAction(title: historyItem.title,
                                subtitle: historyItem.sanitizedURLForDisplay,
                                discoverabilityTitle: historyItem.sanitizedURLForDisplay) { [weak self] _ in
                    self?.loadBackForwardItem(historyItem.backForwardItem)
                }
            } else {
                return  UIAction(title: historyItem.title,
                                 discoverabilityTitle: historyItem.sanitizedURLForDisplay) { [weak self] _ in
                    self?.loadBackForwardItem(historyItem.backForwardItem)
                }
            }
        }
        
        return menuItems
    }
}

// MARK: - AutofillLoginSettingsListViewControllerDelegate
extension MainViewController: AutofillLoginSettingsListViewControllerDelegate {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController) {
        controller.dismiss(animated: true)
    }
}

// swiftlint:enable file_length

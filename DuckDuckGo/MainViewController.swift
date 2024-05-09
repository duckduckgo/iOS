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
import Suggestions
import Subscription
import SwiftUI

#if NETWORK_PROTECTION
import NetworkProtection
#endif

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
    
    weak var notificationView: UIView?

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
    
    let tabManager: TabManager
    let previewsSource: TabPreviewsSource
    let appSettings: AppSettings
    private var launchTabObserver: LaunchTabNotification.Observer?
    
    var doRefreshAfterClear = true

    let bookmarksDatabase: CoreDataDatabase
    private weak var bookmarksDatabaseCleaner: BookmarkDatabaseCleaner?
    private var favoritesViewModel: FavoritesListInteracting
    let syncService: DDGSyncing
    let syncDataProviders: SyncDataProviders
    
    @UserDefaultsWrapper(key: .syncDidShowSyncPausedByFeatureFlagAlert, defaultValue: false)
    private var syncDidShowSyncPausedByFeatureFlagAlert: Bool

    @UserDefaultsWrapper(key: .userDidInteractWithBrokenSitePrompt, defaultValue: false)
    private var userDidInteractWithBrokenSitePrompt: Bool

    private var localUpdatesCancellable: AnyCancellable?
    private var syncUpdatesCancellable: AnyCancellable?
    private var syncFeatureFlagsCancellable: AnyCancellable?
    private var favoritesDisplayModeCancellable: AnyCancellable?
    private var emailCancellables = Set<AnyCancellable>()
    private var urlInterceptorCancellables = Set<AnyCancellable>()
    
#if NETWORK_PROTECTION
    private let tunnelDefaults = UserDefaults.networkProtectionGroupDefaults
    private var vpnCancellables = Set<AnyCancellable>()
#endif

    private lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger
    
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
        return tabManager.current(createIfNeeded: false)
    }
    
    var searchBarRect: CGRect {
        let view = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController?.view
        return viewCoordinator.omniBar.searchContainer.convert(viewCoordinator.omniBar.searchContainer.bounds, to: view)
    }
    
    var keyModifierFlags: UIKeyModifierFlags?
    var showKeyboardAfterFireButton: DispatchWorkItem?
    
    // Skip SERP flow (focusing on autocomplete logic) and prepare for new navigation when selecting search bar
    private var skipSERPFlow = true
    
    private var keyboardHeight: CGFloat = 0.0
    
    var postClear: (() -> Void)?
    var clearInProgress = false
    var dataStoreWarmup: DataStoreWarmup? = DataStoreWarmup()

    required init?(coder: NSCoder) {
        fatalError("Use init?(code:")
    }
    
    var historyManager: HistoryManager
    var viewCoordinator: MainViewCoordinator!
    
    init(
        bookmarksDatabase: CoreDataDatabase,
        bookmarksDatabaseCleaner: BookmarkDatabaseCleaner,
        historyManager: HistoryManager,
        syncService: DDGSyncing,
        syncDataProviders: SyncDataProviders,
        appSettings: AppSettings,
        previewsSource: TabPreviewsSource,
        tabsModel: TabsModel
    ) {
        self.bookmarksDatabase = bookmarksDatabase
        self.bookmarksDatabaseCleaner = bookmarksDatabaseCleaner
        self.historyManager = historyManager
        self.syncService = syncService
        self.syncDataProviders = syncDataProviders
        self.favoritesViewModel = FavoritesListViewModel(bookmarksDatabase: bookmarksDatabase, favoritesDisplayMode: appSettings.favoritesDisplayMode)
        self.bookmarksCachingSearch = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: bookmarksDatabase))
        self.appSettings = appSettings

        self.previewsSource = previewsSource

        self.tabManager = TabManager(model: tabsModel,
                                     previewsSource: previewsSource,
                                     bookmarksDatabase: bookmarksDatabase,
                                     historyManager: historyManager,
                                     syncService: syncService)


        super.init(nibName: nil, bundle: nil)
        
        tabManager.delegate = self
        bindSyncService()
    }

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
    
    var swipeTabsCoordinator: SwipeTabsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        viewCoordinator = MainViewFactory.createViewHierarchy(self.view)
        viewCoordinator.moveAddressBarToPosition(appSettings.currentAddressBarPosition)

        viewCoordinator.toolbarBackButton.action = #selector(onBackPressed)
        viewCoordinator.toolbarForwardButton.action = #selector(onForwardPressed)
        viewCoordinator.toolbarFireButton.action = #selector(onFirePressed)

        installSwipeTabs()
            
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
        loadInitialView()
        previewsSource.prepare()
        addLaunchTabNotificationObserver()
        subscribeToEmailProtectionStatusNotifications()
        subscribeToURLInterceptorNotifications()
        
#if NETWORK_PROTECTION
        subscribeToNetworkProtectionEvents()
#endif

        findInPageView.delegate = self
        findInPageBottomLayoutConstraint.constant = 0
        registerForKeyboardNotifications()
        registerForSyncPausedNotifications()
        registerForUserBehaviorEvents()

        decorate()

        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        swipeTabsCoordinator?.refresh(tabsModel: tabManager.model, scrollToSelected: true)

        _ = AppWidthObserver.shared.willResize(toWidth: view.frame.width)
        applyWidth()
        
        registerForApplicationEvents()
        registerForCookiesManagedNotification()
        registerForSettingsChangeNotifications()

        tabManager.cleanupTabsFaviconCache()

        // Needs to be called here to established correct view hierarchy
        refreshViewsBasedOnAddressBarPosition(appSettings.currentAddressBarPosition)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Needs to be called here because sometimes the frames are not the expected size during didLoad
        refreshViewsBasedOnAddressBarPosition(appSettings.currentAddressBarPosition)

        startOnboardingFlowIfNotSeenBefore()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        swipeTabsCoordinator?.refresh(tabsModel: tabManager.model, scrollToSelected: true)

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

    private func installSwipeTabs() {
        guard swipeTabsCoordinator == nil else { return }
        
        swipeTabsCoordinator = SwipeTabsCoordinator(coordinator: viewCoordinator,
                                                    tabPreviewsSource: previewsSource,
                                                    appSettings: appSettings) { [weak self] in
            
            guard $0 != self?.tabManager.model.currentIndex else { return }
            
            DailyPixel.fire(pixel: .swipeTabsUsedDaily)
            Pixel.fire(pixel: .swipeTabsUsed)
            self?.select(tabAt: $0)
            
        } newTab: { [weak self] in
            Pixel.fire(pixel: .swipeToOpenNewTab)
            self?.newTab()
        } onSwipeStarted: { [weak self] in
            self?.hideKeyboard()
            self?.updatePreviewForCurrentTab()
        }
    }
    
    func updatePreviewForCurrentTab(completion: (() -> Void)? = nil) {
        assert(Thread.isMainThread)
        
        if !viewCoordinator.logoContainer.isHidden,
           self.tabManager.current()?.link == nil,
           let tab = self.tabManager.model.currentTab {
            // Home screen with logo
            if let image = viewCoordinator.logoContainer.createImageSnapshot(inBounds: viewCoordinator.contentContainer.frame) {
                previewsSource.update(preview: image, forTab: tab)
                completion?()
            }

        } else if let currentTab = self.tabManager.current(), currentTab.link != nil {
            // Web view
            currentTab.preparePreview(completion: { image in
                guard let image else { return }
                self.previewsSource.update(preview: image,
                                           forTab: currentTab.tabModel)
                completion?()
            })
        } else if let tab = self.tabManager.model.currentTab {
            // Favorites, etc
            if let image = viewCoordinator.contentContainer.createImageSnapshot() {
                previewsSource.update(preview: image, forTab: tab)
                completion?()
            }
        } else {
            completion?()
        }
    }

    func loadSuggestionTray() {
        let storyboard = UIStoryboard(name: "SuggestionTray", bundle: nil)

        guard let controller = storyboard.instantiateInitialViewController(creator: { coder in
            SuggestionTrayViewController(coder: coder,
                                         favoritesViewModel: self.favoritesViewModel,
                                         bookmarksDatabase: self.bookmarksDatabase,
                                         historyCoordinator: self.historyManager.historyCoordinator)
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    var keyboardShowing = false

    @objc
    private func keyboardDidShow() {
        keyboardShowing = true
    }

    @objc
    private func keyboardWillHide() {
        if homeController?.collectionView.isDragging == true, keyboardShowing {
            Pixel.fire(pixel: .addressBarGestureDismiss)
        }
    }

    @objc
    private func keyboardDidHide() {
        keyboardShowing = false
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
        syncFeatureFlagsCancellable = syncService.featureFlagsPublisher
            .dropFirst()
            .map { $0.contains(.dataSyncing) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDataSyncingAvailable in
                guard let self else {
                    return
                }
                if isDataSyncingAvailable {
                    self.syncDidShowSyncPausedByFeatureFlagAlert = false
                } else if self.syncService.authState == .active, !self.syncDidShowSyncPausedByFeatureFlagAlert {
                    self.showSyncPausedByFeatureFlagAlert()
                    self.syncDidShowSyncPausedByFeatureFlagAlert = true
                }
            }
    }

    private func registerForUserBehaviorEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(attemptToShowBrokenSitePrompt(_:)),
            name: .userBehaviorDidMatchExperimentVariant,
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

    private func showSyncPausedByFeatureFlagAlert(upgradeRequired: Bool = false) {
        let title = UserText.syncPausedTitle
        let description = upgradeRequired ? UserText.syncUnavailableMessageUpgradeRequired : UserText.syncUnavailableMessage
        if self.presentedViewController is SyncSettingsViewController {
            return
        }
        self.presentedViewController?.dismiss(animated: true)
        let alert = UIAlertController(title: title,
                                      message: description,
                                      preferredStyle: .alert)
        if syncService.featureFlags.contains(.userInterface) {
            let learnMoreAction = UIAlertAction(title: UserText.syncPausedAlertLearnMoreButton, style: .default) { _ in
                self.segueToSettingsSync()
            }
            alert.addAction(learnMoreAction)
        }
        alert.addAction(UIAlertAction(title: UserText.syncPausedAlertOkButton, style: .cancel))
        self.present(alert, animated: true)
    }

    func registerForSettingsChangeNotifications() {
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(onAddressBarPositionChanged),
                                               name: AppUserDefaults.Notifications.addressBarPositionChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onShowFullURLAddressChanged),
                                               name: AppUserDefaults.Notifications.showsFullURLAddressSettingChanged,
                                               object: nil)
    }

    @objc func onAddressBarPositionChanged() {
        viewCoordinator.moveAddressBarToPosition(appSettings.currentAddressBarPosition)
        refreshViewsBasedOnAddressBarPosition(appSettings.currentAddressBarPosition)
        updateStatusBarBackgroundColor()
    }

    @objc private func onShowFullURLAddressChanged() {
        refreshOmniBar()
    }

    func refreshViewsBasedOnAddressBarPosition(_ position: AddressBarPosition) {
        switch position {
        case .top:
            swipeTabsCoordinator?.addressBarPositionChanged(isTop: true)
            viewCoordinator.omniBar.moveSeparatorToBottom()
            viewCoordinator.showToolbarSeparator()
            viewCoordinator.constraints.navigationBarContainerBottom.isActive = false

        case .bottom:
            swipeTabsCoordinator?.addressBarPositionChanged(isTop: false)
            viewCoordinator.omniBar.moveSeparatorToTop()
            // If this is called before the toolbar has shown it will not re-add the separator when moving to the top position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.viewCoordinator.hideToolbarSeparator()
            }
        }

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
        keyboardHeight = height

        if let suggestionsTray = suggestionTrayController {
            let suggestionsFrameInView = suggestionsTray.view.convert(suggestionsTray.contentFrame, to: view)

            let overflow = suggestionsFrameInView.size.height + suggestionsFrameInView.origin.y - keyboardFrameInView.origin.y + 10
            if overflow > 0 {
                suggestionsTray.applyContentInset(UIEdgeInsets(top: 0, left: 0, bottom: overflow, right: 0))
            } else {
                suggestionsTray.applyContentInset(.zero)
            }
        }

        let y = self.view.frame.height - height
        let frame = self.findInPageView.frame
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.findInPageView.frame = CGRect(x: 0, y: y - frame.height, width: frame.width, height: frame.height)
        }, completion: nil)

        if self.appSettings.currentAddressBarPosition.isBottom {
            let navBarOffset = min(0, self.toolbarHeight - intersection.height)
            self.viewCoordinator.constraints.navigationBarCollectionViewBottom.constant = navBarOffset
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
        // if let tab = currentTab, tab.link != nil {
        // if let tab = tabManager.current(create: true), tab.link != nil {
        if tabManager.model.currentTab?.link != nil {
            guard let tab = tabManager.current(createIfNeeded: true) else {
                fatalError("Unable to create tab")
            }
            attachTab(tab: tab)
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

        // Access the tab model directly as we don't want to create a new tab controller here
        guard let tabModel = tabManager.model.currentTab else {
            fatalError("No tab model")
        }

        let controller = HomeViewController.loadFromStoryboard(model: tabModel,
                                                               favoritesViewModel: favoritesViewModel,
                                                               appSettings: appSettings,
                                                               syncService: syncService,
                                                               syncDataProviders: syncDataProviders)

        homeController = controller

        controller.chromeDelegate = self
        controller.delegate = self

        addToContentContainer(controller: controller)

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

    func loadUrlInNewTab(_ url: URL, reuseExisting: Bool = false, inheritedAttribution: AdClickAttributionLogic.State?, fromExternalLink: Bool = false) {
        func worker() {
            allowContentUnderflow = false
            viewCoordinator.navigationBarContainer.alpha = 1
            loadViewIfNeeded()
            if reuseExisting, let existing = tabManager.first(withUrl: url) {
                selectTab(existing)
                return
            } else if reuseExisting, let existing = tabManager.firstHomeTab() {
                doRefreshAfterClear = false
                tabManager.selectTab(existing)
                loadUrl(url, fromExternalLink: fromExternalLink)
            } else {
                addTab(url: url, inheritedAttribution: inheritedAttribution, fromExternalLink: fromExternalLink)
            }
            refreshOmniBar()
            refreshTabIcon()
            refreshControls()
            tabsBarController?.refresh(tabsModel: tabManager.model)
            swipeTabsCoordinator?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        }
        
        if clearInProgress {
            postClear = worker
        } else {
            worker()
        }
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

    func loadUrl(_ url: URL, fromExternalLink: Bool = false) {
        prepareTabForRequest {
            self.currentTab?.load(url: url)
            if fromExternalLink {
                self.currentTab?.inferredOpenerContext = .external
            }
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

        if currentTab == nil {
            if tabManager.current(createIfNeeded: true) == nil {
                fatalError("failed to create tab")
            }
        }

        guard let tab = currentTab else { fatalError("no tab") }
        
        request()
        dismissOmniBar()
        select(tab: tab)
    }

    private func addTab(url: URL?, inheritedAttribution: AdClickAttributionLogic.State?, fromExternalLink: Bool = false) {
        let tab = tabManager.add(url: url, inheritedAttribution: inheritedAttribution)
        tab.inferredOpenerContext = .external
        dismissOmniBar()
        attachTab(tab: tab)
    }

    func select(tabAt index: Int) {
        viewCoordinator.navigationBarContainer.alpha = 1
        allowContentUnderflow = false
        
        if tabManager.model.tabs.indices.contains(index) {
            let tab = tabManager.select(tabAt: index)
            select(tab: tab)
        } else {
            assertionFailure("Invalid index selected")
        }
    }

    fileprivate func select(tab: TabViewController) {
        if tab.link == nil {
            attachHomeScreen()
        } else {
            attachTab(tab: tab)
            refreshControls()
        }
        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        swipeTabsCoordinator?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    private func attachTab(tab: TabViewController) {
        removeHomeScreen()
        updateFindInPage()
        currentTab?.progressWorker.progressBar = nil
        currentTab?.chromeDelegate = nil
            
        addToContentContainer(controller: tab)

        viewCoordinator.logoContainer.isHidden = true
        
        tab.progressWorker.progressBar = viewCoordinator.progress
        chromeManager.attach(to: tab.webView.scrollView)
        tab.chromeDelegate = self
    }

    private func addToContentContainer(controller: UIViewController) {
        viewCoordinator.contentContainer.isHidden = false
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

        viewCoordinator.omniBar.refreshText(forUrl: tab.url, forceFullURL: appSettings.showFullSiteAddress)

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
  
    var orientationPixelWorker: DispatchWorkItem?

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if AppWidthObserver.shared.willResize(toWidth: size.width) {
            applyWidth()
        }

        self.showMenuHighlighterIfNeeded()
        
        coordinator.animate { _ in
            self.swipeTabsCoordinator?.refresh(tabsModel: self.tabManager.model, scrollToSelected: true)

            self.deferredFireOrientationPixel()
        } completion: { _ in
            ViewHighlighter.updatePositions()
        }
    }

    private func deferredFireOrientationPixel() {
        orientationPixelWorker?.cancel()
        orientationPixelWorker = nil
        if UIDevice.current.orientation.isLandscape {
            let worker = DispatchWorkItem {
                Pixel.fire(pixel: .deviceOrientationLandscape)
            }
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 3, execute: worker)
            orientationPixelWorker = worker
        }
    }

    private func applyWidth() {

        if AppWidthObserver.shared.isLargeWidth {
            applyLargeWidth()
        } else {
            applySmallWidth()
        }

        DispatchQueue.main.async {
            // Do this async otherwise the toolbar buttons skew to the right
            if self.viewCoordinator.constraints.navigationBarContainerTop.constant >= 0 {
                self.showBars()
            }
            // If tabs have been udpated, do this async to make sure size calcs are current
            self.tabsBarController?.refresh(tabsModel: self.tabManager.model)
            self.swipeTabsCoordinator?.refresh(tabsModel: self.tabManager.model)
            
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
        
        swipeTabsCoordinator?.isEnabled = false
    }

    private func applySmallWidth() {
        viewCoordinator.tabBarContainer.isHidden = true
        viewCoordinator.toolbar.isHidden = false
        viewCoordinator.omniBar.enterPhoneState()
        
        swipeTabsCoordinator?.isEnabled = true
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
    
    func launchAutofillLogins(with currentTabUrl: URL? = nil, openSearch: Bool = false) {
        let appSettings = AppDependencyProvider.shared.appSettings
        let autofillSettingsViewController = AutofillLoginSettingsListViewController(
            appSettings: appSettings,
            currentTabUrl: currentTabUrl,
            syncService: syncService,
            syncDataProviders: syncDataProviders,
            selectedAccount: nil,
            openSearch: openSearch
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
        ViewHighlighter.updatePositions()
    }

    private func showNotification(title: String, message: String, dismissHandler: @escaping NotificationView.DismissHandler) {
        guard notificationView == nil else { return }

        let notificationView = NotificationView.loadFromNib(dismissHandler: dismissHandler)
        notificationView.setTitle(text: title)
        notificationView.setMessage(text: message)

        showNotification(with: notificationView)
    }

    private func showNotification(with contentView: UIView) {
        guard viewCoordinator.topSlideContainer.subviews.isEmpty else { return }
        viewCoordinator.topSlideContainer.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: viewCoordinator.topSlideContainer.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: viewCoordinator.topSlideContainer.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: viewCoordinator.topSlideContainer.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: viewCoordinator.topSlideContainer.bottomAnchor),
        ])

        self.notificationView = contentView
        view.layoutSubviews()
        viewCoordinator.topSlideContainer.layoutIfNeeded()

        viewCoordinator.showTopSlideContainer()
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    func hideNotification() {
        self.view.layoutIfNeeded()
        viewCoordinator.hideTopSlideContainer()
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.notificationView?.removeFromSuperview()
            self.notificationView = nil
        }
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

    private var brokenSitePromptViewHostingController: UIHostingController<BrokenSitePromptView>?
    private var brokenSitePromptEvent: UserBehaviorEvent?

    @objc func attemptToShowBrokenSitePrompt(_ notification: Notification) {
        guard userDidInteractWithBrokenSitePrompt,
              let event = notification.userInfo?[UserBehaviorEvent.Key.event] as? UserBehaviorEvent,
              let url = currentTab?.url, !url.isDuckDuckGo,
              notificationView == nil,
              !isPad,
              DefaultTutorialSettings().hasSeenOnboarding else { return }
        showBrokenSitePrompt(after: event)
    }

    private func showBrokenSitePrompt(after event: UserBehaviorEvent) {
        let host = makeBrokenSitePromptViewHostingController(event: event)
        brokenSitePromptViewHostingController = host
        brokenSitePromptEvent = event
        Pixel.fire(pixel: .siteNotWorkingShown, withAdditionalParameters: [UserBehaviorEvent.Parameter.event: event.rawValue])
        showNotification(with: host.view)
    }

    private func makeBrokenSitePromptViewHostingController(event: UserBehaviorEvent) -> UIHostingController<BrokenSitePromptView> {
        let parameters = [UserBehaviorEvent.Parameter.event: event.rawValue]
        let viewModel = BrokenSitePromptViewModel(onDidDismiss: { [weak self] in
            self?.hideNotification()
            self?.userDidInteractWithBrokenSitePrompt = true
            self?.brokenSitePromptViewHostingController = nil
            Pixel.fire(pixel: .siteNotWorkingDismiss, withAdditionalParameters: parameters)
        }, onDidSubmit: { [weak self] in
            self?.segueToReportBrokenSite(mode: .prompt(event.rawValue))
            self?.hideNotification()
            self?.userDidInteractWithBrokenSitePrompt = true
            self?.brokenSitePromptViewHostingController = nil
            Pixel.fire(pixel: .siteNotWorkingWebsiteIsBroken, withAdditionalParameters: parameters)
        })
        return UIHostingController(rootView: BrokenSitePromptView(viewModel: viewModel))
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
        tabsBarController?.refresh(tabsModel: tabManager.model)
        swipeTabsCoordinator?.refresh(tabsModel: tabManager.model, scrollToSelected: true)
        homeController?.openedAsNewTab(allowingKeyboard: allowingKeyboard)
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
    
    private func subscribeToURLInterceptorNotifications() {
        NotificationCenter.default.publisher(for: .urlInterceptPrivacyPro)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                switch notification.name {
                case .urlInterceptPrivacyPro:
                    self?.launchSettings(deepLinkTarget: .subscriptionFlow)
                default:
                    return
                }
            }
            .store(in: &urlInterceptorCancellables)
    }

#if NETWORK_PROTECTION
    private func subscribeToNetworkProtectionEvents() {
        NotificationCenter.default.publisher(for: .accountDidSignIn)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onNetworkProtectionAccountSignIn(notification)
            }
            .store(in: &vpnCancellables)
        NotificationCenter.default.publisher(for: .entitlementsDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onEntitlementsChange(notification)
            }
            .store(in: &vpnCancellables)
        NotificationCenter.default.publisher(for: .accountDidSignOut)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.onNetworkProtectionAccountSignOut(notification)
            }
            .store(in: &vpnCancellables)

        NotificationCenter.default.publisher(for: .vpnEntitlementMessagingDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onNetworkProtectionEntitlementMessagingChange()
            }
            .store(in: &vpnCancellables)

        let notificationCallback: CFNotificationCallback = { _, _, name, _, _ in
            if let name {
                NotificationCenter.default.post(name: Notification.Name(name.rawValue as String),
                                                object: nil)
            }
        }

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                                        notificationCallback,
                                        Notification.Name.vpnEntitlementMessagingDidChange.rawValue as CFString,
                                        nil, .deliverImmediately)
    }

    private func onNetworkProtectionEntitlementMessagingChange() {
        if tunnelDefaults.showEntitlementAlert {
            presentExpiredEntitlementAlert()
        }

        presentExpiredEntitlementNotification()
    }

    private func presentExpiredEntitlementAlert() {
        let alertController = CriticalAlerts.makeExpiredEntitlementAlert { [weak self] in
            self?.segueToPrivacyPro()
        }
        dismiss(animated: true) {
            self.present(alertController, animated: true, completion: nil)
            DailyPixel.fireDailyAndCount(pixel: .privacyProVPNAccessRevokedDialogShown)
            self.tunnelDefaults.showEntitlementAlert = false
        }
    }

    private func presentExpiredEntitlementNotification() {
        let presenter = NetworkProtectionNotificationsPresenterTogglableDecorator(
            settings: VPNSettings(defaults: .networkProtectionGroupDefaults),
            defaults: .networkProtectionGroupDefaults,
            wrappee: NetworkProtectionUNNotificationPresenter()
        )
        presenter.showEntitlementNotification()
    }

    @objc
    private func onNetworkProtectionAccountSignIn(_ notification: Notification) {
        tunnelDefaults.resetEntitlementMessaging()
        tunnelDefaults.vpnEarlyAccessOverAlertAlreadyShown = true
        os_log("[NetP Subscription] Reset expired entitlement messaging", log: .networkProtection, type: .info)
    }

    @objc
    private func onEntitlementsChange(_ notification: Notification) {
        Task {
            guard case .success(false) = await AccountManager().hasEntitlement(for: .networkProtection) else { return }

            let controller = NetworkProtectionTunnelController()

            if await controller.isInstalled {
                tunnelDefaults.enableEntitlementMessaging()
            }

            if await controller.isConnected {
                DailyPixel.fireDailyAndCount(pixel: .privacyProVPNBetaStoppedWhenPrivacyProEnabled, withAdditionalParameters: [
                    "reason": "entitlement-change"
                ])
            }

            await controller.stop()
            await controller.removeVPN()
        }
    }

    @objc
    private func onNetworkProtectionAccountSignOut(_ notification: Notification) {
        Task {
            let controller = NetworkProtectionTunnelController()
            
            if await controller.isConnected {
                DailyPixel.fireDailyAndCount(pixel: .privacyProVPNBetaStoppedWhenPrivacyProEnabled, withAdditionalParameters: [
                    "reason": "account-signed-out"
                ])
            }

            await controller.stop()
            await controller.removeVPN()
        }
    }
#endif

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

        viewCoordinator.showNavigationBarWithBottomPosition()
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

            self.viewCoordinator.navigationBarContainer.alpha = percent
            self.viewCoordinator.tabBarContainer.alpha = percent
            self.viewCoordinator.toolbar.alpha = percent

            self.view.layoutIfNeeded()
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
        if viewCoordinator.addressBarPosition.isBottom {
            // When position is set to bottom, contentContainer is pinned to top
            // of navigationBarContainer, hence the adjustment.
            bottomHeight += viewCoordinator.navigationBarContainer.frame.height
        }
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
        if brokenSitePromptViewHostingController != nil, let event = brokenSitePromptEvent?.rawValue {
            Pixel.fire(pixel: .siteNotWorkingDismissByNavigation,
                       withAdditionalParameters: [UserBehaviorEvent.Parameter.event: event])
        }
        hideNotification()
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
        fireControllerAwarePixel(ntp: .keyboardGoWhileOnNTP, serp: .keyboardGoWhileOnSERP, website: .keyboardGoWhileOnWebsite)

        guard !viewCoordinator.suggestionTrayContainer.isHidden else { return }
        
        suggestionTrayController?.willDismiss(with: viewCoordinator.omniBar.textField.text ?? "")
    }

    func fireControllerAwarePixel(ntp: Pixel.Event, serp: Pixel.Event, website: Pixel.Event) {
        if homeController != nil {
            Pixel.fire(pixel: ntp)
        } else if let currentTab {
            if currentTab.url?.isDuckDuckGoSearch == true {
                Pixel.fire(pixel: serp)
            } else {
                Pixel.fire(pixel: website)
            }
        }
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

    func onSettingsLongPressed() {
        if featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild {
            segueToDebugSettings()
        } else {
            segueToSettings()
        }
    }

    func performCancel() {
        dismissOmniBar()
        hideSuggestionTray()
        homeController?.omniBarCancelPressed()
        self.showMenuHighlighterIfNeeded()
    }

    func onCancelPressed() {
        fireControllerAwarePixel(ntp: .addressBarCancelPressedOnNTP,
                                 serp: .addressBarCancelPressedOnSERP,
                                 website: .addressBarCancelPressedOnWebsite)
        performCancel()
    }

    func onClearPressed() {
        fireControllerAwarePixel(ntp: .addressBarClearPressedOnNTP,
                                 serp: .addressBarClearPressedOnSERP,
                                 website: .addressBarClearPressedOnWebsite)
    }

    private var isSERPPresented: Bool {
        guard let tabURL = currentTab?.url else { return false }
        return tabURL.isDuckDuckGoSearch
    }
    
    func onTextFieldWillBeginEditing(_ omniBar: OmniBar, tapped: Bool) {
        if let currentTab {
            viewCoordinator.omniBar.refreshText(forUrl: currentTab.url, forceFullURL: true)
        }

        if tapped {
            fireControllerAwarePixel(ntp: .addressBarClickOnNTP, serp: .addressBarClickOnSERP, website: .addressBarClickOnWebsite)
        }

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
        hideNotification()
        if brokenSitePromptViewHostingController != nil, let event = brokenSitePromptEvent?.rawValue {
            Pixel.fire(pixel: .siteNotWorkingDismissByRefresh, 
                       withAdditionalParameters: [UserBehaviorEvent.Parameter.event: event])
        }
    }
    
    func onSharePressed() {
        hideSuggestionTray()
        guard let link = currentTab?.link else { return }
        currentTab?.onShareAction(forLink: link, fromView: viewCoordinator.omniBar.shareButton)
    }

    func onShareLongPressed() {
        if featureFlagger.isFeatureOn(.debugMenu) || isDebugBuild {
            segueToDebugSettings()
        } else {
            onSharePressed()
        }
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
        Pixel.fire(pixel: .favoriteLaunchedWebsite)
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
        switch suggestion {
        case .phrase(phrase: let phrase):
            if let url = URL.makeSearchURL(text: phrase) {
                loadUrl(url)
            } else {
                os_log("Couldn‘t form URL for suggestion “%s”", log: .lifecycleLog, type: .error, phrase)
            }
        case .website(url: let url):
            if url.isBookmarklet() {
                executeBookmarklet(url)
            } else {
                loadUrl(url)
            }
        case .bookmark(_, url: let url, _, _):
            loadUrl(url)
        case .historyEntry(_, url: let url, _):
            loadUrl(url)
        case .unknown(value: let value), .internalPage(title: let value, url: _):
            assertionFailure("Unknown suggestion: \(value)")
        }

        showHomeRowReminder()
    }

    func autocomplete(pressedPlusButtonForSuggestion suggestion: Suggestion) {
        switch suggestion {
        case .phrase(phrase: let phrase):
        viewCoordinator.omniBar.textField.text = phrase
        case .website(url: let url):
            if url.isDuckDuckGoSearch, let query = url.searchQuery {
                viewCoordinator.omniBar.textField.text = query
            } else if !url.isBookmarklet() {
                viewCoordinator.omniBar.textField.text = url.absoluteString
            }
        case .bookmark(title: let title, _, _, _):
            viewCoordinator.omniBar.textField.text = title
        case .historyEntry(title: let title, _, _):
            viewCoordinator.omniBar.textField.text = title
        case .unknown(value: let value), .internalPage(title: let value, url: _):
            assertionFailure("Unknown suggestion: \(value)")
        }

        viewCoordinator.omniBar.textDidChange()
    }
    
    func autocomplete(highlighted suggestion: Suggestion, for query: String) {

        switch suggestion {
        case .phrase(phrase: let phrase):
            viewCoordinator.omniBar.textField.text = phrase
            if phrase.hasPrefix(query) {
                viewCoordinator.omniBar.selectTextToEnd(query.count)
            }
        case .website(url: let url):
            viewCoordinator.omniBar.textField.text = url.absoluteString
        case .bookmark(title: let title, _, _, _):
            viewCoordinator.omniBar.textField.text = title
            if title.hasPrefix(query) {
                viewCoordinator.omniBar.selectTextToEnd(query.count)
            }
        case .historyEntry(title: let title, let url, _):
            if (title ?? url.absoluteString).hasPrefix(query) {
                viewCoordinator.omniBar.selectTextToEnd(query.count)
            }
        case .unknown(value: let value), .internalPage(title: let value, url: _):
            assertionFailure("Unknown suggestion: \(value)")
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

        // Don't use a request or else the page gets stuck on "about:blank"
        let newTab = tabManager.addURLRequest(nil,
                                              with: configuration,
                                              inheritedAttribution: inheritingAttribution)
        newTab.openedByPage = true
        newTab.openingTab = tab
        
        newTabAnimation {
            guard self.tabManager.model.tabs.contains(newTab.tabModel) else { return }

            self.dismissOmniBar()
            self.attachTab(tab: newTab)
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
        tabManager.save()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        // note: model in swipeTabsCoordinator doesn't need to be updated here
        // https://app.asana.com/0/414235014887631/1206847376910045/f
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
                self.currentTab?.openedByPage = true
                self.currentTab?.openingTab = tab
            }
            tabSwitcherButton.incrementAnimated()
        } else {
            loadUrlInNewTab(url, inheritedAttribution: attribution)
            self.currentTab?.openingTab = tab
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

    func tab(_ tab: TabViewController, didRequestToggleReportWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        segueToReportBrokenSite(mode: .toggleReport(completionHandler: completionHandler))
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

        viewCoordinator.hideNavigationBarWithBottomPosition()
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
        guard currentTab === tab else { return }
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
            self.performCancel()
        }
    }

    func tabCheckIfItsBeingCurrentlyPresented(_ tab: TabViewController) -> Bool {
        return currentTab === tab
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
            // However, as a result, viewDidAppear on the home controller thinks the tab 
            //  switcher is still presented.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tabSwitcher.dismiss(animated: true) {
                    self.homeController?.viewDidAppear(true)
                }
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
        tabsBarController?.refresh(tabsModel: tabManager.model)
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
        Pixel.fire(pixel: .tabSwitchLongPressNewTab)
        newTab()
    }

    func showTabSwitcher(_ button: TabSwitcherButton) {
        Pixel.fire(pixel: .tabBarTabSwitcherPressed)
        showTabSwitcher()
    }

    func showTabSwitcher() {
        guard currentTab ?? tabManager.current(createIfNeeded: true) != nil else {
            fatalError("Unable to get current tab")
        }

        updatePreviewForCurrentTab {
            ViewHighlighter.hideAll()
            self.segueToTabSwitcher()
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
        omniBar.resignFirstResponder()
        findInPageView?.done()
        tabManager.removeAll()
    }

    func refreshUIAfterClear() {
        guard doRefreshAfterClear else {
            doRefreshAfterClear = true
            return
        }
        showBars()
        attachHomeScreen()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        swipeTabsCoordinator?.refresh(tabsModel: tabManager.model)
        Favicons.shared.clearCache(.tabs)
    }

    @MainActor
    func clearDataFinished(_: AutoClear) {
        refreshUIAfterClear()
    }

    @MainActor
    func forgetData() async {
        guard !clearInProgress else {
            assertionFailure("Shouldn't get called multiple times")
            return
        }
        clearInProgress = true

        // This needs to happen only once per app launch
        if let dataStoreWarmup {
            await dataStoreWarmup.ensureReady()
            self.dataStoreWarmup = nil
        }

        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()

        let pixel = TimedPixel(.forgetAllDataCleared)
        await WebCacheManager.shared.clear()
        pixel.fire(withAdditionalParameters: [PixelParameters.tabCount: "\(self.tabManager.count)"])

        AutoconsentManagement.shared.clearCache()
        DaxDialogs.shared.clearHeldURLData()

        if self.syncService.authState == .inactive {
            self.bookmarksDatabaseCleaner?.cleanUpDatabaseNow()
        }

        await historyManager.removeAllHistory()

        self.clearInProgress = false
        
        self.postClear?()
        self.postClear = nil
    }
    
    func stopAllOngoingDownloads() {
        AppDependencyProvider.shared.downloadManager.cancelAllDownloads()
    }
    
    func forgetAllWithAnimation(transitionCompletion: (() -> Void)? = nil, showNextDaxDialog: Bool = false) {
        let spid = Instruments.shared.startTimedEvent(.clearingData)
        Pixel.fire(pixel: .forgetAllExecuted)

        tabManager.prepareAllTabsExceptCurrentForDataClearing()
        
        fireButtonAnimator.animate {
            self.tabManager.prepareCurrentTabForDataClearing()
            self.stopAllOngoingDownloads()
            self.forgetTabs()
            await self.forgetData()
            Instruments.shared.endTimedEvent(for: spid)
            DaxDialogs.shared.resumeRegularFlow()
        } onTransitionCompleted: {
            ActionMessageView.present(message: UserText.actionForgetAllDone,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: self.appSettings.currentAddressBarPosition.isBottom))
            transitionCompletion?()
            self.refreshUIAfterClear()
        } completion: {
            // Ideally this should happen once data clearing has finished AND the animation is finished
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

extension MainViewController {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateStatusBarBackgroundColor()
    }

    private func updateStatusBarBackgroundColor() {
        let theme = ThemeManager.shared.currentTheme

        if appSettings.currentAddressBarPosition == .bottom {
            viewCoordinator.statusBackground.backgroundColor = theme.backgroundColor
        } else {
            if AppWidthObserver.shared.isPad && traitCollection.horizontalSizeClass == .regular {
                viewCoordinator.statusBackground.backgroundColor = theme.tabsBarBackgroundColor
            } else {
                viewCoordinator.statusBackground.backgroundColor = theme.omniBarBackgroundColor
            }
        }
    }

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme

        updateStatusBarBackgroundColor()

        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = theme.mainViewBackgroundColor

        viewCoordinator.navigationBarContainer.backgroundColor = theme.barBackgroundColor
        viewCoordinator.navigationBarContainer.tintColor = theme.barTintColor

        viewCoordinator.toolbar.barTintColor = theme.barBackgroundColor
        viewCoordinator.toolbar.tintColor = theme.barTintColor

        viewCoordinator.toolbarTabSwitcherButton.tintColor = theme.barTintColor
        
        viewCoordinator.logoText.tintColor = theme.ddgTextTintColor
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

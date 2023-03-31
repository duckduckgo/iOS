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
import Core
import Lottie
import Kingfisher
import os.log
import BrowserServicesKit
import Bookmarks
import Persistence
import PrivacyDashboard

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class MainViewController: UIViewController {
// swiftlint:enable type_body_length

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        return isIPad ? [.left, .right] : []
    }
    
    @IBOutlet weak var progressView: ProgressView!

    @IBOutlet weak var suggestionTrayContainer: UIView!
    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fireButton: FireBarButtonItem!
    @IBOutlet weak var lastToolbarButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBarTop: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottom: NSLayoutConstraint!
    @IBOutlet weak var containerViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var tabsBar: UIView!
    @IBOutlet weak var tabsBarTop: NSLayoutConstraint!

    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var notificationContainerTop: NSLayoutConstraint!
    @IBOutlet weak var notificationContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var findInPageView: FindInPageView!
    @IBOutlet weak var findInPageHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var findInPageBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var findInPageInnerContainerView: UIView!

    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoText: UIImageView!

    weak var notificationView: NotificationView?

    var omniBar: OmniBar!
    var chromeManager: BrowserChromeManager!

    var allowContentUnderflow = false {
        didSet {
            containerViewTop.constant = allowContentUnderflow ? contentUnderflow : 0
        }
    }
    
    var contentUnderflow: CGFloat {
        return 3 + (allowContentUnderflow ? -customNavigationBar.frame.size.height : 0)
    }
    
    var homeController: HomeViewController?
    var tabsBarController: TabsBarViewController?
    var suggestionTrayController: SuggestionTrayViewController?

    var tabManager: TabManager!
    private let previewsSource = TabPreviewsSource()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()
    private var launchTabObserver: LaunchTabNotification.Observer?
    
    private let bookmarksDatabase: CoreDataDatabase
    private let favoritesViewModel: FavoritesListInteracting
    
    lazy var menuBookmarksViewModel: MenuBookmarksInteracting = MenuBookmarksViewModel(bookmarksDatabase: bookmarksDatabase)

    weak var tabSwitcherController: TabSwitcherViewController?
    let tabSwitcherButton = TabSwitcherButton()
    
    /// Do not reference directly, use `presentedMenuButton`
    let menuButton = MenuButton()
    var presentedMenuButton: MenuButton {
        AppWidthObserver.shared.isLargeWidth ? omniBar.menuButtonContent : menuButton
    }
    
    let gestureBookmarksButton = GestureToolbarButton()
    
    private lazy var fireButtonAnimator: FireButtonAnimator = FireButtonAnimator(appSettings: appSettings)
    
    private var bookmarksCachingSearch: BookmarksCachingSearch

    fileprivate lazy var tabSwitcherTransition = TabSwitcherTransitionDelegate()
    var currentTab: TabViewController? {
        return tabManager?.current
    }

    var keyModifierFlags: UIKeyModifierFlags?
    var showKeyboardAfterFireButton: DispatchWorkItem?
    
    // Skip SERP flow (focusing on autocomplete logic) and prepare for new navigation when selecting search bar
    private var skipSERPFlow = true
    
    private enum Constants {
                
        // Environment Keys/Values
        static let environmentOnboardingKey = "ONBOARDING"
        static let environmentOnboardingKeytrue = "true"
        static let environmentOnboardingKeyfalse = "false"
        
        static let onboardingFlow = "DaxOnboarding"
        static let bookmarksImage = "Bookmarks"
        
        // Segue Identifiers
        static let bookmarksSegue = "Bookmarks"
        static let bookmarksEditSegue = "BookmarksEdit"
        static let bookmarksEditCurrentSegue = "BookmarksEditCurrent"
        static let instructionsSegue = "instructions"
        static let downloadsSegue = "Downloads"
        static let reportBrokenSiteSegue = "ReportBrokenSite"
        static let actionSheetDaxDialogSegue = "ActionSheetDaxDialog"
        static let settingsSegue = "Settings"
        static let showTabsSegue = "ShowTabs"
    }
    
    required init?(coder: NSCoder,
                   bookmarksDatabase: CoreDataDatabase) {
        self.bookmarksDatabase = bookmarksDatabase
        self.favoritesViewModel = FavoritesListViewModel(bookmarksDatabase: bookmarksDatabase)
        self.bookmarksCachingSearch = BookmarksCachingSearch(bookmarksStore: CoreDataBookmarksSearchStore(bookmarksStore: bookmarksDatabase))
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init?(code:")
    }

    fileprivate var tabCountInfo: TabCountInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
                
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
        addDuckDuckGoEmailAuthenticationObservers()

        findInPageView.delegate = self
        findInPageBottomLayoutConstraint.constant = 0
        registerForKeyboardNotifications()

        applyTheme(ThemeManager.shared.currentTheme)

        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)

        _ = AppWidthObserver.shared.willResize(toWidth: view.frame.width)
        applyWidth()
        
        registerForApplicationEvents()
        registerForCookiesManagedNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startOnboardingFlowIfNotSeenBefore()
        tabsBarController?.refresh(tabsModel: tabManager.model)
        
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
        }
    }

    func startAddFavoriteFlow() {
        DaxDialogs.shared.enableAddFavoriteFlow()
        if DefaultTutorialSettings().hasSeenOnboarding {
            newTab()
        }
    }
    
    func startOnboardingFlowIfNotSeenBefore() {
        
        guard ProcessInfo.processInfo.environment[Constants.environmentOnboardingKey] != Constants.environmentOnboardingKeyfalse else {
            // explicitly skip onboarding, e.g. for integration tests
            return
        }
        
        let settings = DefaultTutorialSettings()
        let showOnboarding = !settings.hasSeenOnboarding ||
            // explicitly show onboarding, can be set in the scheme > Run > Environment Variables
        ProcessInfo.processInfo.environment[Constants.environmentOnboardingKey] == Constants.environmentOnboardingKeyfalse
        guard showOnboarding else { return }

        let onboardingFlow = Constants.onboardingFlow

        performSegue(withIdentifier: onboardingFlow, sender: self)
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    /// This is only really for iOS 10 devices that don't properly support the change frame approach.
    @objc private func keyboardWillHide(_ notification: Notification) {

        guard findInPageBottomLayoutConstraint.constant > 0,
            let userInfo = notification.userInfo else {
            return
        }

        findInPageBottomLayoutConstraint.constant = 0
        animateForKeyboard(userInfo: userInfo, y: view.frame.height)
    }

    /// Based on https://stackoverflow.com/a/46117073/73479
    ///  Handles iPhone X devices properly.
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {

        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

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

        animateForKeyboard(userInfo: userInfo, y: view.frame.height - height)
    }
    
    private func animateForKeyboard(userInfo: [AnyHashable: Any], y: CGFloat) {
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        let frame = self.findInPageView.frame
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: {
            self.findInPageView.frame = CGRect(x: 0, y: y - frame.height, width: frame.width, height: frame.height)
        }, completion: nil)

    }

    private func initTabButton() {
        tabSwitcherButton.delegate = self
        tabsButton.customView = tabSwitcherButton
        tabsButton.isAccessibilityElement = true
        tabsButton.accessibilityTraits = .button
    }
    
    private func initMenuButton() {
        lastToolbarButton.customView = menuButton
        lastToolbarButton.isAccessibilityElement = true
        lastToolbarButton.accessibilityTraits = .button
        
        menuButton.delegate = self
    }
    
    private func initBookmarksButton() {
        omniBar.bookmarksButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                                  action: #selector(quickSaveBookmarkLongPress(gesture:))))
        gestureBookmarksButton.delegate = self
        gestureBookmarksButton.image = UIImage(named: Constants.bookmarksImage)
    }
    
    @objc func quickSaveBookmarkLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            quickSaveBookmark()
        }
    }

    @objc func quickSaveBookmark() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        guard currentTab != nil else {
            ActionMessageView.present(message: UserText.webSaveBookmarkNone)
            return
        }
        
        Pixel.fire(pixel: .tabBarBookmarksLongPressed)
        currentTab?.saveAsBookmark(favorite: true, viewModel: menuBookmarksViewModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        
        if let controller = segue.destination as? TabsBarViewController {
            controller.delegate = self
            tabsBarController = controller
            return
        }
        
        if let navController = segue.destination as? UINavigationController,
            let brokenSiteScreen = navController.topViewController as? ReportBrokenSiteViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                segue.destination.modalPresentationStyle = .formSheet
            }
            
            brokenSiteScreen.brokenSiteInfo = currentTab?.getCurrentWebsiteInfo()
        }

        if var onboarding = segue.destination as? Onboarding {
            onboarding.delegate = self
        }
        
        if let controller = segue.destination as? ActionSheetDaxDialogViewController {
            let spec = sender as? DaxDialogs.ActionSheetSpec
            if spec == DaxDialogs.ActionSheetSpec.fireButtonEducation {
                ViewHighlighter.hideAll()
            }
            controller.spec = spec
            controller.delegate = self
        }

    }
    
    @IBSegueAction func onCreateSuggestionTray(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> SuggestionTrayViewController {
        guard let controller = SuggestionTrayViewController(coder: coder,
                                                            favoritesViewModel: favoritesViewModel,
                                                            bookmarksSearch: bookmarksCachingSearch) else {
            fatalError("Failed to create controller")
        }
        
        controller.dismissHandler = dismissSuggestionTray
        controller.autocompleteDelegate = self
        controller.favoritesOverlayDelegate = self
        suggestionTrayController = controller
        
        return controller
    }
    
    @IBSegueAction func onCreateBookmarksList(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> BookmarksViewController {
        guard let controller = BookmarksViewController(coder: coder,
                                                       bookmarksDatabase: self.bookmarksDatabase,
                                                       bookmarksSearch: bookmarksCachingSearch) else {
            fatalError("Failed to create controller")
        }
        controller.delegate = self
        
        if segueIdentifier == Constants.bookmarksEditCurrentSegue,
            let link = currentTab?.link,
            let bookmark = menuBookmarksViewModel.favorite(for: link.url) ?? menuBookmarksViewModel.bookmark(for: link.url) {
            controller.openEditFormWhenPresented(bookmark: bookmark)
        } else if segueIdentifier == Constants.bookmarksEditSegue,
                  let bookmark = sender as? BookmarkEntity {
            controller.openEditFormWhenPresented(bookmark: bookmark)
        }
        
        return controller
    }
    
    @IBSegueAction func onCreateTabSwitcher(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> TabSwitcherViewController {
        guard let controller = TabSwitcherViewController(coder: coder,
                                                         bookmarksDatabase: bookmarksDatabase) else {
            fatalError("Failed to create controller")
        }
        
        controller.transitioningDelegate = tabSwitcherTransition
        controller.delegate = self
        controller.tabsModel = tabManager.model
        controller.previewsSource = previewsSource
        tabSwitcherController = controller
        
        return controller
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            ThemeManager.shared.refreshSystemTheme()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
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
        omniBar = OmniBar.loadFromXib()
        omniBar.omniDelegate = self
        omniBar.menuButtonContent.delegate = self
        omniBar.frame = customNavigationBar.bounds
        customNavigationBar.addSubview(omniBar)
    }

    fileprivate func attachHomeScreen() {
        logoContainer.isHidden = false
        findInPageView.isHidden = true
        chromeManager.detach()
        
        currentTab?.dismiss()
        removeHomeScreen()

        let tabModel = currentTab?.tabModel
        let controller = HomeViewController.loadFromStoryboard(model: tabModel!, favoritesViewModel: favoritesViewModel)
        homeController = controller

        controller.chromeDelegate = self
        controller.delegate = self

        addToView(controller: controller)

        refreshControls()
    }

    fileprivate func removeHomeScreen() {
        homeController?.willMove(toParent: nil)
        homeController?.dismiss()
        homeController = nil
    }

    @IBAction func onFirePressed() {
        Pixel.fire(pixel: .forgetAllPressedBrowsing)
        DailyPixel.fire(pixel: .experimentDailyFireButtonTapped)
        FireButton.stopAllFireButtonAnimations()
        
        FireButtonExperiment.storeThatFireButtonWasTapped()
        
        wakeLazyFireButtonAnimator()
        
        if let spec = DaxDialogs.shared.fireButtonEducationMessage() {
            performSegue(withIdentifier: Constants.actionSheetDaxDialogSegue, sender: spec)
        } else {
            let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
                self?.forgetAllWithAnimation {}
            })
            self.present(controller: alert, fromView: self.toolbar)
        }
    }
    
    func onQuickFirePressed() {
        wakeLazyFireButtonAnimator()
        
        self.forgetAllWithAnimation {}
        self.dismiss(animated: true)
        dismissOmniBar()
        if KeyboardSettings().onAppLaunch {
            self.enterSearch()
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
        dismissOmniBar()
        refreshOmniBar()
    }

    @IBAction func onForwardPressed() {
        Pixel.fire(pixel: .tabBarForwardPressed)
        dismissOmniBar()
        currentTab?.goForward()
    }
    
    func didReturnFromBackground() {
        skipSERPFlow = true
        if DaxDialogs.shared.shouldShowFireButtonPulse {
            showFireButtonPulse()
            
            tabSwitcherController?.viewDidAppear(false)
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
        customNavigationBar.alpha = 1
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
            omniBar.becomeFirstResponder()
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
        customNavigationBar.alpha = 1
        allowContentUnderflow = false
        request()
        guard let tab = currentTab else { fatalError("no tab") }
        select(tab: tab)
        dismissOmniBar()
    }

    private func addTab(url: URL?, inheritedAttribution: AdClickAttributionLogic.State?) {
        let tab = tabManager.add(url: url, inheritedAttribution: inheritedAttribution)
        dismissOmniBar()
        addToView(tab: tab)
    }

    func select(tabAt index: Int) {
        customNavigationBar.alpha = 1
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
        tab.progressWorker.progressBar = progressView
        chromeManager.attach(to: tab.webView.scrollView)
        tab.chromeDelegate = self
    }

    private func addToView(controller: UIViewController) {
        addChild(controller)
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.addSubview(controller.view)
        controller.view.frame = containerView.bounds
        controller.didMove(toParent: self)

    }

    fileprivate func updateCurrentTab() {
        if let currentTab = currentTab {
            select(tab: currentTab)
            omniBar.resignFirstResponder()
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
        tabsButton.accessibilityHint = UserText.numberOfTabs(tabManager.count)
        tabSwitcherButton.tabCount = tabManager.count
        tabSwitcherButton.hasUnread = tabManager.hasUnread
    }

    private func refreshOmniBar() {
        guard let tab = currentTab, tab.link != nil else {
            omniBar.stopBrowsing()
            return
        }

        omniBar.refreshText(forUrl: tab.url)

        if tab.isError {
            omniBar.hidePrivacyIcon()
        } else if let privacyInfo = tab.privacyInfo, privacyInfo.url.host == tab.url?.host {
            omniBar.updatePrivacyIcon(for: privacyInfo)
        } else {
            omniBar.resetPrivacyIcon(for: tab.url)
        }
            
        omniBar.startBrowsing()
    }

    func dismissOmniBar() {
        omniBar.resignFirstResponder()
        hideSuggestionTray()
        refreshOmniBar()
    }

    fileprivate func refreshBackForwardButtons() {
        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
        
        omniBar.backButton.isEnabled = backButton.isEnabled
        omniBar.forwardButton.isEnabled = forwardButton.isEnabled
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
            if self.navBarTop.constant >= 0 {
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
            lastToolbarButton.accessibilityLabel = UserText.bookmarksButtonHint
            omniBar.menuButton.accessibilityLabel = UserText.bookmarksButtonHint

        } else {
            if presentedViewController is BrowsingMenuViewController {
                expectedState = .closeImage
            } else {
                expectedState = .menuImage
            }
            lastToolbarButton.accessibilityLabel = UserText.menuButtonHint
            omniBar.menuButton.accessibilityLabel = UserText.menuButtonHint
        }

        presentedMenuButton.decorate(with: ThemeManager.shared.currentTheme)
        presentedMenuButton.setState(expectedState, animated: false)
    }

    private func applyWidthToTrayController() {
        if AppWidthObserver.shared.isLargeWidth {
            self.suggestionTrayController?.float(withWidth: self.omniBar.searchStackContainer.frame.width + 24)
        } else {
            self.suggestionTrayController?.fill()
        }
    }
    
    private func applyLargeWidth() {
        tabsBar.isHidden = false
        toolbar.isHidden = true
        omniBar.enterPadState()
    }

    private func applySmallWidth() {
        tabsBar.isHidden = true
        toolbar.isHidden = false
        omniBar.enterPhoneState()
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
            if type.hideOmnibarSeparator() {
                omniBar.hideSeparator()
            }
        }
        suggestionTrayContainer.isHidden = false
        currentTab?.webView.accessibilityElementsHidden = true
    }
    
    func hideSuggestionTray() {
        omniBar.showSeparator()
        suggestionTrayContainer.isHidden = true
        currentTab?.webView.accessibilityElementsHidden = false
        suggestionTrayController?.didHide()
    }
    
    fileprivate func launchReportBrokenSite() {
        performSegue(withIdentifier: Constants.reportBrokenSiteSegue, sender: self)
    }
    
    fileprivate func launchDownloads() {
        performSegue(withIdentifier: Constants.downloadsSegue, sender: self)
    }
    
    fileprivate func launchAutofillLogins(with currentTabUrl: URL? = nil) {
        let appSettings = AppDependencyProvider.shared.appSettings
        let autofillSettingsViewController = AutofillLoginSettingsListViewController(appSettings: appSettings, currentTabUrl: currentTabUrl)
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
    
    func launchSettings() {
        performSegue(withIdentifier: Constants.settingsSegue, sender: self)
    }
    
    func launchCookiePopupManagementSettings() {
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
           let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            
            settingsController.showCookiePopupManagement(animated: false)
            self.present(navController, animated: true)
        }
    }

    fileprivate func launchInstructions() {
        performSegue(withIdentifier: Constants.instructionsSegue, sender: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notificationView?.layoutSubviews()
        let height = notificationView?.frame.size.height ?? 0
        notificationContainerHeight.constant = height
        ViewHighlighter.updatePositions()
    }

    func showNotification(title: String, message: String, dismissHandler: @escaping NotificationView.DismissHandler) {

        let notificationView = NotificationView.loadFromNib(dismissHandler: dismissHandler)

        notificationView.setTitle(text: title)
        notificationView.setMessage(text: message)
        notificationContainer.addSubview(notificationView)
        notificationContainerTop.constant = -notificationView.frame.size.height
        self.notificationView = notificationView

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.notificationContainerTop.constant = 0
            self.notificationContainerHeight.constant = notificationView.frame.size.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }

    }

    func hideNotification() {

        notificationContainerTop.constant = -(notificationView?.frame.size.height ?? 0)
        notificationContainerHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.notificationContainerTop.constant = 0
            self.notificationView?.removeFromSuperview()
        })

    }

    func showHomeRowReminder() {
        let feature = HomeRowReminder()
        if feature.showNow() {
            showNotification(title: UserText.homeRowReminderTitle, message: UserText.homeRowReminderMessage) { tapped in
                if tapped {
                    self.launchInstructions()
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

    func replaceToolbar(item target: UIBarButtonItem, with replacement: UIBarButtonItem) {
        guard let items = toolbar.items else { return }

        let newItems = items.compactMap({
            $0 == target ? replacement : $0
        })

        toolbar.setItems(newItems, animated: false)
    }

    func newTab(reuseExisting: Bool = false) {
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
        homeController?.openedAsNewTab()
        tabsBarController?.refresh(tabsModel: tabManager.model)
    }
    
    func animateLogoAppearance() {
        logoContainer.alpha = 0
        logoContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.2) {
                self.logoContainer.alpha = 1
                self.logoContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func updateFindInPage() {
        currentTab?.findInPage?.delegate = self
        findInPageView.update(with: currentTab?.findInPage, updateTextField: true)
        // hide toolbar on iPhone
        toolbar.accessibilityElementsHidden = !AppWidthObserver.shared.isLargeWidth
    }
    
    private func showVoiceSearch() {
        // https://app.asana.com/0/0/1201408131067987
        UIMenuController.shared.hideMenu()
        omniBar.removeTextSelection()
        
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
    
    private func addDuckDuckGoEmailAuthenticationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDuckDuckGoEmailSignIn), name: .emailDidSignIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDuckDuckGoEmailSignOut), name: .emailDidSignOut, object: nil)
    }

    @objc
    private func onDuckDuckGoEmailSignIn(_ notification: Notification) {
        fireEmailPixel(.emailEnabled, notification: notification)
    }
    
    @objc
    private func onDuckDuckGoEmailSignOut(_ notification: Notification) {
        fireEmailPixel(.emailDisabled, notification: notification)
    }
    
    private func fireEmailPixel(_ pixel: Pixel.Event, notification: Notification) {
        var pixelParameters: [String: String] = [:]
        
        if let userInfo = notification.userInfo as? [String: String], let cohort = userInfo[EmailManager.NotificationParameter.cohort] {
            pixelParameters[PixelParameters.emailCohort] = cohort
        }
        
        Pixel.fire(pixel: pixel, withAdditionalParameters: pixelParameters, includedParameters: [.atb])
    }
    
    private func installFavoritesOverlay() {
        let favoritesOverlay = FavoritesOverlay(favoritesViewModel: favoritesViewModel)
        favoritesOverlay.delegate = self
        addChild(favoritesOverlay)
        favoritesOverlay.view.frame = containerView.bounds
        containerView.addSubview(favoritesOverlay.view)
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
        toolbar.accessibilityElementsHidden = false
    }
    
}

extension MainViewController: BrowserChromeDelegate {

    struct ChromeAnimationConstants {
        static let duration = 0.1
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
            
            self.omniBar.alpha = percent
            self.tabsBar.alpha = percent
            self.toolbar.alpha = percent
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
        omniBar.alpha = hidden ? 0 : 1
        tabsBar.alpha = hidden ? 0 : 1
        statusBarBackground.alpha = hidden ? 0 : 1
    }
    
    var canHideBars: Bool {
        return !DaxDialogs.shared.shouldShowFireButtonPulse
    }

    var isToolbarHidden: Bool {
        return toolbar.alpha < 1
    }

    var toolbarHeight: CGFloat {
        return toolbar.frame.size.height
    }
    
    var barsMaxHeight: CGFloat {
        return max(toolbarHeight, omniBar.frame.size.height)
    }

    // 1.0 - full size, 0.0 - hidden
    private func updateToolbarConstant(_ ratio: CGFloat) {
        var bottomHeight = toolbarHeight
        bottomHeight += view.safeAreaInsets.bottom
        let multiplier = toolbar.isHidden ? 1.0 : 1.0 - ratio
        toolbarBottom.constant = bottomHeight * multiplier
        findInPageHeightLayoutConstraint.constant = findInPageInnerContainerView.frame.height + view.safeAreaInsets.bottom
    }

    // 1.0 - full size, 0.0 - hidden
    private func updateNavBarConstant(_ ratio: CGFloat) {
        let browserTabsOffset = (tabsBar.isHidden ? 0 : tabsBar.frame.size.height)
        let navBarTopOffset = customNavigationBar.frame.size.height + browserTabsOffset
        if !tabsBar.isHidden {
            let topBarsConstant = -browserTabsOffset * (1.0 - ratio)
            tabsBarTop.constant = topBarsConstant
        }
        navBarTop.constant = browserTabsOffset + -navBarTopOffset * (1.0 - ratio)
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
        dismissOmniBar()
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
        performSegue(withIdentifier: Constants.bookmarksSegue, sender: self)
    }
    
    func onBookmarkEdit() {
        ViewHighlighter.hideAll()
        hideSuggestionTray()
        performSegue(withIdentifier: Constants.bookmarksEditCurrentSegue, sender: self)
    }
    
    func onEnterPressed() {
        guard !suggestionTrayContainer.isHidden else { return }
        suggestionTrayController?.willDismiss(with: omniBar.textField.text ?? "")
    }

    func onDismissed() {
        dismissOmniBar()
    }

    func onSettingsPressed() {
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
        launchSettings()
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
        currentTab?.onShareAction(forLink: link, fromView: omniBar.shareButton, orginatedFromMenu: false)
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
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .bookmarks, fromCache: .tabs)
        if url.isBookmarklet() {
            executeBookmarklet(url)
        } else {
            loadUrl(url)
        }
        showHomeRowReminder()
    }
    
    func favoritesOverlay(_ controller: FavoritesOverlay, didRequestEditFavorite favorite: BookmarkEntity) {
        performSegue(withIdentifier: Constants.bookmarksEditSegue, sender: favorite)
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
                omniBar.textField.text = suggestion.suggestion
            } else if !url.isBookmarklet() {
                omniBar.textField.text = url.absoluteString
            }
        } else {
            omniBar.textField.text = suggestion.suggestion
        }
        omniBar.textDidChange()
    }
    
    func autocomplete(highlighted suggestion: Suggestion, for query: String) {
        if let url = suggestion.url {
            omniBar.textField.text = url.absoluteString
        } else {
            omniBar.textField.text = suggestion.suggestion
            
            if suggestion.suggestion.hasPrefix(query),
               let fromPosition = omniBar.textField.position(from: omniBar.textField.beginningOfDocument, offset: query.count) {
                omniBar.textField.selectedTextRange = omniBar.textField.textRange(from: fromPosition,
                                                                                  to: omniBar.textField.endOfDocument)
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
        performSegue(withIdentifier: Constants.bookmarksEditSegue, sender: favorite)
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
        launchSettings()
    }
    
    func home(_ home: HomeViewController, didRequestHideLogo hidden: Bool) {
        logoContainer.isHidden = hidden
    }
    
    func homeDidRequestLogoContainer(_ home: HomeViewController) -> UIView {
        return logoContainer
    }
    
    func home(_ home: HomeViewController, searchTransitionUpdated percent: CGFloat) {
        statusBarBackground?.alpha = percent
        customNavigationBar?.alpha = percent
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
            omniBar.updatePrivacyIcon(for: privacyInfo)
        }
    }

    func tabDidRequestReportBrokenSite(tab: TabViewController) {
        launchReportBrokenSite()
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
        launchDownloads()
    }
    
    func tabDidRequestAutofillLogins(tab: TabViewController) {
        launchAutofillLogins(with: currentTab?.url)
    }
    
    func tabDidRequestSettings(tab: TabViewController) {
        launchSettings()
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
        let view = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController?.view
        return omniBar.searchContainer.convert(omniBar.searchContainer.bounds, to: view)
    }

    func tab(_ tab: TabViewController,
             didRequestPresentingTrackerAnimation privacyInfo: PrivacyInfo,
             isCollapsing: Bool) {
        guard tabManager.current === tab else { return }
        omniBar?.startTrackersAnimation(privacyInfo, forDaxDialog: !isCollapsing)
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
                self.performSegue(withIdentifier: Constants.showTabsSegue, sender: self)
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
    }
    
    func stopAllOngoingDownloads() {
        AppDependencyProvider.shared.downloadManager.cancelAllDownloads()
    }
    
    func forgetAllWithAnimation(transitionCompletion: (() -> Void)? = nil, showNextDaxDialog: Bool = false) {
        let spid = Instruments.shared.startTimedEvent(.clearingData)
        Pixel.fire(pixel: .forgetAllExecuted)
        DailyPixel.fire(pixel: .experimentDailyFireButtonDataCleared)
        
        self.tabCountInfo = tabManager.makeTabCountInfo()
        
        tabManager.prepareAllTabsExceptCurrentForDataClearing()
        
        fireButtonAnimator.animate {
            self.tabManager.prepareCurrentTabForDataClearing()
            
            self.stopAllOngoingDownloads()
            self.forgetData()
            DaxDialogs.shared.resumeRegularFlow()
            self.forgetTabs()
        } onTransitionCompleted: {
            ActionMessageView.present(message: UserText.actionForgetAllDone)
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
        if toolbar.isHidden {
            fireButtonView = tabsBarController?.fireButton
        } else {
            fireButtonView = fireButton.value(forKey: "view") as? UIView
        }
        guard let view = fireButtonView else { return }
        
        if !ViewHighlighter.highlightedViews.contains(where: { $0.view == view }) {
            ViewHighlighter.hideAll()
            ViewHighlighter.showIn(window, focussedOnView: view)
            
            if let fireButton = view as? FireButton {
                FireButtonExperiment.playFireButtonForOnboarding(fireButton: fireButton)
            }
        }
    }
    
}

extension MainViewController: Themable {
    
    func decorate(with theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()

        if AppWidthObserver.shared.isLargeWidth {
            statusBarBackground.backgroundColor = theme.tabsBarBackgroundColor
        } else {
            statusBarBackground.backgroundColor = theme.barBackgroundColor
        }

        view.backgroundColor = theme.backgroundColor

        customNavigationBar?.backgroundColor = theme.barBackgroundColor
        customNavigationBar?.tintColor = theme.barTintColor
        
        omniBar?.decorate(with: theme)
        progressView?.decorate(with: theme)
        
        toolbar?.barTintColor = theme.barBackgroundColor
        toolbar?.tintColor = theme.barTintColor
        
        fireButton.decorate(with: theme)
        tabSwitcherButton.decorate(with: theme)
        gestureBookmarksButton.decorate(with: theme)
        tabsButton.tintColor = theme.barTintColor
        
        presentedMenuButton.decorate(with: theme)
        
        tabManager.decorate(with: theme)

        findInPageView.decorate(with: theme)
        
        logoText.tintColor = theme.ddgTextTintColor
        
        FireButtonExperiment.decorateFireButton(fireButton: fireButton, for: theme)
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
        omniBar.backButton.menu = backMenu
        backButton.menu = backMenu
        
        let forwardMenu = historyMenu(with: currentTab.webView.backForwardList.forwardList)
        omniBar.forwardButton.menu = forwardMenu
        forwardButton.menu = forwardMenu
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

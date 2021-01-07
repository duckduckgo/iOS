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

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class MainViewController: UIViewController {
// swiftlint:enable type_body_length

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @IBOutlet weak var progressView: ProgressView!

    @IBOutlet weak var suggestionTrayContainer: UIView!
    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var fireButton: UIBarButtonItem!
    @IBOutlet weak var bookmarksButton: UIBarButtonItem!
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

    private lazy var appUrls: AppUrls = AppUrls()

    var tabManager: TabManager!
    private let previewsSource = TabPreviewsSource()
    fileprivate lazy var bookmarkStore: BookmarkUserDefaults = BookmarkUserDefaults()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()
    private weak var launchTabObserver: LaunchTabNotification.Observer?

    weak var tabSwitcherController: TabSwitcherViewController?
    let tabSwitcherButton = TabSwitcherButton()
    let gestureBookmarksButton = GestureToolbarButton()
    
    private var fireButtonAnimator: FireButtonAnimator?

    fileprivate lazy var tabSwitcherTransition = TabSwitcherTransitionDelegate()
    var currentTab: TabViewController? {
        return tabManager?.current
    }

    var keyModifierFlags: UIKeyModifierFlags?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        Favicons.shared.migrateIfNeeded {
            DispatchQueue.main.async {
                self.homeController?.collectionView.reloadData()
            }
        }
         
        attachOmniBar()

        view.addInteraction(UIDropInteraction(delegate: self))
        
        chromeManager = BrowserChromeManager()
        chromeManager.delegate = self
        initTabButton()
        initBookmarksButton()
        configureTabManager()
        loadInitialView()
        previewsSource.prepare()
        addLaunchTabNotificationObserver()
        fireButtonAnimator = FireButtonAnimator(appSettings: appSettings)

        findInPageView.delegate = self
        findInPageBottomLayoutConstraint.constant = 0
        registerForKeyboardNotifications()

        applyTheme(ThemeManager.shared.currentTheme)

        tabsBarController?.refresh(tabsModel: tabManager.model, scrollToSelected: true)

        _ = AppWidthObserver.shared.willResize(toWidth: view.frame.width)
        applyWidth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startOnboardingFlowIfNotSeenBefore()
        tabsBarController?.refresh(tabsModel: tabManager.model)
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

        let onboardingFlow = "DaxOnboarding"

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
    
    private func initBookmarksButton() {
        omniBar.bookmarksButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
                                                                                  action: #selector(quickSaveBookmarkLongPress(gesture:))))
        gestureBookmarksButton.delegate = self
        gestureBookmarksButton.image = UIImage(named: "Bookmarks")
        bookmarksButton.customView = gestureBookmarksButton
        bookmarksButton.isAccessibilityElement = true
        bookmarksButton.accessibilityTraits = .button
    }
    
    @objc func quickSaveBookmarkLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            quickSaveBookmark()
        }
    }
    
    @objc func quickSaveBookmark() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        guard currentTab != nil else {
            view.showBottomToast(UserText.webSaveBookmarkNone)
            return
        }
        
        Pixel.fire(pixel: .tabBarBookmarksLongPressed)
        
        currentTab!.saveAsBookmark(favorite: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        ViewHighlighter.hideAll()

        if let controller = segue.destination as? SuggestionTrayViewController {
            controller.dismissHandler = dismissSuggestionTray
            controller.autocompleteDelegate = self
            controller.favoritesOverlayDelegate = self
            suggestionTrayController = controller
            return
        }
        
        if let controller = segue.destination as? TabsBarViewController {
            controller.delegate = self
            tabsBarController = controller
            return
        }

        if segue.destination.children.count > 0,
            let controller = segue.destination.children[0] as? BookmarksViewController {
            controller.delegate = self
            return
        }

        if let controller = segue.destination as? TabSwitcherViewController {
            controller.transitioningDelegate = tabSwitcherTransition
            controller.delegate = self
            controller.tabsModel = tabManager.model
            controller.previewsSource = previewsSource
            tabSwitcherController = controller
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

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
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
                                delegate: self)
    }

    private func addLaunchTabNotificationObserver() {
        launchTabObserver = LaunchTabNotification.addObserver(handler: { urlString in
            guard let url = URL(string: urlString) else { return }

            self.loadUrlInNewTab(url)
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

    @available(iOS 13.4, *)
    func handlePressEvent(event: UIPressesEvent?) {
        keyModifierFlags = event?.modifierFlags
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard #available(iOS 13.4, *) else { return }
        handlePressEvent(event: event)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        guard #available(iOS 13.4, *) else { return }
        handlePressEvent(event: event)
    }

    private func attachOmniBar() {
        omniBar = OmniBar.loadFromXib()
        omniBar.omniDelegate = self
        omniBar.frame = customNavigationBar.bounds
        customNavigationBar.addSubview(omniBar)
    }

    fileprivate func attachHomeScreen() {
        logoContainer.isHidden = false
        findInPageView.isHidden = true
        chromeManager.detach()
        
        currentTab?.dismiss()
        removeHomeScreen()

        let controller = HomeViewController.loadFromStoryboard()
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

        let alert = ForgetDataAlert.buildAlert(forgetTabsAndDataHandler: { [weak self] in
            self?.forgetAllWithAnimation {}
        })
        self.present(controller: alert, fromView: self.toolbar)
    }
    
    func onQuickFirePressed() {
        self.forgetAllWithAnimation {}
        self.dismiss(animated: true)
        if KeyboardSettings().onAppLaunch {
            self.enterSearch()
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

    public var siteRating: SiteRating? {
        return currentTab?.siteRating
    }

    func loadQueryInNewTab(_ query: String, reuseExisting: Bool = false) {
        dismissOmniBar()
        let url = appUrls.url(forQuery: query)
        loadUrlInNewTab(url, reuseExisting: reuseExisting)
    }

    func loadUrlInNewTab(_ url: URL, reuseExisting: Bool = false) {
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
            addTab(url: url)
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
        let queryUrl = appUrls.url(forQuery: query)
        loadUrl(queryUrl)
    }

    func loadUrl(_ url: URL) {
        customNavigationBar.alpha = 1
        allowContentUnderflow = false
        currentTab?.load(url: url)
        guard let tab = currentTab else { fatalError("no tab") }
        select(tab: tab)
        dismissOmniBar()
    }

    private func addTab(url: URL?) {
        let tab = tabManager.add(url: url)
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
        containerView.addSubview(controller.view)
        controller.view.frame = containerView.bounds
        controller.didMove(toParent: self)

    }

    fileprivate func updateCurrentTab() {
        if let currentTab = currentTab {
            select(tab: currentTab)
        } else {
            attachHomeScreen()
        }
    }

    fileprivate func refreshControls() {
        refreshTabIcon()
        refreshOmniBar()
        refreshBackForwardButtons()
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
        updateSiteRating(tab.siteRating)
        omniBar.startBrowsing()
    }
    
    private func updateSiteRating(_ siteRating: SiteRating?) {
        omniBar.updateSiteRating(siteRating, with: AppDependencyProvider.shared.storageCache.current)
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

        self.currentTab?.showMenuHighlighterIfNeeded()
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
        }
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

    func showSuggestionTray(_ type: SuggestionTrayViewController.SuggestionType) {
        
        if suggestionTrayController?.willShow(for: type) ?? false {
            applyWidthToTrayController()

            if !AppWidthObserver.shared.isLargeWidth {
                ViewHighlighter.hideAll()
                if type.hideOmnibarSeparator() {
                    omniBar.hideSeparator()
                }
            }
            
            suggestionTrayContainer.isHidden = false
        }
        
    }
    
    func hideSuggestionTray() {
        omniBar.showSeparator()
        suggestionTrayContainer.isHidden = true
        suggestionTrayController?.didHide()
    }
    
    fileprivate func launchBrowsingMenu() {
        currentTab?.launchBrowsingMenu()
    }
    
    fileprivate func launchReportBrokenSite() {
        performSegue(withIdentifier: "ReportBrokenSite", sender: self)
    }
    
    fileprivate func launchSettings() {
        performSegue(withIdentifier: "Settings", sender: self)
    }

    fileprivate func launchInstructions() {
        performSegue(withIdentifier: "instructions", sender: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        notificationView?.layoutSubviews()
        let height = notificationView?.frame.size.height ?? 0
        notificationContainerHeight.constant = height

        if #available(iOS 11.0, *) {
            // no-op
        } else if traitCollection.containsTraits(in: .init(verticalSizeClass: .compact)),
            traitCollection.containsTraits(in: .init(horizontalSizeClass: .compact)) {
            // adjust frame to toolbar height change
            tabSwitcherButton.layoutSubviews()
            gestureBookmarksButton.layoutSubviews()
        }
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
        if #available(iOS 14, *) {
            guard feature.showNow(isDefaultBrowserSupported: true) else { return }
        } else {
            guard feature.showNow(isDefaultBrowserSupported: false) else { return }
        }

        showNotification(title: UserText.homeRowReminderTitle, message: UserText.homeRowReminderMessage) { tapped in
            if tapped {
                self.launchInstructions()
            }

            self.hideNotification()
        }

        feature.setShown()
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
    
    func updateFindInPage() {
        currentTab?.findInPage?.delegate = self
        findInPageView.update(with: currentTab?.findInPage, updateTextField: true)
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
        if percent < 1 { hideKeyboard() }
        
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
        if #available(iOS 11.0, *) {
            bottomHeight += view.safeAreaInsets.bottom
        }
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

    func onOmniQueryUpdated(_ updatedQuery: String) {
        if updatedQuery.isEmpty {
            if homeController != nil {
                hideSuggestionTray()
            } else {
                showSuggestionTray(.favorites)
            }
        } else {
            showSuggestionTray(.autocomplete(query: updatedQuery))
        }
        
    }

    func onOmniQuerySubmitted(_ query: String) {
        ViewHighlighter.hideAll()
        loadQuery(query)
        hideSuggestionTray()
        showHomeRowReminder()
    }

    func onSiteRatingPressed() {
        ViewHighlighter.hideAll()
        hideSuggestionTray()
        currentTab?.showPrivacyDashboard()
    }

    func onMenuPressed() {
        ViewHighlighter.hideAll()
        hideSuggestionTray()
        launchBrowsingMenu()
    }

    @objc func onBookmarksPressed() {
        ViewHighlighter.hideAll()
        hideSuggestionTray()
        performSegue(withIdentifier: "Bookmarks", sender: self)
    }
    
    func onEnterPressed() {
        guard !suggestionTrayContainer.isHidden else { return }
        
        suggestionTrayController?.willDismiss(with: omniBar.textField.text ?? "")
    }

    func onDismissed() {
        dismissOmniBar()
    }

    func onSettingsPressed() {
        ViewHighlighter.hideAll()
        launchSettings()
    }
    
    func onCancelPressed() {
        dismissOmniBar()
        hideSuggestionTray()
        homeController?.omniBarCancelPressed()
        self.currentTab?.showMenuHighlighterIfNeeded()
    }
    
    func onTextFieldWillBeginEditing(_ omniBar: OmniBar) {
        guard homeController == nil else { return }
        showSuggestionTray(.favorites)
    }

    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) {
        ViewHighlighter.hideAll()
        guard let homeController = homeController else { return }
        homeController.launchNewSearch()
    }
    
    func onRefreshPressed() {
        hideSuggestionTray()
        currentTab?.refresh()
    }
    
    func onSharePressed() {
        hideSuggestionTray()
        guard let link = currentTab?.link else { return }
        currentTab?.onShareAction(forLink: link, fromView: omniBar.shareButton)
    }
    
}

extension MainViewController: FavoritesOverlayDelegate {
    
    func favoritesOverlay(_ overlay: FavoritesOverlay, didSelect link: Link) {
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        Favicons.shared.loadFavicon(forDomain: link.url.host, intoCache: .bookmarks, fromCache: .tabs)
        loadUrl(link.url)
        showHomeRowReminder()
    }
}

extension MainViewController: AutocompleteViewControllerDelegate {

    func autocomplete(selectedSuggestion suggestion: Suggestion) {
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        if let url = suggestion.url {
            loadUrl(url)
        } else {
            loadQuery(suggestion.suggestion)
        }
        showHomeRowReminder()
    }

    func autocomplete(pressedPlusButtonForSuggestion suggestion: Suggestion) {
        if let url = suggestion.url {
            if AppUrls().isDuckDuckGoSearch(url: url) {
                omniBar.textField.text = suggestion.suggestion
            } else {
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
       loadUrl(url)
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
             for navigationAction: WKNavigationAction) -> WKWebView? {

        showBars()
        currentTab?.dismiss()

        let newTab = tabManager.addURLRequest(navigationAction.request, withConfiguration: configuration)
        newTab.openedByPage = true
        newTabAnimation {
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
        findInPageView.done()
        
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

    func tab(_ tab: TabViewController, didRequestNewBackgroundTabForUrl url: URL) {
        _ = tabManager.add(url: url, inBackground: true)
        animateBackgroundTab()
    }

    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL, openedByPage: Bool) {
        _ = findInPageView.resignFirstResponder()

        if openedByPage {
            showBars()
            newTabAnimation {
                self.loadUrlInNewTab(url)
                self.tabManager.current?.openedByPage = true
                self.tabManager.current?.openingTab = tab
            }
            tabSwitcherButton.incrementAnimated()
        } else {
            loadUrlInNewTab(url)
            self.tabManager.current?.openingTab = tab
        }

    }

    func tab(_ tab: TabViewController, didChangeSiteRating siteRating: SiteRating?) {
        if currentTab == tab {
            updateSiteRating(siteRating)
        }
    }

    func tabDidRequestReportBrokenSite(tab: TabViewController) {
        launchReportBrokenSite()
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

    func selectTab(_ tab: Tab) {
        guard let index = tabManager.model.indexOf(tab: tab) else { return }
        select(tabAt: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.onCancelPressed()
        }
    }

}

extension MainViewController: TabSwitcherDelegate {

    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController) {
        newTab()
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTab tab: Tab) {
        selectTab(tab)
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTab tab: Tab) {
        if tabManager.count == 1 {
            // Make sure UI updates finish before dimissing the view.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tabSwitcher.dismiss()
            }
        }
        closeTab(tab)
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
    func bookmarksDidSelect(link: Link) {
        dismissOmniBar()
        loadUrl(link.url)
    }
    
    func bookmarksUpdated() {
        if homeController != nil {
            removeHomeScreen()
            attachHomeScreen()
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
                self.performSegue(withIdentifier: "ShowTabs", sender: self)
            })
        }
    }
}

extension MainViewController: GestureToolbarButtonDelegate {
    
    func singleTapDetected(in sender: GestureToolbarButton) {
        Pixel.fire(pixel: .tabBarBookmarksPressed)
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
        
        ServerTrustCache.shared.clear()

        let pixel = TimedPixel(.forgetAllDataCleared)
        WebCacheManager.shared.clear {
            pixel.fire(withAdditionalParmaeters: [PixelParameters.tabCount: "\(self.tabManager.count)"])
        }
    }
    
    func forgetAllWithAnimation(transitionCompletion: (() -> Void)? = nil) {
        let spid = Instruments.shared.startTimedEvent(.clearingData)
        Pixel.fire(pixel: .forgetAllExecuted)
        
        fireButtonAnimator?.animate {
            self.forgetData()
            DaxDialogs.shared.resumeRegularFlow()
            self.forgetTabs()
        } onTransitionCompleted: {
            transitionCompletion?()
        } completion: {
            Instruments.shared.endTimedEvent(for: spid)
            if KeyboardSettings().onNewTab {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.enterSearch()
                }
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
        
        tabSwitcherButton.decorate(with: theme)
        gestureBookmarksButton.decorate(with: theme)
        tabsButton.tintColor = theme.barTintColor
        
        tabManager.decorate(with: theme)

        findInPageView.decorate(with: theme)
        
        logoText.tintColor = theme.ddgTextTintColor
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
                urls.forEach { self.loadUrlInNewTab($0) }
            }
            
        } else if session.canLoadObjects(ofClass: String.self) {
            _ = session.loadObjects(ofClass: String.self) { strings in
                self.loadQuery(strings[0])
            }
            
        }
        
    }
}

// swiftlint:enable file_length

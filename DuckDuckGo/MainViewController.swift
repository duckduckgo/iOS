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

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class MainViewController: UIViewController {
// swiftlint:enable type_body_length

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @IBOutlet weak var progressView: ProgressView!

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

    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var notificationContainerTop: NSLayoutConstraint!
    @IBOutlet weak var notificationContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var findInPageView: FindInPageView!
    @IBOutlet weak var findInPageBottomLayoutConstraint: NSLayoutConstraint!
    
    weak var notificationView: NotificationView?

    var omniBar: OmniBar!
    var chromeManager: BrowserChromeManager!

    var allowContentUnderflow = false {
        didSet {
            let constant = allowContentUnderflow ? -customNavigationBar.frame.size.height : 0
            containerViewTop.constant = constant
        }
    }
    
    var homeController: HomeViewController?
    var autocompleteController: AutocompleteViewController?

    private lazy var appUrls: AppUrls = AppUrls()

    var tabManager: TabManager!
    fileprivate lazy var bookmarkStore: BookmarkUserDefaults = BookmarkUserDefaults()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()
    private weak var launchTabObserver: LaunchTabNotification.Observer?

    weak var tabSwitcherController: TabSwitcherViewController?
    let tabSwitcherButton = TabSwitcherButton()
    let gestureBookmarksButton = GestureToolbarButton()

    fileprivate lazy var blurTransition = CompositeTransition(presenting: BlurAnimatedTransitioning(), dismissing: DissolveAnimatedTransitioning())

    var currentTab: TabViewController? {
        return tabManager?.current
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chromeManager = BrowserChromeManager()
        chromeManager.delegate = self
        initTabButton()
        initBookmarksButton()
        attachOmniBar()
        configureTabManager()
        loadInitialView()
        addLaunchTabNotificationObserver()

        findInPageView.delegate = self
        findInPageBottomLayoutConstraint.constant = 0
        registerForKeyboardNotifications()

        applyTheme(ThemeManager.shared.currentTheme)
        
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

        if #available(iOS 11, *) {
            let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
            let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
            let intersection = safeAreaFrame.intersection(keyboardFrameInView)
            height = intersection.height
            
        }

        findInPageBottomLayoutConstraint.constant = height
        currentTab?.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
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
        gestureBookmarksButton.delegate = self
        gestureBookmarksButton.image = UIImage(named: "Bookmarks")
        bookmarksButton.customView = gestureBookmarksButton
        bookmarksButton.isAccessibilityElement = true
        bookmarksButton.accessibilityTraits = .button
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.destination.children.count > 0,
            let controller = segue.destination.children[0] as? BookmarksViewController {
            controller.delegate = self
            return
        }

        if let controller = segue.destination as? TabSwitcherViewController {
            controller.transitioningDelegate = blurTransition
            controller.homePageSettingsDelegate = self
            controller.delegate = self
            controller.tabsModel = tabManager.model
            tabSwitcherController = controller
            return
        }

        if let controller = segue.destination as? SiteFeedbackViewController {
            controller.prepareForSegue(url: currentTab?.url?.absoluteString)
            return
        }
        
        if let navigationController = segue.destination as? UINavigationController,
            let controller = navigationController.topViewController as? SettingsViewController {
            controller.homePageSettingsDelegate = self
            return
        }
        
    }

    private func configureTabManager() {
        let tabsModel: TabsModel
        let shouldClearTabsModelOnStartup = AutoClearSettingsModel(settings: appSettings) != nil
        if shouldClearTabsModelOnStartup {
            tabsModel = TabsModel()
            tabsModel.save()
        } else {
            tabsModel = TabsModel.get() ?? TabsModel()
        }
        tabManager = TabManager(model: tabsModel, delegate: self)
    }

    private func addLaunchTabNotificationObserver() {
        launchTabObserver = LaunchTabNotification.addObserver(handler: { urlString in
            guard let url = URL(string: urlString) else { return }

            self.loadUrlInNewTab(url)
        })
    }

    private func loadInitialView() {
        if let tab = currentTab {
            addToView(tab: tab)
            refreshControls()
        } else {
            attachHomeScreen()
        }
    }

    private func attachOmniBar() {
        omniBar = OmniBar.loadFromXib()
        omniBar.omniDelegate = self
        omniBar.frame = customNavigationBar.bounds
        customNavigationBar.addSubview(omniBar)
    }

    fileprivate func attachHomeScreen() {
        findInPageView.isHidden = true
        removeHomeScreen()

        let controller = HomeViewController.loadFromStoryboard()
        homeController = controller

        controller.chromeDelegate = self
        controller.delegate = self

        addToView(controller: controller)

        tabManager.clearSelection()
        refreshControls()
    }

    fileprivate func removeHomeScreen() {
        homeController?.willMove(toParent: nil)
        homeController?.dismiss()
        homeController = nil
    }

    @IBAction func onFirePressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(forgetAllAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: toolbar)
    }
    
    func onQuickFirePressed() {
        forgetAll {}
        dismiss(animated: true)
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

    func loadQueryInNewTab(_ query: String) {
        let url = appUrls.url(forQuery: query)
        loadUrlInNewTab(url)
    }

    func loadUrlInNewTab(_ url: URL) {
        allowContentUnderflow = false
        customNavigationBar.alpha = 1
        loadViewIfNeeded()
        addTab(url: url)
        refreshOmniBar()
    }

    func launchNewSearch() {
        loadViewIfNeeded()
        attachHomeScreen()
        homeController?.launchNewSearch()
        omniBar.becomeFirstResponder()
    }

    fileprivate func loadQuery(_ query: String) {
        let queryUrl = appUrls.url(forQuery: query)
        loadUrl(queryUrl)
    }

    func loadUrl(_ url: URL) {
        if let currentTab = currentTab {
            currentTab.load(url: url)
        } else {
            loadUrlInNewTab(url)
        }
    }

    private func addTab(url: URL?) {
        let tab = tabManager.add(url: url)
        omniBar.resignFirstResponder()
        addToView(tab: tab)
    }

    func select(tabAt index: Int) {
        let tab = tabManager.select(tabAt: index)
        select(tab: tab)
    }

    fileprivate func select(tab: TabViewController) {
        addToView(tab: tab)
        refreshControls()
    }

    private func addToView(tab: TabViewController) {
        removeHomeScreen()
        updateFindInPage()
        currentTab?.progressWorker.progressBar = nil
        currentTab?.chromeDelegate = nil
        addToView(controller: tab)
        tab.progressWorker.progressBar = progressView
        tab.webView.scrollView.delegate = chromeManager
        tab.chromeDelegate = self
    }

    private func addToView(controller: UIViewController) {
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.view.frame = containerView.bounds
        controller.didMove(toParent: self)

    }

    fileprivate func remove(tabAt index: Int) {
        tabManager.remove(at: index)
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
        guard let tab = currentTab else {
            omniBar.stopBrowsing()
            return
        }

        omniBar.refreshText(forUrl: tab.url)
        omniBar.updateSiteRating(tab.siteRating)
        omniBar.startBrowsing()
    }

    fileprivate func dismissOmniBar() {
        omniBar.resignFirstResponder()
        dismissAutcompleteSuggestions()
        refreshOmniBar()
    }

    fileprivate func refreshBackForwardButtons() {
        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        dismissOmniBar()
    }

    fileprivate func displayAutocompleteSuggestions(forQuery query: String) {
        if autocompleteController == nil && appSettings.autocomplete {
            let controller = AutocompleteViewController.loadFromStoryboard()
            controller.shouldOffsetY = allowContentUnderflow
            controller.delegate = self
            addChild(controller)
            containerView.addSubview(controller.view)
            controller.didMove(toParent: self)
            autocompleteController = controller
            omniBar.hideSeparator()
        }
        guard let autocompleteController = autocompleteController else { return }
        autocompleteController.updateQuery(query: query)
    }

    fileprivate func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        omniBar.showSeparator()
        autocompleteController = nil
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

    fileprivate func launchBrowsingMenu() {
        currentTab?.launchBrowsingMenu()
    }

    private func forgetAllAction() -> UIAlertAction {
        let action = UIAlertAction(title: UserText.actionForgetAll, style: .destructive) { [weak self] _ in
            self?.forgetAll {}
        }
        action.accessibilityLabel = UserText.confirm
        return action
    }

    fileprivate func launchReportBrokenSite() {
        performSegue(withIdentifier: "ReportBrokenSite", sender: self)
    }

    fileprivate func launchSettings() {
        Pixel.fire(pixel: .settingsOpened)
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
        guard feature.showNow() else { return }

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
    }

    func replaceToolbar(item target: UIBarButtonItem, with replacement: UIBarButtonItem) {
        guard let items = toolbar.items else { return }

        let newItems = items.compactMap({
            $0 == target ? replacement : $0
        })

        toolbar.setItems(newItems, animated: false)
    }

    func newTab() {
        attachHomeScreen()
        homeController?.openedAsNewTab()
    }
    
    func updateFindInPage() {
        currentTab?.findInPage?.delegate = self
        findInPageView.update(with: currentTab?.findInPage)
    }
        
}

extension MainViewController: FindInPageDelegate {
    
    func updated(findInPage: FindInPage) {
        findInPageView.update(with: findInPage)
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
        omniBar.resignFirstResponder()
        _ = findInPageView.resignFirstResponder()
    }

    func setBarsHidden(_ hidden: Bool, animated: Bool) {
        if hidden { hideKeyboard() }

        updateToolbarConstant(hidden)
        updateNavBarConstant(hidden)

        if animated {

            self.view.layer.removeAllAnimations()

            UIView.animate(withDuration: ChromeAnimationConstants.duration, delay: 0.0, options: .allowUserInteraction, animations: {
                self.omniBar.alpha = hidden ? 0 : 1
                self.toolbar.alpha = hidden ? 0 : 1

                self.view.layoutIfNeeded()
            }, completion: nil)

        } else {
            setNavigationBarHidden(hidden)
            toolbar.alpha = hidden ? 0 : 1
        }

    }

    func setNavigationBarHidden(_ hidden: Bool) {
        if hidden { hideKeyboard() }
        
        updateNavBarConstant(hidden)
        omniBar.alpha = hidden ? 0 : 1
        statusBarBackground.alpha = hidden ? 0 : 1
    }

    var isToolbarHidden: Bool {
        return toolbar.alpha < 1
    }

    var toolbarHeight: CGFloat {
        return toolbar.frame.size.height
    }

    private func updateToolbarConstant(_ hidden: Bool) {
        var bottomHeight = self.toolbar.frame.size.height
        if #available(iOS 11.0, *) {
            bottomHeight += view.safeAreaInsets.bottom
        }
        toolbarBottom.constant = hidden ? bottomHeight : 0
    }

    private func updateNavBarConstant(_ hidden: Bool) {
        navBarTop.constant = hidden ? -self.customNavigationBar.frame.size.height : 0
    }

}

extension MainViewController: OmniBarDelegate {

    func onOmniQueryUpdated(_ updatedQuery: String) {
        displayAutocompleteSuggestions(forQuery: updatedQuery)
    }

    func onOmniQuerySubmitted(_ query: String) {
        loadQuery(query)
        dismissAutcompleteSuggestions()
        showHomeRowReminder()
    }

    func onSiteRatingPressed() {
        currentTab?.showPrivacyProtection()
    }

    func onMenuPressed() {
        launchBrowsingMenu()
    }

    func onBookmarksPressed() {
        performSegue(withIdentifier: "Bookmarks", sender: self)
    }

    func onDismissed() {
        dismissOmniBar()
    }

    func onSettingsPressed() {
        launchSettings()
    }
    
    func onCancelPressed() {
        dismissOmniBar()
        autocompleteController?.keyboardEscape()
        homeController?.omniBarCancelPressed()
    }

    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) {
        homeController?.launchNewSearch()
    }
    
    func onRefreshPressed() {
        currentTab?.refresh()
    }
    
}

extension MainViewController: AutocompleteViewControllerDelegate {

    func autocomplete(selectedSuggestion suggestion: String) {
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        loadQuery(suggestion)
        showHomeRowReminder()
    }

    func autocomplete(pressedPlusButtonForSuggestion suggestion: String) {
        omniBar.textField.text = suggestion
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
        loadUrlInNewTab(url)
    }

    func homeDidDeactivateOmniBar(home: HomeViewController) {
        dismissAutcompleteSuggestions()
        omniBar.resignFirstResponder()
    }

    func showInstructions(_ home: HomeViewController) {
        launchInstructions()
    }
    
    func showSettings(_ home: HomeViewController) {
        launchSettings()
    }
    
}

extension MainViewController: TabDelegate {

    func tabLoadingStateDidChange(tab: TabViewController) {
        findInPageView.done()
        
        if currentTab == tab {
            refreshControls()
        }
        tabManager?.save()
    }

    func tabDidRequestNewTab(_ tab: TabViewController) {
        _ = findInPageView.resignFirstResponder()
        newTab()
    }

    func tab(_ tab: TabViewController, didRequestNewBackgroundTabForUrl url: URL) {
        _ = tabManager.add(url: url, inBackground: true)
        animateBackgroundTab()
    }

    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL) {
        _ = findInPageView.resignFirstResponder()
        loadUrlInNewTab(url)
    }

    func tab(_ tab: TabViewController, didChangeSiteRating siteRating: SiteRating?) {
        if currentTab == tab {
            omniBar.updateSiteRating(siteRating)
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

}

extension MainViewController: TabSwitcherDelegate {

    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController) {
        newTab()
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTab tab: Tab) {
        guard let index = tabManager.model.indexOf(tab: tab) else { return }
        customNavigationBar.alpha = 1
        allowContentUnderflow = false
        select(tabAt: index)
    }

    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTab tab: Tab) {
        closeTab(tab)
    }
    
    func closeTab(_ tab: Tab) {
        guard let index = tabManager.model.indexOf(tab: tab) else { return }
        remove(tabAt: index)
    }

    func tabSwitcherDidRequestForgetAll(tabSwitcher: TabSwitcherViewController) {
        forgetAll {
            tabSwitcher.dismiss(animated: false, completion: nil)
        }
    }
    
    func tabSwitcherDidAppear(_ tabSwitcher: TabSwitcherViewController) {
        currentTab?.removeBrowsingTips()
    }
    
    func tabSwitcherDidDisappear(_ tabSwitcher: TabSwitcherViewController) {
        currentTab?.installBrowsingTips()
    }
    
}

extension MainViewController: BookmarksDelegate {
    func bookmarksDidSelect(link: Link) {
        omniBar.resignFirstResponder()
        loadUrl(link.url)
    }
    
    func bookmarksUpdated() {
        homeController?.refresh()
    }
}

extension MainViewController: TabSwitcherButtonDelegate {
    
    func showTabSwitcher() {
        Pixel.fire(pixel: .tabBarTabSwitcherPressed)
        performSegue(withIdentifier: "ShowTabs", sender: self)
    }

}

extension MainViewController: GestureToolbarButtonDelegate {
    
    func singleTapDetected(in sender: GestureToolbarButton) {
        Pixel.fire(pixel: .tabBarBookmarksPressed)
        onBookmarksPressed()
    }
    
    func longPressDetected(in sender: GestureToolbarButton) {
        guard currentTab != nil else {
            view.showBottomToast(UserText.webSaveBookmarkNone)
            return
        }
        currentTab!.promptSaveBookmarkAction()
    }
    
}

extension MainViewController: AutoClearWorker {
    
    func clearNavigationStack() {
        if let presented = presentedViewController {
            presented.dismiss(animated: false) { [weak self] in
                self?.clearNavigationStack()
            }
        }
    }
    
    func forgetTabs() {
        findInPageView?.done()
        tabManager.removeAll()
        showBars()
        attachHomeScreen()
    }
    
    func forgetData() {
        findInPageView?.done()
        ServerTrustCache.shared.clear()
        WebCacheManager.clear()
    }
    
    fileprivate func forgetAll(completion: @escaping () -> Void) {
        findInPageView.done()
        Pixel.fire(pixel: .forgetAllExecuted)
        forgetData()
        FireAnimation.animate {
            self.forgetTabs()
            completion()
        }
        let window = UIApplication.shared.keyWindow
        window?.showBottomToast(UserText.actionForgetAllDone, duration: 1)
    }
    
}

extension MainViewController: Themable {
    
    func decorate(with theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()

        view.backgroundColor = theme.backgroundColor
  
        statusBarBackground.backgroundColor = theme.barBackgroundColor
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
    }
    
}

extension MainViewController: HomePageSettingsDelegate {
    
    func homePageChanged(to config: HomePageConfiguration.ConfigName) {
        guard homeController != nil else { return }
        removeHomeScreen()
        attachHomeScreen()
    }
    
}

// swiftlint:enable file_length

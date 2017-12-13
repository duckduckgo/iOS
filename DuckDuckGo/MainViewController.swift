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

class MainViewController: UIViewController {

    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBarTop: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottom: NSLayoutConstraint!

    weak var fireButton: UIView!
    var omniBar: OmniBar!
    var chromeManager: BrowserChromeManager!

    fileprivate var homeController: HomeViewController?
    fileprivate var autocompleteController: AutocompleteViewController?

    private lazy var appUrls: AppUrls = AppUrls()
    fileprivate var tabManager: TabManager!
    fileprivate lazy var bookmarkStore: BookmarkUserDefaults = BookmarkUserDefaults()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()
    private weak var launchTabObserver: LaunchTabNotification.Observer?

    fileprivate var currentTab: TabViewController? {
        return tabManager?.current
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        chromeManager = BrowserChromeManager(delegate: self)
        attachOmniBar()
        configureTabManager()
        loadInitialView()
        addLaunchTabNotificationObserver()

        fireButton = toolbar.addFireButton { [weak self] in self?.launchFireMenu() }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.destination.childViewControllers.count > 0,
            let controller = segue.destination.childViewControllers[0] as? BookmarksViewController {
            controller.delegate = self
            return
        }

        if let controller = segue.destination as? TabSwitcherViewController {
            controller.transitioningDelegate = self
            controller.delegate = self
            controller.tabsModel = tabManager.model
            return
        }

    }

    private func configureTabManager() {
        let tabsModel = TabsModel.get() ?? TabsModel()
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
            attachHomeScreen(active: false)
        }
    }
    
    private func attachOmniBar() {
        omniBar = OmniBar.loadFromXib()
        omniBar.omniDelegate = self
        omniBar.frame = customNavigationBar.bounds
        customNavigationBar.addSubview(omniBar)
    }
    
    fileprivate func attachHomeScreen(active: Bool = true)  {
        removeHomeScreen()

        let controller = HomeViewController.loadFromStoryboard(active: active)
        homeController = controller

        controller.chromeDelegate = self
        controller.delegate = self

        addToView(controller: controller)

        tabManager.clearSelection()
        refreshControls()
    }
    
    fileprivate func removeHomeScreen() {
        homeController?.willMove(toParentViewController: nil)
        homeController?.dismiss()
        homeController = nil
    }
    
    @IBAction func onBackPressed() {
        currentTab?.goBack()
    }
    
    @IBAction func onForwardPressed() {
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
        loadRequestInNewTab(URLRequest(url: url))
    }
    
    func loadRequestInNewTab(_ request: URLRequest) {
        loadViewIfNeeded()
        addTab(forUrlRequest: request)
        refreshOmniBar()
    }

    func launchNewSearch() {
        loadViewIfNeeded()
        attachHomeScreen()
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
    
    private func addTab(forUrlRequest urlRequest: URLRequest) {
        let tab = tabManager.add(request: urlRequest)
        omniBar.resignFirstResponder()
        addToView(tab: tab)
    }

    fileprivate func select(tabAt index: Int) {
        let tab = tabManager.select(tabAt: index)
        select(tab: tab)
    }
    
    fileprivate func select(tab: TabViewController) {
        addToView(tab: tab)
        refreshControls()
    }
    
    private func addToView(tab: TabViewController) {
        removeHomeScreen()
        currentTab?.chromeDelegate = nil
        addToView(controller: tab)
        tab.webView.scrollView.delegate = chromeManager
        tab.chromeDelegate = self
    }

    private func addToView(controller: UIViewController) {
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.view.frame = containerView.bounds
        controller.didMove(toParentViewController: self)
    }

    fileprivate func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        if let currentTab = currentTab {
            select(tab: currentTab)
        } else {
            attachHomeScreen(active: false)
        }
    }
    
    fileprivate func forgetAll(completion: @escaping () -> Void) {
        ServerTrustCache.shared.clear()
        WebCacheManager.clear() {}
        FireAnimation.animate() {
            self.tabManager.removeAll()
            self.attachHomeScreen(active: false)
            completion()
        }
        let window = UIApplication.shared.keyWindow
        window?.showBottomToast(UserText.actionForgetAllDone, duration: 1)
    }
    
    fileprivate func refreshControls() {
        refreshOmniBar()
        refreshBackForwardButtons()
    }
    
    private func refreshOmniBar() {
        guard let tab = currentTab else {
            omniBar.stopBrowsing()
            return
        }

        if !tab.isError {
            omniBar.refreshText(forUrl: tab.link?.url)
        }

        omniBar.updateSiteRating(tab.siteRating)
        omniBar.startBrowsing()
    }
    
    fileprivate func dismissOmniBar() {
        omniBar.resignFirstResponder()
        dismissAutcompleteSuggestions()
        refreshOmniBar()
        homeController?.omniBarWasDismissed()
    }
    
    fileprivate func refreshBackForwardButtons() {
        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
    }
    
    fileprivate func displayAutocompleteSuggestions(forQuery query: String) {
        if autocompleteController == nil && appSettings.autocomplete {
            let controller = AutocompleteViewController.loadFromStoryboard()
            controller.delegate = self
            addChildViewController(controller)
            containerView.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
            autocompleteController = controller
        }
        guard let autocompleteController = autocompleteController else { return }
        autocompleteController.updateQuery(query: query)
    }
    
    fileprivate func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        autocompleteController = nil
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    fileprivate func launchBrowsingMenu() {
        currentTab?.launchBrowsingMenu()
    }
    
    private func launchFireMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(forgetAllAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: fireButton)
    }

    private func forgetAllAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionForgetAll, style: .destructive) { [weak self] action in
            self?.forgetAll() {}
        }
    }

    fileprivate func launchSettings() {
        let controller = SettingsViewController.loadFromStoryboard()
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }

}

extension MainViewController: BrowserChromeDelegate {

    struct ChromeAnimationConstants {
        static let duration = 0.3
    }

    func setBarsHidden(_ hidden: Bool, animated: Bool) {

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
        updateNavBarConstant(hidden)
        omniBar.alpha = hidden ? 0 : 1
    }

    var isToolbarHidden: Bool {
        get { return toolbar.alpha < 1 }
    }

    var toolbarHeight: CGFloat {
        get { return toolbar.frame.size.height }
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
}

extension MainViewController: AutocompleteViewControllerDelegate {
    
    func autocomplete(selectedSuggestion suggestion: String) {
        homeController?.chromeDelegate = nil
        dismissOmniBar()
        loadQuery(suggestion)
    }
    
    func autocomplete(pressedPlusButtonForSuggestion suggestion: String) {
        omniBar.textField.text = suggestion
    }
    
    func autocompleteWasDismissed() {
        dismissOmniBar()
    }
}

extension MainViewController: HomeControllerDelegate {
    
    func homeDidActivateOmniBar(home: HomeViewController) {
        omniBar.clear()
        omniBar.becomeFirstResponder()
    }
    
    func homeDidDeactivateOmniBar(home: HomeViewController) {
        dismissAutcompleteSuggestions()
        omniBar.resignFirstResponder()
    }
    
    func homeDidRequestForgetAll(home: HomeViewController) {
        forgetAll() {}
    }
    
    func home(_ home: HomeViewController, didRequestQuery query: String) {
        loadQueryInNewTab(query)
    }
    
    func home(_ home: HomeViewController, didRequestUrl url: URL) {
        loadUrlInNewTab(url)
    }
}

extension MainViewController: TabDelegate {
    
    func tabLoadingStateDidChange(tab: TabViewController) {
        if currentTab == tab {
            refreshControls()
        }
        tabManager?.save()
    }

    func tabDidRequestNewTab(_ tab: TabViewController) {
        attachHomeScreen()
    }
    
    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL) {
        loadUrlInNewTab(url)
    }

    func tab(_ tab: TabViewController, didChangeSiteRating siteRating: SiteRating?) {
        if currentTab == tab {
            omniBar.updateSiteRating(siteRating)
        }
    }
    
    func tabDidRequestSettings(tab: TabViewController) {
        launchSettings()
    }
    
    func tabContentProcessDidTerminate(tab: TabViewController) {
        tabManager.invalidateCache(forController: tab)
    }
    
    func showBars() {
        chromeManager.reset()
    }
    
}

extension MainViewController: TabSwitcherDelegate {
    
    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController) {
        attachHomeScreen()
    }
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTabAt index: Int) {
        select(tabAt: index)
    }
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTabAt index: Int) {
        remove(tabAt: index)
    }
    
    func tabSwitcherDidRequestForgetAll(tabSwitcher: TabSwitcherViewController) {
        forgetAll() {
            tabSwitcher.dismiss(animated: false, completion:  nil)
        }
    }
}

extension MainViewController: BookmarksDelegate {
    func bookmarksDidSelect(link: Link) {
        omniBar.resignFirstResponder()
        loadUrl(link.url)
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BlurAnimatedTransitioning()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DissolveAnimatedTransitioning()
    }
}



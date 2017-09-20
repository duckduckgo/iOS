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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var tabsButton: UIButton!
    weak var omniBar: OmniBar!

    fileprivate var homeController: HomeViewController?
    fileprivate var autocompleteController: AutocompleteViewController?

    private lazy var appUrls: AppUrls = AppUrls()
    fileprivate var tabManager: TabManager!
    fileprivate lazy var bookmarkStore = BookmarkUserDefaults()
    fileprivate lazy var appSettings: AppSettings = AppUserDefaults()

    fileprivate var currentTab: TabViewController? {
        return tabManager.current
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachOmniBar()
        configureTabManager()
        loadInitialView()
    }
    
    private func configureTabManager() {
        let tabsModel = TabsModel.get() ?? TabsModel()
        tabManager = TabManager(model: tabsModel, delegate: self)
    }
    
    private func loadInitialView() {
        if let tab = currentTab {
            addToView(tab: tab)
            refreshControls()
        } else {
            attachHomeScreen(active: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showiOS11Popup()
    }
    
    private func showiOS11Popup() {
        var settings = TutorialSettings()
        if !settings.hasSeenOnboarding || settings.hasSeeniOS11Popup {
            return
        }
        
        if #available(iOS 11.0, *) {
            let title = "iOS 11 Update Coming Soon"
            let message = "You may notice that our app looks a little odd on iOS 11. Never fear, an update is coming soon!"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true, completion: nil)
            settings.hasSeeniOS11Popup = true
        }
    }

    private func attachOmniBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        omniBar = OmniBar.loadFromXib()
        omniBar.omniDelegate = self
        omniBar.frame = navigationBar.bounds
        navigationBar.addSubview(omniBar)
        navigationBar.addEqualSizeConstraints(subView: omniBar)
    }
    
    fileprivate func attachHomeScreen(active: Bool = true)  {
        removeHomeScreen()
        let controller = HomeViewController.loadFromStoryboard(active: active)
        homeController = controller
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
    
    @IBAction func onFirePressed() {
        launchFireMenu()
    }
    
    @IBAction func onBookmarksTapped() {
        launchBookmarks()
    }
    
    @IBAction func onTabsTapped() {
        launchTabSwitcher()
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
    
    fileprivate func loadUrl(_ url: URL) {
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
        let selectedTab = tabManager.select(tabAt: index)
        addToView(tab: selectedTab)
        refreshControls()
    }
    
    private func addToView(tab: UIViewController) {
        removeHomeScreen()
        addToView(controller: tab)
    }

    private func addToView(controller: UIViewController) {
        controller.view.frame = containerView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

    fileprivate func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        if let index = tabManager.currentIndex {
            select(tabAt: index)
        } else {
            attachHomeScreen(active: false)
        }
    }
    
    fileprivate func forgetAll(completion: @escaping () -> Swift.Void) {
        WebCacheManager.clear() {}
        FireAnimation.animate() {
            completion()
            self.tabManager.clearAll()
            self.attachHomeScreen(active: false)
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
        omniBar.refreshText(forUrl: tab.link?.url)
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

    fileprivate func launchContentBlockerPopover() {
        currentTab?.launchContentBlockerPopover()
    }
    
    fileprivate func launchTabSwitcher() {
        if let currentTab = currentTab {
            tabManager.updateModelFromTab(tab: currentTab)
        }
        let controller = TabSwitcherViewController.loadFromStoryboard(delegate: self, tabsModel: tabManager.model)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func launchBookmarks() {
        let controller = BookmarksViewController.loadFromStoryboard(delegate: self)
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func launchSettings() {
        let controller = SettingsViewController.loadFromStoryboard()
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
}

extension MainViewController: OmniBarDelegate {
    
    func onOmniQueryUpdated(_ updatedQuery: String) {
        displayAutocompleteSuggestions(forQuery: updatedQuery)
    }
    
    func onOmniQuerySubmitted(_ query: String) {
        dismissOmniBar()
        loadQuery(query)
    }
    
    func onSiteRatingPressed() {
        launchContentBlockerPopover()
    }
    
    func onMenuPressed() {
        launchBrowsingMenu()
    }
    
    func onBookmarksPressed() {
        launchBookmarks()
    }
    
    func onDismissed() {
        dismissOmniBar()
    }
}

extension MainViewController: AutocompleteViewControllerDelegate {
    
    func autocomplete(selectedSuggestion suggestion: String) {
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
        refreshControls()
        tabManager.updateModelFromTab(tab: tab)
    }

    func tabDidRequestNewTab(_ tab: TabViewController) {
        attachHomeScreen()
    }
    
    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL) {
        loadUrlInNewTab(url)
    }

    func tab(_ tab: TabViewController, didChangeSiteRating siteRating: SiteRating?) {
        omniBar.updateSiteRating(siteRating)
    }
    
    func tabDidRequestSettings(tab: TabViewController) {
        launchSettings()
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

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

    fileprivate var tabManager: TabManager!
    fileprivate lazy var bookmarkStore = BookmarkUserDefaults()
    private lazy var contentBlocker =  ContentBlocker()
    
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
        tabManager = TabManager(model: tabsModel, contentBlocker: contentBlocker, delegate: self)
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
        navigationController?.navigationBar.addSubview(omniBar)
    }
    
    fileprivate func attachHomeScreen(active: Bool = true)  {
        removeHomeScreen()
        let controller = HomeViewController.loadFromStoryboard()
        homeController = controller
        controller.delegate = self
        addToView(controller: controller)
        tabManager.clearSelection()
        controller.refreshMode(active: active)
        refreshControls()
    }
    
    fileprivate func removeHomeScreen() {
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
        guard let url = AppUrls.url(forQuery: query) else { return }
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
    
    fileprivate func loadQuery(_ query: String) {
        guard let queryUrl = AppUrls.url(forQuery: query) else { return }
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
    }

    fileprivate func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        if let index = tabManager.currentIndex {
            select(tabAt: index)
        } else {
            attachHomeScreen(active: false)
        }
    }

    fileprivate func forgetCurrentPage(animated: Bool) {
        guard let tab = currentTab else { return }
        tab.forgetPage()
        
        let completion = {
            self.tabManager.remove(tab: tab)
            self.attachHomeScreen(active: false)
        }
        
        if animated {
            FireAnimation.animate(withCompletion: completion)
        } else {
            completion()
        }
    }
    
    fileprivate func forgetAll(animated: Bool) {
        WebCacheManager.clear() {}
        let completion = {
            self.tabManager.clearAll()
            self.attachHomeScreen(active: false)
        }
        
        if animated {
            FireAnimation.animate(withCompletion: completion)
        } else {
            completion()
        }
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
        omniBar.updateContentBlockerMonitor(monitor: tab.contentBlockerMonitor)
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
        if autocompleteController == nil {
            let controller = AutocompleteViewController.loadFromStoryboard()
            controller.delegate = self
            addChildViewController(controller)
            containerView.addSubview(controller.view)
            autocompleteController = controller
        }
        guard let autocompleteController = autocompleteController else { return }
        autocompleteController.updateQuery(query: query)
    }
    
    fileprivate func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        autocompleteController = nil
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    fileprivate func launchBrowsingMenu() {
        currentTab?.launchBrowsingMenu()
    }
    
    private func launchFireMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if currentTab != nil {
            alert.addAction(forgetPageAction())
        }
        alert.addAction(forgetAllAction())
        alert.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel))
        present(controller: alert, fromView: fireButton)
    }
    
    private func forgetPageAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionForgetPage, style: .default) { [weak self] action in
            self?.forgetCurrentPage(animated: true)
        }
    }
    
    private func forgetAllAction() -> UIAlertAction {
        return UIAlertAction(title: UserText.actionForgetAll, style: .destructive) { [weak self] action in
            self?.forgetAll(animated: true)
        }
    }

    fileprivate func launchContentBlockerPopover() {
        currentTab?.launchContentBlockerPopover()
    }
    
    fileprivate func launchTabSwitcher() {
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
    
    func onMenuPressed() {
        launchBrowsingMenu()
    }
    
    func onBookmarksPressed() {
        launchBookmarks()
    }
    
    func onContenBlockerPressed() {
        launchContentBlockerPopover()
    }
    
    func onDismissButtonPressed() {
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
        omniBar.becomeFirstResponder()
    }
    
    func homeDidDeactivateOmniBar(home: HomeViewController) {
        dismissAutcompleteSuggestions()
        omniBar.resignFirstResponder()
        omniBar.clear()
    }
    
    func homeDidRequestForgetAll(home: HomeViewController) {
        forgetAll(animated: true)
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
    
    func tab(_ tab: TabViewController, contentBlockerMonitorForCurrentPageDidChange monitor: ContentBlockerMonitor) {
        omniBar.updateContentBlockerMonitor(monitor: monitor)
    }

    func tabDidRequestNewTab(_ tab: TabViewController) {
        attachHomeScreen()
    }
    
    func tabDidRequestTabSwitcher(tab: TabViewController) {
        launchTabSwitcher()
    }
    
    func tabDidRequestBookmarks(tab: TabViewController) {
        launchBookmarks()
    }
    
    func tabDidRequestSettings(tab: TabViewController) {
        launchSettings()
    }
    
    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL) {
        loadUrlInNewTab(url)
    }
    
    func tab(_ tab: TabViewController, didRequestNewTabForRequest urlRequest: URLRequest) {
        loadRequestInNewTab(urlRequest)
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
        forgetAll(animated: false)
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

//
//  MainViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit
import Core

class MainViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    weak var omniBar: OmniBar!

    fileprivate var homeController: HomeViewController?
    fileprivate var autocompleteController: AutocompleteViewController?
    
    fileprivate lazy var bookmarkStore = BookmarkUserDefaults()
    fileprivate lazy var searchFilterStore = SearchFilterUserDefaults()
    fileprivate lazy var tabManager = TabManager()
    private lazy var contentBlocker =  ContentBlocker()
    
    fileprivate var currentTab: Tab? {
        return tabManager.current
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachOmniBar()
        attachHomeScreen()
    }
    
    override func viewDidLayoutSubviews() {
        updateAutocompleteSize()
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
    
    func loadQueryInNewTab(_ query: String) {
        guard let url = AppUrls.url(forQuery: query, filters: searchFilterStore) else { return }
        loadUrlInNewTab(url)
    }
    
    func loadUrlInNewTab(_ url: URL) {
        loadViewIfNeeded()
        currentTab?.dismiss()
        attachTab(forUrl: url)
        refreshControls()
    }
    
    fileprivate func loadQuery(_ query: String) {
        guard let queryUrl = AppUrls.url(forQuery: query, filters: searchFilterStore) else { return }
        loadUrl(queryUrl)
    }
    
    fileprivate func loadUrl(_ url: URL) {
        if let currentTab = currentTab {
            currentTab.load(url: url)
        } else {
            loadUrlInNewTab(url)
        }
    }
    
    fileprivate func launchTabFrom(webTab: WebTabViewController, forUrl url: URL) {
        launchTabFrom(webTab: webTab, forUrlRequest: URLRequest(url: url))
    }
    
    fileprivate func launchTabFrom(webTab: WebTabViewController, forUrlRequest urlRequest: URLRequest) {
        attachSiblingTab(fromWebView: webTab.webView, forUrlRequest: urlRequest)
        refreshControls()
    }
    
    private func attachTab(forUrl url: URL) {
        let tab = WebTabViewController.loadFromStoryboard(contentBlocker: contentBlocker)
        tab.attachNewWebView(persistsData: true)
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        tab.load(url: url)
        addToView(tab: tab)
    }
    
    private func attachSiblingTab(fromWebView webView: WKWebView, forUrlRequest urlRequest: URLRequest) {
        let tab = WebTabViewController.loadFromStoryboard(contentBlocker: contentBlocker)
        tab.attachWebView(newWebView: webView.createSiblingWebView())
        tab.tabDelegate = self
        tabManager.add(tab: tab)
        tab.load(urlRequest: urlRequest)
        addToView(tab: tab)
    }
    
    fileprivate func select(tabAt index: Int) {
        let selectedTab = tabManager.select(tabAt: index) as! UIViewController
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
        
        if tabManager.isEmpty {
            attachHomeScreen(active: false)
            return
        }
        
        if let lastIndex = tabManager.lastIndex, index > lastIndex {
            select(tabAt: lastIndex)
            return
        }
        
        select(tabAt: index)
    }
    
    fileprivate func clearAllTabs() {
        tabManager.clearAll()
        attachHomeScreen(active: false)
    }
    
    fileprivate func refreshControls() {
        refreshOmniBar()
        refreshNavigationButtons()
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
    }
    
    private func refreshOmniBar() {
        guard let tab = currentTab else {
            omniBar.clear()
            return
        }
        omniBar.refreshText(forUrl: tab.url)
        omniBar.updateContentBlockerCount(count: tab.contentBlockerCount)
        omniBar.isBrowsing = currentTab != nil
    }
    
    fileprivate func updateOmniBar(withQuery updatedQuery: String) {
        displayAutocompleteSuggestions(forQuery: updatedQuery)
    }
    
    private func displayAutocompleteSuggestions(forQuery query: String) {
        if autocompleteController == nil {
            let controller = AutocompleteViewController.loadFromStoryboard()
            controller.delegate = self
            addChildViewController(controller)
            containerView.addSubview(controller.view)
            autocompleteController = controller
            updateAutocompleteSize()
        }
        guard let autocompleteController = autocompleteController else { return }
        autocompleteController.updateQuery(query: query)
    }
    
    private func updateAutocompleteSize() {
        autocompleteController?.widthConstraint.constant = omniBar.frame.width
    }
    
    fileprivate func dismissOmniBar() {
        omniBar.resignFirstResponder()
        dismissAutcompleteSuggestions()
        refreshOmniBar()
        homeController?.omniBarWasDismissed()
        currentTab?.omniBarWasDismissed()
    }
    
    fileprivate func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        autocompleteController = nil
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    fileprivate func launchMenu() {
        currentTab?.launchBrowsingMenu()
    }
    
    fileprivate func launchContentBlockerPopover() {
        currentTab?.launchContentBlockerPopover()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        currentTab?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        currentTab?.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = currentTab?.url {
            let title = currentTab?.name ?? ""
            var items: [Any] = [url, title]
            if let favicon = currentTab?.favicon {
                items.append(favicon)
            }
            presentShareSheet(withItems: items, fromButtonItem: sender)
        }
    }
    
    @IBAction func onSaveBookmark(_ sender: UIBarButtonItem) {
        if let link = currentTab?.link {
            bookmarkStore.addBookmark(link)
            makeToast(text: UserText.webSaveLinkDone)
        }
    }
    
    @IBAction func onTabButtonPressed(_ sender: UIBarButtonItem) {
        launchTabSwitcher()
    }
    
    fileprivate func launchTabSwitcher() {
        let index = tabManager.currentIndex
        let controller = TabSwitcherViewController.loadFromStoryboard(delegate: self, scrollTo: index)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onBookmarksButtonPressed(_ sender: UIBarButtonItem) {
        launchBookmarks()
    }
    
    fileprivate func launchBookmarks() {
        let controller = BookmarksViewController.loadFromStoryboard(delegate: self)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true, completion: nil)
    }
    
    private func makeToast(text: String) {
        let x = view.bounds.size.width / 2.0
        let y = view.bounds.size.height - 80
        view.makeToast(text, duration: ToastManager.shared.duration, position: CGPoint(x: x, y: y))
    }
}

extension MainViewController: OmniBarDelegate {
    
    func onOmniQueryUpdated(_ updatedQuery: String) {
        updateOmniBar(withQuery: updatedQuery)
    }
    
    func onOmniQuerySubmitted(_ query: String) {
        dismissOmniBar()
        loadQuery(query)
    }
    
    func onMenuPressed() {
        launchMenu()
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
    
    func homeControllerDidActivateOmniBar(homeController: HomeViewController) {
        omniBar.becomeFirstResponder()
    }
    
    func homeControllerDidDeactivateOmniBar(homeController: HomeViewController) {
        dismissAutcompleteSuggestions()
        omniBar.resignFirstResponder()
        omniBar.clear()
    }
    
    func homeController(_ homeController: HomeViewController, didRequestQuery query: String) {
        loadQueryInNewTab(query)
    }
    
    func homeController(_ homeController: HomeViewController, didRequestUrl url: URL) {
        loadUrlInNewTab(url)
    }
}

extension MainViewController: WebTabDelegate {
    
    func webTabLoadingStateDidChange(webTab: WebTabViewController) {
        refreshControls()
    }
    
    func webTab(_ webTab: WebTabViewController, contentBlockingCountForCurrentPageDidChange count: Int) {
        omniBar.updateContentBlockerCount(count: count)
    }
    
    func webTab(_ webTab: WebTabViewController, didRequestNewTabForUrl url: URL) {
        launchTabFrom(webTab: webTab, forUrl: url)
    }
    
    func webTab(_ webTab: WebTabViewController, didRequestNewTabForRequest urlRequest: URLRequest) {
        launchTabFrom(webTab: webTab, forUrlRequest: urlRequest)
    }
}

extension MainViewController: TabSwitcherDelegate {
    
    var tabDetails: [Link] {
        return tabManager.tabDetails
    }
    
    func tabSwitcherDidRequestNewTab(tabSwitcher: TabSwitcherViewController) {
        attachHomeScreen()
    }
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didSelectTabAt index: Int) {
        select(tabAt: index)
    }
    
    func tabSwitcher(_ tabSwitcher: TabSwitcherViewController, didRemoveTabAt index: Int) {
        remove(tabAt: index)
    }
    
    func tabSwitcherDidRequestClearAll(tabSwitcher: TabSwitcherViewController) {
        clearAllTabs()
    }
}

extension MainViewController: BookmarksDelegate {
    func bookmarksDidSelect(link: Link) {
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

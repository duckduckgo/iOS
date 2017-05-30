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
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    let reachability = Reachability()!
    var previouslyReachable = false
    
    fileprivate var autocompleteController: AutocompleteViewController?
    
    fileprivate lazy var groupData = GroupDataStore()
    fileprivate lazy var tabManager = TabManager()
    
    weak var omniBar: OmniBar?
    
    fileprivate var currentTab: Tab? {
        return tabManager.current
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        launchTab(active: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                    if !self.previouslyReachable {
                        self.currentTab?.reload()
                        self.previouslyReachable = true
                    }
                    self.makeToast(text: "Using Wifi Connection")
                } else {
                    print("Reachable via Cellular")
                    if !self.previouslyReachable {
                        self.currentTab?.reload()
                        self.previouslyReachable = true
                    }
                    self.makeToast(text: "Using 3G Connection")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                print("Not reachable")
                self.previouslyReachable = false
                self.makeToast(text: "Lost Internet Connection")
                
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reachability.stopNotifier()
    }
    
    override func viewDidLayoutSubviews() {
        updateAutocompleteSize()
    }
    
    func loadQueryInNewWebTab(query: String) {
        if let url = AppUrls.url(forQuery: query, filters: groupData) {
            loadUrlInNewWebTab(url: url)
        }
    }
    
    func loadUrlInNewWebTab(url: URL) {
        loadViewIfNeeded()
        if let homeTab = currentTab as? HomeTabViewController {
            tabManager.remove(tab: homeTab)
        }
        currentTab?.dismiss()
        attachWebTab(forUrl: url)
        refreshControls()
    }
    
    fileprivate func loadQueryInCurrentTab(query: String) {
        if let queryUrl = AppUrls.url(forQuery: query, filters: groupData) {
            loadUrlInCurrentTab(url: queryUrl)
        }
    }
    
    fileprivate func loadUrlInCurrentTab(url: URL) {
        currentTab?.load(url: url)
    }
    
    fileprivate func launchTab(active: Bool? = nil) {
        let active = active ?? true
        attachHomeTab(active: active)
        refreshControls()
    }
    
    fileprivate func launchTabFrom(webTab: WebTabViewController, forUrl url: URL) {
        launchTabFrom(webTab: webTab, forUrlRequest: URLRequest(url: url))
    }
    
    fileprivate func launchTabFrom(webTab: WebTabViewController, forUrlRequest urlRequest: URLRequest) {
        refreshTabIcon(count: tabManager.count+1)
        attachSiblingWebTab(fromWebView: webTab.webView, forUrlRequest: urlRequest)
        refreshControls()
    }
    
    private func attachHomeTab(active: Bool = false) {
        let tab = HomeTabViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        addToView(tab: tab)
        if active {
            tab.enterActiveMode()
        }
    }
    
    private func attachWebTab(forUrl url: URL) {
        let tab = WebTabViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        tab.load(url: url)
        addToView(tab: tab)
    }
    
    private func attachSiblingWebTab(fromWebView webView: WKWebView, forUrlRequest urlRequest: URLRequest) {
        let tab = WebTabViewController.loadFromStoryboard()
        tab.attachWebView(newWebView: webView.createSiblingWebView())
        tab.tabDelegate = self
        tabManager.add(tab: tab)
        tab.load(urlRequest: urlRequest)
        addToView(tab: tab)
    }
    
    private func addToView(tab: UIViewController) {
        if let tab = tab as? Tab {
            resetOmniBar(withStyle: tab.omniBarStyle)
        }
        tab.view.frame = containerView.frame
        tab.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(tab)
        containerView.addSubview(tab.view)
    }
    
    fileprivate func select(tabAt index: Int) {
        let selectedTab = tabManager.select(tabAt: index) as! UIViewController
        addToView(tab: selectedTab)
        refreshControls()
    }
    
    fileprivate func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        
        if tabManager.isEmpty {
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
        launchTab(active: false)
    }
    
    private func resetOmniBar(withStyle style: OmniBar.Style) {
        if omniBar?.style == style {
            return
        }
        let omniBarText = omniBar?.textField.text
        omniBar = OmniBar.loadFromXib(withStyle: style)
        omniBar?.textField.text = omniBarText
        omniBar?.omniDelegate = self
        navigationItem.titleView = omniBar
    }
    
    fileprivate func refreshControls() {
        refreshOmniText()
        refreshTabIcon()
        refreshNavigationButtons()
        refreshShareButton()
    }
    
    private func refreshTabIcon() {
        refreshTabIcon(count: tabManager.count)
    }
    
    private func refreshTabIcon(count: Int) {
        tabsButton.image = TabIconMaker().icon(forTabs: count)
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = currentTab?.canGoBack ?? false
        forwardButton.isEnabled = currentTab?.canGoForward ?? false
    }
    
    private func refreshShareButton() {
        shareButton.isEnabled = currentTab?.canShare ?? false
    }
    
    private func refreshOmniText() {
        guard let tab = currentTab else {
            return
        }
        if tab.showsUrlInOmniBar {
            omniBar?.refreshText(forUrl: tab.url)
        } else {
            omniBar?.clear()
        }
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
        if let omniBarWidth = omniBar?.frame.width, let autocompleteController = autocompleteController {
            autocompleteController.widthConstraint.constant = omniBarWidth
        }
    }
    
    fileprivate func dismissOmniBar() {
        omniBar?.resignFirstResponder()
        dismissAutcompleteSuggestions()
        refreshOmniText()
        currentTab?.omniBarWasDismissed()
    }
    
    private func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        autocompleteController = nil
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
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
            groupData.addBookmark(link)
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
        present(controller, animated: false, completion: nil)
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
        loadQueryInCurrentTab(query: query)
    }
    
    func onFireButtonPressed() {
        dismissOmniBar()
        if let index = tabManager.currentIndex {
            remove(tabAt: index)
        }
        if groupData.omniFireOpensNewTab {
            launchTab()
        } else {
            launchTabSwitcher()
        }
    }
    
    func onBookmarksButtonPressed() {
        launchBookmarks()
    }
    
    func onRefreshButtonPressed() {
        currentTab?.reload()
    }
    
    func onDismissButtonPressed() {
        dismissOmniBar()
    }
}

extension MainViewController: AutocompleteViewControllerDelegate {
    
    func autocomplete(selectedSuggestion suggestion: String) {
        dismissOmniBar()
        loadQueryInCurrentTab(query: suggestion)
    }
    
    func autocomplete(pressedPlusButtonForSuggestion suggestion: String) {
        omniBar?.textField.text = suggestion
    }
    
    func autocompleteWasDismissed() {
        dismissOmniBar()
    }
}

extension MainViewController: HomeTabDelegate {
    
    func homeTabDidActivateOmniBar(homeTab: HomeTabViewController) {
        omniBar?.becomeFirstResponder()
    }
    
    func homeTabDidDeactivateOmniBar(homeTab: HomeTabViewController) {
        omniBar?.resignFirstResponder()
        omniBar?.clear()
    }
    
    func homeTab(_ homeTab: HomeTabViewController, didRequestQuery query: String) {
        loadQueryInNewWebTab(query: query)
    }
    
    func homeTab(_ homeTab: HomeTabViewController, didRequestUrl url: URL) {
        loadUrlInNewWebTab(url: url)
    }
    
    func homeTabDidRequestTabsSwitcher(homeTab: HomeTabViewController) {
        launchTabSwitcher()
    }
    
    func homeTabDidRequestBookmarks(homeTab: HomeTabViewController) {
        launchBookmarks()
    }
    
    func homeTabDidRequestTabCount(homeTab: HomeTabViewController) -> Int {
        return tabManager.count
    }
}

extension MainViewController: WebTabDelegate {
    
    func webTabLoadingStateDidChange(webTab: WebTabViewController) {
        refreshControls()
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
        launchTab()
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
        loadUrlInCurrentTab(url: link.url)
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

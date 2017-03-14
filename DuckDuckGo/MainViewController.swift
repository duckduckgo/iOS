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
    
    fileprivate var autocompleteController: AutocompleteViewController?
    
    fileprivate lazy var groupData = GroupData()
    fileprivate lazy var settings = Settings()
    fileprivate lazy var tabManager = TabManager()
    
    weak var omniBar: OmniBar?
    
    fileprivate var currentTab: Tab? {
        return tabManager.current
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachHomeTab()
    }
    
    func loadQueryInNewWebTab(query: String) {
        if let url = AppUrls.url(forQuery: query) {
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
        dismissAutcompleteSuggestions()
        if let queryUrl = AppUrls.url(forQuery: query) {
            currentTab?.load(url: queryUrl)
        }
    }
    
    fileprivate func launchTab() {
        attachHomeTab()
        refreshControls()
    }
    
    fileprivate func launchTabFrom(webTab: WebTabViewController, forUrl url: URL) {
        refreshTabIcon(count: tabManager.count+1)
        attachSiblingWebTab(fromWebView: webTab.webView, forUrl: url)
        refreshControls()
    }
    
    private func attachHomeTab() {
        let tab = HomeTabViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        addToView(tab: tab)
    }
    
    private func attachWebTab(forUrl url: URL) {
        let tab = WebTabViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        tab.load(url: url)
        addToView(tab: tab)
    }
    
    private func attachSiblingWebTab(fromWebView webView: WKWebView, forUrl url: URL) {
        let tab = WebTabViewController.loadFromStoryboard()
        tab.attachWebView(newWebView: webView.createSiblingWebView())
        tab.tabDelegate = self
        tabManager.add(tab: tab)
        tab.load(url: url)
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
            launchTab()
        }
        
        if let lastIndex = tabManager.lastIndex, index > lastIndex {
            select(tabAt: lastIndex)
            return
        }
        
        select(tabAt: index)
    }
    
    fileprivate func clearAllTabs() {
        tabManager.clearAll()
        launchTab()
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
        }
        guard let autocompleteController = autocompleteController else { return }
        autocompleteController.updateQuery(query: query)
    }
    
    fileprivate func dismissOmniBar() {
        dismissAutcompleteSuggestions()
        refreshOmniText()
        currentTab?.omniBarWasDismissed()
    }
    
    private func dismissAutcompleteSuggestions() {
        guard let controller = autocompleteController else { return }
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        autocompleteController = nil
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        currentTab?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        currentTab?.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = currentTab?.url {
            presentShareSheet(withItems: [url], fromButtonItem: sender)
        }
    }
    
    @IBAction func onSaveQuickLink(_ sender: UIBarButtonItem) {
        if let link = currentTab?.link {
            groupData.addQuickLink(link: link)
            makeToast(text: UserText.webSaveLinkDone)
        }
    }
    
    fileprivate func launchTabSwitcher() {
        let controller = TabSwitcherViewController.loadFromStoryboard()
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TabSwitcherViewController {
            onTabSwitcherViewControllerSegue(controller: controller)
            return
        }
    }
    
    private func onTabSwitcherViewControllerSegue(controller: TabSwitcherViewController) {
        controller.delegate = self
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
        loadQueryInCurrentTab(query: query)
    }
    
    func onActionButtonPressed() {
        clearAllTabs()
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
        loadQueryInCurrentTab(query: suggestion)
        omniBar?.resignFirstResponder()
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
}

extension MainViewController: WebTabDelegate {
    
    func webTabLoadingStateDidChange(webTab: WebTabViewController) {
        refreshControls()
    }
    
    func webTab(_ webTab: WebTabViewController, didRequestNewTabForUrl url: URL) {
        launchTabFrom(webTab: webTab, forUrl: url)
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

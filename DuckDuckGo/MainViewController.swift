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
    
    private let groupData = GroupData()
    
    lazy var tabManager = TabManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachHomeTab()
    }
    
    func attachHomeTab() {
        let tab = HomeViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        addToView(tab: tab)
    }
    
    func attachWebTab(forUrl url: URL? = nil) {
        let tab = WebTabViewController.loadFromStoryboard()
        tabManager.add(tab: tab)
        tab.tabDelegate = self
        if let url = url {
            tab.load(url: url)
        }
        addToView(tab: tab)
        
    }
    
    func attachSiblingTab(fromWebView webView: WKWebView, forUrl url: URL) {
        let tab = WebTabViewController.loadFromStoryboard()
        tab.attachWebView(newWebView: webView.createSiblingWebView())
        tab.tabDelegate = self
        tabManager.add(tab: tab)
        tab.load(url: url)
        addToView(tab: tab)
    }
    
    func addToView(tab: UIViewController) {
        tab.view.frame = containerView.frame
        tab.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(tab)
        containerView.addSubview(tab.view)
        tab.didMove(toParentViewController: self)
        if let tab = tab as? Tab {
            navigationItem.titleView = tab.omniBar
        }
    }
    
    func refreshControls() {
        refreshTabIcon()
        refreshNavigationButtons()
        refreshOmniText()
    }

    func refreshTabIcon() {
        refreshTabIcon(count: tabManager.count)
    }

    func refreshTabIcon(count: Int) {
        tabsButton.image = TabIconMaker().icon(forTabs: count)
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = tabManager.current?.canGoBack ?? false
        forwardButton.isEnabled = tabManager.current?.canGoForward ?? false
    }
    
    private func refreshOmniText() {
        tabManager.current?.refreshOmniText()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        tabManager.current?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        tabManager.current?.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = tabManager.current?.url {
            presentShareSheet(withItems: [url], fromButtonItem: sender)
        }
    }
    
    @IBAction func onSaveQuickLink(_ sender: UIBarButtonItem) {
        if let link = tabManager.current?.link {
            groupData.addQuickLink(link: link)
            makeToast(text: UserText.webSaveLinkDone)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TabViewController {
            onTabViewControllerSegue(controller: controller)
            return
        }
    }
    
    private func onTabViewControllerSegue(controller: TabViewController) {
        controller.delegate = self
    }
    
    func makeToast(text: String) {
        let x = view.bounds.size.width / 2.0
        let y = view.bounds.size.height - 80
        view.makeToast(text, duration: ToastManager.shared.duration, position: CGPoint(x: x, y: y))
    }
}

extension MainViewController: HomeTabDelegate {
    
    func loadNewWebQuery(query: String) {
        if let url = AppUrls.url(forQuery: query) {
            loadNewWebUrl(url: url)
        }
    }
    
    func loadNewWebUrl(url: URL) {
        loadViewIfNeeded()
        let homeTab = tabManager.current as? HomeViewController
        attachWebTab(forUrl: url)
        if let oldTab = homeTab {
            tabManager.remove(tab: oldTab)
        }
        refreshControls()
    }
    
    func launchTabsSwitcher() {
        let controller = TabViewController.loadFromStoryboard()
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true, completion: nil)
    }
}

extension MainViewController: WebTabDelegate {
    
    func openNewTab(fromWebView webView: WKWebView, forUrl url: URL) {
        refreshTabIcon(count: tabManager.count+1)
        attachSiblingTab(fromWebView: webView, forUrl: url)
    }
    
    func resetAll() {
        clearAllTabs()
    }
}

extension MainViewController: TabViewControllerDelegate {
    
    var tabDetails: [Link] {
        return tabManager.tabDetails
    }
    
    func createTab() {
        attachHomeTab()
        refreshControls()
    }
    
    func select(tabAt index: Int) {
        let selectedTab = tabManager.get(at: index) as! UIViewController
        addToView(tab: selectedTab)
        refreshControls()
    }
    
    func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        
        if tabManager.isEmpty {
            createTab()
        }
        
        if let lastIndex = tabManager.lastIndex, index > lastIndex {
            select(tabAt: lastIndex)
            return
        }
        
        select(tabAt: index)
    }
    
    func clearAllTabs() {
        tabManager.clearAll()
        createTab()
    }
}

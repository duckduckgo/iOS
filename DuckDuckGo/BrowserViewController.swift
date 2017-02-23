//
//  BrowserViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit
import Core

class BrowserViewController: UIViewController, WebLoadingDelegate, WebViewCreationDelegate {
    
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    private var omniBar: OmniBar!
    fileprivate weak var webController: WebViewController?
    private var initialUrl: URL?
    
    private let groupData = GroupData()
    
    lazy var tabManager = TabManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOmniBar()
        refreshNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureOmniBar() {
        omniBar = OmniBar()
        omniBar.omniDelegate = self
        navigationItem.titleView = omniBar
    }
    
    private func configureNavigationBar() {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.isToolbarHidden = false
    }
    
    func webViewCreated(webView: WKWebView) {
        tabManager.add(tab: webView)
        refeshTabIcon()
    }
    
    func webViewDestroyed(webView: WKWebView) {
        tabManager.remove(webView: webView)
        refeshTabIcon()
    }
    
    func webpageDidStartLoading() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webpageDidFinishLoading() {
        refreshNavigationButtons()
        refreshOmniBar()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func refreshOmniBar() {
        omniBar.refreshText(forUrl: webController?.url)
    }
    
    func refeshTabIcon() {
        tabsButton.image = TabIconMaker().icon(forTabs: tabManager.count)
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = webController?.canGoBack ?? false
        forwardButton.isEnabled = webController?.canGoForward ?? false
    }
    
    func load(query: String) {
        guard let url = AppUrls.url(forQuery: query) else {
            return
        }
        load(url: url)
    }
    
    func load(url: URL) {
        if let webController = webController {
            webController.load(url: url)
        } else {
            initialUrl = url
        }
    }
    
    @IBAction func onHomePressed(_ sender: UIBarButtonItem) {
        webController?.loadHomepage()
    }
    
    @IBAction func onRefreshPressed(_ sender: UIBarButtonItem) {
        webController?.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        webController?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        webController?.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = webController?.url {
            presentShareSheetFromButton(activityItems: [url], buttonItem: sender)
        }
    }
    
    @IBAction func onSaveQuickLink(_ sender: UIBarButtonItem) {
        if let link = webController?.link {
            groupData.addQuickLink(link: link)
            view.makeToast(UserText.webSaveLinkDone)
        }
    }
    
    @IBAction func onDeleteEverything(_ sender: UIBarButtonItem) {
        webController?.reset()
        clearAllTabs()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WebViewController {
            onWebViewControllerSegue(controller: controller)
            return
        }
        if let controller = segue.destination as? TabViewController {
            onTabViewControllerSegue(controller: controller)
            return
        }
    }
    
    private func onWebViewControllerSegue(controller: WebViewController) {
        webController = controller
        controller.loadingDelegate = self
        controller.webViewCreationDelegate = self
        controller.initialUrl = initialUrl
        initialUrl = nil
    }
    
    private func onTabViewControllerSegue(controller: TabViewController) {
        controller.delegate = self
    }
}

extension BrowserViewController: OmniBarDelegate {
    
    func onOmniQuerySubmitted(_ query: String) {
        load(query: query)
    }
}

extension BrowserViewController: TabViewControllerDelegate {
    
    var tabDetails: [Link] {
        return tabManager.tabDetails
    }
    
    func createTab() {
        webController?.attachNewWebView()
        refreshOmniBar()
        refeshTabIcon()
    }
    
    func select(tabAt index: Int) {
        let selectedTab = tabManager.get(at: index)
        webController?.attachWebView(newWebView: selectedTab)
        refreshOmniBar()
        refeshTabIcon()
    }
    
    func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        
        if tabManager.isEmpty {
            createTab()
            return
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

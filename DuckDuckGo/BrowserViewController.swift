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

class BrowserViewController: UIViewController, WebEventsDelegate {
    
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
        configureNavigationBar()
        configureOmniBar()
        refreshNavigationButtons()
    }
    
    private func configureOmniBar() {
        omniBar = OmniBar.loadFromXib(withStyle: .web)
        omniBar.omniDelegate = self
        navigationItem.titleView = omniBar
        navigationController?.toolbar.tintColor = UIColor.tint
    }
    
    private func configureNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = false
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func webViewCreated(webView: WKWebView) {
        tabManager.add(tab: webView)
        webView.loadScripts()
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
    
    func refreshControls() {
        refreshOmniBar()
        refeshTabIcon()
        refreshNavigationButtons()
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
    
    fileprivate func onRefreshPressed() {
        webController?.reload()
    }

    func webView(_ webView: WKWebView, didReceiveLongPressAtPoint point: Point) {
        webView.getUrlAtPoint(x: point.x, y: point.y) { (url) in
            if let url = url {
                self.view.makeToast(UserText.webUrlLaunchedInNewTab)
                self.webController?.attachNewWebView(forUrl: url)
            }
        }
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
        controller.delegate = self
        controller.initialUrl = initialUrl
        initialUrl = nil
    }
    
    private func onTabViewControllerSegue(controller: TabViewController) {
        controller.delegate = self
    }
    
    fileprivate func dismissAll() {
        tabManager.clearAll()
        _ = navigationController?.popToRootViewController(animated: false)
    }
}

extension BrowserViewController: OmniBarDelegate {
    
    func onOmniQuerySubmitted(_ query: String) {
        load(query: query)
    }
    
    func onLeftButtonPressed() {
        dismissAll()
    }
    
    func onRightButtonPressed() {
        onRefreshPressed()
    }

}

extension BrowserViewController: TabViewControllerDelegate {
    
    var tabDetails: [Link] {
        return tabManager.tabDetails
    }
    
    func createTab() {
        webController?.attachNewWebView()
        refreshControls()
    }
    
    func select(tabAt index: Int) {
        let selectedTab = tabManager.get(at: index)
        webController?.attachWebView(newWebView: selectedTab)
        refreshControls()
    }
    
    func remove(tabAt index: Int) {
        tabManager.remove(at: index)
        
        if tabManager.isEmpty {
            dismissAll()
            return
        }
        
        if let lastIndex = tabManager.lastIndex, index > lastIndex {
            select(tabAt: lastIndex)
            return
        }
        
        select(tabAt: index)
    }
    
    func clearAllTabs() {
        dismissAll()
    }
}

//
//  BrowserViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit


class BrowserViewController: UIViewController, UISearchBarDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        configureSearchBar()
    }
    
    private func configureWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        loadHomepage()
        view.addSubview(webView)
    }
    
    private func configureSearchBar() {
        let searchBar = UISearchBar()
        searchBar.placeholder = UserText.searchDuckDuckGo
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }

    private func loadHomepage() {
        webView.load(URLRequest(url: URL(string: Urls.home)!))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @IBAction func onHomePressed(_ sender: UIBarButtonItem) {
        loadHomepage()
    }
    
    @IBAction func onRefreshPressed(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func onSharePressed(_ sender: UIBarButtonItem) {
        if let url = webView.url {
            presentShareSheetFromButton(activityItems: [url], buttonItem: sender)
        }
    }
    
    @IBAction func onDeleteEverything(_ sender: UIBarButtonItem) {
        clearCache()
        resetWebView()
    }
    
    private func clearCache() {
        let allData = WKWebsiteDataStore.allWebsiteDataTypes()
        let distandPast = Date.distantPast
        let dataStore = webView.configuration.websiteDataStore
        dataStore.removeData(ofTypes: allData, modifiedSince: distandPast) {
            Logger.log(text: "Cache cleared")
        }
    }
    
    private func resetWebView() {
        webView.removeFromSuperview()
        configureWebView()
    }
}

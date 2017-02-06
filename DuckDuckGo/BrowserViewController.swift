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
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var webView: WKWebView!
    private var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        configureSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureWebView() {
        webView = WKWebView.createPrivateBrowser(frame: view.bounds)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        loadHomepage()
        refreshNavigationButtons()
        view.insertSubview(webView, at: 0)
    }
    
    private func configureSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = UserText.searchDuckDuckGo
        searchBar.textColor = UIColor.darkGrey
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
    
    private func configureNavigationBar() {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.isToolbarHidden = false
    }
    
    private func loadHomepage() {
        webView.load(URLRequest(url: URL(string: AppUrls.home)!))
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressIndicators()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicators()
        refreshNavigationButtons()
        refreshSearchText()
    }
    
    private func showProgressIndicators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        progressBar.alpha = 1
    }
    
    private func hideProgressIndicators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        UIView.animate(withDuration: 1) {
            self.progressBar.alpha = 0
        }
    }
    
    private func refreshSearchText() {
        guard let url = webView.url else {
            searchBar.text = nil
            return
        }
        guard !AppUrls.isDuckDuckGo(url: url) else {
            searchBar.text = nil
            return
        }
        searchBar.text = url.absoluteString
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchSubmitted()
    }
    
    private func onSearchSubmitted() {
        searchBar.resignFirstResponder()
        guard let text = searchBar.text?.trimWhitespace() else {
            return
        }
        if let url = URL.webUrl(fromText: text) {
            webView.load(URLRequest(url: url))
        } else if let searchUrl = AppUrls.search(text: text) {
            webView.load(URLRequest(url: searchUrl))
        }
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
    
    @IBAction func onOpenInSafari(_ sender: UIBarButtonItem) {
        if let url = webView.url {
            UIApplication.shared.openURL(url)
        }
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
        webView.clearCache {
            Logger.log(text: "Cache cleared")
        }
    }
    
    private func resetWebView() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
        configureWebView()
    }
}

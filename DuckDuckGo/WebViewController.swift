//
//  WebViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private static let estimatedProgressKeyPath = "estimatedProgress"
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var webView: WKWebView!
    
    var loadingDelegate: WebLoadingDelegate?
    
    var url: URL? {
        get {
            return webView.url
        }
    }
    
    var canGoBack: Bool {
        get {
            return webView.canGoBack
        }
    }
    
    var canGoForward: Bool {
        get {
            return webView.canGoForward
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        loadHomepage()
    }
    
    private func configureWebView() {
        webView = WKWebView.createPrivateBrowser(frame: view.bounds)
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.navigationDelegate = self
        view.insertSubview(webView, at: 0)
    }
    
    func loadHomepage() {
        load(url: URL(string: AppUrls.home)!)
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    func load(text: String) {
        if let url = URL.webUrl(fromText: text) {
            load(url: url)
        } else if let searchUrl = AppUrls.search(text: text) {
            load(url: searchUrl)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.estimatedProgressKeyPath {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressIndicator()
        loadingDelegate?.webpageDidStartLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        loadingDelegate?.webpageDidFinishLoading()
    }
    
    private func showProgressIndicator() {
        progressBar.alpha = 1
    }
    
    private func hideProgressIndicator() {
        UIView.animate(withDuration: 1) {
            self.progressBar.alpha = 0
        }
    }
    
    func reload() {
        webView.reload()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reset() {
        clearCache()
        resetWebView()
        loadHomepage()
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

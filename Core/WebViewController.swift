//
//  WebViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

public class WebViewController: UIViewController, WKNavigationDelegate {
    
    private static let estimatedProgressKeyPath = "estimatedProgress"
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var webView: WKWebView!
    
    public var loadingDelegate: WebLoadingDelegate?
    
    public var initialUrl: URL?
    
    public var url: URL? {
        return webView.url
    }
    
    public var link: Link? {
        if let url = webView.url, let title = webView.title {
            return Link(title: title, url: url)
        }
        return nil
    }
    
    public var canGoBack: Bool {
        return webView.canGoBack
    }
    
    public var canGoForward: Bool {
        return webView.canGoForward
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        loadStartPage()
    }
    
    private func loadStartPage() {
        if let url = initialUrl {
            load(url: url)
            initialUrl = nil
        } else {
           loadHomepage()
        }
    }
    
    private func configureWebView() {
        webView = WKWebView.createPrivateBrowser(frame: view.bounds)
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.navigationDelegate = self
        view.insertSubview(webView, at: 0)
    }
    
    public func loadHomepage() {
        load(url: URL(string: AppUrls.home)!)
    }
    
    public func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.estimatedProgressKeyPath {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressIndicator()
        loadingDelegate?.webpageDidStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
    
    public func reload() {
        webView.reload()
    }
    
    public func goBack() {
        webView.goBack()
    }
    
    public func goForward() {
        webView.goForward()
    }
    
    public func reset() {
        clearCache()
        resetWebView()
        loadHomepage()
    }
    
    private func clearCache() {
        webView.clearCache {
            Logger.log(text: "Cache cleared")
        }
        view.makeToast(UserText.webSessionCleared)
    }
    
    private func resetWebView() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
        configureWebView()
    }
}

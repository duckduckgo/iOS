//
//  WebViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

open class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private static let estimatedProgressKeyPath = "estimatedProgress"
    
    public weak var webEventsDelegate: WebEventsDelegate?
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    open private(set) var webView: WKWebView!
    
    public var name: String? {
        return webView.title    
    }
    
    public var url: URL? {
        return webView.url
    }
    
    public var favicon: URL?
    
    public var link: Link? {
        if let url = webView.url, let title = name {
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if webView == nil {
            attachNewWebView()
        }
    }
    
    private func loadStartPage(url: URL? = nil) {
        if let url = url {
            load(url: url)
        } else {
            loadHomepage()
        }
    }
    
    public func attachNewWebView() {
        let newWebView = WKWebView.createPrivateWebView(frame: view.bounds)
        attachWebView(newWebView: newWebView)
        loadStartPage(url: url)
    }
    
    public func attachWebView(newWebView: WKWebView) {
        if let oldWebView = webView {
            detachWebView(webView: oldWebView)
        }
        webView = newWebView
        attachLongPressHandler(webView: newWebView)
        newWebView.allowsBackForwardNavigationGestures = true
        newWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(newWebView, at: 0)
        view.addEqualSizeConstraints(subView: newWebView)
        webEventsDelegate?.attached(webView: webView)
    }
    
    private func attachLongPressHandler(webView: WKWebView) {
        let handler = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        handler.delegate = self
        webView.scrollView.addGestureRecognizer(handler)
    }
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let x = Int(sender.location(in: webView).x)
        let y = Int(sender.location(in: webView).y)
        let offsetY = y - Int(touchesYOffset())
        
        webView.getUrlAtPoint(x: x, y: offsetY)  { [weak self] (url) in
            guard let webView = self?.webView, let url = url else { return }
            let point = Point(x: x, y: y)
            self?.webEventsDelegate?.webView(webView, didReceiveLongPressForUrl: url, atPoint: point)
        }
    }
    
    private func detachWebView(webView: WKWebView) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
    }
    
    public func loadHomepage() {
        load(url: AppUrls.home)
    }
    
    public func load(url: URL) {
        load(urlRequest: URLRequest(url: url))
    }
 
    public func load(urlRequest: URLRequest) {
        loadViewIfNeeded()
        webView.load(urlRequest)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.estimatedProgressKeyPath {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        favicon = nil
        showProgressIndicator()
        webEventsDelegate?.webpageDidStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        webView.getFavicon(completion: { [weak self] (favicon) in
            self?.favicon = favicon
        })
        webEventsDelegate?.webpageDidFinishLoading()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFinishLoading()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let delegate = webEventsDelegate,
            let url = navigationAction.request.url,
            let documentUrl = navigationAction.request.mainDocumentURL else {
            decisionHandler(.allow)
            return
        }
        
        if delegate.webView(webView, shouldLoadUrl: url, forDocument: documentUrl) {
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(.cancel)
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webEventsDelegate?.webView(webView, didRequestNewTabForRequest: navigationAction.request)
        return nil
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
    
    public func tearDown() {
        clearCache()
        if let webView = webView {
            detachWebView(webView: webView)
        }
    }
    
    public func clearCache() {
        webView.clearCache {
            Logger.log(text: "Cache cleared")
        }
        view.makeToast(UserText.webSessionCleared)
    }
    
    fileprivate func touchesYOffset() -> CGFloat {
        guard navigationController != nil else { return 0 }
        return decorHeight
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let yOffset = touchesYOffset()
        let x = Int(gestureRecognizer.location(in: webView).x)
        let y = Int(gestureRecognizer.location(in: webView).y-yOffset)
        let url = webView.getUrlAtPointSynchronously(x: x, y: y)
        return url != nil
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

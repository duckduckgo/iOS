//
//  WebViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 24/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

open class WebViewController: UIViewController, WKNavigationDelegate {
    
    private static let estimatedProgressKeyPath = "estimatedProgress"
    
    public weak var webEventsDelegate: WebEventsDelegate?
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    open var webView: WKWebView!
    
    public var name: String? {
        return webView.title
    }
    
    public var url: URL? {
        return webView.url
    }
    
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
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        newWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        newWebView.navigationDelegate = self
        view.insertWithEqualSize(subView: newWebView)
        webEventsDelegate?.attached(webView: webView)
    }
    
    private func attachLongPressHandler(webView: WKWebView) {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        longPressRecogniser.delegate = self
        webView.scrollView.addGestureRecognizer(longPressRecogniser)
    }
    
    func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        let webView = sender.view?.superview as! WKWebView
        let x = Int(sender.location(in: webView).x)
        let y = Int(sender.location(in: webView).y)
        let point = Point(x: x, y: y)
        webEventsDelegate?.webView(webView, didReceiveLongPressAtPoint: point)
    }
    
    private func detachWebView(webView: WKWebView) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
    }
    
    public func loadHomepage() {
        load(url: URL(string: AppUrls.home)!)
    }
    
    public func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.estimatedProgressKeyPath {
            progressBar.progress = Float(webView.estimatedProgress)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressIndicator()
        webEventsDelegate?.webpageDidStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFinishLoading()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFinishLoading()
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
    
    public func reset() {
        clearCache()
        attachNewWebView()
    }
    
    public func clearCache() {
        webView.clearCache {
            Logger.log(text: "Cache cleared")
        }
        view.makeToast(UserText.webSessionCleared)
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

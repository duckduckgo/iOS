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
    
    public weak var delegate: WebEventsDelegate?
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    private var webView: WKWebView!
    
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
        attachNewWebView()
    }
    
    private func loadStartPage(url: URL? = nil) {
        if let url = url ?? initialUrl {
            load(url: url)
            initialUrl = nil
        } else {
            loadHomepage()
        }
    }
    
    public func attachNewWebView(forUrl url: URL? = nil) {
        let newWebView = WKWebView.createPrivateBrowser(frame: view.bounds)
        newWebView.allowsBackForwardNavigationGestures = true
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        attachWebView(newWebView: newWebView)
        attachLongPressHandler(webView: webView)
        delegate?.webViewCreated(webView: webView)
        loadStartPage(url: url)
    }
    
    public func attachWebView(newWebView: WKWebView) {
        if let oldWebView = webView {
            detachWebView(webView: oldWebView)
        }
        newWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        newWebView.navigationDelegate = self
        view.insertWithEqualSize(subView: newWebView)
        webView = newWebView
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
        delegate?.webView(webView, didReceiveLongPressAtPoint: point)
    }
    
    private func detachWebView(webView: WKWebView) {
        webView.removeFromSuperview()
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
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
        delegate?.webpageDidStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        delegate?.webpageDidFinishLoading()
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
    }
    
    private func clearCache() {
        webView.clearCache {
            Logger.log(text: "Cache cleared")
        }
        view.makeToast(UserText.webSessionCleared)
    }
    
    private func resetWebView() {
        delegate?.webViewDestroyed(webView: webView)
        attachNewWebView()
    }
}

extension WebViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

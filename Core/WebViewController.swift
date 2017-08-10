//
//  WebViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import WebKit

open class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    private static let estimatedProgressKeyPath = "estimatedProgress"
    
    public weak var webEventsDelegate: WebEventsDelegate?
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var errorMessage: UILabel!
    
    open private(set) var webView: WKWebView!

    public var name: String? {
        return webView.title    
    }
    
    public var url: URL? {
        return webView.url
    }
    
    public var favicon: URL?
    
    public var link: Link? {
        guard let url = url else { return nil }
        return Link(title: name, url: url, favicon: favicon)
    }
    
    public var canGoBack: Bool {
        return webView.canGoBack
    }
    
    public var canGoForward: Bool {
        return webView.canGoForward
    }
    
    public func attachWebView(persistsData: Bool) {
        webView = WKWebView.createWebView(frame: view.bounds, persistsData: persistsData)
        attachLongPressHandler(webView: webView)
        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, at: 0)
        view.addEqualSizeConstraints(subView: webView)
        webEventsDelegate?.attached(webView: webView)
        
        if let url = url {
            load(url: url)
        }
    }
    
    private func attachLongPressHandler(webView: WKWebView) {
        let handler = WebLongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
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
    
    private func onFaviconLoaded(_ favicon: URL) {
        self.favicon = favicon
        if let url = url {
            webEventsDelegate?.faviconWasUpdated(favicon, forUrl: url)
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        favicon = nil
        hideErrorMessage()
        showProgressIndicator()
        webEventsDelegate?.webpageDidStartLoading()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressIndicator()
        webView.getFavicon(completion: { [weak self] (favicon) in
            if let favicon = favicon {
                self?.onFaviconLoaded(favicon)
            }
        })
        webEventsDelegate?.webpageDidFinishLoading()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFailToLoad()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideProgressIndicator()
        webEventsDelegate?.webpageDidFailToLoad()
        showError(message: error.localizedDescription)
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
        guard let webView = webView else { return }
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
    }
    
    fileprivate func touchesYOffset() -> CGFloat {
        guard navigationController != nil else { return 0 }
        return decorHeight
    }
    
    private func showError(message: String) {
        webView.alpha = 0
        errorMessage.text = String(format: UserText.webPageFailedLoad, message.localizedLowercase)
        errorMessage.alpha = 1
        errorMessage.adjustPlainTextLineHeight(1.5)
    }
    
    private func hideErrorMessage() {
        errorMessage.alpha = 0
        webView.alpha = 1
    }
    
}

extension WebViewController: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is WebLongPressGestureRecognizer else {
            return false
        }
        
        let yOffset = touchesYOffset()
        let x = Int(gestureRecognizer.location(in: webView).x)
        let y = Int(gestureRecognizer.location(in: webView).y-yOffset)
        let url = webView.getUrlAtPointSynchronously(x: x, y: y)
        return url != nil
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is WebLongPressGestureRecognizer
    }
}

fileprivate class WebLongPressGestureRecognizer: UILongPressGestureRecognizer {}

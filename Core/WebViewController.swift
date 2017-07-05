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
    
    open private(set) var webView: WKWebView!
    
    public var name: String? {
        return webView?.title
    }
    
    public var url: URL? {
        return webView?.url
    }
    
    public var favicon: URL?
    
    public var link: Link? {
        guard let url = url else { return nil }
        return Link(title: name, url: url, favicon: favicon)
    }
    
    public var canGoBack: Bool {
        return webView?.canGoBack ?? false
    }
    
    public var canGoForward: Bool {
        return webView?.canGoForward ?? false
    }
    
    public func attachNewWebView(persistsData: Bool) {
        let newWebView = WKWebView.createWebView(frame: view.bounds, persistsData: persistsData)
        attachWebView(newWebView: newWebView)
        if let url = url {
            load(url: url)
        }
    }

    public func attachWebView(newWebView: WKWebView) {
        webView = newWebView
        attachLongPressHandler(webView: newWebView)
        newWebView.allowsBackForwardNavigationGestures = true
        newWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        newWebView.navigationDelegate = self
        newWebView.uiDelegate = self
        newWebView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(newWebView, at: 0)
        view.addEqualSizeConstraints(subView: newWebView)
        webEventsDelegate?.attached(webView: newWebView)
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
        
        webView?.getUrlAtPoint(x: x, y: offsetY)  { [weak self] (url) in
            guard let webView = self?.webView, let url = url else { return }
            let point = Point(x: x, y: y)
            self?.webEventsDelegate?.webView(webView, didReceiveLongPressForUrl: url, atPoint: point)
        }
    }
    
    private func detachWebView(webView: WKWebView) {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeFromSuperview()
    }
    
    public func load(url: URL) {
        load(urlRequest: URLRequest(url: url))
    }
 
    public func load(urlRequest: URLRequest) {
        loadViewIfNeeded()
        webView?.load(urlRequest)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.estimatedProgressKeyPath {
            progressBar.progress = Float(webView?.estimatedProgress ?? 100)
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
        webView?.reload()
    }
    
    public func goBack() {
        webView?.goBack()
    }
    
    public func goForward() {
        webView?.goForward()
    }
    
    public func tearDown() {
        guard let webView = webView else { return }
        detachWebView(webView: webView)
    }
    
    fileprivate func touchesYOffset() -> CGFloat {
        guard navigationController != nil else { return 0 }
        return decorHeight
    }
    
    override open func encodeRestorableState(with coder: NSCoder) {
        coder.encode(link, forKey: "Link")
        super.encodeRestorableState(with: coder)
    }
    
    override open func decodeRestorableState(with coder: NSCoder) {
        if let link = coder.decodeObject(forKey: "Link") as? Link {
            attachNewWebView(persistsData: true)
            webView?.load(URLRequest(url: link.url))
        }
        Logger.log(text: "STATE: MainViewController did restore data")
        super.decodeRestorableState(with: coder)
    }

}

extension WebViewController: UIGestureRecognizerDelegate {
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let webView = webView else { return false }
        
        let yOffset = touchesYOffset()
        let x = Int(gestureRecognizer.location(in: webView).x)
        let y = Int(gestureRecognizer.location(in: webView).y-yOffset)
        let url = webView.getUrlAtPointSynchronously(x: x, y: y)
        return url != nil
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

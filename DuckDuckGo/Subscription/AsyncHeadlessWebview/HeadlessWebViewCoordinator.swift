//
//  HeadlessWebViewCoordinator.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Foundation
import WebKit

final class HeadlessWebViewCoordinator: NSObject {
    
    var parent: HeadlessWebView
    weak var presenter: UIViewController?
    
    var onScroll: ((CGPoint) -> Void)?
    var onURLChange: ((URL) -> Void)?
    var onCanGoBack: ((Bool) -> Void)?
    var onCanGoForward: ((Bool) -> Void)?
    var onContentType: ((String) -> Void)?
    var onNavigationError: ((Error?) -> Void)?
    var settings: AsyncHeadlessWebViewSettings
    
    var size: CGSize = .zero
    
    private var lastURL: URL?
    
    enum Constants {
        static let contentTypeJS = "document.contentType"
        static let externalSchemes =  ["tel", "sms", "facetime"]
    }
    
    private var webViewURLObservation: NSKeyValueObservation?
    private var webViewCanGoBackObservation: NSKeyValueObservation?
    private var webViewCanGoForwardObservation: NSKeyValueObservation?

    init(_ parent: HeadlessWebView,
         presenter: UIViewController?,
         onScroll: ((CGPoint) -> Void)?,
         onURLChange: ((URL) -> Void)?,
         onCanGoBack: ((Bool) -> Void)?,
         onCanGoForward: ((Bool) -> Void)?,
         onContentType: ((String) -> Void)?,
         onNavigationError: ((Error?) -> Void)?,
         allowedDomains: [String]? = nil,
         settings: AsyncHeadlessWebViewSettings = AsyncHeadlessWebViewSettings()) {
        self.parent = parent
        self.presenter = presenter
        self.onScroll = onScroll
        self.onURLChange = onURLChange
        self.onCanGoBack = onCanGoBack
        self.onCanGoForward = onCanGoForward
        self.onNavigationError = onNavigationError
        self.onContentType = onContentType
        self.settings = settings
    }
    
    func setupWebViewObservation(_ webView: WKWebView) {
        webViewURLObservation = webView.observe(\.url, options: [.new]) { [weak self] _, change in
            if let newURL = change.newValue as? URL {
                DispatchQueue.main.async {
                    self?.onURLChange?(newURL)
                    self?.onCanGoBack?(webView.canGoBack)
                }
            }
        }

        webViewCanGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] _, change in
            if let canGoBack = change.newValue {
                DispatchQueue.main.async {
                    self?.onCanGoBack?(canGoBack)
                }
            }
        }
        
        webViewCanGoForwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] _, change in
            if let onCanGoForward = change.newValue {
                DispatchQueue.main.async {
                    self?.onCanGoForward?(onCanGoForward)
                }
            }
        }
    }
    
    // Called from the webView dismantle
    func cleanUp() {
        webViewURLObservation?.invalidate()
        webViewCanGoBackObservation?.invalidate()
        webViewCanGoForwardObservation?.invalidate()
        
        webViewURLObservation = nil
        webViewCanGoBackObservation = nil
        webViewCanGoForwardObservation = nil
                
        onScroll = nil
        onURLChange = nil
        onCanGoBack = nil
        onCanGoForward = nil
        onContentType = nil
        onNavigationError = nil
    }
  
}

extension HeadlessWebViewCoordinator: WKUIDelegate {}

extension HeadlessWebViewCoordinator: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        onScroll?(contentOffset)
    }
}

extension HeadlessWebViewCoordinator: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Force all requests for new windows or frame to be loaded in the View Itself (No popups or new windows)
            webView.load(navigationAction.request)
           return nil
       }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        onNavigationError?(nil)
        if let url = webView.url, url != lastURL {
            onURLChange?(url)
            lastURL = url
            if let onCanGoBack {
                onCanGoBack(webView.canGoBack)
            }
            if let onCanGoForward {
                onCanGoForward(webView.canGoForward)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if settings.javascriptEnabled {
            webView.evaluateJavaScript(Constants.contentTypeJS) { result, error in
                guard error == nil, let contentType = result as? String else {
                    return
                }
                self.onContentType?(contentType)
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let scheme = url.scheme else {
            decisionHandler(.cancel)
            return
        }
        
        // Handle custom schemes (e.g., tel:, facetime:, etc.)
        if Constants.externalSchemes.contains(scheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // Publish the URL change
        self.onURLChange?(url)
        lastURL = url
        
        // Validate the URL against allowed domains list, if present
        if let allowedDomains = settings.allowedDomains, !allowedDomains.isEmpty {
            let isURLAllowed = allowedDomains.contains { domain in
                url.isPart(ofDomain: domain)
            }

            decisionHandler(isURLAllowed ? .allow : .cancel)
            return
        }
        
        // Default policy: allow navigation
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        handleWebViewError(error)
                
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleWebViewError(error)
    }
    
    private func handleWebViewError(_ error: Error) {
        let NSError = error as NSError
        // Check for the specific NSURLErrorDomain and the cancelled error code -999 and ignore
        if NSError.domain == NSURLErrorDomain && NSError.code == -999 {
            return
        } else {
            onNavigationError?(error)
        }
    }
    
    // Javascript Confirm dialogs Delegate
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard let presenter = presenter else {
            completionHandler(false)
            return
        }

        let alertController = UIAlertController(title: UserText.subscriptionConfirmTitle, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: UserText.actionOK, style: .default, handler: { _ in completionHandler(true) }))
        alertController.addAction(UIAlertAction(title: UserText.actionCancel, style: .cancel, handler: { _ in completionHandler(false) }))
        presenter.present(alertController, animated: true, completion: nil)
    }
    
    // Javascript Confirm alert dialogs
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            guard let presenter = presenter else {
                completionHandler()
                return
            }

        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: UserText.actionOK, style: .default, handler: { _ in completionHandler() }))
            presenter.present(alertController, animated: true, completion: nil)
        }
    
}

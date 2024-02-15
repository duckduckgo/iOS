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
    var onScroll: ((CGPoint) -> Void)?
    var onURLChange: ((URL) -> Void)?
    var onCanGoBack: ((Bool) -> Void)?
    var onCanGoForward: ((Bool) -> Void)?
    var onContentType: ((String) -> Void)?
    var allowedDomains: [String]?
    
    private var lastURL: URL?
    
    enum Constants {
        static let contentTypeJS = "document.contentType"
        static let externalSchemes =  ["tel", "sms", "facetime"]
    }
    
    private var webViewURLObservation: NSKeyValueObservation?
    private var webViewCanGoBackObservation: NSKeyValueObservation?
    private var webViewCanGoForwardObservation: NSKeyValueObservation?

    init(_ parent: HeadlessWebView,
         onScroll: ((CGPoint) -> Void)?,
         onURLChange: ((URL) -> Void)?,
         onCanGoBack: ((Bool) -> Void)?,
         onCanGoForward: ((Bool) -> Void)?,
         onContentType: ((String) -> Void)?,
         allowedDomains: [String]? = nil) {
        self.parent = parent
        self.onScroll = onScroll
        self.onURLChange = onURLChange
        self.onCanGoBack = onCanGoBack
        self.onCanGoForward = onCanGoForward
        self.onContentType = onContentType
        self.allowedDomains = allowedDomains
    }
    
    func setupWebViewObservation(_ webView: WKWebView) {
        webViewURLObservation = webView.observe(\.url, options: [.new]) { [weak self] _, change in
            if let newURL = change.newValue as? URL {
                self?.onURLChange?(newURL)
                self?.onCanGoBack?(webView.canGoBack)
            }
        }

        webViewCanGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] _, change in
            if let canGoBack = change.newValue {
                self?.onCanGoBack?(canGoBack)
            }
        }
        
        webViewCanGoForwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] _, change in
            if let onCanGoForward = change.newValue {
                self?.onCanGoForward?(onCanGoForward)
            }
        }
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
        webView.evaluateJavaScript(Constants.contentTypeJS) { result, error in
            guard error == nil, let contentType = result as? String else {
                return
            }
            self.onContentType?(contentType)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
          return
        }

        guard let scheme = url.scheme else {
            decisionHandler(.cancel)
            return
        }
        
        // Custom Schemes (tel: facetime: etc)
        if Constants.externalSchemes.contains(scheme) && UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
            
        } else {
            
            // Validate the URL is in the allowed domains list (if present)
            if let allowedDomains,
                allowedDomains.count > 0,
                let url = navigationAction.request.url {
                
                for domain in allowedDomains {
                    if url.isPart(ofDomain: domain) {
                        decisionHandler(.allow)
                        return
                    }
                }
                decisionHandler(.cancel)
                return
            }
            
            // Allow by default
            decisionHandler(.allow)
            
        }
                
    }
    
}

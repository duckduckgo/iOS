//
//  DuckPlayerWebView.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

@preconcurrency import WebKit
import SwiftUI
import Core
import os.log

struct DuckPlayerWebView: UIViewRepresentable {
   let url: URL
       
   struct Constants {
       static let referrerHeader: String = "Referrer"
       static let referrerHeaderValue: String = "http://localhost"
   }
   
   func makeCoordinator() -> Coordinator {
       Coordinator()
   }
   
   func makeUIView(context: Context) -> WKWebView {
       let configuration = WKWebViewConfiguration()
       configuration.allowsInlineMediaPlayback = true
       configuration.mediaTypesRequiringUserActionForPlayback = []
       
       // Disable all data storage and cookies
       configuration.websiteDataStore = .nonPersistent()
       
       // Disable caching
       let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
       configuration.websiteDataStore.removeData(ofTypes: websiteDataTypes, modifiedSince: .distantPast, completionHandler: {})
       
       // Additional storage restrictions
       let preferences = WKWebpagePreferences()
       configuration.defaultWebpagePreferences = preferences
       
       // Disable cache in URL cache
       URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
       
       // Create a custom process pool to ensure isolation
       configuration.processPool = WKProcessPool()
       
       let webView = WKWebView(frame: .zero, configuration: configuration)
       webView.backgroundColor = .black
       webView.isOpaque = false
       webView.scrollView.backgroundColor = .black
       webView.scrollView.bounces = false
       webView.navigationDelegate = context.coordinator
       webView.uiDelegate = context.coordinator
       
       // Set DDG's agent
       webView.customUserAgent = DefaultUserAgentManager.shared.userAgent(isDesktop: false, url: url)
       
       // Disable all types of caching
       let dataStore = webView.configuration.websiteDataStore
       dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
           records.forEach { record in
               dataStore.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
           }
       }
       
       return webView
   }
   
   func updateUIView(_ webView: WKWebView, context: Context) {
       var request = URLRequest(url: url)
       request.setValue(Constants.referrerHeaderValue, forHTTPHeaderField: Constants.referrerHeader)
       webView.load(request)
   }
   
   class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
       
       @MainActor
       func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           guard let url = navigationAction.request.url else {
               decisionHandler(.cancel)
               return
           }
           
           // Users should be able to navigate to Youtube's watch pages
           // To be implemented here
           Logger.duckplayer.log("[DuckPlayer] Deciding policy for navigation to: \(url.absoluteString)")
           decisionHandler(.allow)
       }
       
       func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
           if let url = navigationAction.request.url {
               UIApplication.shared.open(url)
           }
           return nil
       }
   }
}

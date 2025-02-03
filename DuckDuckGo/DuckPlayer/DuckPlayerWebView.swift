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
import Combine

struct DuckPlayerWebView: UIViewRepresentable {
   let viewModel: DuckPlayerViewModel
   let coordinator: Coordinator
       
   struct Constants {
       static let referrerHeader: String = "Referer"
       static let referrerHeaderValue: String = "http://localhost"
   }
   
   init(viewModel: DuckPlayerViewModel) {
       self.viewModel = viewModel
       Logger.duckplayer.debug("Creating new coordinator")
       self.coordinator = Coordinator(viewModel: viewModel)
   }
   
   func makeCoordinator() -> Coordinator {
       coordinator
   }
   
   func makeUIView(context: Context) -> WKWebView {
       let configuration = WKWebViewConfiguration()
       configuration.allowsInlineMediaPlayback = true
       configuration.mediaTypesRequiringUserActionForPlayback = []
       
       // Use non-persistent data store to prevent cookie storage
       configuration.websiteDataStore = .nonPersistent()
       
       // Set up preferences with privacy-focused settings
       let preferences = WKWebpagePreferences()
       preferences.allowsContentJavaScript = true  // Needed for YouTube player
       configuration.defaultWebpagePreferences = preferences
       
       // Prevent automatic window opening
       configuration.preferences.javaScriptCanOpenWindowsAutomatically = false
       
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
       webView.customUserAgent = DefaultUserAgentManager.shared.userAgent(isDesktop: false, url: viewModel.getVideoURL())
       
       return webView
   }
   
   func updateUIView(_ webView: WKWebView, context: Context) {
       guard let url = viewModel.getVideoURL() else { return }
       Logger.duckplayer.debug("Updating WebView with URL: \(url)")
       var request = URLRequest(url: url)
       request.setValue(Constants.referrerHeaderValue, forHTTPHeaderField: Constants.referrerHeader)
       webView.load(request)
   }
   
   class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
       let viewModel: DuckPlayerViewModel
       
       init(viewModel: DuckPlayerViewModel) {
           self.viewModel = viewModel
           super.init()
       }
       
       private func handleYouTubeWatchURL(_ url: URL) {
           Logger.duckplayer.debug("Detected YouTube watch URL: \(url.absoluteString)")
           viewModel.handleYouTubeNavigation(url)
       }
       
       @MainActor
      func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
          guard let url = navigationAction.request.url else {
              decisionHandler(.cancel)
              return
          }
          
          Logger.duckplayer.log("[DuckPlayer] Navigation request to: \(url.absoluteString), type: \(navigationAction.navigationType.rawValue)")
          
          // Always allow youtube-nocookie.com iframe content
          if url.isDuckPlayer {
              decisionHandler(.allow)
              return
          }
          
          // Handle YouTube navigation attempts (from logo, links, etc)
          if url.isYoutubeWatch {
              handleYouTubeWatchURL(url)
          } else if url.isYoutubeWatch == true {
              Logger.duckplayer.log("[DuckPlayer] Blocked navigation to YouTube domain: \(url.absoluteString)")
          }
          
          // Cancel all navigation outside of youtube-nocookie.com
          decisionHandler(.cancel)
        }
        
       
       func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
           // Prevent automatic opening of URLs in browser
           if let url = navigationAction.request.url {
               if url.isYoutubeWatch {
                   handleYouTubeWatchURL(url)
               } else {
                   Logger.duckplayer.log("[DuckPlayer] Blocked window creation for: \(url.absoluteString)")
               }
           }
           return nil
       }
       
    
   }
}

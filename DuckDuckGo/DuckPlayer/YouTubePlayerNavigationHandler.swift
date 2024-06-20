//
//  YouTubePlayerNavigationHandler.swift
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
import ContentScopeScripts
import WebKit

struct YoutubePlayerNavigationHandler {
    
    static var htmlTemplatePath: String {
           guard let file = ContentScopeScripts.Bundle.path(forResource: "index", ofType: "html", inDirectory: "pages/duckplayer") else {
               assertionFailure("YouTube Private Player HTML template not found")
               return ""
           }
           return file
       }

   private func makeDuckPlayerRequest(from originalRequest: URLRequest) -> URLRequest {
       guard let (youtubeVideoID, timestamp) = originalRequest.url?.youtubeVideoParams else {
           assertionFailure("Request should have ID")
           return originalRequest
       }

       return makeDuckPlayerRequest(for: youtubeVideoID, timestamp: timestamp)
   }

    private func makeDuckPlayerRequest(for videoID: String, timestamp: String?) -> URLRequest {
       var request = URLRequest(url: .youtubeNoCookie(videoID, timestamp: timestamp))
       request.addValue("http://localhost/", forHTTPHeaderField: "Referer")
       request.httpMethod = "GET"

       return request
   }

    private func makeHTMLFromTemplate() -> String {
       guard let html = try? String(contentsOfFile: Self.htmlTemplatePath) else {
           assertionFailure("Should be able to load template")
           return ""
       }
       return html
   }
    
    
    private func performNavigation(_ request: URLRequest, responseHTML: String, webView: WKWebView) {
        if #available(iOS 15.0, *) {
            webView.loadSimulatedRequest(request, responseHTML: responseHTML)
        } else {
            // NOOP
        }
    }
    
    private func performRequest(request: URLRequest, webView: WKWebView) {
        let html = makeHTMLFromTemplate()
        let duckPlayerRequest = makeDuckPlayerRequest(from: request)
        performNavigation(duckPlayerRequest, responseHTML: html, webView: webView)
    }
    
}

extension YoutubePlayerNavigationHandler: DuckNavigationHandling {
    
    func handleNavigation(_ navigationAction: WKNavigationAction, webView: WKWebView, completion: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        if url.isDuckPlayer {
            let html = makeHTMLFromTemplate()
            let newRequest = makeDuckPlayerRequest(from: URLRequest(url: url))
            if #available(iOS 15.0, *) {
                webView.loadSimulatedRequest(newRequest, responseHTML: html)
                
                completion(.allow)
                return
            }
        }
        completion(.cancel)
    }
        
    func handleRedirect(url: URL?, webView: WKWebView) {
            guard let url = url,
              url.isYoutubeVideo,
              !url.isDuckPlayer,
              let (videoID, timestamp) = url.youtubeVideoParams else {
            return
        }

        webView.stopLoading()
        let newURL = URL.duckPlayer(videoID, timestamp: timestamp)
        webView.load(URLRequest(url: newURL))
    }
    
    func handleRedirect(_ navigationAction: WKNavigationAction,
                        completion: @escaping (WKNavigationActionPolicy) -> Void,
                        webView: WKWebView) {
        
        guard let url = navigationAction.request.url,
                url.isYoutubeVideo,
                !url.isDuckPlayer,
                let (videoID, timestamp) = navigationAction.request.url?.youtubeVideoParams else {
            completion(.cancel)
            return
        }

        webView.load(URLRequest(url: .duckPlayer(videoID, timestamp: timestamp)))
        completion(.allow)
    }
    
    // We skip the Youtube video the was replaced with the Player
    func goBack(webView: WKWebView) {
        guard let backURL = webView.backForwardList.backItem?.url,
              backURL.isYoutubeVideo,
              backURL.youtubeVideoParams?.videoID == webView.url?.youtubeVideoParams?.videoID else {
            webView.goBack()
            return
        }
        webView.goBack(skippingHistoryItems: 2)
    }
    
}

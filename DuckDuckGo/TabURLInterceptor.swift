//
//  TabURLInterceptor.swift
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
import BrowserServicesKit
import Common
import Subscription

enum InterceptedURL: String {
    case privacyPro
}

struct InterceptedURLInfo {
    let id: InterceptedURL
    let TLD: String
    let path: String
}

protocol TabURLInterceptor {
    func allowsNavigatingTo(url: URL) -> Bool
}

final class TabURLInterceptorDefault: TabURLInterceptor {

    private let tld = TLD()

    static let interceptedURLs: [InterceptedURLInfo] = [
        InterceptedURLInfo(id: .privacyPro, TLD: "duckduckgo.com", path: "/pro")
    ]
    
    func allowsNavigatingTo(url: URL) -> Bool {
        guard let components = normalizeScheme(url.absoluteString), let
                urlTLD = components.eTLDplus1(tld: tld) else {
            return true
        }
        
        guard let matchingURL = urlToIntercept(tld: urlTLD, path: components.path) else {
            return true
        }
        
        return Self.handleURLInterception(url: matchingURL.id)
        
    }
}


extension TabURLInterceptorDefault {
    
    private func urlToIntercept(tld: String, path: String) -> InterceptedURLInfo? {
        let results = Self.interceptedURLs.filter { $0.TLD == tld && $0.path == path }
        return results.first
    }
    
    private func normalizeScheme(_ rawUrl: String) -> URLComponents? {
        if !rawUrl.starts(with: URL.URLProtocol.https.scheme) &&
           !rawUrl.starts(with: URL.URLProtocol.http.scheme) &&
           rawUrl.contains("://") {
            return nil
        }
        let noScheme = rawUrl.dropping(prefix: URL.URLProtocol.https.scheme).dropping(prefix: URL.URLProtocol.http.scheme)
        
        return URLComponents(string: "\(URL.URLProtocol.https.scheme)\(noScheme)")
    }

    private static func handleURLInterception(url: InterceptedURL) -> Bool {
        switch url {
            
            // Opens the Privacy Pro Subscription Purchase page (if user can purchase)
            case .privacyPro:
                if SubscriptionPurchaseEnvironment.canPurchase {
                    NotificationCenter.default.post(name: .urlInterceptPrivacyPro, object: nil)
                    return false
                }
            }
        return true
        
    }
}

extension NSNotification.Name {
    static let urlInterceptPrivacyPro: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.urlInterceptPrivacyPro")
}

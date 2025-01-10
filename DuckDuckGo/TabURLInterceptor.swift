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
import AIChat

enum InterceptedURL: String {
    case privacyPro
    case aiChat
}

struct InterceptedURLInfo {
    let id: InterceptedURL
    let path: String
}

protocol TabURLInterceptor {
    func allowsNavigatingTo(url: URL) -> Bool
}

final class TabURLInterceptorDefault: TabURLInterceptor {
    
    typealias CanPurchaseUpdater = () -> Bool
    private let canPurchase: CanPurchaseUpdater
    private let featureFlagger: FeatureFlagger

    init(featureFlagger: FeatureFlagger, canPurchase: @escaping CanPurchaseUpdater) {
        self.canPurchase = canPurchase
        self.featureFlagger = featureFlagger
    }

    static let interceptedURLs: [InterceptedURLInfo] = [
        InterceptedURLInfo(id: .privacyPro, path: "/pro")
    ]
    
    func allowsNavigatingTo(url: URL) -> Bool {
        if featureFlagger.isFeatureOn(.aiChatDeepLink), url.isDuckAIURL {
            return handleURLInterception(interceptedURL: .aiChat, queryItems: nil)
        }

        guard url.isPart(ofDomain: "duckduckgo.com"),
              let components = normalizeScheme(url.absoluteString),
              let matchingURL = urlToIntercept(path: components.path) else {
            return true
        }

        return handleURLInterception(interceptedURL: matchingURL.id, queryItems: components.percentEncodedQueryItems)
    }

}

extension TabURLInterceptorDefault {
    
    private func urlToIntercept(path: String) -> InterceptedURLInfo? {
        let results = Self.interceptedURLs.filter { $0.path == path }
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

    private func handleURLInterception(interceptedURL: InterceptedURL, queryItems: [URLQueryItem]?) -> Bool {
        switch interceptedURL {
            // Opens the Privacy Pro Subscription Purchase page (if user can purchase)
        case .privacyPro:
            if canPurchase() {
                // If URL has an `origin` query parameter, append it to the `subscriptionPurchase` URL.
                // Also forward the origin as it will need to be sent as parameter to the Pixel to track subcription attributions.
                let originQueryItem = queryItems?.first(where: { $0.name == AttributionParameter.origin })
                NotificationCenter.default.post(
                    name: .urlInterceptPrivacyPro,
                    object: nil,
                    userInfo: [AttributionParameter.origin: originQueryItem?.value as Any]
                )
                return false
            }
        case .aiChat:
            if featureFlagger.isFeatureOn(.aiChatDeepLink) {
                NotificationCenter.default.post(
                    name: .urlInterceptAIChat,
                    object: nil,
                    userInfo: nil
                )
                return false
            }
        }
        return true
    }
}

extension NSNotification.Name {
    static let urlInterceptPrivacyPro: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.urlInterceptPrivacyPro")
    static let urlInterceptAIChat: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.urlInterceptAIChat")
}

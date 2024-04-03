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

struct InterceptedURLInfo {
    let url: URL
    let cancelsNavigation: Bool
    let action: ((URL) -> Void)?
}

protocol TabURLInterceptor {
    func interceptURL(url: URL) -> Bool
}

final class TabURLInterceptorDefault: TabURLInterceptor {
    
    static let interceptURLs: [String: InterceptedURLInfo] = [
        "https://duckduckgo.com/pro": InterceptedURLInfo(
            url: URL(string: "https://duckduckgo.com/pro")!,
            cancelsNavigation: true,
            action: { _ in
                handlePrivacyProURL()
            }
        )
    ]
    
    func interceptURL(url: URL) -> Bool {
        guard let interceptedInfo = TabURLInterceptorDefault.interceptURLs[url.absoluteString] else {
            return false // No interception occurred
        }
        
        interceptedInfo.action?(url)
        return interceptedInfo.cancelsNavigation
    }
}

extension TabURLInterceptorDefault {
        
    private static func handlePrivacyProURL() {
        NotificationCenter.default.post(name: .urlInterceptPrivacyPro, object: nil)
    }
}

extension NSNotification.Name {
    static let urlInterceptPrivacyPro: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.urlInterceptPrivacyPro")
}

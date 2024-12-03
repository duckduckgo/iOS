//
//  Fireproofing.swift
//  Core
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Subscription

public protocol Fireproofing {

    var loginDetectionEnabled: Bool { get set }
    var allowedDomains: [String] { get }

    func isAllowed(cookieDomain: String) -> Bool
    func isAllowed(fireproofDomain domain: String) -> Bool
    func addToAllowed(domain: String)
    func remove(domain: String)
    func clearAll()

}

// This class is not final because we override allowed domains in WebCacheManagerTests
public class UserDefaultsFireproofing: Fireproofing {

    /// This is only here because there are some places that don't support injection at this time.  DO NOT USE IT.
    ///  If you find you really need to use it, ping Apple Devs channel first.
    public static let xshared: Fireproofing = UserDefaultsFireproofing()

    public struct Notifications {
        public static let loginDetectionStateChanged = Foundation.Notification.Name("com.duckduckgo.ios.PreserveLogins.loginDetectionStateChanged")
    }

    @UserDefaultsWrapper(key: .fireproofingAllowedDomains, defaultValue: [])
    private(set) public var allowedDomains: [String]

    @UserDefaultsWrapper(key: .fireproofingDetectionEnabled, defaultValue: false)
    public var loginDetectionEnabled: Bool {
        didSet {
            NotificationCenter.default.post(name: Notifications.loginDetectionStateChanged, object: nil)
        }
    }

    private var allowedDomainsIncludingDuckDuckGo: [String] {
        allowedDomains + [
            URL.ddg.host ?? "",
            SubscriptionCookieManager.cookieDomain
        ]
    }

    public func addToAllowed(domain: String) {
        allowedDomains += [domain]
    }

    public func isAllowed(cookieDomain: String) -> Bool {
        return allowedDomainsIncludingDuckDuckGo.contains(where: { HTTPCookie.cookieDomain(cookieDomain, matchesTestDomain: $0) })
    }

    public func remove(domain: String) {
        allowedDomains = allowedDomains.filter { $0 != domain }
    }

    public func clearAll() {
        allowedDomains = []
    }

    public func isAllowed(fireproofDomain domain: String) -> Bool {
        return allowedDomainsIncludingDuckDuckGo.contains(domain)
    }

}

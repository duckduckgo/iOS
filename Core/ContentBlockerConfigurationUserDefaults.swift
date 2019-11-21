//
//  ContentBlockerConfigurationUserDefaults.swift
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

import Foundation
import SafariServices

public class ContentBlockerConfigurationUserDefaults: ContentBlockerConfigurationStore {

    private struct Keys {
        static let whitelistedDomains = "com.duckduckgo.contentblocker.whitelist"
        static let trackerList = "com.duckduckgo.trackerList"
    }

    private let suiteName: String

    public init(suiteName: String = ContentBlockerStoreConstants.groupName) {
        self.suiteName =  suiteName
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }

    public private(set) var domainWhitelist: Set<String> {
        get {
            guard let data = userDefaults?.data(forKey: Keys.whitelistedDomains) else { return Set<String>() }
            guard let whitelist = NSKeyedUnarchiver.unarchiveObject(with: data) as? Set<String> else { return Set<String>() }
            return whitelist
        }
        set(newWhitelistedDomain) {
            let data = NSKeyedArchiver.archivedData(withRootObject: newWhitelistedDomain)
            userDefaults?.set(data, forKey: Keys.whitelistedDomains)
            onStoreChanged()
        }
    }

    public func whitelisted(domain: String) -> Bool {
        return domainWhitelist.contains(domain)
    }

    public func addToWhitelist(domain: String) {
        var whitelist = domainWhitelist
        whitelist.insert(domain)
        domainWhitelist = whitelist
    }

    public func removeFromWhitelist(domain: String) {
        var whitelist = domainWhitelist
        whitelist.remove(domain)
        domainWhitelist = whitelist
    }

    public func protecting(domain: String?) -> Bool {
        guard let domain = domain else { return true }
        return !whitelisted(domain: domain)
    }

    private func onStoreChanged() {
        NotificationCenter.default.post(name: ContentBlockerConfigurationChangedNotification.name, object: nil)
    }
}

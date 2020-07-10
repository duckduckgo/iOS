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

public class ContentBlockerProtectionUserDefaults: ContentBlockerProtectionStore {

    private struct Keys {
        static let unprotectedDomains = "com.duckduckgo.contentblocker.whitelist"
        static let trackerList = "com.duckduckgo.trackerList"
    }

    private let suiteName: String

    public init(suiteName: String = ContentBlockerStoreConstants.groupName) {
        self.suiteName =  suiteName
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }

    public private(set) var unprotectedDomains: Set<String> {
        get {
            guard let data = userDefaults?.data(forKey: Keys.unprotectedDomains) else { return Set<String>() }
            guard let unprotectedDomains = NSKeyedUnarchiver.unarchiveObject(with: data) as? Set<String> else { return Set<String>() }
            return unprotectedDomains
        }
        set(newUnprotectedDomain) {
            let data = NSKeyedArchiver.archivedData(withRootObject: newUnprotectedDomain)
            userDefaults?.set(data, forKey: Keys.unprotectedDomains)
            onStoreChanged()
        }
    }

    public func isProtected(domain: String?) -> Bool {
        guard let domain = domain else { return true }
        return !unprotectedDomains.contains(domain)
    }

    public func disableProtection(forDomain domain: String) {
        var domains = unprotectedDomains
        domains.insert(domain)
        unprotectedDomains = domains
    }

    public func enableProtection(forDomain domain: String) {
        var domains = unprotectedDomains
        domains.remove(domain)
        unprotectedDomains = domains
    }

    private func onStoreChanged() {
        NotificationCenter.default.post(name: ContentBlockerProtectionChangedNotification.name, object: nil)
    }
}

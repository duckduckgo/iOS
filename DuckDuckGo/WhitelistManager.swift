//
//  WhitelistManager.swift
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

public class WhitelistManager {

    private let contentBlockerConfigurationStore: ContentBlockerConfigurationStore

    public var count: Int {
        get {
            return contentBlockerConfigurationStore.domainWhitelist.count
        }
    }

    private var domains: [String]?

    public init(contentBlockerConfigurationStore: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()) {
        self.contentBlockerConfigurationStore = contentBlockerConfigurationStore
    }

    public func add(domain: String) {
        contentBlockerConfigurationStore.addToWhitelist(domain: domain)
        domains = nil
    }

    public func remove(domain: String) {
        contentBlockerConfigurationStore.removeFromWhitelist(domain: domain)
        domains = nil
    }

    public func isWhitelisted(domain: String) -> Bool {
        return contentBlockerConfigurationStore.domainWhitelist.contains(domain)
    }

    public func domain(at index: Int) -> String? {
        if self.domains == nil {
            self.domains = Array(contentBlockerConfigurationStore.domainWhitelist).sorted()
        }
        return self.domains?[index]
    }

}

//
//  UnprotectedSitesManager.swift
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

public class UnprotectedSitesManager {

    private let contentBlockerProtectionStore: ContentBlockerProtectionStore

    public var count: Int {
        return contentBlockerProtectionStore.unprotectedDomains.count
    }

    var domains: [String]? {
        Array(contentBlockerProtectionStore.unprotectedDomains).sorted()
    }

    public init(contentBlockerProtectionStore: ContentBlockerProtectionStore = ContentBlockerProtectionUserDefaults()) {
        self.contentBlockerProtectionStore = contentBlockerProtectionStore
    }

    public func add(domain: String) {
        contentBlockerProtectionStore.disableProtection(forDomain: domain)
    }

    public func remove(domain: String) {
        contentBlockerProtectionStore.enableProtection(forDomain: domain)
    }

    public func isProtected(domain: String) -> Bool {
        return contentBlockerProtectionStore.isProtected(domain: domain)
    }

    public func domain(at index: Int) -> String? {
        return domains?[index]
    }

}

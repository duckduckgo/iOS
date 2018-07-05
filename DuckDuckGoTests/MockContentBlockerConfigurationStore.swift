//
//  MockContentBlockerConfigurationStore.swift
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

@testable import Core

class MockContentBlockerConfigurationStore: ContentBlockerConfigurationStore {

    var domainWhitelist = Set<String>()
    var protecting = true
    var enabled = true

    func whitelisted(domain: String) -> Bool {
        return domainWhitelist.contains(domain)
    }

    func addToWhitelist(domain: String) {
        domainWhitelist.insert(domain)
    }

    func removeFromWhitelist(domain: String) {
        domainWhitelist.remove(domain)
    }

    func protecting(domain: String?) -> Bool {
        return protecting
    }

}

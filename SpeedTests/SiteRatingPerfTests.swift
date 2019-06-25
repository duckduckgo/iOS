//
//  SiteRatingPerfTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import XCTest

@testable import DuckDuckGo
@testable import Core

class SiteRatingPerfTests: XCTestCase {
    
    override func setUp() {
        loadBlockingLists()
    }

    func testSiteRatingInitialization() {
        
        let url = URL(string: "https://google.com")!
        
        let cache = StorageCache()
        makeSiteRating(url: url, cache: cache)
        
        self.measure {
            self.makeSiteRating(url: url, cache: cache)
        }
    }
    
    func makeSiteRating(url: URL, cache: StorageCache) {
        let privacyPractices = PrivacyPractices(tld: cache.tlds,
                                                termsOfServiceStore: cache.termsOfServiceStore,
                                                entityMapping: cache.entityMapping)
        
        _ = SiteRating(url: url,
                       httpsForced: false,
                       entityMapping: cache.entityMapping,
                       privacyPractices: privacyPractices,
                       prevalenceStore: cache.prevalenceStore)
    }
}

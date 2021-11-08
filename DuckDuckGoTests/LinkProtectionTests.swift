//
//  LinkProtectionTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
@testable import Core

class LinkProtectionTests: XCTestCase {
    
    var config: PrivacyConfiguration!

    override func setUpWithError() throws {
        
        let settings: [String: Any] = [
            "ampLinkFormats": ["https?:\\/\\/(?:w{3}\\.)?google\\.\\w{2,}\\/amp\\/s\\/(\\S+)"],
            "ampKeywords": ["/amp"],
            "trackingParameters": []
        ]
        
        let features = [
            PrivacyFeature.trackingLinks.rawValue: PrivacyConfigurationData.PrivacyFeature(state: "enabled",
                                                                                           exceptions: [],
                                                                                           settings: settings)
                        ]
        let privacyData = PrivacyConfigurationData(features: features,
                                                   unprotectedTemporary: [],
                                                   trackerAllowlist: [:])

        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = []

        config = AppPrivacyConfiguration(data: privacyData,
                                       identifier: "",
                                       localProtection: localProtection)
    }

    func testLinkCleanerExtractsURL() throws {
        let testUrl = URL(string: "https://www.google.com/amp/s/www.example.com/some/article")!
        
        if let cleanUrl = LinkCleaner.shared.extractCanonicalFromAmpLink(initiator: nil, destination: testUrl,
                                                                         config: config) {
            XCTAssertEqual(cleanUrl.absoluteString, "https://www.example.com/some/article", "LinkCleaner - AMP link incorrectly extracted.")
        } else {
            XCTFail("LinkCleaner - AMP link incorrectly extracted. cleanUrl is nil.")
        }
    }

    func testAmpExtractorDetectsLink() throws {
        let testUrl = URL(string: "https://example.com/amp/some/article")
        
        let result = AMPCanonicalExtractor.shared.urlContainsAmpKeyword(testUrl, config: config)
        XCTAssertTrue(result, "AMPCanonicalExtractor - Should detect AMP keyword")
    }

}

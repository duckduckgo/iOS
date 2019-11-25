//
//  PrivacyPracticesTests.swift
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

import XCTest
@testable import Core

class PrivacyPracticesTests: XCTestCase {
    
    func testUnknownPrivacyPractices() {
        let tosdrStore = MockTermsOfServiceStore(terms: [:])
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore)
        let practice = testee.findPractice(forHost: "example.com")
        XCTAssertEqual(2, practice.score)
        XCTAssertEqual(.unknown, practice.summary)
    }
    
    func testScoreForParentEntityUsesWorstForNetwork() {
        
        let tosdrStore = MockTermsOfServiceStore(terms: [
            "sibling1.com": TermsOfService(classification: .a, score: 0, goodReasons: [], badReasons: ["reason"]),
            "sibling2.com": TermsOfService(classification: .b, score: 0, goodReasons: [], badReasons: []),
            "sibling3.com": TermsOfService(classification: .c, score: 0, goodReasons: [], badReasons: []),
            "sibling4.com": TermsOfService(classification: .d, score: 0, goodReasons: [], badReasons: [])
            ])
        
        let entityMapping = EntityMapping(entities: ["Sibling": EntityMapping.Entity(displayName: "Sibling", domains: nil, prevalence: 100)],
                                          domains: ["sibling1.com": "Sibling",
                                                    "sibling2.com": "Sibling",
                                                    "sibling3.com": "Sibling",
                                                    "sibling4.com": "Sibling"])
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMapping: entityMapping)
        XCTAssertEqual(10, testee.findPractice(forHost: "sibling1.com").score)
        
    }
    
    func testWhenDomainUsedBecauseNoParentEntityThenScoreIsFound() {

        let tosdrStore = MockTermsOfServiceStore(terms: [
            "orphan.com": TermsOfService(classification: .d, score: 0, goodReasons: [], badReasons: [])
            ])
        
        let entityMapping = EntityMapping(entities: [:], domains: [:])
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMapping: entityMapping)
        XCTAssertEqual(10, testee.findPractice(forHost: "orphan.com").score)

    }
    
    func testWhenDomainUsedForLookupThenTermsAreReturned() {
        let entityMapping = EntityMapping(entities: [:], domains: [:])
        let testee = PrivacyPractices(entityMapping: entityMapping)
        let practice = testee.findPractice(forHost: "google.com")
        XCTAssertEqual(.poor, practice.summary)
    }

    func testWhenSubDomainUsedForLookupThenTermsAreReturned() {
        let entityMapping = EntityMapping(entities: [:], domains: [:])
        let testee = PrivacyPractices(entityMapping: entityMapping)
        let practice = testee.findPractice(forHost: "maps.google.com")
        XCTAssertEqual(.poor, practice.summary)
    }

}

private struct MockTermsOfServiceStore: TermsOfServiceStore {
    
    var terms: [String: TermsOfService]
    
}

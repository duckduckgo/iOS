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
        let practice = testee.practice(for: URL(string: "http://example.com")!)
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
        
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMapping: entityMapping)
        XCTAssertEqual(10, testee.practice(for: URL(string: "http://sibling1.com")!).score)
        
    }
    
    func testWhenDomainUsedBecauseNoParentEntityThenScoreIsFound() {

        let tosdrStore = MockTermsOfServiceStore(terms: [
            "orphan.com": TermsOfService(classification: .d, score: 0, goodReasons: [], badReasons: [])
            ])
        
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMapping: entityMapping)
        XCTAssertEqual(10, testee.practice(for: URL(string: "http://orphan.com")!).score)

    }
    
    func testWhenDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMapping: entityMapping)
        let score = testee.practice(for: URL(string: "http://google.com")!)
        XCTAssertEqual(.poor, score.summary)
    }

    func testWhenSubDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMapping: entityMapping)
        let score = testee.practice(for: URL(string: "http://maps.google.com")!)
        XCTAssertEqual(.poor, score.summary)
    }

}

private struct MockTermsOfServiceStore: TermsOfServiceStore {
    
    var terms: [String: TermsOfService]
    
}

private class MockEntityMappingStore: EntityMappingStore {
    
    func load() -> Data? {
        return """
{
    "Google": {
        "properties": [
            "google.com"
        ]
    },
    "SharedParent": {
        "properties": [
            "sibling1.com",
            "sibling2.com",
            "sibling3.com",
            "sibling4.com"
        ]
    }
}
""".data(using: .utf8)
    }
    
    func persist(data: Data) {
    }
    
}

//
//  PrivacyPracticesTests.swift
//  UnitTests
//
//  Created by Chris Brind on 19/09/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class PrivacyPracticesTests: XCTestCase {
    
    func testScoreForParentEntityUsesWorstForNetwork() {
        
        let tosdrStore = MockTermsOfServiceStore(terms: [
            "sibling1.com": TermsOfService(classification: .a, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil)),
            "sibling2.com": TermsOfService(classification: .b, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil)),
            "sibling3.com": TermsOfService(classification: .c, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil)),
            "sibling4.com": TermsOfService(classification: .d, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))
            ])
        
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMaping: entityMapping)
        XCTAssertEqual(10, testee.findPractice(forEntity: "SharedParent").score)
        
    }
    
    func testWhenDomainUsedBecauseNoParentEntityThenScoreIsFound() {

        let tosdrStore = MockTermsOfServiceStore(terms: [
            "orphan.com": TermsOfService(classification: .d, score: 0, reasons: TermsOfService.Reasons(good: nil, bad: nil))
            ])
        
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(termsOfServiceStore: tosdrStore, entityMaping: entityMapping)
        XCTAssertEqual(10, testee.findPractice(forEntity: "orphan.com").score)

    }
    
    func testWhenEntityUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.findPractice(forEntity: "Google")
        XCTAssertEqual(.poor, score.summary)
    }
    
    func testWhenDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.findPractice(forEntity: "google.com")
        XCTAssertEqual(.poor, score.summary)
    }

    func testWhenSubDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.findPractice(forEntity: "maps.google.com")
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

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
    
    func testWhenEntityUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.score(forEntity: "Google")
        XCTAssertEqual(.poor, score.summary)
    }
    
    func testWhenDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.score(forEntity: "google.com")
        XCTAssertEqual(.poor, score.summary)
    }

    func testWhenSubDomainUsedForLookupThenTermsAreReturned() {
        let entityMappingStore = MockEntityMappingStore()
        let entityMapping = EntityMapping(store: entityMappingStore)
        let testee = PrivacyPractices(entityMaping: entityMapping)
        let score = testee.score(forEntity: "maps.google.com")
        XCTAssertEqual(.poor, score.summary)
    }

}

private class MockEntityMappingStore: EntityMappingStore {
    
    func load() -> Data? {
        return """
{
    "Google": {
        "properties": [
            "google.com"
        ]
    }
}
""".data(using: .utf8)
    }
    
    func persist(data: Data) {
    }
    
}

//
//  EntityMappingTests.swift
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

class EntityMappingTests: XCTestCase {
    
    struct SampleData {
    
        static let jsonWithUnexpectedItem = """
{
    "365Media": {
        "properties": [
            "aggregateintelligence.com"
        ],
        "resources": [
            "aggregateintelligence.com"
        ],
        "unexpected": 100
    }
}
"""
   
        static let validJson = """
{
    "365Media": {
        "properties": [
            "aggregateintelligence.com"
        ],
        "resources": [
            "365dm.com",
            "365media.com",
            "aggregateintelligence.com"
        ]
    },
    "4mads": {
        "properties": [
            "4mads.com"
        ],
        "resources": [
            "4madsaye.com"
        ]
    }
}
"""
        
        static let invalidJson = "{"
        
    }

    func testWhenDomainHasSubdomainThenParentEntityIsFound() {
        let testee = EntityMapping(store: MockEntityMappingStore(data: SampleData.validJson.data(using: .utf8)))
        XCTAssertEqual("365Media", testee.findEntity(forHost: "sub.domain.365dm.com"))
        XCTAssertEqual("4mads", testee.findEntity(forHost: "www.4mads.com"))
    }
    
    func testWhenJsonContainsUnexpectedPropertiesThenCorrectEntitiesAreExtracted() {
        let testee = EntityMapping(store: MockEntityMappingStore(data: SampleData.jsonWithUnexpectedItem.data(using: .utf8)))
        XCTAssertEqual("365Media", testee.findEntity(forHost: "aggregateintelligence.com"))
    }

    func testWhenJsonIsInvalidThenNoEntitiesFound() {
        let testee = EntityMapping(store: MockEntityMappingStore(data: SampleData.invalidJson.data(using: .utf8)))
        XCTAssertNil(testee.findEntity(forHost: "aggregateintelligence.com"))
    }
    
    func testWhenJsonIsValidThenCorrectEntitiesAreExtracted() {
        
        let testee = EntityMapping(store: MockEntityMappingStore(data: SampleData.validJson.data(using: .utf8)))
        XCTAssertEqual("365Media", testee.findEntity(forHost: "aggregateintelligence.com"))
        XCTAssertEqual("365Media", testee.findEntity(forHost: "365media.com"))
        XCTAssertEqual("365Media", testee.findEntity(forHost: "365dm.com"))
        XCTAssertEqual("4mads", testee.findEntity(forHost: "4mads.com"))
        XCTAssertEqual("4mads", testee.findEntity(forHost: "4madsaye.com"))

    }
    
}

private class MockEntityMappingStore: EntityMappingStore {
    
    var data: Data?

    init(data: Data?) {
        self.data = data
    }
    
    func load() -> Data? {
        return data
    }
    
    func persist(data: Data) {
        self.data = data
    }

}

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
    
    /// This is now based on the embedded tracker data so if this test fails it might be because the embedded data was updated.
    func testWhenDomainHasSubdomainThenParentEntityIsFound() {
        let testee = EntityMapping()
        XCTAssertEqual("comScore", testee.findEntity(forHost: "sub.domain.comscore.com")?.displayName)
        XCTAssertEqual("comScore", testee.findEntity(forHost: "www.comscore.com")?.displayName)
        XCTAssertEqual("comScore", testee.findEntity(forHost: "comscore.com")?.displayName)
    }
    
}

//
//  BookmarksMigrationAssertionTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import XCTest
@testable import DuckDuckGo
@testable import Core

class BookmarksMigrationAssertionTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<Any>.Key.bookmarksMigrationVersion.rawValue)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<Any>.Key.bookmarksLastGoodVersion.rawValue)
    }
    
    func testWhenAssertWithDifferentVersionThenNoAssertion() {
        let assertion = BookmarksMigrationAssertion()
        do {
            try assertion.assert(migrationVersion: 1)
        } catch {
            XCTFail("Unexpected throw")
        }

        do {
            try assertion.assert(migrationVersion: 2)
        } catch {
            XCTFail("Unexpected throw")
        }
    }

    func testWhenAssertWithSameVersionThenAssertionFails() {
        let assertion = BookmarksMigrationAssertion()
        do {
            try assertion.assert(migrationVersion: 1)
        } catch {
            XCTFail("Unexpected throw")
        }

        do {
            try assertion.assert(migrationVersion: 1)
            XCTFail("Expected throw didn't happen")
        } catch {
            // no-op
        }
    }
    
    func testWhenInitialStateThenNoAssertionAndLastGoodVersionSet() {
        let assertion = BookmarksMigrationAssertion()
        do {
            try assertion.assert(migrationVersion: 1)
        } catch {
            XCTFail("Unexpected throw")
        }
        XCTAssertNotNil(assertion.lastGoodVersion)
    }
    
}

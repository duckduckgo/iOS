//
//  UsageSegmentationStorageTests.swift
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
@testable import Core
@testable import TestUtils

class UsageSegmentationStorageTests: XCTestCase {

    let keyValueStore = MockKeyValueStore()

    func test() {

        // Initial state
        let storage = UsageSegmentationStorage(keyValueStore: keyValueStore)
        XCTAssertEqual(storage.atbs, [])

        // Save some data and get it back from same instance
        let testAtb1 = Atb(version: "test1", updateVersion: nil)
        storage.atbs = [testAtb1]
        XCTAssertEqual(storage.atbs, [testAtb1])

        // Get it back from a different instance
        let newStorage = UsageSegmentationStorage(keyValueStore: keyValueStore)
        XCTAssertEqual(newStorage.atbs, [testAtb1])

        // Check we use underlying storage by saving on one instance and getting back on the other
        storage.atbs = []
        XCTAssertEqual(newStorage.atbs, [])
    }

}

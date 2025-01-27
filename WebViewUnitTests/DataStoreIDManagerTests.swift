//
//  DataStoreIDManagerTests.swift
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
import WebKit
import PersistenceTestingUtils

class DataStoreIDManagerTests: XCTestCase {

    func testWhenFreshlyInstalledThenNoIDIsAllocated() {
        let manager = DataStoreIDManager(store: MockKeyValueStore())
        XCTAssertNil(manager.currentID)
    }

    func testWhenIDIsInvalidatedThenNoNewIDIsCreated() {
        let manager = DataStoreIDManager(store: MockKeyValueStore())
        XCTAssertNil(manager.currentID)
        manager.invalidateCurrentID()
        XCTAssertNil(manager.currentID)
    }

    func testWhenIDAlreadyExistsThenItIsRedFromTheStore() {
        let storedUUID = UUID().uuidString
        let store = MockKeyValueStore()
        store.set(storedUUID, forKey: DataStoreIDManager.Constants.currentWebContainerID.rawValue)
        let manager = DataStoreIDManager(store: store)
        XCTAssertEqual(manager.currentID?.uuidString, storedUUID)
        manager.invalidateCurrentID()
        XCTAssertNil(manager.currentID)
    }

}

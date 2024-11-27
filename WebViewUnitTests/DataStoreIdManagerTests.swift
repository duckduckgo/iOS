//
//  DataStoreIdManagerTests.swift
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
import TestUtils

class DataStoreIdManagerTests: XCTestCase {

    func testWhenFreshlyInstalledThenNoIdIsAllocated() {
        let manager = DataStoreIdManager(store: MockKeyValueStore())
        XCTAssertNil(manager.currentId)
    }

    func testWhenIdIsInvalidatedThenNoNewIdIsCreated() {
        let manager = DataStoreIdManager(store: MockKeyValueStore())
        XCTAssertNil(manager.currentId)
        manager.invalidateCurrentId()
        XCTAssertNil(manager.currentId)
    }

    func testWhenIdAlreadyExistsThenItIsRedFromTheStore() {
        let storedUUID = UUID().uuidString
        let store = MockKeyValueStore()
        store.set(storedUUID, forKey: DataStoreIdManager.Constants.currentWebContainerId.rawValue)
        let manager = DataStoreIdManager(store: store)
        XCTAssertEqual(manager.currentId?.uuidString, storedUUID)
        manager.invalidateCurrentId()
        XCTAssertNil(manager.currentId)
    }

}

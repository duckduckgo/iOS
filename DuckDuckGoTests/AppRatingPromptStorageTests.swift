//
//  AppRatingPromptStorageTests.swift
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
@testable import DuckDuckGo
import CoreData

class AppRatingPromptStorageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        reset()
    }
    
    func testWhenUniqueAccessDaysIsSetThenItIsPersisted() {
        let storage = AppRatingPromptCoreDataStorage()
        storage.uniqueAccessDays = 6
        XCTAssertEqual(6, AppRatingPromptCoreDataStorage().uniqueAccessDays)
    }
    
    func testWhenDateIsSetThenItIsPersisted() {
        let storage = AppRatingPromptCoreDataStorage()
        storage.lastAccess = Date()
        XCTAssertNotNil(AppRatingPromptCoreDataStorage().lastAccess)
    }
    
    func testWhenStorageIsNewThenDateIsNull() {
        let storage = AppRatingPromptCoreDataStorage()
        XCTAssertNil(storage.lastAccess)
    }
    
    func testWhenStorageIsNewThenUniqueAccessDaysIsZero() {
        let storage = AppRatingPromptCoreDataStorage()
        XCTAssertEqual(0, storage.uniqueAccessDays)
    }

    private func reset() {
        let storage = AppRatingPromptCoreDataStorage()
        storage.context.delete(storage.ratingPromptEntity())
        try? storage.context.save()
    }
    
}

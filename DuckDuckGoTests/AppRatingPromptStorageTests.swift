//
//  AppRatingPromptStorageTests.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 24/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
        storage.persistence.managedObjectContext.delete(storage.entity())
        try? storage.persistence.managedObjectContext.save()
    }
    
}

//
//  AppRatingPromptTests.swift
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

class AppRatingPromptTests: XCTestCase {
    
    fileprivate var stub: AppRatingPromptStorageStub!

    override func setUp() {
        super.setUp()
        stub = AppRatingPromptStorageStub()
    }
    
    func testWhenUserAlreadyShownThenDoesntShowAgainOnSameDay() {
        
        let stub = AppRatingPromptStorageStub()
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
    
        appRatingPrompt.shown(onDate: Date().inDays(fromNow: 2))
        
        XCTAssertFalse(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 2)))
        
    }
    
    func testWhenUserAccessSeventhDayAfterSkippingSomeThenShouldPrompt() {
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 3))
        
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 5))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 6))

        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 7))

        XCTAssertTrue(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 7)))
        
    }

    func testWhenUserAccessFourthDayAfterSkippingSomeThenShouldNotPrompt() {
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 6))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 6)))
    }

    func testWhenUserAccessThirdDayAfterSkippingOneThenShouldPrompt() {
        
        let stub = AppRatingPromptStorageStub()
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 3))
        XCTAssertTrue(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 3)))
        
    }

    func testWhenUserAccessThirdDayThenShouldPrompt() {

        let stub = AppRatingPromptStorageStub()
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
        XCTAssertTrue(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 2)))
        
    }
    
    func testWhenUserAccessSecondUniqueDayThenShouldNotPrompt() {
        
        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 0))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 1)))

    }

    func testWhenUserAccessSecondTimeOnFirstDayThenShouldNotPrompt() {

        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 0))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(onDate: Date().inDays(fromNow: 0)))
        
    }

    func testWhenUserAccessFirstDayThenShouldNotPrompt() {
        XCTAssertFalse(AppRatingPrompt(storage: AppRatingPromptStorageStub()).shouldPrompt(onDate: Date().inDays(fromNow: 0)))
    }
    
}

private class AppRatingPromptStorageStub: AppRatingPromptStorage {
    
    var lastAccess: Date?
    
    var uniqueAccessDays: Int = 0
    
    var lastShown: Date?
    
}

fileprivate extension Date {
    
    func inDays(fromNow day: Int) -> Date {
        let components = DateComponents(day: day)
        return Calendar.current.date(byAdding: components, to: self)!
    }

}

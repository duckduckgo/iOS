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
    
    func testWhenUserAccessSeventhDayAfterSkippingSomeThenShouldPrompt() {
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 1))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 2))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 3))
        
        _ = appRatingPrompt.shouldPrompt(date: days(later: 5))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 6))
        
        XCTAssertTrue(appRatingPrompt.shouldPrompt(date: days(later: 7)))
        
    }

    func testWhenUserAccessFourthDayAfterSkippingSomeThenShouldNotPrompt() {
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 1))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 2))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(date: days(later: 5)))
    }

    func testWhenUserAccessThirdDayAfterSkippingOneThenShouldPrompt() {
        
        let stub = AppRatingPromptStorageStub()
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 1))
        XCTAssertTrue(appRatingPrompt.shouldPrompt(date: days(later: 3)))
        
    }

    func testWhenUserAccessThirdDayThenShouldPrompt() {

        let stub = AppRatingPromptStorageStub()
        
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        _ = appRatingPrompt.shouldPrompt(date: days(later: 1))
        XCTAssertTrue(appRatingPrompt.shouldPrompt(date: days(later: 2)))
        
    }
    
    func testWhenUserAccessSecondUniqueDayThenShouldNotPrompt() {
        
        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(date: days(later: 1)))

    }

    func testWhenUserAccessSecondTimeOnFirstDayThenShouldNotPrompt() {

        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)
        _ = appRatingPrompt.shouldPrompt(date: days(later: 0))
        XCTAssertFalse(appRatingPrompt.shouldPrompt(date: days(later: 0)))
        
    }

    func testWhenUserAccessFirstDayThenShouldNotPrompt() {
        XCTAssertFalse(AppRatingPrompt(storage: AppRatingPromptStorageStub()).shouldPrompt(date: days(later: 0)))
    }
    
    func days(later: Int) -> Date {
        var date = Date()
        
        if later == 0 {
            return date
        }
        
        for _ in 1 ... later {
            date = date.nextDay()
        }
        
        return date
    }
    
}

private class AppRatingPromptStorageStub: AppRatingPromptStorage {
    
    var lastAccess: Date?
    
    var uniqueAccessDays: Int = 0
    
}

fileprivate extension Date {
    
    func nextDay() -> Date {
        let components = DateComponents(day: 1)
        return Calendar.current.date(byAdding: components, to: self)!
    }

}

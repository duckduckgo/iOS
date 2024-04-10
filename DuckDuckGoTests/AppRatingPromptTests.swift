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
    
    func testPromptScenarios() {

        struct Scenario {
            let currentUsageDay: Int
            let firstShown: Date?
            let lastShown: Date?
            let shouldPrompt: Bool
        }

        let scenarios = [
            Scenario(currentUsageDay: 0, firstShown: nil, lastShown: nil, shouldPrompt: false),
            Scenario(currentUsageDay: 1, firstShown: nil, lastShown: nil, shouldPrompt: false),
            Scenario(currentUsageDay: 2, firstShown: nil, lastShown: nil, shouldPrompt: false),

            // This is the first day that we should see first prompt
            Scenario(currentUsageDay: 3, firstShown: nil, lastShown: nil, shouldPrompt: true),

            // But if not shown on that day it might happen later
            Scenario(currentUsageDay: 4, firstShown: nil, lastShown: nil, shouldPrompt: true),
            Scenario(currentUsageDay: 5, firstShown: nil, lastShown: nil, shouldPrompt: true),
            Scenario(currentUsageDay: 6, firstShown: nil, lastShown: nil, shouldPrompt: true),

            // Showing it resets current usage day, so if first shown is set we shouldn't show the prompt again until later
            Scenario(currentUsageDay: 0, firstShown: Date(), lastShown: nil, shouldPrompt: false),
            Scenario(currentUsageDay: 1, firstShown: Date(), lastShown: nil, shouldPrompt: false),
            Scenario(currentUsageDay: 2, firstShown: Date(), lastShown: nil, shouldPrompt: false),
            Scenario(currentUsageDay: 3, firstShown: Date(), lastShown: nil, shouldPrompt: false),

            // This is the first day that we should see second prompt
            Scenario(currentUsageDay: 4, firstShown: Date(), lastShown: nil, shouldPrompt: true),

            // But if not shown on that day it might happen later
            Scenario(currentUsageDay: 5, firstShown: Date(), lastShown: nil, shouldPrompt: true),
            Scenario(currentUsageDay: 6, firstShown: Date(), lastShown: nil, shouldPrompt: true),
            Scenario(currentUsageDay: 7, firstShown: Date(), lastShown: nil, shouldPrompt: true),

            // Once last shown is set then we wouldn't show again
            Scenario(currentUsageDay: 2, firstShown: Date(), lastShown: Date(), shouldPrompt: false),
            Scenario(currentUsageDay: 3, firstShown: Date(), lastShown: Date(), shouldPrompt: false),
            Scenario(currentUsageDay: 4, firstShown: Date(), lastShown: Date(), shouldPrompt: false),
            Scenario(currentUsageDay: 5, firstShown: Date(), lastShown: Date(), shouldPrompt: false),

            // This scenario means the user migrated their database
            Scenario(currentUsageDay: 3, firstShown: nil, lastShown: Date(), shouldPrompt: false),
            Scenario(currentUsageDay: 4, firstShown: nil, lastShown: Date(), shouldPrompt: false),
            Scenario(currentUsageDay: 5, firstShown: nil, lastShown: Date(), shouldPrompt: false),
        ]

        for scenario in scenarios {

            let stub = AppRatingPromptStorageStub()
            stub.firstShown = scenario.firstShown
            stub.lastShown = scenario.lastShown
            stub.uniqueAccessDays = scenario.currentUsageDay

            let appRatingPrompt = AppRatingPrompt(storage: stub)
            XCTAssertEqual(scenario.shouldPrompt, appRatingPrompt.shouldPrompt(), "\(scenario)")

        }

    }

    func testWhenAppPromptIsShownThenUsageDaysIsReset() {
        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)

        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 6))
        appRatingPrompt.shown()

        XCTAssertEqual(0, stub.uniqueAccessDays)
    }

    func testWhenRegisterUsageOnUniqueDaysThenIncrementsUsageCounter() {

        let stub = AppRatingPromptStorageStub()
        let appRatingPrompt = AppRatingPrompt(storage: stub)

        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 0))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 1))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 2))
        appRatingPrompt.registerUsage(onDate: Date().inDays(fromNow: 6))

        XCTAssertEqual(4, stub.uniqueAccessDays)
    }

    func testWhenUserAccessFirstDayThenShouldNotPrompt() {
        XCTAssertFalse(AppRatingPrompt(storage: AppRatingPromptStorageStub()).shouldPrompt(onDate: Date().inDays(fromNow: 0)))
    }
}

private class AppRatingPromptStorageStub: AppRatingPromptStorage {
    
    var firstShown: Date?

    var lastAccess: Date?
    
    var uniqueAccessDays: Int? = 0

    var lastShown: Date?
    
}

private extension Date {
    
    func inDays(fromNow day: Int) -> Date {
        let components = DateComponents(day: day)
        return Calendar.current.date(byAdding: components, to: self)!
    }

}

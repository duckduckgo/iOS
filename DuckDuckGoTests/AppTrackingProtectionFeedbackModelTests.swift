//
//  AppTrackingProtectionFeedbackModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Persistence
import CoreData
@testable import Core

class AppTrackingProtectionFeedbackModelTests: XCTestCase {

    var database: CoreDataDatabase!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: AppTrackingProtectionFeedbackModel.self)
        let model = CoreDataDatabase.loadModel(from: bundle, named: "AppTrackingProtectionModel")!
        let options = [
            NSPersistentHistoryTrackingKey: true as NSNumber,
            NSPersistentStoreRemoteChangeNotificationPostOptionKey: true as NSNumber
        ]

        database = CoreDataDatabase(name: "AppTrackingProtectionFeedbackModelTests",
                                    containerLocation: tempDBDir(),
                                    model: model,
                                    options: options)
        database.loadStore()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try database.tearDown(deleteStores: true)
    }

    func testWhenFetchingTrackers_ThenOnlyTrackersMoreRecentThanTheSpecifiedDateAreReturned() {
        let includedDate = createDate(year: 2023, month: 1, day: 3, hour: 1, minute: 5)
        let thresholdDate = createDate(year: 2023, month: 1, day: 3, hour: 1, minute: 0) // Use a date that is older than the trackers we want to get

        saveTracker(domain: "test1.com", owner: "Test 1", date: includedDate)
        saveTracker(domain: "test2.com", owner: "Test 2", date: includedDate)
        saveTracker(domain: "test3.com", owner: "Test 3", date: includedDate)
        saveTracker(domain: "test.com", owner: "Test", date: createDate(year: 2023, month: 1, day: 2))
        saveTracker(domain: "test.com", owner: "Test", date: createDate(year: 2023, month: 1, day: 1))

        let feedbackModel = AppTrackingProtectionFeedbackModel(appTrackingProtectionDatabase: database)
        let trackers = feedbackModel.trackers(moreRecentThan: thresholdDate)

        let expectedDomains = Set(["test1.com", "test2.com", "test3.com"])
        let fetchedDomains = Set(trackers.map(\.domain))

        XCTAssertEqual(expectedDomains, fetchedDomains)
    }

    private func saveTracker(domain: String, owner: String, date: Date) {
        let storingModel = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        storingModel.storeTracker(domain: domain, trackerOwner: owner, blocked: true, date: date)
    }

    private func createDate(year: Int, month: Int, day: Int, hour: Int = 9, minute: Int = 42) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute

        return Calendar(identifier: .gregorian).date(from: dateComponents)!
    }

}

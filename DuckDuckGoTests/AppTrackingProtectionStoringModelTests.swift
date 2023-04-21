//
//  AppTrackingProtectionStoringModelTests.swift
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

class AppTrackingProtectionStoringModelTests: XCTestCase {

    var database: CoreDataDatabase!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: AppTrackingProtectionListViewModel.self)
        let model = CoreDataDatabase.loadModel(from: bundle, named: "AppTrackingProtectionModel")!

        database = CoreDataDatabase(name: "AppTrackingProtectionStoringModelTests", containerLocation: tempDBDir(), model: model)
        database.loadStore()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try database.tearDown(deleteStores: true)
    }

    func testWhenStoringSingleTracker_AndTrackerIsGivenADate_ThenTrackerIsPutIntoCorrectBucket() {
        let store = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let trackers = fetchTrackers(context)

        XCTAssertEqual(trackers.count, 1)
        XCTAssertEqual(trackers.first?.bucket, "2023-01-01")
    }

    func testWhenStoringMultipleTrackers_AndTrackersHaveSameDate_ThenAllTrackersAreInTheSameBucket() {
        let store = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain2.com", trackerOwner: "Owner 2", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain3.com", trackerOwner: "Owner 3", blocked: true, date: createDate(year: 2023, month: 1, day: 1))

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let trackers = fetchTrackers(context)

        XCTAssertEqual(trackers.count, 3)

        for tracker in trackers {
            XCTAssertEqual(tracker.bucket, "2023-01-01")
        }
    }

    func testWhenStoringMultipleTrackers_AndTrackersHaveSameDomainAndDate_ThenOnlySingleTrackerIsSaved_AndTrackerCountIsUpdated() {
        let store = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let trackers = fetchTrackers(context)

        XCTAssertEqual(trackers.count, 1)
        XCTAssertEqual(trackers.first?.bucket, "2023-01-01")
        XCTAssertEqual(trackers.first?.count, 3)
    }

    func testWhenStoringTrackers_ThenStaleTrackersAreRemoved() {
        let store = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain2.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))
        store.storeTracker(domain: "domain3.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let initialTrackers = fetchTrackers(context)
        XCTAssertEqual(initialTrackers.count, 3)

        // Store a tracker that is over 7 days later from previous ones, which is expected to trigger stale trackers to be purged.
        store.storeTracker(domain: "domain4.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 9))

        let updatedTrackers = fetchTrackers(context)
        XCTAssertEqual(updatedTrackers.count, 1)
    }

    func testWhenRemovingStaleTrackers_ThenValidTrackersRemain() {
        let store = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        store.storeTracker(domain: "domain.com", trackerOwner: "Owner", blocked: true, date: createDate(year: 2023, month: 1, day: 1))

        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let initialTrackers = fetchTrackers(context)
        XCTAssertEqual(initialTrackers.count, 1)

        store.removeStaleEntries(currentDate: createDate(year: 2023, month: 2, day: 1))

        let updatedTrackers = fetchTrackers(context)
        XCTAssertEqual(updatedTrackers.count, 0)
    }

    // MARK: - Utilities

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 9
        dateComponents.minute = 42

        return Calendar(identifier: .gregorian).date(from: dateComponents)!
    }

    private func fetchTrackers(_ context: NSManagedObjectContext) -> [AppTrackerEntity] {
        let request = AppTrackerEntity.fetchRequest()
        request.returnsObjectsAsFaults = false
        return (try? context.fetch(request)) ?? []
    }

}

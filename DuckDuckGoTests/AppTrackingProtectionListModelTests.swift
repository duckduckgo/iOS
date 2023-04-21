//
//  AppTrackingProtectionListModelTests.swift
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
import Combine
@testable import Core

class AppTrackingProtectionListModelTests: XCTestCase {

    var database: CoreDataDatabase!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: AppTrackingProtectionListViewModel.self)
        let model = CoreDataDatabase.loadModel(from: bundle, named: "AppTrackingProtectionModel")!
        let options = [
            NSPersistentHistoryTrackingKey: true as NSNumber,
            NSPersistentStoreRemoteChangeNotificationPostOptionKey: true as NSNumber
        ]

        database = CoreDataDatabase(name: "AppTrackingProtectionListModelTests",
                                    containerLocation: tempDBDir(),
                                    model: model,
                                    options: options)
        database.loadStore()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try database.tearDown(deleteStores: true)
    }

    func testWhenSavingMultipleTrackers_AndTrackersHaveTheSameBucket_ThenOneSectionIsReturned() {
        saveTracker(domain: "test1.com", owner: "Test 1", date: createDate(year: 2023, month: 1, day: 1))
        saveTracker(domain: "test2.com", owner: "Test 2", date: createDate(year: 2023, month: 1, day: 1))
        saveTracker(domain: "test3.com", owner: "Test 3", date: createDate(year: 2023, month: 1, day: 1))

        let listModel = AppTrackingProtectionListViewModel(appTrackingProtectionDatabase: database)

        XCTAssertEqual(listModel.sections.count, 1)
        XCTAssertEqual(listModel.sections.first?.objects?.count, 3)
    }

    func testWhenSavingMultipleTrackers_AndTrackersHaveDifferentBuckets_ThenMultipleSectionsAreReturned_AndMostRecentSectionsAreFirst() {
        saveTracker(domain: "test.com", owner: "Test", date: createDate(year: 2023, month: 1, day: 1))
        saveTracker(domain: "test.com", owner: "Test", date: createDate(year: 2023, month: 1, day: 2))
        saveTracker(domain: "test.com", owner: "Test", date: createDate(year: 2023, month: 1, day: 3))

        let listModel = AppTrackingProtectionListViewModel(appTrackingProtectionDatabase: database)

        XCTAssertEqual(listModel.sections.count, 3)
        XCTAssertEqual(listModel.sections.first?.name, "2023-01-03")
        XCTAssertEqual(listModel.sections.first?.objects?.count, 1)
        XCTAssertEqual(listModel.sections.last?.name, "2023-01-01")
        XCTAssertEqual(listModel.sections.last?.objects?.count, 1)
    }

    func testWhenNewChangesAreWrittenToTheDatabase_ThenTheSectionsPropertyIsUpdated() {
        let listModel = AppTrackingProtectionListViewModel(appTrackingProtectionDatabase: database)
        XCTAssertEqual(listModel.sections.count, 0)

        let expectation = self.expectation(description: "Fetched new sections expectation")
        var fetchedSections: [NSFetchedResultsSectionInfo]?

        let sectionsCancellable = listModel.$sections.dropFirst().sink { sections in
            fetchedSections = sections
            expectation.fulfill()
        }

        saveTracker(domain: "domain.com", owner: "Owner", date: Date())

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(fetchedSections?.count, 1)
        XCTAssertEqual((fetchedSections?.first?.objects?.first as? AppTrackerEntity)?.domain, "domain.com")

        sectionsCancellable.cancel()
    }

    private func saveTracker(domain: String, owner: String, date: Date) {
        let storingModel = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        storingModel.storeTracker(domain: domain, trackerOwner: owner, blocked: true, date: date)
    }

    private func createDate(year: Int, month: Int, day: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 9
        dateComponents.minute = 42

        return Calendar(identifier: .gregorian).date(from: dateComponents)!
    }

}

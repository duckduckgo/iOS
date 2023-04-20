//
//  AppTrackingProtectionStoringModelPerformanceTests.swift
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
import CoreData
import Persistence
@testable import Core

class AppTrackingProtectionStoringModelPerformanceTests: XCTestCase {

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var database: CoreDataDatabase!

    override func setUp() {
        super.setUp()

        let bundle = Bundle(for: AppTrackingProtectionStoringModel.self)
        let model = CoreDataDatabase.loadModel(from: bundle, named: "AppTrackingProtectionModel")!
        let options = [
            NSPersistentHistoryTrackingKey: true as NSNumber,
            NSPersistentStoreRemoteChangeNotificationPostOptionKey: true as NSNumber
        ]

        database = CoreDataDatabase(name: "AppTrackingProtectionStoringModelPerformanceTests",
                                    containerLocation: tempDBDir(),
                                    model: model,
                                    options: options)
        database.loadStore()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try database.tearDown(deleteStores: true)
    }

    func testNewTrackerPerformance() throws {
        let dates = [
            createDate(year: 2023, month: 01, day: 01),
            createDate(year: 2023, month: 01, day: 02),
            createDate(year: 2023, month: 01, day: 03),
            createDate(year: 2023, month: 01, day: 04),
            createDate(year: 2023, month: 01, day: 05),
            createDate(year: 2023, month: 01, day: 06),
            createDate(year: 2023, month: 01, day: 07)
        ]

        for date in dates {
            try populateData(in: database, date: date, trackerCount: 10_000)
        }

        let storingModel = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)
        var newTrackerValue = 1

        measure {
            storingModel.storeTracker(domain: "newtracker\(newTrackerValue).com",
                                             trackerOwner: "New",
                                             blocked: true,
                                             date: createDate(year: 2023, month: 01, day: 07))
            newTrackerValue += 1
        }
    }

    func testExistingTrackerPerformance() throws {
        let dates = [
            createDate(year: 2023, month: 01, day: 01),
            createDate(year: 2023, month: 01, day: 02),
            createDate(year: 2023, month: 01, day: 03),
            createDate(year: 2023, month: 01, day: 04),
            createDate(year: 2023, month: 01, day: 05),
            createDate(year: 2023, month: 01, day: 06),
            createDate(year: 2023, month: 01, day: 07)
        ]

        for date in dates {
            try populateData(in: database, date: date, trackerCount: 10_000)
        }

        let storingModel = AppTrackingProtectionStoringModel(appTrackingProtectionDatabase: database)

        measure {
            storingModel.storeTracker(domain: "tracker1.com", trackerOwner: "Existing",
                                      blocked: true, date: createDate(year: 2023, month: 01, day: 07))
        }
    }

    // MARK: - Utilities

    func populateData(in database: CoreDataDatabase, date: Date, trackerCount: Int) throws {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let bucket = dateFormatter.string(from: date)

        for value in 0...trackerCount {
            let name = "tracker\(value).com"
            _ = AppTrackerEntity.makeTracker(domain: name, trackerOwner: name, blocked: true, date: date, bucket: bucket, context: context)
        }

        try context.save()
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

    private func fetchTrackers(_ context: NSManagedObjectContext) -> [AppTrackerEntity] {
        let request = AppTrackerEntity.fetchRequest()
        request.returnsObjectsAsFaults = false
        return (try? context.fetch(request)) ?? []
    }

}

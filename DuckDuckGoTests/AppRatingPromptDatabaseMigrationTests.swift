//
//  AppRatingPromptDatabaseMigrationTests.swift
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

import XCTest
@testable import DuckDuckGo
@testable import Core
import CoreData
import Persistence

// If making future changes take a copy of the v2 momd and Database file like here and update / add tests as appropiate.
class AppRatingPromptDatabaseMigrationTests: XCTestCase {

    func testExpectedNumberOfModelVersionsInLatestModel() throws {
        guard let modelURL = Bundle.main.url(forResource: "AppRatingPrompt", withExtension: "momd") else {
            XCTFail("Error loading model URL")
            return
        }
        let modelVersions = try FileManager.default.contentsOfDirectory(at: modelURL, includingPropertiesForKeys: nil, options: [])
            .filter { $0.lastPathComponent.hasSuffix(".mom") }
        XCTAssertEqual(2, modelVersions.count)
    }

    func testMigrationFromV1toLatest() {

        guard let baseURL = Bundle(for: (type(of: self))).url(forResource: "AppRatingPrompt_v1", withExtension: nil) else {
            XCTFail("could not get base url")
            return
        }

        guard let latestModel = CoreDataDatabase.loadModel(from: .main, named: "AppRatingPrompt") else {
            XCTFail("could not load latest model")
            return
        }

        let storeURL = baseURL.appendingPathComponent("Database.sqlite")

        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]

            // Run the migration
            let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: latestModel)
            let newStore = try newCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                 configurationName: nil,
                                                                 at: storeURL,
                                                                 options: options)

            // Check the data exists
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = newCoordinator
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "AppRatingPromptEntity")
            let count = try context.count(for: fetchRequest)
            XCTAssertGreaterThan(count, 0, "Migration failed, no entities found.")

        } catch {
            XCTFail("Migration failed with error: \(error)")
        }

    }

}

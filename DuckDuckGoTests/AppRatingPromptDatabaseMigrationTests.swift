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
import CoreData

class AppRatingPromptDatabaseMigrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    func testMigrationFromV1toV2() {
        let oldModelURL = Bundle(for: type(of: self)).url(forResource: "AppRatingPrompt_v1", withExtension: "momd")!
        let oldModel = NSManagedObjectModel(contentsOf: oldModelURL)!

        let newModelURL = Bundle(for: type(of: self)).url(forResource: "NewModel", withExtension: "momd")!
        let newModel = NSManagedObjectModel(contentsOf: newModelURL)!

        let storeURL = Bundle(for: type(of: self)).url(forResource: "AppRatingPrompt_v1", withExtension: "sqlite")!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldModel)

        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            let oldStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: storeURL,
                                                              options: options)

            // Attempt to migrate to the new model
            let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: newModel)
            let newStore = try newCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                 configurationName: nil,
                                                                 at: storeURL,
                                                                 options: options)

            // Verify migration success (example: checking the count of a specific entity)
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = newCoordinator
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "YourEntityName")
            let count = try context.count(for: fetchRequest)
            XCTAssertGreaterThan(count, 0, "Migration failed, no entities found.")

        } catch {
            XCTFail("Migration failed with error: \(error)")
        }

    }

}

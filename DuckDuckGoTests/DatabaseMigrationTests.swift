//
//  DatabaseMigrationTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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
@testable import Core
@testable import DuckDuckGo

class DatabaseMigrationTests: XCTestCase {
    
    let sourceDB = Database(name: "Source", model: Database.shared.model)

    override func setUp() {
        sourceDB.loadStore()
        
        cleanup(database: Database.shared)
        cleanup(database: sourceDB)
    }
    
    override func tearDown() {
        cleanup(database: Database.shared)
        cleanup(database: sourceDB)
    }
    
    private func cleanup(database: Database) {
        let context = database.makeContext(concurrencyType: .mainQueueConcurrencyType)
        context.deleteAll(entityDescriptions: [PPTrackerNetwork.entity(),
                                               PPPageStats.entity()])
        try? context.save()
    }
    
    private func populate(context: NSManagedObjectContext) {
        let tn1 = PPTrackerNetwork(context: context)
        tn1.name = "1"
        let tn2 = PPTrackerNetwork(context: context)
        tn2.name = "2"
        
        _ = PPPageStats(context: context)
        
        do {
            try context.save()
        } catch {
            XCTFail("Could not save context: \(error.localizedDescription)")
        }
    }
    
    func testWhenDestinationIsEmptyThenMigrateAndClean() {
        let destination = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let source = sourceDB.makeContext(concurrencyType: .mainQueueConcurrencyType)
        
        populate(context: source)
        
        var result = (try? destination.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.isEmpty)
        
        result = (try? source.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.count == 2)
        
        let migrated = expectation(description: "Migration finished")
        DatabaseMigration.migrate(from: source,
                                  to: destination,
                                  with: { (source: PPTrackerNetwork, dest: PPTrackerNetwork) in
                                    dest.name = source.name
        },
                                  completion: { migrated.fulfill() })
        
        result = (try? destination.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.count == 2)
        XCTAssert(destination.hasChanges == false)
        
        result = (try? source.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.isEmpty)
        XCTAssert(source.hasChanges == false)
        
        wait(for: [migrated], timeout: 1)
    }
    
    func testWhenDestinationIsNotEmptyThenSkipAndClean() {
        let destination = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let source = sourceDB.makeContext(concurrencyType: .mainQueueConcurrencyType)
        
        populate(context: source)
        populate(context: destination)
        
        var result: [PPTrackerNetwork] = (try? destination.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.count == 2)
        
        // Update name here, this change should be unsaved after migration
        result.last?.name = "Updated"
        
        result = (try? source.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.count == 2)
        
        let migrated = expectation(description: "Migration finished")
        DatabaseMigration.migrate(from: source,
                                  to: destination,
                                  with: { (source: PPTrackerNetwork, dest: PPTrackerNetwork) in
                                    dest.name = source.name
        },
                                  completion: { migrated.fulfill() })
        
        result = (try? destination.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.count == 2)
        XCTAssert(destination.hasChanges)
        let modified = destination.updatedObjects.first(where: { ($0 as? PPTrackerNetwork)?.name == "Updated"})
        XCTAssertNotNil(modified)
        
        result = (try? source.fetch(PPTrackerNetwork.fetchRequest())) ?? []
        XCTAssert(result.isEmpty)
        
        wait(for: [migrated], timeout: 1)
    }
}

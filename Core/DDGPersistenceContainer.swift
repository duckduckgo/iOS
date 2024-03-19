//
//  DDGPersistenceContainer.swift
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

import Foundation
import CoreData

/// Redundant when only targeting iOS 11+, can use NSPersistentContainer
public class DDGPersistenceContainer {

    public let managedObjectModel: NSManagedObjectModel
    public let persistenceStoreCoordinator: NSPersistentStoreCoordinator
    public let managedObjectContext: NSManagedObjectContext

    public init?(name: String, model: NSManagedObjectModel, concurrencyType: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType) {

        self.managedObjectModel = model

        guard let persistenceStoreCoordinator =
            DDGPersistenceContainer.createPersistenceStoreCoordinator(name: name, model: managedObjectModel) else { return nil }
        self.persistenceStoreCoordinator = persistenceStoreCoordinator

        managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistenceStoreCoordinator
    }

    private static func createPersistenceStoreCoordinator(name: String, model: NSManagedObjectModel) -> NSPersistentStoreCoordinator? {
        guard let storeURL = storeURL(for: name) else { return nil }

        let persistenceStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let options = [ NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true ]
        do {
            try persistenceStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            return nil
        }

        return persistenceStoreCoordinator
    }

    public static func storeURL(for name: String) -> URL? {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return nil }

        let storeName = name + ".sqlite"
        return docsDir.appendingPathComponent(storeName)
    }

    public func save() -> Bool {

        do {
            try managedObjectContext.save()
        } catch {
            debugPrint("Error saving context", error.localizedDescription)
            return false
        }

        return true
    }
}

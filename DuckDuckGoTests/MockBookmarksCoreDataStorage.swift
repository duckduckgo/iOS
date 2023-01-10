//
//  MockBookmarksCoreDataStorage.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import os.log
@testable import DuckDuckGo
@testable import Core

class MockBookmarksCoreDataStore: BookmarksCoreDataStorage {

    override init() {
        super.init()

        persistentContainer = NSPersistentContainer(
            name: BookmarksCoreDataStorage.Constants.databaseName,
            managedObjectModel: BookmarksCoreDataStorage.managedObjectModel
        )

        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSInMemoryStoreType
        storeDescription.url = URL(fileURLWithPath: "/dev/null")

        persistentContainer.persistentStoreDescriptions = [storeDescription]

        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // We'll throw a fatalError() because we can't really proceed without loading the PersistentStore
                fatalError("loadPersistentStore failed \(error), \(error.userInfo)")
            }
        }

        viewContext = persistentContainer.viewContext
    }

    func saveContext() {
        viewContext.performAndWait {
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    os_log("Failed to save context %s", log: .generalLog, type: .error, error.localizedDescription)
                }
            }
        }
    }

    override func getTemporaryPrivateContext() -> NSManagedObjectContext {
        return viewContext
    }

    override func loadStoreAndCaches(andMigrate handler: @escaping (NSManagedObjectContext) -> Void) {
        cacheReadOnlyTopLevelBookmarksFolder()
        cacheReadOnlyTopLevelFavoritesFolder()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(objectsDidChange),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
}

//
//  CoreDataTestUtilities.swift
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
@testable import DuckDuckGo

final class CoreData {

    static func createInMemoryPersistentContainer(modelName: String, bundle: Bundle) -> NSPersistentContainer {
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let objectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing object model from: \(modelURL)")
        }

        let container = NSPersistentContainer(name: modelName, managedObjectModel: objectModel)

        // Creates a persistent store using the in-memory model, no state will be written to disk.
        // This was the approach recommended in a WWDC session, but there is also an `NSInMemoryStoreType` option.
        // More info: https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/

        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Failed to load stores: \(error), \(error.userInfo)")
            }
        })

        return container
    }
}

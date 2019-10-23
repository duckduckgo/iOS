//
//  Database.swift
//  Core
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

import Foundation
import CoreData

public class Database {
    
    fileprivate struct Constants {
        static let databaseGroupID = "group.com.duckduckgo.database"
    }
    
    public static let shared = Database()

    private let lock = NSLock()
    private let container: NSPersistentContainer
    
    init() {
        let mainBundle = Bundle.main
        let coreBundle = Bundle(identifier: "com.duckduckgo.mobile.ios.Core")!
        
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [mainBundle, coreBundle]) else { fatalError("No DB scheme found") }
        
        container = DDGPersistentContainer(name: "Database", managedObjectModel: managedObjectModel)
        
        loadStore()
    }
    
    private func loadStore() {
        lock.lock()
        container.loadPersistentStores { _, _ in self.lock.unlock() }
    }
    
    public func makeContext(concurrencyType: NSManagedObjectContextConcurrencyType, name: String? = nil) -> NSManagedObjectContext {
        lock.lock()
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = container.persistentStoreCoordinator
        context.name = name
        lock.unlock()
        
        return context
    }
}

extension NSManagedObjectContext {
    
    public func deleteAll(entities: [NSManagedObject]?) {
        guard let entities = entities else { return }
        for entity in entities {
            delete(entity)
        }
    }
}

private class DDGPersistentContainer: NSPersistentContainer {

    override public class func defaultDirectoryURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Database.Constants.databaseGroupID)!
    } 
}

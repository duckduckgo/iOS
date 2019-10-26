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
        
        static let databaseName = "Database"
    }
    
    public static let shared = Database()

    private let semaphore = DispatchSemaphore(value: 0)
    private let container: NSPersistentContainer
    
    public var model: NSManagedObjectModel {
        return container.managedObjectModel
    }
    
    convenience init() {
        let mainBundle = Bundle.main
        let coreBundle = Bundle(identifier: "com.duckduckgo.mobile.ios.Core")!
        
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [mainBundle, coreBundle]) else { fatalError("No DB scheme found") }
        
        self.init(name: Constants.databaseName, model: managedObjectModel)
    }
    
    init(name: String, model: NSManagedObjectModel) {
        container = DDGPersistentContainer(name: name, managedObjectModel: model)
    }
    
    public func loadStore(andMigrate handler: @escaping (NSManagedObjectContext) -> Void = { _ in }) {
        container.loadPersistentStores { _, error in
            if let error = error {
                Pixel.fire(pixel: .dbInitializationError, error: error)
                // Give Pixel a chance to be sent, but not too long
                Thread.sleep(forTimeInterval: 1)
                fatalError("Could not load DB: \(error.localizedDescription)")
            }
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.container.persistentStoreCoordinator
            context.name = "Migration"
            context.perform {
                handler(context)
                self.semaphore.signal()
            }
        }
    }
    
    public func makeContext(concurrencyType: NSManagedObjectContextConcurrencyType, name: String? = nil) -> NSManagedObjectContext {
        semaphore.wait()
        let context = NSManagedObjectContext(concurrencyType: concurrencyType)
        context.persistentStoreCoordinator = container.persistentStoreCoordinator
        context.name = name
        semaphore.signal()
        
        return context
    }
}

extension NSManagedObjectContext {
    
    public func deleteAll(entities: [NSManagedObject] = []) {
        for entity in entities {
            delete(entity)
        }
    }
    
    public func deleteAll<T: NSManagedObject>(matching request: NSFetchRequest<T>) {
            if let result = try? fetch(request) {
                deleteAll(entities: result)
            }
    }
    
    public func deleteAll(entityDescriptions: [NSEntityDescription] = []) {
        for entityDescription in entityDescriptions {
            let request = NSFetchRequest<NSManagedObject>()
            request.entity = entityDescription
            
            deleteAll(matching: request)
        }
    }
}

private class DDGPersistentContainer: NSPersistentContainer {

    override public class func defaultDirectoryURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Database.Constants.databaseGroupID)!
    } 
}

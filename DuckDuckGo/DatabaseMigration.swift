//
//  DatabaseMigration.swift
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

import BrowserServicesKit
import Common
import Foundation
import CoreData
import Core

class DatabaseMigration {
    
    private enum LegacyStores: String, CaseIterable {
        case appRating = "AppRatingPrompt"
        case httpsUpgrade = "HTTPSUpgrade"
    }
    
    static func migrate(to context: NSManagedObjectContext) {
        let group = DispatchGroup()
        
        var success = true
        group.enter()
        migrate(db: LegacyStores.appRating.rawValue, to: context,
                with: { (source: AppRatingPromptEntity, destination: AppRatingPromptEntity) in
                    destination.lastAccess = source.lastAccess
                    destination.lastShown = source.lastShown
                    destination.uniqueAccessDays = source.uniqueAccessDays
        }, completion: { result in
            group.leave()
            success = success && result
        })
        
        group.enter()
        migrate(db: LegacyStores.httpsUpgrade.rawValue, to: context,
                with: { (source: HTTPSStoredBloomFilterSpecification, destination: HTTPSStoredBloomFilterSpecification) in
                    destination.errorRate = source.errorRate
                    destination.totalEntries = source.totalEntries
                    destination.sha256 = source.sha256
        }, completion: { result in
            group.leave()
            success = success && result
        })
        
        group.enter()
        migrate(db: LegacyStores.httpsUpgrade.rawValue, to: context,
                with: { (source: HTTPSExcludedDomain, destination: HTTPSExcludedDomain) in
                    destination.domain = source.domain
        }, completion: { result in
            group.leave()
            success = success && result
        })
        
        group.wait()
        
        if success,
            let model = context.persistentStoreCoordinator?.managedObjectModel {
            
            for legacyStore in LegacyStores.allCases {
                removeDatabase(dbName: legacyStore.rawValue, model: model)
            }
        }
    }
    
    static func migrate<T: NSManagedObject>(db name: String,
                                            to destination: NSManagedObjectContext,
                                            with logic: @escaping (_ source: T, _ dest: T) -> Void,
                                            completion: @escaping (Bool) -> Void) {
        guard isDatabaseAvailable(dbName: name) else {
            completion(true)
            return
        }
        
        let oldStack = DDGPersistenceContainer(name: name,
                                               model: destination.persistentStoreCoordinator!.managedObjectModel,
                                               concurrencyType: .privateQueueConcurrencyType)
        guard let stack = oldStack else {
            completion(false)
            return
        }
        
        stack.managedObjectContext.performAndWait {
            self.migrate(from: stack.managedObjectContext,
                         to: destination,
                         with: logic,
                         completion: completion)
            
            guard let store = stack.persistenceStoreCoordinator.persistentStores.last else { return }
            
            do {
                try stack.persistenceStoreCoordinator.remove(store)
            } catch {
                Pixel.fire(pixel: .dbRemovalError, error: error)
                os_log("Error removing store: %s", log: .generalLog, type: .debug, error.localizedDescription)
            }
        }
    }
    
    static func migrate<T: NSManagedObject>(from source: NSManagedObjectContext,
                                            to destination: NSManagedObjectContext,
                                            with logic: (_ source: T, _ dest: T) -> Void,
                                            completion: (Bool) -> Void) {
        let fetchRequest = T.fetchRequest()
        
        guard let existingEntities = try? source.fetch(fetchRequest) as? [T] else {
            completion(false)
            return
        }
        
        if let count = try? destination.count(for: fetchRequest), count == 0 {
            for existingEntity in existingEntities {
                let newEntity = T(context: destination)
                logic(existingEntity, newEntity)
            }
            
            do {
                try destination.save()
            } catch {
                Pixel.fire(pixel: .dbMigrationError, error: error)
                completion(false)
                return
            }
        }

        source.deleteAll(entities: existingEntities)
        try? source.save()
        
        completion(true)
    }

    private static func isDatabaseAvailable(dbName: String) -> Bool {
        guard let url = DDGPersistenceContainer.storeURL(for: dbName) else { return false }
        
        return (try? url.checkResourceIsReachable()) ?? false
    }
    
    private static func removeDatabase(dbName: String, model: NSManagedObjectModel) {
        guard let oldStack = DDGPersistenceContainer(name: dbName,
                                                     model: model,
                                                     concurrencyType: .privateQueueConcurrencyType),
            let storeURL = oldStack.persistenceStoreCoordinator.persistentStores.last?.url else { return }

        os_log("Destroying store: %s", log: .generalLog, type: .debug, dbName)
        
        do {
            try oldStack.persistenceStoreCoordinator.destroyPersistentStore(at: storeURL,
                                                                            ofType: NSSQLiteStoreType,
                                                                            options: nil)
        } catch {
            Pixel.fire(pixel: .dbDestroyError, error: error)
            os_log("Error destroying store: %s", log: .generalLog, type: .debug, error.localizedDescription)
        }
        
        removeFile(at: storeURL)
        
        let walURL = URL(fileURLWithPath: storeURL.path.appending("-wal"))
        removeFile(at: walURL)
        let shmURL = URL(fileURLWithPath: storeURL.path.appending("-shm"))
        removeFile(at: shmURL)
    }

    private static func removeFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            let nserror = error as NSError
            if nserror.domain != NSCocoaErrorDomain || nserror.code != NSFileNoSuchFileError {
                Pixel.fire(pixel: .dbDestroyFileError, error: error)
            }
            os_log("Error removing file: %s", log: .generalLog, type: .debug, error.localizedDescription)
        }
    }
}

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

import Foundation
import CoreData
import Core

class DatabaseMigration {
    
    private enum LegacyStores: String, CaseIterable {
        case appRating = "AppRatingPrompt"
        case networkLeaderboard = "NetworkLeaderboard"
        case httpsUpgrade = "HTTPSUpgrade"
    }
    
    // swiftlint:disable function_body_length
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
        migrate(db: LegacyStores.networkLeaderboard.rawValue, to: context,
                with: { (source: PPTrackerNetwork, destination: PPTrackerNetwork) in
                    destination.detectedOnCount = source.detectedOnCount
                    destination.trackersCount = source.trackersCount
                    destination.name = source.name
        }, completion: { result in
            group.leave()
            success = success && result
        })
        
        group.enter()
        migrate(db: LegacyStores.networkLeaderboard.rawValue, to: context,
                with: { (source: PPPageStats, destination: PPPageStats) in
                    destination.httpsUpgrades = source.httpsUpgrades
                    destination.pagesLoaded = source.pagesLoaded
                    destination.pagesWithTrackers = source.pagesWithTrackers
                    destination.startDate = source.startDate
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
                with: { (source: HTTPSWhitelistedDomain, destination: HTTPSWhitelistedDomain) in
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
    // swiftlint:enable function_body_length
    
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
                Logger.log(text: "Error removing store: \(error.localizedDescription)")
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
        
        Logger.log(text: "Destroying store: \(dbName)")
        
        do {
            try oldStack.persistenceStoreCoordinator.destroyPersistentStore(at: storeURL,
                                                                            ofType: NSSQLiteStoreType,
                                                                            options: nil)
            
            try FileManager.default.removeItem(at: storeURL)

            let walURL = URL(fileURLWithPath: storeURL.path.appending("-wal"))
            try FileManager.default.removeItem(at: walURL)
            let shmURL = URL(fileURLWithPath: storeURL.path.appending("-shm"))
            try FileManager.default.removeItem(at: shmURL)
        } catch {
            Pixel.fire(pixel: .dbDestroyError, error: error)
            Logger.log(text: "Error destroying store: \(error.localizedDescription)")
        }
    }
}

private class MigrationPersistentContainer: NSPersistentContainer {

    override public class func defaultDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}

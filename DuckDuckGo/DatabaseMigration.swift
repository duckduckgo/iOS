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

    static func migrate(to context: NSManagedObjectContext) {
        
        let group = DispatchGroup()
        
        group.enter()
        migrate(db: "AppRatingPrompt",
                to: context,
                with: { (source: AppRatingPromptEntity, destination: AppRatingPromptEntity) in
            destination.lastAccess = source.lastAccess
            destination.lastShown = source.lastShown
            destination.uniqueAccessDays = source.uniqueAccessDays
        }, completion: {
            group.leave()
        })
        
        group.enter()
        migrate(db: "NetworkLeaderboard",
                to: context,
                with: { (source: PPTrackerNetwork, destination: PPTrackerNetwork) in
            destination.detectedOnCount = source.detectedOnCount
            destination.trackersCount = source.trackersCount
            destination.name = source.name
        }, completion: {
            group.leave()
        })
        
        group.enter()
        migrate(db: "NetworkLeaderboard",
                to: context,
                with: { (source: PPPageStats, destination: PPPageStats) in
            destination.httpsUpgrades = source.httpsUpgrades
            destination.pagesLoaded = source.pagesLoaded
            destination.pagesWithTrackers = source.pagesWithTrackers
            destination.startDate = source.startDate
        }, completion: {
            group.leave()
        })
        
        group.enter()
        migrate(db: "HTTPSUpgrade",
                to: context,
                with: { (source: HTTPSStoredBloomFilterSpecification, destination: HTTPSStoredBloomFilterSpecification) in
            destination.errorRate = source.errorRate
            destination.totalEntries = source.totalEntries
            destination.sha256 = source.sha256
        }, completion: {
            group.leave()
        })
        
        group.enter()
        migrate(db: "HTTPSUpgrade",
                to: context,
                with: { (source: HTTPSWhitelistedDomain, destination: HTTPSWhitelistedDomain) in
            destination.domain = source.domain
        }, completion: {
            group.leave()
        })
        
        group.wait()
    }
    
    static func migrate<T: NSManagedObject>(db name: String,
                                            to destination: NSManagedObjectContext,
                                            with logic: @escaping (_ source: T, _ dest: T) -> Void,
                                            completion: @escaping () -> Void) {
        let oldStack = DDGPersistenceContainer(name: name,
                                               model: destination.persistentStoreCoordinator!.managedObjectModel,
                                               concurrencyType: .privateQueueConcurrencyType)
        guard let stack = oldStack else {
            completion()
            return
        }
        
        stack.managedObjectContext.performAndWait {
            self.migrate(from: stack.managedObjectContext,
                         to: destination,
                         with: logic,
                         completion: completion)
        }
    }
    
    static func migrate<T: NSManagedObject>(from source: NSManagedObjectContext,
                                            to destination: NSManagedObjectContext,
                                            with logic: (_ source: T, _ dest: T) -> Void,
                                            completion: () -> Void) {
        let fetchRequest = T.fetchRequest()
        
        guard let existingEntities = try? source.fetch(fetchRequest) as? [T] else {
            completion()
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
                completion()
                return
            }
        }

        source.deleteAll(entities: existingEntities)
        do {
            try source.save()
        } catch {}
        
        completion()
    }
}

private class MigrationPersistentContainer: NSPersistentContainer {

    override public class func defaultDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}

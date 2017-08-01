//
//  PersistenceContainer.swift
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

import Core
import Foundation
import CoreData

class PersistenceContainer {
    
    let managedObjectModel: NSManagedObjectModel
    let persistenceStoreCoordinator: NSPersistentStoreCoordinator
    let managedObjectContext: NSManagedObjectContext
    
    init?(name: String) {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil) else { return nil }
        self.managedObjectModel = managedObjectModel
    
        guard let persistenceStoreCoordinator = PersistenceContainer.createPersistenceStoreCoordinator(name: name, model: managedObjectModel) else { return nil }
        self.persistenceStoreCoordinator = persistenceStoreCoordinator
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistenceStoreCoordinator
    }
    
    private class func createPersistenceStoreCoordinator(name: String, model: NSManagedObjectModel) -> NSPersistentStoreCoordinator? {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return nil }
        
        let storeName = name + ".sqlite"
        let storeURL = docsDir.appendingPathComponent(storeName)
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
    
    func createStory(in feed: DDGStoryFeed) -> DDGStory {
        let story = NSEntityDescription.insertNewObject(forEntityName: "Story", into: managedObjectContext) as! DDGStory
        
        story.feed = feed
        feed.addToStories(story)
        
        return story
    }
    
    func createFeed() -> DDGStoryFeed {
        return NSEntityDescription.insertNewObject(forEntityName: "Feed", into: managedObjectContext) as! DDGStoryFeed
    }
    
    func savedStories() -> [DDGStory] {
        do {
            let request:NSFetchRequest<DDGStory> = DDGStory.fetchRequest()
            request.predicate = NSPredicate(format: "saved > 0")
            
            return try managedObjectContext.fetch(request)
        } catch {
            debugPrint("Failed to fetch stories", error.localizedDescription)
        }
        return []
    }

    func allStories() -> [DDGStory] {
        do {
            return try managedObjectContext.fetch(DDGStory.fetchRequest())
        } catch {
            debugPrint("Failed to fetch stories", error.localizedDescription)
        }
        return []
    }

    func clear() {
        
        for story in allStories() {
            managedObjectContext.delete(story)
        }
        
        _ = save()
    }
    
    func save() -> Bool {
        
        do {
            try managedObjectContext.save()
        } catch {
            debugPrint("Error saving context", error.localizedDescription)
            return false
        }
        
        return true
    }
    
}

//
//  PersistenceContainer.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation
import CoreData

class PersistenceContainer {
    
    var managedObjectModel: NSManagedObjectModel!
    var persistenceStoreCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    
    init(name: String) {
        guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: nil) else { return }
        self.managedObjectModel = managedObjectModel
        
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return }
        debugPrint("docsDir", docsDir)

        let storeName = name + ".sqlite"
        let storeURL = docsDir.appendingPathComponent(storeName)
        let persistenceStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            try persistenceStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            return
        }
        self.persistenceStoreCoordinator = persistenceStoreCoordinator
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistenceStoreCoordinator
        self.managedObjectContext = managedObjectContext
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
    
    func stories() -> [DDGStory] {
        do {
            return try managedObjectContext.fetch(DDGStory.fetchRequest()) 
        } catch {
            debugPrint("Failed to fetch stories", error.localizedDescription)
        }
        return []
    }
    
    func clear() {
        
        managedObjectContext.reset()
        
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

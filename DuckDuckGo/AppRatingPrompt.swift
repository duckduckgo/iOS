//
//  AppRatingPrompt.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import Core
import CoreData

protocol AppRatingPromptStorage {
    
    var lastAccess: Date? { get set }
    
    var uniqueAccessDays: Int { get set }
    
    var lastShown: Date? { get set }
    
}

class AppRatingPrompt {

    var storage: AppRatingPromptStorage
    
    init(storage: AppRatingPromptStorage = AppRatingPromptCoreDataStorage()) {
        self.storage = storage
    }
    
    func registerUsage(onDate date: Date = Date()) {
        if !date.isSameDay(storage.lastAccess) {
            storage.uniqueAccessDays += 1
        }
        storage.lastAccess = date
    }
    
    func shouldPrompt(onDate date: Date = Date()) -> Bool {
        return [3, 7].contains(storage.uniqueAccessDays) && !date.isSameDay(storage.lastShown)
    }
    
    func shown(onDate date: Date = Date()) {
        storage.lastShown = date
    }
    
}

class AppRatingPromptCoreDataStorage: AppRatingPromptStorage {
    
    var lastAccess: Date? {
        get {
            return ratingPromptEntity().lastAccess
        }
        
        set {
            ratingPromptEntity().lastAccess = newValue
            try? context.save()
        }
    }
    
    var uniqueAccessDays: Int {
        get {
            return Int(ratingPromptEntity().uniqueAccessDays)
        }
        
        set {
            ratingPromptEntity().uniqueAccessDays = Int64(newValue)
            try? context.save()
        }
    }
    
    var lastShown: Date? {
        get {
            return ratingPromptEntity().lastShown
        }
        
        set {
            ratingPromptEntity().lastShown = newValue
            try? context.save()
        }
    }
    
    let context: NSManagedObjectContext = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "AppRatingPrompt")
    
    public init() { }
    
    func ratingPromptEntity() -> AppRatingPromptEntity {

        let fetchRequest: NSFetchRequest<AppRatingPromptEntity> = AppRatingPromptEntity.fetchRequest()
        
        guard let results = try? context.fetch(fetchRequest) else {
            fatalError("Error fetching AppRatingPromptEntity")
        }

        if let result = results.first {
            return result
        } else {
            let entityDescription = NSEntityDescription.entity(forEntityName: "AppRatingPromptEntity",
                                                               in: context)!

            return AppRatingPromptEntity(entity: entityDescription,
                                         insertInto: context)
        }
    }
    
}

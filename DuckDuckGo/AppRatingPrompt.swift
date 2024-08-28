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
import os.log

protocol AppRatingPromptStorage {
    
    var firstShown: Date? { get set }

    var lastAccess: Date? { get set }
    
    var uniqueAccessDays: Int? { get set }

    var lastShown: Date? { get set }
    
}

class AppRatingPrompt {

    var storage: AppRatingPromptStorage
    
    var uniqueAccessDays: Int {
        storage.uniqueAccessDays ?? 0
    }

    init(storage: AppRatingPromptStorage = AppRatingPromptCoreDataStorage()) {
        self.storage = storage
    }
    
    func registerUsage(onDate date: Date = Date()) {
        guard storage.lastShown == nil else { return }

        if !date.isSameDay(storage.lastAccess), let currentUniqueAccessDays = storage.uniqueAccessDays {
            storage.uniqueAccessDays = currentUniqueAccessDays + 1
        }
        storage.lastAccess = date
    }
    
    func shouldPrompt(onDate date: Date = Date()) -> Bool {
        // To keep the database migration "lightweight" we just need to check if lastShown has been set yet.
        //  If it has then this user won't see any more prompts, which is preferable to seeing too many or too frequently.
        if uniqueAccessDays >= 3 && storage.firstShown == nil && storage.lastShown == nil {
            return true
        } else if uniqueAccessDays >= 4 && storage.lastShown == nil {
            return true
        }
        return false
    }
    
    func shown(onDate date: Date = Date()) {
        if storage.firstShown == nil {
            storage.firstShown = date
            storage.uniqueAccessDays = 0
        } else if storage.lastShown == nil {
            storage.lastShown = date
        }
    }
    
}

class AppRatingPromptCoreDataStorage: AppRatingPromptStorage {
    
    var firstShown: Date? {
        get {
            return ratingPromptEntity()?.firstShown
        }
        set {
            ratingPromptEntity()?.firstShown = newValue
            try? context.save()
        }
    }

    var lastAccess: Date? {
        get {
            return ratingPromptEntity()?.lastAccess
        }
        
        set {
            ratingPromptEntity()?.lastAccess = newValue
            try? context.save()
        }
    }
    
    var uniqueAccessDays: Int? {
        get {
            guard let ratingPromptEntity = ratingPromptEntity() else {
                return nil
            }
            return Int(ratingPromptEntity.uniqueAccessDays)
        }
        
        set {
            guard let newValue else {
                return
            }
            ratingPromptEntity()?.uniqueAccessDays = Int64(newValue)
            try? context.save()
        }
    }
    
    var lastShown: Date? {
        get {
            return ratingPromptEntity()?.lastShown
        }
        
        set {
            ratingPromptEntity()?.lastShown = newValue
            try? context.save()
        }
    }
    
    let context: NSManagedObjectContext = Database.shared.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "AppRatingPrompt")
    
    public init() { }
    
    func ratingPromptEntity() -> AppRatingPromptEntity? {

        let fetchRequest: NSFetchRequest<AppRatingPromptEntity> = AppRatingPromptEntity.fetchRequest()

        let results: [AppRatingPromptEntity]

        do {
            results = try context.fetch(fetchRequest)
        } catch {
            Logger.general.error("Error while fetching AppRatingPromptEntity: \(error.localizedDescription, privacy: .public)")
            return nil
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

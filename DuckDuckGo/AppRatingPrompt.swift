//
//  AppRatingPrompt.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 23/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation
import Core

protocol AppRatingPromptStorage {
    
    var lastAccess: Date? { get set }
    
    var uniqueAccessDays: Int { get set }
    
}

class AppRatingPrompt {

    var storage: AppRatingPromptStorage
    
    init(storage: AppRatingPromptStorage = AppRatingPromptCoreDataStorage()) {
        self.storage = storage
    }
    
    func shouldPrompt(date: Date = Date()) -> Bool {
        
        if !sameDay(date1: storage.lastAccess, date2: date) {
            storage.uniqueAccessDays += 1
        }

        storage.lastAccess = date
        
        return [3, 5, 7].contains(storage.uniqueAccessDays)
    }
 
    private func sameDay(date1: Date?, date2: Date?) -> Bool {
        guard let date1 = date1 else { return false }
        guard let date2 = date2 else { return false }
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
}

class AppRatingPromptCoreDataStorage: AppRatingPromptStorage {
    
    var lastAccess: Date? {
        get {
            return entity().lastAccess
        }
        
        set {
            
        }
    }
    
    var uniqueAccessDays: Int {
        get {
            return Int(entity().uniqueAccessDays)
        }
        
        set {
            
        }
    }
    
    let persistence = DDGPersistenceContainer(name: "AppRatingPrompt")
    
    func entity() -> AppRatingPromptEntity {
        return AppRatingPromptEntity()
    }
    
}

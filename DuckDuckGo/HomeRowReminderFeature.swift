//
//  HomeRowReminderFeature.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 25/04/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Core

protocol HomeRowReminderFeatureStorage {
    
    var firstAccessDate: Date? { get set }
    var shown: Bool { get set }
    
}

class HomeRowReminderFeature {
    
    struct Constants {
        
        static let reminderTimeInDays = 3.0
        
    }
    
    private var featureManager: FeatureManager
    private var storage: HomeRowReminderFeatureStorage
    
    init(featureManager: FeatureManager, storage: HomeRowReminderFeatureStorage) {
        self.featureManager = featureManager
        self.storage = storage
    }
    
    func showNow() -> Bool {
        guard isEnabled() else { return false }
        guard !hasShownBefore() else { return false }
        guard hasReminderTimeElapsed() else { return false }
        return true
    }
    
    func setShown() {
        storage.shown = true
    }
    
    private func hasShownBefore() -> Bool {
        return storage.shown
    }
    
    private func isEnabled() -> Bool {
        return featureManager.feature(named: .homerow_reminder).isEnabled
    }
    
    private func hasReminderTimeElapsed() -> Bool {
        guard let date = storage.firstAccessDate else {
            storage.firstAccessDate = Date()
            return false
        }
        let days = date.timeIntervalSinceNow / 24 / 60 / 60
        return days > Constants.reminderTimeInDays
    }
    
}

public class UserDefaultsHomeRowReminderStorage: HomeRowReminderFeatureStorage {
    
    struct Keys {
        static let firstAccessDate = "com.duckduckgo.homerow.reminder.firstAccessDate"
        static let shown = "com.duckduckgo.homerow.reminder.shown"
    }
    
    var firstAccessDate: Date? {
        
        set {
            if let date = newValue {
                userDefaults.set(date.timeIntervalSince1970, forKey: Keys.firstAccessDate)
            } else {
                userDefaults.removeObject(forKey: Keys.firstAccessDate)
            }
        }
        
        get {
            if let interval = userDefaults.object(forKey: Keys.firstAccessDate) as? Double {
                return Date(timeIntervalSince1970: interval)
            }
            return nil
        }

    }
    
    var shown: Bool {
        
        set {
            userDefaults.set(newValue, forKey: Keys.shown)
        }
        
        get {
            return userDefaults.bool(forKey: Keys.shown)
        }
        
    }

    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

}

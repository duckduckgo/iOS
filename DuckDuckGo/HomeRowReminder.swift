//
//  HomeRowReminder.swift
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

import Core

protocol HomeRowReminderStorage {

    var firstAccessDate: Date? { get set }
    var shown: Bool { get set }

}

class HomeRowReminder {

    struct Constants {

        static let reminderTimeInDays = 3.0

    }

    private var storage: HomeRowReminderStorage

    init(storage: HomeRowReminderStorage = UserDefaultsHomeRowReminderStorage()) {
        self.storage = storage
    }

    func showNow() -> Bool {
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

    private func hasReminderTimeElapsed() -> Bool {
        guard let date = storage.firstAccessDate else {
            storage.firstAccessDate = Date()
            return false
        }
        let days = abs(date.timeIntervalSinceNow / 24 / 60 / 60)
        return days > Constants.reminderTimeInDays
    }

}

public class UserDefaultsHomeRowReminderStorage: HomeRowReminderStorage {

    struct Keys {
        static let firstAccessDate = "com.duckduckgo.homerow.reminder.firstAccessDate"
        static let shown = "com.duckduckgo.homerow.reminder.shown"
    }

    var firstAccessDate: Date? {

        get {
            if let interval = userDefaults.object(forKey: Keys.firstAccessDate) as? Double {
                return Date(timeIntervalSince1970: interval)
            }
            return nil
        }
        
        set {
            if let date = newValue {
                userDefaults.set(date.timeIntervalSince1970, forKey: Keys.firstAccessDate)
            } else {
                userDefaults.removeObject(forKey: Keys.firstAccessDate)
            }
        }

    }

    var shown: Bool {
        
        get {
            return userDefaults.bool(forKey: Keys.shown)
        }

        set {
            userDefaults.set(newValue, forKey: Keys.shown)
        }

    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

}

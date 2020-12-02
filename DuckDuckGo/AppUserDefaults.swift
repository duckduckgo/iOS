//
//  AppUserDefaults.swift
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

import Foundation
import Core

public class AppUserDefaults: AppSettings {
    
    public struct Notifications {
        public static let doNotSellStatusChange = Notification.Name("com.duckduckgo.app.DoNotSellStatusChange")
    }

    private let groupName: String

    private struct Keys {
        static let autocompleteKey = "com.duckduckgo.app.autocompleteDisabledKey"
        static let currentThemeNameKey = "com.duckduckgo.app.currentThemeNameKey"
        
        static let autoClearActionKey = "com.duckduckgo.app.autoClearActionKey"
        static let autoClearTimingKey = "com.duckduckgo.app.autoClearTimingKey"
        
        static let homePage = "com.duckduckgo.app.homePage"

        static let foregroundFetchStartCount = "com.duckduckgo.app.fgFetchStartCount"
        static let foregroundFetchNoDataCount = "com.duckduckgo.app.fgFetchNoDataCount"
        static let foregroundFetchNewDataCount = "com.duckduckgo.app.fgFetchNewDataCount"
        
        static let backgroundFetchStartCount = "com.duckduckgo.app.bgFetchStartCount"
        static let backgroundFetchNoDataCount = "com.duckduckgo.app.bgFetchNoDataCount"
        static let backgroundFetchNewDataCount = "com.duckduckgo.app.bgFetchNewDataCount"
        
        static let notificationsEnabled = "com.duckduckgo.app.notificationsEnabled"
        static let allowUniversalLinks = "com.duckduckgo.app.allowUniversalLinks"
        static let longPressPreviews = "com.duckduckgo.app.longPressPreviews"
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }

    init(groupName: String =  "group.com.duckduckgo.app") {
        self.groupName = groupName
    }

    var autocomplete: Bool {

        get {
            return userDefaults?.bool(forKey: Keys.autocompleteKey, defaultValue: true) ?? true
        }

        set {
            userDefaults?.setValue(newValue, forKey: Keys.autocompleteKey)
        }

    }
    
    var currentThemeName: ThemeName {
        
        get {
            var currentThemeName: ThemeName?
            if let stringName = userDefaults?.string(forKey: Keys.currentThemeNameKey) {
                currentThemeName = ThemeName(rawValue: stringName)
            }
            
            if let themeName = currentThemeName {
                return themeName
            } else if #available(iOS 13.0, *) {
                return .systemDefault
            } else {
                return .dark
            }
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.currentThemeNameKey)
        }
        
    }
    
    var autoClearAction: AutoClearSettingsModel.Action {
        
        get {
            let value = userDefaults?.integer(forKey: Keys.autoClearActionKey) ?? 0
            return AutoClearSettingsModel.Action(rawValue: value)
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.autoClearActionKey)
        }
        
    }
    
    var autoClearTiming: AutoClearSettingsModel.Timing {
        
        get {
            if let rawValue = userDefaults?.integer(forKey: Keys.autoClearTimingKey),
                let value = AutoClearSettingsModel.Timing(rawValue: rawValue) {
                return value
            }
            return .termination
        }
        
        set {
            userDefaults?.setValue(newValue.rawValue, forKey: Keys.autoClearTimingKey)
        }
        
    }
    
    var allowUniversalLinks: Bool {
        get {
            return userDefaults?.object(forKey: Keys.allowUniversalLinks) as? Bool ?? true
        }
        
        set {
            userDefaults?.set(newValue, forKey: Keys.allowUniversalLinks)
        }
    }

    var longPressPreviews: Bool {
        get {
            return userDefaults?.object(forKey: Keys.longPressPreviews) as? Bool ?? true
        }

        set {
            userDefaults?.set(newValue, forKey: Keys.longPressPreviews)
        }
    }
    
    @UserDefaultsWrapper(key: .doNotSell, defaultValue: true)
    var sendDoNotSell: Bool
    
}

extension AppUserDefaults: AppConfigurationFetchStatistics {
    
    var foregroundStartCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchStartCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchStartCount)
        }
    }
    
    var foregroundNoDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchNoDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchNoDataCount)
        }
    }
    
    var foregroundNewDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.foregroundFetchNewDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.foregroundFetchNewDataCount)
        }
    }
    
    var backgroundStartCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchStartCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchStartCount)
        }
    }
    
    var backgroundNoDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchNoDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchNoDataCount)
        }
    }
    
    var backgroundNewDataCount: Int {
        get {
            return userDefaults?.integer(forKey: Keys.backgroundFetchNewDataCount) ?? 0
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.backgroundFetchNewDataCount)
        }
    }
}

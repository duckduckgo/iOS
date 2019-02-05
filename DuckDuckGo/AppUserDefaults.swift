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

public class AppUserDefaults: AppSettings {

    private let groupName: String

    private struct Keys {
        static let autocompleteKey = "com.duckduckgo.app.autocompleteDisabledKey"
        static let currentThemeNameKey = "com.duckduckgo.app.currentThemeNameKey"
        
        static let autoClearActionKey = "com.duckduckgo.app.autoClearActionKey"
        static let autoClearTimingKey = "com.duckduckgo.app.autoClearTimingKey"
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
            var currentThemeName = ThemeName.dark
            if let stringName = userDefaults?.string(forKey: Keys.currentThemeNameKey) {
                currentThemeName = ThemeName(rawValue: stringName) ?? ThemeName.dark
            }
            return currentThemeName
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
    
    // MARK: - For experiment, remove when not needed anymore
    
    func setInitialThemeNameIfNeeded(name: ThemeName) {
        guard userDefaults?.string(forKey: Keys.currentThemeNameKey) == nil else { return }
        
        currentThemeName = name
    }
}

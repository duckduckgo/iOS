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
        static let lightThemeKey = "com.duckduckgo.app.lightThemeEnabledKey"
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
    
    var lightTheme: Bool {
        
        get {
            return userDefaults?.bool(forKey: Keys.lightThemeKey, defaultValue: false) ?? false
        }
        
        set {
            userDefaults?.setValue(newValue, forKey: Keys.lightThemeKey)
        }
        
    }
    
    //MARK: - For experiment, remove when not needed anymore
    
    func setInitialLightThemeValueIfNeeded(value: Bool) {
        guard userDefaults?.object(forKey: Keys.lightThemeKey) == nil else { return }
        
        lightTheme = value
    }
}

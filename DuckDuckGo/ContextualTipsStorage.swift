//
//  ContextualTipsStorage.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

protocol ContextualTipsStorage {
    
    var isEnabled: Bool { get set }
    var nextHomeScreenTip: Int { get set }
    var nextBrowsingTip: Int { get set }
    
}

class DefaultContextualTipsStorage: ContextualTipsStorage {
    
    struct Keys {
        static let enabled = "com.duckduckgo.contextual.tips.enabled"
        static let homeScreen = "com.duckduckgo.contextual.tips.homescreen"
        static let browsing = "com.duckduckgo.contextual.tips.browsing"
    }

    // Must be explicitly enabled to prevent existing users seeing it
    var isEnabled: Bool {
        
        set {
            userDefaults.set(newValue, forKey: Keys.enabled)
        }
        
        get {
            return userDefaults.bool(forKey: Keys.enabled, defaultValue: false)
        }
        
    }
    
    var nextHomeScreenTip: Int {
        
        set {
            userDefaults.set(newValue, forKey: Keys.homeScreen)
        }
        
        get {
            return userDefaults.integer(forKey: Keys.homeScreen)
        }
        
    }

    var nextBrowsingTip: Int {
        
        set {
            userDefaults.set(newValue, forKey: Keys.browsing)
        }
        
        get {
            return userDefaults.integer(forKey: Keys.browsing)
        }
        
    }

    private let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

}

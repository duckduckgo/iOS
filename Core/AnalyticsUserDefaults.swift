//
//  AnalyticsUserDefaults.swift
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

public class AnalyticsUserDefaults: AnalyticsStore {
    
    private let groupName: String
    
    private struct Keys {
        static let campaignVersion = "com.duckduckgo.analytics.campaignVersion.key"
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
    public init(groupName: String =  "group.com.duckduckgo.analytics") {
        self.groupName = groupName
    }
    
    public var campaignVersion: String? {
        
        get {
            return userDefaults?.string(forKey: Keys.campaignVersion)
        }
        
        set {
            userDefaults?.setValue(newValue, forKey: Keys.campaignVersion)
        }
    }
}


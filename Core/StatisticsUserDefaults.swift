//
//  StatisticsUserDefaults.swift
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

public class StatisticsUserDefaults: StatisticsStore {
    
    private let groupName: String
    
    private struct Keys {
        static let atb = "com.duckduckgo.statistics.atb.key"
        static let retentionAtb = "com.duckduckgo.statistics.retentionatb.key"
    }
    
    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }
    
    public init(groupName: String =  "group.com.duckduckgo.statistics") {
        self.groupName = groupName
    }
    
    public var hasInstallStatistics: Bool {
        return atb != nil && retentionAtb != nil
    }
    
    public var atb: String? {
        get {
            return userDefaults?.string(forKey: Keys.atb)
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.atb)
        }
    }

    public var retentionAtb: String? {
        get {
            return userDefaults?.string(forKey: Keys.retentionAtb)
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.retentionAtb)
        }
    }
}


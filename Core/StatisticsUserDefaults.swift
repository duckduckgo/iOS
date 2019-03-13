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
        static let installDate = "com.duckduckgo.statistics.installdate.key"
        static let atb = "com.duckduckgo.statistics.atb.key"
        static let searchRetentionAtb = "com.duckduckgo.statistics.retentionatb.key"
        static let appRetentionAtb = "com.duckduckgo.statistics.appretentionatb.key"
        static let variant = "com.duckduckgo.statistics.variant.key"
        static let httpsUpgradesTotal = "com.duckduckgo.statistics.httpsupgradestotal.key"
        static let httpsUpgradesFailures = "com.duckduckgo.statistics.httpsupgradesfailures.key"
    }

    private var userDefaults: UserDefaults? {
        return UserDefaults(suiteName: groupName)
    }

    public init(groupName: String = "group.com.duckduckgo.statistics") {
        self.groupName = groupName
    }

    public var hasInstallStatistics: Bool {
        return atb != nil
    }

    public var atb: String? {
        get {
            return userDefaults?.string(forKey: Keys.atb)
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.atb)
        }
    }
    
    public var installDate: Date? {
        get {
            guard let interval = userDefaults?.double(forKey: Keys.installDate), interval > 0 else {
                return nil
            }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            userDefaults?.setValue(newValue?.timeIntervalSince1970, forKey: Keys.installDate)
        }
    }

    public var searchRetentionAtb: String? {
        get {
            return userDefaults?.string(forKey: Keys.searchRetentionAtb) ?? atb
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.searchRetentionAtb)
        }
    }
    
    public var appRetentionAtb: String? {
        get {
            return userDefaults?.string(forKey: Keys.appRetentionAtb) ?? atb
        }
        set {
            userDefaults?.setValue(newValue, forKey: Keys.appRetentionAtb)
        }
    }

    public var variant: String? {
        get {
            return userDefaults?.string(forKey: Keys.variant)
        }

        set {
            userDefaults?.setValue(newValue, forKey: Keys.variant)
        }
    }

    public var atbWithVariant: String? {
        guard let atb = atb else { return nil }
        return "\(atb)\(variant ?? "")"
    }
    
    public var httpsUpgradesTotal: Int {
        get {
            return userDefaults?.integer(forKey: Keys.httpsUpgradesTotal) ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.httpsUpgradesTotal)
        }
    }
    
    public var httpsUpgradesFailures: Int {
        get {
            return userDefaults?.integer(forKey: Keys.httpsUpgradesFailures) ?? 0
        }
        set {
            userDefaults?.set(newValue, forKey: Keys.httpsUpgradesFailures)
        }
    }
}

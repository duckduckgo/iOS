//
//  HomeRowOnboarding.swift
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

protocol HomeRowCTAStorage: class {

    var dismissed: Bool { get set }

}

class HomeRowCTA {
    
    private let storage: HomeRowCTAStorage
    private let tutorialSettings: TutorialSettings
    private let statistics: StatisticsStore

    init(storage: HomeRowCTAStorage = UserDefaultsHomeRowCTAStorage(),
         tutorialSettings: TutorialSettings = DefaultTutorialSettings(),
         statistics: StatisticsStore = StatisticsUserDefaults()) {
        self.storage = storage
        self.tutorialSettings = tutorialSettings
        self.statistics = statistics
    }

    func shouldShow(currentDate: Date = Date(), variantManager: VariantManager = DefaultVariantManager()) -> Bool {
        guard !storage.dismissed, tutorialSettings.hasSeenOnboarding else {
            return false
        }
        
        guard statistics.installDate != nil else {
            // no install date, then show it as they're upgrading
            return true
        }
        return true
    }

    func dismissed() {
        storage.dismissed = true
    }

}

class UserDefaultsHomeRowCTAStorage: HomeRowCTAStorage {

    struct Keys {
        static let dismissed = "com.duckduckgo.homerow.onboarding.dismissed"
    }

    var dismissed: Bool {

        set {
            userDefaults.set(newValue, forKey: Keys.dismissed)
        }

        get {
            return userDefaults.bool(forKey: Keys.dismissed)
        }

    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

}

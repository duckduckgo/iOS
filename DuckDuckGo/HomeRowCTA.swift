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
    private let tipsStorage: ContextualTipsStorage
    private let tutorialSettings: TutorialSettings
    private let statistics: StatisticsStore

    init(storage: HomeRowCTAStorage = UserDefaultsHomeRowCTAStorage(),
         tipsStorage: ContextualTipsStorage = DefaultContextualTipsStorage(),
         tutorialSettings: TutorialSettings = DefaultTutorialSettings(),
         statistics: StatisticsStore = StatisticsUserDefaults()) {
        self.storage = storage
        self.tipsStorage = tipsStorage
        self.tutorialSettings = tutorialSettings
        self.statistics = statistics
    }

    func shouldShow(currentDate: Date = Date()) -> Bool {
        guard tutorialSettings.hasSeenOnboarding else {
            return false
        }

        if tipsStorage.isEnabled && tipsStorage.nextHomeScreenTip < HomeScreenTips.Tips.allCases.count {
            return false
        }
        
        if storage.dismissed {
            return false
        }
        
        guard let installDate = statistics.installDate else {
            // no install date, then show it as they're upgrading
            return true
        }
        
        // only show if we're on a different day
        return !Calendar.current.isDate(installDate, inSameDayAs: currentDate)
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

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

protocol HomeRowOnboardingStorage: class {
    
    var dismissed:Bool { get set }
    
}

class HomeRowOnboarding {
    
    private let storage: HomeRowOnboardingStorage
    private let featureManager: FeatureManager

    init(storage: HomeRowOnboardingStorage = UserDefaultsHomeRowOnboardingFeatureStorage(), featureManager: FeatureManager = DefaultFeatureManager()) {
        self.storage = storage
        self.featureManager = featureManager
    }
    
    func showNow() -> Bool {
        guard !storage.dismissed else { return false }
        return self.featureManager.feature(named: .homeRowOnboarding).isEnabled
    }
    
    func dismissed() {
        storage.dismissed = true
    }
    
}

class UserDefaultsHomeRowOnboardingFeatureStorage: HomeRowOnboardingStorage {
    
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

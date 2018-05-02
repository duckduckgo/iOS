//
//  HomeRowOnboardingFeature.swift
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

protocol HomeRowOnboardingFeatureStorage: class {
    
    var dismissed:Bool { get set }
    
}

class HomeRowOnboardingFeature {
    
    private let storage: HomeRowOnboardingFeatureStorage
    private let featureManager: FeatureManager

    init(storage: HomeRowOnboardingFeatureStorage = UserDefaultsHomeRowOnboardingFeatureStorage(), featureManager: FeatureManager = DefaultFeatureManager()) {
        self.storage = storage
        self.featureManager = featureManager
    }
    
    func showNow() -> Bool {
        guard !storage.dismissed else { return false }
        return self.featureManager.feature(named: .homerow_onboarding).isEnabled
    }
    
    func dismissed() {
        storage.dismissed = true
    }
    
}

class UserDefaultsHomeRowOnboardingFeatureStorage: HomeRowOnboardingFeatureStorage {
    
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

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
    
    var dismissed:Bool { get set }
    
}

class HomeRowCTA {
    
    enum CTAType: String {
        
        case experiment1, experiment2
        
    }
    
    private let storage: HomeRowCTAStorage
    private let variantManager: VariantManager

    init(storage: HomeRowCTAStorage = UserDefaultsHomeRowCTAStorage(), variantManager: VariantManager = DefaultVariantManager()) {
        self.storage = storage
        self.variantManager = variantManager
    }
    
    func ctaToShow() -> CTAType? {
//        guard !storage.dismissed else { return nil }
//        guard let variant = variantManager.currentVariant else { return .experiment1 }
//
//        if variant.features.contains(.homeRowCTADefault) {
//            return .experiment1
//        } else if variant.features.contains(.homeRowCTAAlternative1) {
//            return .experiment2
//        }
//
//        return nil
        return .experiment2
    }
    
    func dismissed() {
        storage.dismissed = true
    }
    
    func shown() {
        if ctaToShow() == .experiment1 {
            storage.dismissed = true
        }
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

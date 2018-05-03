//
//  VariantManager.swift
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

public protocol VariantRNG {
    
    func nextInt(upperBound: Int) -> Int
    
}

public protocol VariantStorage: class {
    
    var currentVariant: String? { get set }
    
}

public protocol VariantManager {
    
    var currentVariant: String? { get }
    func assignVariant()
    
}

public class DefaultVariantManager: VariantManager {
    
    public var currentVariant: String? {
        return storage.currentVariant
    }
    
    private let variants: [String]
    private let storage: VariantStorage
    private let rng: VariantRNG
    
    /**
     
     - Parameters:
        - variants: defaults to 3 possible variants "m1", "m2" or "m3" with a weighting of 50%, 25%, 25% respectively expressed as list with repeating elements to represent weighting
        - rng: defaults to arc4random_uniform based random number generation
        - storage: defaults to UserDefaults based storage of current variant

    */
    public init(variants: [String] = ["m1", "m1", "m2", "m3"], storage: VariantStorage = UserDefaultsVariantStorage(), rng: VariantRNG = Arc4RandomUniformVariantRNG()) {
        self.variants = variants
        self.storage = storage
        self.rng = rng
    }
    
    public func assignVariant() {
        let variant = selectVariant()
        storage.currentVariant = variant
    }
    
    private func selectVariant() -> String {
        return variants[rng.nextInt(upperBound: variants.count)]
    }
    
}

public class Arc4RandomUniformVariantRNG: VariantRNG {
    
    public init() { }
    
    public func nextInt(upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
    
}

public class UserDefaultsVariantStorage: VariantStorage {
    
    struct Keys {
        static let variant = "com.duckduckgo.variant"
    }
    
    public var currentVariant: String? {
        set {
            userDefaults.set(newValue, forKey: Keys.variant)
        }
        
        get {
            return userDefaults.string(forKey: Keys.variant)
        }
    }
    
    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
}

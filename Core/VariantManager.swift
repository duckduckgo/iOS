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

public enum FeatureName {
    
    case homeRowOnboarding, homeRowReminder
    
}

public struct Variant {
    
    public static let defaultVariants = [
        Variant(name: "m1", percent: 50, features: []),
        Variant(name: "m2", percent: 25, features: [.homeRowOnboarding]),
        Variant(name: "m3", percent: 25, features: [.homeRowOnboarding, .homeRowReminder]),
    ]
    
    public let name: String
    public let percent: Int
    public let features: [FeatureName]
    
}

public protocol VariantRNG {
    
    func nextInt(upperBound: Int) -> Int
    
}

public protocol VariantManager {
    
    var currentVariant: Variant? { get }
    func assignVariant()
    
}

public class DefaultVariantManager: VariantManager {
    
    public var currentVariant: Variant? {
        return variants.first(where: { $0.name == storage.variant })
    }
    
    private let variants: [Variant]
    private let storage: StatisticsStore
    private let rng: VariantRNG
    
    public init(variants: [Variant] = Variant.defaultVariants, storage: StatisticsStore = StatisticsUserDefaults(), rng: VariantRNG = Arc4RandomUniformVariantRNG()) {
        self.variants = variants
        self.storage = storage
        self.rng = rng
    }
    
    public func assignVariant() {
        let variant = selectVariant()
        storage.variant = variant?.name
    }
    
    private func selectVariant() -> Variant? {
        let randomPercent = rng.nextInt(upperBound: 100)

        var runningTotal = 0
        for variant in variants {
            runningTotal += variant.percent
            if randomPercent < runningTotal {
                return variant
            }
        }
        
        return nil
    }
    
}

public class Arc4RandomUniformVariantRNG: VariantRNG {
    
    public init() { }
    
    public func nextInt(upperBound: Int) -> Int {
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
    
}

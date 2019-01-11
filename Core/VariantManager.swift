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
    case centeredSearchHomeScreen
    case homeScreen
    case singleFavorite
    case additionalFavorites
}

public struct Variant {
    
    public static let defaultVariants: [Variant] = [
        
        // SERP variants - do not remove
        Variant(name: "sc", weight: 1, features: []),
        Variant(name: "sd", weight: 1, features: []),
        
        // Enhanced home page experiment
        Variant(name: "mk", weight: 1, features: []),
        Variant(name: "ml", weight: 0, features: [.homeScreen, .singleFavorite]),
        Variant(name: "mm", weight: 0, features: [.homeScreen, .singleFavorite, .additionalFavorites]),
        Variant(name: "mn", weight: 1, features: [.centeredSearchHomeScreen])
    ]
    
    public let name: String
    public let weight: Int
    public let features: [FeatureName]
    
}

public protocol VariantRNG {
    
    func nextInt(upperBound: Int) -> Int
    
}

public protocol VariantManager {
    
    var currentVariant: Variant? { get }
    func assignVariantIfNeeded()
    
}

public class DefaultVariantManager: VariantManager {
    
    public var currentVariant: Variant? {
        return variants.first(where: { $0.name == storage.variant })
    }
    
    private let variants: [Variant]
    private let storage: StatisticsStore
    private let rng: VariantRNG
    private let uiIdiom: UIUserInterfaceIdiom
    
    public init(variants: [Variant] = Variant.defaultVariants,
                storage: StatisticsStore = StatisticsUserDefaults(),
                rng: VariantRNG = Arc4RandomUniformVariantRNG(),
                uiIdiom: UIUserInterfaceIdiom = UI_USER_INTERFACE_IDIOM()) {
        self.variants = variants
        self.storage = storage
        self.rng = rng
        self.uiIdiom = uiIdiom
    }
    
    public func assignVariantIfNeeded() {
        guard !storage.hasInstallStatistics else {
            Logger.log(text: "no new variant needed for existing user")
            return
        }
        
        if let variant = currentVariant {
            Logger.log(text: "already assigned variant: \(variant)")
            return
        }
        
        guard let variant = selectVariant() else {
            Logger.log(text: "Failed to assign variant")
            return
        }
        
        if !isHomeScreenExperimentAndPad(variant) {
            storage.variant = variant.name
            Logger.log(text: "newly assigned variant: \(currentVariant as Any)")
        }
    }
    
    private func isHomeScreenExperimentAndPad(_ variant: Variant) -> Bool {
        return (variant.features.contains(.homeScreen) || variant.features.contains(.centeredSearchHomeScreen))
            && uiIdiom == .pad
    }
    
    private func selectVariant() -> Variant? {
        let totalWeight = variants.reduce(0, { $0 + $1.weight })
        let randomPercent = rng.nextInt(upperBound: totalWeight)
        
        var runningTotal = 0
        for variant in variants {
            runningTotal += variant.weight
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

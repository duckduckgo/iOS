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
import os.log

public enum FeatureName: String {

    // Used for unit tests
    case dummy
     
}

public struct Variant {
    
    struct When {
        static let always = { return true }
        static let padDevice = { return UIDevice.current.userInterfaceIdiom == .pad }
        static let notPadDevice = { return !Self.padDevice() }

        static let inRequiredCountry = { return ["AU", "AT", "DK", "FI", "FR", "DE", "IT", "IE", "NZ", "NO", "ES", "SE", "GB"]
                .contains(where: { Locale.current.regionCode == $0 }) }
    }
    
    static let doNotAllocate = 0
    
    // Note: Variants with `doNotAllocate` weight, should always be included so that previous installations are unaffected
    public static let defaultVariants: [Variant] = [
        
        // SERP testing
        Variant(name: "sc", weight: 1, isIncluded: When.inRequiredCountry, features: []),
        Variant(name: "sd", weight: doNotAllocate, isIncluded: When.always, features: []),
        Variant(name: "se", weight: 1, isIncluded: When.inRequiredCountry, features: [])

    ]
    
    public let name: String
    public let weight: Int
    public let isIncluded: () -> Bool
    public let features: [FeatureName]

}

public protocol VariantRNG {
    
    func nextInt(upperBound: Int) -> Int
    
}

public protocol VariantManager {
    
    var currentVariant: Variant? { get }
    func assignVariantIfNeeded(_ newInstallCompletion: (VariantManager) -> Void)
    func isSupported(feature: FeatureName) -> Bool
    
}

public class DefaultVariantManager: VariantManager {
    
    public var currentVariant: Variant? {
        let variantName = ProcessInfo.processInfo.environment["VARIANT", default: storage.variant ?? "" ]
        return variants.first(where: { $0.name == variantName })
    }
    
    private let variants: [Variant]
    private let storage: StatisticsStore
    private let rng: VariantRNG
    
    public init(variants: [Variant] = Variant.defaultVariants,
                storage: StatisticsStore = StatisticsUserDefaults(),
                rng: VariantRNG = Arc4RandomUniformVariantRNG()) {
        self.variants = variants
        self.storage = storage
        self.rng = rng
    }

    public func isSupported(feature: FeatureName) -> Bool {
        return currentVariant?.features.contains(feature) ?? false
    }
    
    public func assignVariantIfNeeded(_ newInstallCompletion: (VariantManager) -> Void) {
        guard !storage.hasInstallStatistics else {
            os_log("no new variant needed for existing user", log: generalLog, type: .debug)
            return
        }
        
        if let variant = currentVariant {
            os_log("already assigned variant: %s", log: generalLog, type: .debug, String(describing: variant))
            return
        }
        
        guard let variant = selectVariant() else {
            os_log("Failed to assign variant", log: generalLog, type: .debug)
            
            // it's possible this failed because there are none to assign, we should still let new install logic execute
            _ = newInstallCompletion(self)
            return
        }
        
        storage.variant = variant.name
        newInstallCompletion(self)
    }
    
    private func selectVariant() -> Variant? {
        let totalWeight = variants.reduce(0, { $0 + $1.weight })
        let randomPercent = rng.nextInt(upperBound: totalWeight)
        
        var runningTotal = 0
        for variant in variants {
            runningTotal += variant.weight
            if randomPercent < runningTotal {
                return variant.isIncluded() ? variant : nil
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

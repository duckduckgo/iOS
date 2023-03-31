//
//  DefaultVariantManager.swift
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
import Speech
import BrowserServicesKit

extension FeatureName {
    
    public static let fireButtonAnimation = FeatureName(rawValue: "fireButtonAnimation")
    public static let fireButtonColor = FeatureName(rawValue: "fireButtonColor")
    
}

public struct VariantIOS: Variant {
    
    struct When {
        static let always = { return true }
        static let padDevice = { return UIDevice.current.userInterfaceIdiom == .pad }
        static let notPadDevice = { return !Self.padDevice() }

        static let inRequiredCountry = { return ["AU", "AT", "DK", "FI", "FR", "DE", "IT", "IE", "NZ", "NO", "ES", "SE", "GB"]
                .contains(where: { Locale.current.regionCode == $0 }) }
        
        static let inEnglish = { return Locale.current.languageCode == "en" }

        static let iOS15 = { () -> Bool in
            if #available(iOS 15, *) {
                return true
            }
            return false
        }
    }
    
    static let doNotAllocate = 0
    
    // Note: Variants with `doNotAllocate` weight, should always be included so that previous installations are unaffected
    public static let defaultVariants: [Variant] = [
        VariantIOS(name: "mc", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "ma", weight: doNotAllocate, isIncluded: When.always, features: [.fireButtonAnimation]),
        VariantIOS(name: "mf", weight: doNotAllocate, isIncluded: When.always, features: [.fireButtonColor]),
        
        // SERP testing
        VariantIOS(name: "sc", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "sd", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "se", weight: doNotAllocate, isIncluded: When.always, features: [])
        
    ]
    
    public var name: String
    public var weight: Int
    public var isIncluded: () -> Bool
    public var features: [FeatureName]

}

public protocol VariantRNG {
    
    func nextInt(upperBound: Int) -> Int
    
}

public class DefaultVariantManager: VariantManager {
    
    public var currentVariant: Variant? {
        let variantName = ProcessInfo.processInfo.environment["VARIANT", default: storage.variant ?? "" ]
        return variants.first(where: { $0.name == variantName })
    }
    
    private let variants: [Variant]
    private let storage: StatisticsStore
    private let rng: VariantRNG
    
    public init(variants: [Variant] = VariantIOS.defaultVariants,
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
            os_log("no new variant needed for existing user", log: .generalLog, type: .debug)
            return
        }
        
        if let variant = currentVariant {
            os_log("already assigned variant: %s", log: .generalLog, type: .debug, String(describing: variant))
            return
        }
        
        guard let variant = selectVariant() else {
            os_log("Failed to assign variant", log: .generalLog, type: .debug)
            
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
        // swiftlint:disable:next legacy_random
        return Int(arc4random_uniform(UInt32(upperBound)))
    }
    
}

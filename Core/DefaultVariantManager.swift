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

import Common
import Foundation
import Speech
import BrowserServicesKit

extension FeatureName {
    // Define your feature e.g.:
    // public static let experimentalFeature = FeatureName(rawValue: "experimentalFeature")

    public static let fixedUserAgent = FeatureName(rawValue: "fixedUserAgent")
    public static let closestUserAgent = FeatureName(rawValue: "closestUserAgent")
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

    /// This variant is used for returning users to separate them from really new users.
    static let returningUser = VariantIOS(name: "ru", weight: doNotAllocate, isIncluded: When.always, features: [])

    static let doNotAllocate = 0

    /// The list of cohorts in active ATB experiments.
    ///
    /// Variants set to `doNotAllocate` are active, but not adding users to a new cohort, do not change them unless you're sure the experiment is finished.
    public static let defaultVariants: [Variant] = [
        VariantIOS(name: "sc", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "sd", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "se", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "me", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "mf", weight: doNotAllocate, isIncluded: When.always, features: []),
        VariantIOS(name: "mg", weight: 1, isIncluded: When.always, features: [.fixedUserAgent]),
        VariantIOS(name: "mh", weight: 1, isIncluded: When.always, features: [.closestUserAgent]),
        returningUser
    ]

    /// The name of the variant.  Shuld be a two character string like `ma` or `mb`
    public var name: String

    /// The relative weight of this variant, e.g. if two variants have the same weight they will get 50% of the cohorts each.
    public var weight: Int

    /// Function to determine inclusion, e.g. if you want to only run an experiment on English users use `When.inEnglish`
    public var isIncluded: () -> Bool

    /// The experimental feature(s) being tested.
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
    private let returningUserMeasurement: ReturnUserMeasurement
    
    init(variants: [Variant],
         storage: StatisticsStore,
         rng: VariantRNG,
         returningUserMeasurement: ReturnUserMeasurement) {

        self.variants = variants
        self.storage = storage
        self.rng = rng
        self.returningUserMeasurement = returningUserMeasurement
    }

    public convenience init() {
        self.init(
            variants: VariantIOS.defaultVariants,
            storage: StatisticsUserDefaults(),
            rng: Arc4RandomUniformVariantRNG(),
            returningUserMeasurement: KeychainReturnUserMeasurement()
        )
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
        if returningUserMeasurement.isReturningUser {
            return VariantIOS.returningUser
        }

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

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
    
    case iPadImprovements
    case tabSwitcherListLayout
    
}

public enum VariantInclusion {
    
    case always
    case when(_ filter: () -> Bool)
    
}

public struct Variant {
    
    struct Is {
        static let padDevice = { return UIDevice.current.userInterfaceIdiom == .pad }
        static let notPadDevice = { return !Is.padDevice() }
    }
    
    static let doNotAllocate = 0
    
    // Note: Variants with `doNotAllocate` weight, should always be included so that previous installations are unaffected
    public static let defaultVariants: [Variant] = [
        
        // SERP testing
        Variant(name: "sc", weight: 1, features: [], isIncluded: .when(Is.notPadDevice)),
        Variant(name: "sd", weight: doNotAllocate, features: [], isIncluded: .always),
        Variant(name: "se", weight: 1, features: [], isIncluded: .when(Is.notPadDevice)),

        // Tab switcher list experiment
        Variant(name: "me", weight: doNotAllocate, features: [], isIncluded: .always),
        Variant(name: "mf", weight: doNotAllocate, features: [.tabSwitcherListLayout], isIncluded: .always),
        
        // iPad improvement experiment
        Variant(name: "mc", weight: 1, features: [], isIncluded: .when(Is.padDevice)),
        Variant(name: "md", weight: 1, features: [.iPadImprovements], isIncluded: .when(Is.padDevice))

    ]
    
    public let name: String
    public let weight: Int
    public let features: [FeatureName]
    public let isIncluded: VariantInclusion

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
        
        self.variants = variants.filter {            
            switch $0.isIncluded {
            case .always:
                return true
                
            case .when(let filter):
                return filter()
            }
        }
        
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

//
//  FeatureManager.swift
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

public enum FeatureName: String {
    case homerow_onboarding, homerow_reminder
}

public struct Feature {
    public let name: String
    public let isEnabled: Bool
}

public protocol FeatureManager {
    
    func feature(named: FeatureName) -> Feature
    
}

public class DefaultFeatureManager: FeatureManager {
    
    // in future this may be downloaded as json from the server
    let featuresEnabledForVariants: [FeatureName: [String]] = [
        FeatureName.homerow_onboarding: ["m2", "m3"],
        FeatureName.homerow_reminder: ["m3"]
    ]
    
    private let variantManager: VariantManager
    private let statistics: StatisticsStore
    
    public init(variantManager: VariantManager = DefaultVariantManager(), statistics: StatisticsStore = StatisticsUserDefaults()) {
        self.variantManager = variantManager
        self.statistics = statistics
    }
    
    public func feature(named: FeatureName) -> Feature {
        let variants = featuresEnabledForVariants[named, default: []]
        let enabled = variants.contains(variantManager.currentVariant ?? "")
        return Feature(name: named.rawValue, isEnabled: enabled)
    }
    
}

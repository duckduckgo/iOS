//
//  MarketplaceAdPostback.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import StoreKit
import AdAttributionKit

enum MarketplaceAdPostback {
    case installNewUser
    case installReturningUser

    /// An enumeration representing coarse conversion values for both SKAdNetwork and AdAttributionKit.
    ///
    /// This enum provides a unified interface to handle coarse conversion values, which are used in both SKAdNetwork and AdAttributionKit.
    /// Despite having the same value names (`low`, `medium`, `high`), the types for these values differ between the two frameworks.
    /// This wrapper simplifies the usage by providing a common interface.
    ///
    /// - Cases:
    ///    - `low`: Represents a low conversion value.
    ///    - `medium`: Represents a medium conversion value.
    ///    - `high`: Represents a high conversion value.
    ///
    /// - Properties:
    ///    - `coarseConversionValue`: Available on iOS 17.4 and later, this property returns the corresponding `CoarseConversionValue` from AdAttributionKit.
    ///    - `skAdCoarseConversionValue`: Available on iOS 16.1 and later, this property returns the corresponding `SKAdNetwork.CoarseConversionValue`.
    ///
    enum CoarseConversion {
        case low
        case medium
        case high

        /// Returns the corresponding `CoarseConversionValue` from AdAttributionKit.
        @available(iOS 17.4, *)
        var coarseConversionValue: CoarseConversionValue {
            switch self {
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }

        /// Returns the corresponding `SKAdNetwork.CoarseConversionValue`.
        @available(iOS 16.1, *)
        var skAdCoarseConversionValue: SKAdNetwork.CoarseConversionValue {
            switch self {
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }
    }

    // https://app.asana.com/0/0/1208126219488943/f
    var fineValue: Int {
        switch self {
        case .installNewUser: return 0
        case .installReturningUser: return 1
        }
    }

    var coarseValue: CoarseConversion {
        switch self {
        case .installNewUser: return .high
        case .installReturningUser: return .low
        }
    }

    @available(iOS 17.4, *)
    var adAttributionKitCoarseValue: CoarseConversionValue {
        return coarseValue.coarseConversionValue
    }

    @available(iOS 16.1, *)
    var SKAdCoarseValue: SKAdNetwork.CoarseConversionValue {
        return coarseValue.skAdCoarseConversionValue
    }
}

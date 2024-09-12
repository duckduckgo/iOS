//
//  MarketplaceAdAttributionPostback.swift
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
    case appLaunchNewUser
    case appLaunchReturningUser

    enum CoarseConversion {
        case low
        case medium
        case high

        @available(iOS 17.4, *)
        var coarseConversionValue: CoarseConversionValue {
            switch self {
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }

        @available(iOS 16.1, *)
        var skAdCoarseConversionValue: SKAdNetwork.CoarseConversionValue {
            switch self {
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }
    }

    var fineValue: Int {
        switch self {
        case .appLaunchNewUser: return 0
        case .appLaunchReturningUser: return 1

        }
    }

    var coarseValue: CoarseConversion {
        switch self {
        case .appLaunchNewUser: return .high
        case .appLaunchReturningUser: return .low
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

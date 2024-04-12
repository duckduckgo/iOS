//
//  Subscription.swift
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
import Subscription

public extension AccountManager {
    convenience init() {
        self.init(subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs))
    }
}

enum SubscriptionPurchaseError: Error {
    case purchaseFailed,
         missingEntitlements,
         failedToGetSubscriptionOptions,
         failedToSetSubscription,
         failedToRestorePastPurchase,
         subscriptionExpired,
         hasActiveSubscription,
         cancelledByUser,
         generalError
}

enum SubscriptionFeatureName {
      static let netP = "vpn"
      static let itr = "identity-theft-restoration"
      static let dbp = "personal-information-removal"
  }

enum SubscriptionFeatureSelection: Codable {
    case netP
    case itr
    case dbp

    init?(featureName: String) {
        switch featureName {
        case SubscriptionFeatureName.netP:
            self = .netP
        case SubscriptionFeatureName.itr:
            self = .itr
        case SubscriptionFeatureName.dbp:
            self = .dbp
        default:
            return nil
        }
    }
}

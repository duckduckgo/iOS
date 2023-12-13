//
//  AppStorePurchaseFlow.swift
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

protocol PurchaseFlow {

}

public struct SubscriptionOptions: Encodable {
    let platform: String
    let options: [SubscriptionOption]
    let features: [SubscriptionFeature]
}

public struct SubscriptionOption: Encodable {
    let id: String
    let cost: SubscriptionOptionCost
}

struct SubscriptionOptionCost: Encodable {
    let displayPrice: String
    let recurrence: String
}

public struct SubscriptionFeature: Encodable {
    let name: String
}

// MARK: -

public enum SubscriptionFeatureName: String, CaseIterable {
    case privateBrowsing = "private-browsing"
    case privateSearch = "private-search"
    case emailProtection = "email-protection"
    case appTrackingProtection = "app-tracking-protection"
    case vpn = "vpn"
    case personalInformationRemoval = "personal-information-removal"
    case identityTheftRestoration = "identity-theft-restoration"
}

public enum SubscriptionPlatformName: String {
    case macos
    case stripe
}

// MARK: -

public struct PurchaseUpdate: Codable {
    let type: String
    let token: String?

    public init(type: String, token: String? = nil) {
        self.type = type
        self.token = token
    }
}

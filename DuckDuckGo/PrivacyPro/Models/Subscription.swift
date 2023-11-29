//
//  Subscription.swift
//  DuckDuckGo
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

struct Subscription: Encodable {
    let token: String
}

/// Values that the Frontend can use to determine the current state.
struct SubscriptionValues: Codable {
    enum CodingKeys: String, CodingKey {
        case token
    }
    let token: String
}

struct SubscriptionOptions: Encodable {
    let platform: String
    let options: [SubscriptionOption]
    let features: [SubscriptionFeature]
}

struct SubscriptionOption: Encodable {
    let id: String
    let cost: SubscriptionCost

    struct SubscriptionCost: Encodable {
        let displayPrice: String
        let recurrence: String
    }
}

enum SubscriptionFeatureName: String, CaseIterable {
    case privateBrowsing = "private-browsing"
    case privateSearch = "private-search"
    case emailProtection = "email-protection"
    case appTrackingProtection = "app-tracking-protection"
    case vpn = "vpn"
    case personalInformationRemoval = "personal-information-removal"
    case identityTheftRestoration = "identity-theft-restoration"
}

struct SubscriptionFeature: Encodable {
    let name: String
}

struct SubscriptionSelection: Decodable {
    let id: String
}

//
//  SubscriptionManageriOS14.swift
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

class SubscriptionManageriOS14: SubscriptionManaging {
    var accountManager: AccountManaging
    var subscriptionAPIService: SubscriptionAPIServicing = SubscriptionAPIService(currentServiceEnvironment: .production)
    var authAPIService: AuthAPIServicing = AuthAPIService(currentServiceEnvironment: .production)

    @available(iOS 15, *)
    func storePurchaseManager() -> StorePurchaseManaging {
        StorePurchaseManager()
    }
    var currentEnvironment: SubscriptionEnvironment = SubscriptionEnvironment.default
    var canPurchase: Bool = false
    func loadInitialData() {}
    func updateSubscriptionStatus(completion: @escaping (Bool) -> Void) {}

    func url(for type: SubscriptionURL) -> URL {
        URL(string: "https://duckduckgo.com")!
    }

    init(accountManager: AccountManaging) {
        self.accountManager = accountManager
    }
}

//
//  URL+Subscription.swift
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

public extension URL {

    static var purchaseSubscription: URL {
        URL(string: "https://abrown.duckduckgo.com/subscriptions/welcome")!
    }

    static var subscriptionFAQ: URL {
        URL(string: "https://duckduckgo.com/about")!
    }

    // MARK: - Subscription Email
    static var activateSubscriptionViaEmail: URL {
        URL(string: "https://abrown.duckduckgo.com/subscriptions/activate")!
    }

    static var addEmailToSubscription: URL {
        URL(string: "https://abrown.duckduckgo.com/subscriptions/add-email")!
    }

    static var manageSubscriptionEmail: URL {
        URL(string: "https://abrown.duckduckgo.com/subscriptions/manage")!
    }

    // MARK: - App Store app manage subscription URL

    static var manageSubscriptionsInAppStoreAppURL: URL {
        URL(string: "macappstores://apps.apple.com/account/subscriptions")!
    }
}

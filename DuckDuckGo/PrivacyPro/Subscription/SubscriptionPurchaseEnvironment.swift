//
//  SubscriptionPurchaseEnvironment.swift
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

public final class SubscriptionPurchaseEnvironment {

    public enum Environment {
        case appStore, stripe
    }

    public static var current: Environment = .appStore {
        didSet {
            canPurchase = false

            switch current {
            case .appStore:
                setupForAppStore()
            case .stripe:
                setupForStripe()
            }
        }
    }

    public static var canPurchase: Bool = false

    private static func setupForAppStore() {
        if #available(macOS 12.0, iOS 15.0, *) {
            Task {
                await PurchaseManager.shared.updateAvailableProducts()
                canPurchase = !PurchaseManager.shared.availableProducts.isEmpty
            }
        }
    }

    private static func setupForStripe() {
        Task {
            if case let .success(products) = await SubscriptionService.getProducts() {
                canPurchase = !products.isEmpty
            }
        }
    }
}

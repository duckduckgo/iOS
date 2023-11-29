//
//  SubscriptionPagesUseSubscriptionFeature.swift
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

#if SUBSCRIPTION

import BrowserServicesKit
import Common
import Foundation
import WebKit
import UserScript

final class SubscriptionPagesUseSubscriptionFeature: Subfeature {
    var broker: UserScriptMessageBroker?

    var featureName = "useSubscription"

    var messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: "duckduckgo.com"),
        .exact(hostname: "abrown.duckduckgo.com")
    ])

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case "getSubscription": return getSubscription
        case "setSubscription": return setSubscription
        case "backToSettings": return backToSettings
        case "getSubscriptionOptions": return getSubscriptionOptions
        case "subscriptionSelected": return subscriptionSelected
        case "activateSubscription": return activateSubscription
        case "featureSelected": return featureSelected
        default:
            return nil
        }
    }

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

    func getSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        var authToken = AccountManager().authToken ?? ""
        return Subscription(token: authToken)
    }

    func setSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        guard let subscriptionValues: SubscriptionValues = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            return nil
        }

        await AccountManager().exchangeAndStoreTokens(with: subscriptionValues.token)
        return nil
    }

    func backToSettings(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        await AccountManager().refreshAccountData()
        return nil
    }

    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async throws -> Encodable? {
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

        let subscriptionOptions: [SubscriptionOption]

        if #available(macOS 12.0, iOS 15, *) {
            let monthly = PurchaseManager.shared.availableProducts.first(where: { $0.id.contains("1month") })
            let yearly = PurchaseManager.shared.availableProducts.first(where: { $0.id.contains("1year") })

            guard let monthly, let yearly else { return nil }

            subscriptionOptions = [SubscriptionOption(id: monthly.id, cost: .init(displayPrice: monthly.displayPrice, recurrence: "monthly")),
                                   SubscriptionOption(id: yearly.id, cost: .init(displayPrice: yearly.displayPrice, recurrence: "yearly"))]
        } else {
            return nil
        }

        let message = SubscriptionOptions(platform: "macos",
                                          options: subscriptionOptions,
                                          features: SubscriptionFeatureName.allCases.map { SubscriptionFeature(name: $0.rawValue) })

        return message
    }

    func subscriptionSelected(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        struct SubscriptionSelection: Decodable {
            let id: String
        }

        let message = original

        if #available(macOS 12.0, iOS 15, *) {
            guard let subscriptionSelection: SubscriptionSelection = DecodableHelper.decode(from: params) else {
                assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionSelection")
                return nil
            }

            print("Selected: \(subscriptionSelection.id)")

            let emailAccessToken = try? EmailManager().getToken()

            switch await AppStorePurchaseFlow.purchaseSubscription(with: subscriptionSelection.id, emailAccessToken: emailAccessToken) {
            case .success:
                break
            case .failure(let error):
                print("Purchase failed: \(error)")
                return nil
            }

            await AppStorePurchaseFlow.checkForEntitlements(wait: 2.0, retry: 15)

            DispatchQueue.main.async {
                self.pushAction(method: .onPurchaseUpdate, webView: message.webView!, params: PurchaseUpdate(type: "completed"))
            }
        }

        return nil
    }

    func activateSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        print(">>> Selected to activate a subscription -- show the activation settings screen")
        return nil
    }

    func featureSelected(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        struct FeatureSelection: Codable {
            let feature: String
        }

        guard let featureSelection: FeatureSelection = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of FeatureSelection")
            return nil
        }

        print(">>> Selected a feature -- show the corresponding UI", featureSelection)
        return nil
    }

    enum SubscribeActionName: String {
        case onPurchaseUpdate
    }

    struct PurchaseUpdate: Codable {
        let type: String
    }

    func pushAction(method: SubscribeActionName, webView: WKWebView, params: Encodable) {
        let broker = UserScriptMessageBroker(context: SubscriptionPagesUserScript.context, requiresRunInPageContentWorld: true )

        print(">>> Pushing into WebView:", method.rawValue, String(describing: params))
        broker.push(method: method.rawValue, params: params, for: self, into: webView)
    }
}

#endif

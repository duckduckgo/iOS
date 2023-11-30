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
    
    struct Constants {
        static let featureName = "useSubscription"
        static let os = "ios"
        static let empty = ""
    }
    
    struct OriginDomains {
        static let duckduckgo = "duckduckgo.com"
        static let abrown = "abrown.duckduckgo.com"
    }
    
    struct Handlers {
        static let getSubscription = "getSubscription"
        static let setSubscription = "setSubscription"
        static let backToSettings = "backToSettings"
        static let getSubscriptionOptions = "getSubscriptionOptions"
        static let subscriptionSelected = "subscriptionSelected"
        static let activateSubscription = "activateSubscription"
        static let featureSelected = "featureSelected"
    }
    
    struct ProductIDs {
        static let monthly = "1month"
        static let yearly = "1year"
    }
    
    struct RecurrenceOptions {
        static let month = "monthly"
        static let year = "yearly"
    }
    
    var broker: UserScriptMessageBroker?

    var featureName = Constants.featureName

    var messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: OriginDomains.duckduckgo),
        .exact(hostname: OriginDomains.abrown)
    ])

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {
        switch methodName {
        case Handlers.getSubscription: return getSubscription
        case Handlers.setSubscription: return setSubscription
        case Handlers.backToSettings: return backToSettings
        case Handlers.getSubscriptionOptions: return getSubscriptionOptions
        case Handlers.subscriptionSelected: return subscriptionSelected
        case Handlers.activateSubscription: return activateSubscription
        case Handlers.featureSelected: return featureSelected
        default:
            return nil
        }
    }

    func getSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        var authToken = AccountManager().authToken ?? Constants.empty
        return Subscription(token: authToken)
    }
    
    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async throws -> Encodable? {

        let subscriptionOptions: [SubscriptionOption]

        if #available(iOS 15, *) {
            let monthly = PurchaseManager.shared.availableProducts.first(where: { $0.id.contains(ProductIDs.monthly) })
            let yearly = PurchaseManager.shared.availableProducts.first(where: { $0.id.contains(ProductIDs.yearly) })

            guard let monthly, let yearly else { return nil }

            subscriptionOptions = [SubscriptionOption(id: monthly.id, cost: .init(displayPrice: monthly.displayPrice, recurrence: RecurrenceOptions.month)),
                                   SubscriptionOption(id: yearly.id, cost: .init(displayPrice: yearly.displayPrice, recurrence: RecurrenceOptions.year))]
        } else {
            return nil
        }

        let message = SubscriptionOptions(platform: Constants.os,
                                          options: subscriptionOptions,
                                          features: SubscriptionFeatureName.allCases.map { SubscriptionFeature(name: $0.rawValue) })

        return message
    }
    
    func subscriptionSelected(params: Any, original: WKScriptMessage) async throws -> Encodable? {

        let message = original

        if #available(iOS 15, *) {
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

    func setSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        // WIP
        return nil
    }

    func backToSettings(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        // WIP
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

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

final class SubscriptionPagesUseSubscriptionFeature: Subfeature, ObservableObject {
    
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
    
    @Published var transactionInProgress = false
    
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
    
    struct Subscription: Encodable {
        let token: String
    }
    
    /// Values that the Frontend can use to determine the current state.
    // swiftlint:disable nesting
    struct SubscriptionValues: Codable {
        enum CodingKeys: String, CodingKey {
            case token
        }
        let token: String
    }
    // swiftlint:enable nesting
    
    // Manage transation in progress flag
    private func withTransactionInProgress<T>(_ work: () async throws -> T) async rethrows -> T {
        transactionInProgress = true
        defer {
            transactionInProgress = false
        }
        return try await work()
    }

    func getSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        let authToken = AccountManager().authToken ?? Constants.empty
        return Subscription(token: authToken)
    }
    
    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        
        await withTransactionInProgress {
            if #available(iOS 15.0, *) {
                switch await AppStorePurchaseFlow.subscriptionOptions() {
                case .success(let subscriptionOptions):
                    return subscriptionOptions
                case .failure:
                    // TODO: handle errors - no products found
                    return nil
                }
            }
            return nil
        }
    }
    
    func subscriptionSelected(params: Any, original: WKScriptMessage) async throws -> Encodable? {

        await withTransactionInProgress {
            struct SubscriptionSelection: Decodable {
                let id: String
            }
            
            let message = original
            
            if #available(iOS 15, *) {
                guard let subscriptionSelection: SubscriptionSelection = DecodableHelper.decode(from: params) else {
                    assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionSelection")
                    return nil
                }
                
                print("Selected: \(subscriptionSelection.id)")
                
                // Trigger sign in pop-up
                switch await PurchaseManager.shared.syncAppleIDAccount() {
                case .success:
                    break
                case .failure:
                    return nil
                }
                
                // Check for active subscriptions
                if await PurchaseManager.hasActiveSubscription() {
                    print("hasActiveSubscription: TRUE")
                    // TODO: Present something here
                    // await WindowControllersManager.shared.lastKeyMainWindowController?.showSubscriptionFoundAlert(originalMessage: message)
                    return nil
                }
                
                let emailAccessToken = try? EmailManager().getToken()

                switch await AppStorePurchaseFlow.purchaseSubscription(with: subscriptionSelection.id, emailAccessToken: emailAccessToken) {
                case .success:
                    break
                case .failure:
                    return nil
                }
                
                switch await AppStorePurchaseFlow.completeSubscriptionPurchase() {
                case .success(let purchaseUpdate):
                    await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: purchaseUpdate)
                case .failure:
                    // TODO: handle errors - missing entitlements on post purchase check
                    await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate(type: "completed"))
                }
            }
            
            return nil
        }
    }

    func setSubscription(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        guard let subscriptionValues: SubscriptionValues = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            return nil
        }

        let authToken = subscriptionValues.token
        let accountManager = AccountManager()
        if case let .success(accessToken) = await accountManager.exchangeAuthTokenToAccessToken(authToken),
           case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
            accountManager.storeAuthToken(token: authToken)
            accountManager.storeAccount(token: accessToken, email: accountDetails.email, externalID: accountDetails.externalID)
        }

        return nil
    }

    func backToSettings(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        let accountManager = AccountManager()
        if let accessToken = accountManager.accessToken,
           case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
            accountManager.storeAccount(token: accessToken, email: accountDetails.email, externalID: accountDetails.externalID)
        }

        // TODO: Navigate back to settings

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

    // MARK: Push actions

    enum SubscribeActionName: String {
        case onPurchaseUpdate
    }

    @MainActor
    func pushPurchaseUpdate(originalMessage: WKScriptMessage, purchaseUpdate: PurchaseUpdate) async {
        pushAction(method: .onPurchaseUpdate, webView: originalMessage.webView!, params: purchaseUpdate)
    }

    func pushAction(method: SubscribeActionName, webView: WKWebView, params: Encodable) {
        let broker = UserScriptMessageBroker(context: SubscriptionPagesUserScript.context, requiresRunInPageContentWorld: true )

        print(">>> Pushing into WebView:", method.rawValue, String(describing: params))
        broker.push(method: method.rawValue, params: params, for: self, into: webView)
    }
}
#endif

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
import Combine
import Subscription
import Core

enum SubscriptionTransactionStatus {
    case idle, purchasing, restoring, polling
}

@available(iOS 15.0, *)
// swiftlint:disable:next type_body_length
final class SubscriptionPagesUseSubscriptionFeature: Subfeature, ObservableObject {
    
    struct Constants {
        static let featureName = "useSubscription"
        static let os = "ios"
        static let empty = ""
        static let token = "token"
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
    
    enum UseSubscriptionError: Error {
        case purchaseFailed,
             missingEntitlements,
             failedToGetSubscriptionOptions,
             failedToSetSubscription,
             failedToRestoreFromEmail,
             failedToRestoreFromEmailSubscriptionInactive,
             failedToRestorePastPurchase,
             subscriptionNotFound,
             subscriptionExpired,
             hasActiveSubscription,
             cancelledByUser,
             accountCreationFailed,
             generalError
    }
        
    // Transaction Status and errors are observed from ViewModels to handle errors in the UI
    @Published private(set) var transactionStatus: SubscriptionTransactionStatus = .idle
    @Published private(set) var transactionError: UseSubscriptionError?
    
    // Subscription Activation Actions
    var onSetSubscription: (() -> Void)?
    var onBackToSettings: (() -> Void)?
    var onFeatureSelected: ((SubscriptionFeatureSelection) -> Void)?
    var onActivateSubscription: (() -> Void)?
    
    struct FeatureSelection: Codable {
        let feature: String
    }
    
    weak var broker: UserScriptMessageBroker?

    var featureName = Constants.featureName

    var messageOriginPolicy: MessageOriginPolicy = .only(rules: [
        .exact(hostname: OriginDomains.duckduckgo),
        .exact(hostname: OriginDomains.abrown)
    ])
    
    var originalMessage: WKScriptMessage?

    func with(broker: UserScriptMessageBroker) {
        self.broker = broker
    }

    func handler(forMethodNamed methodName: String) -> Subfeature.Handler? {

        os_log("WebView handler: %s", log: .subscription, type: .debug, methodName)
        switch methodName {
        case Handlers.getSubscription: return getSubscription
        case Handlers.setSubscription: return setSubscription
        case Handlers.getSubscriptionOptions: return getSubscriptionOptions
        case Handlers.subscriptionSelected: return subscriptionSelected
        case Handlers.activateSubscription: return activateSubscription
        case Handlers.featureSelected: return featureSelected
        case Handlers.backToSettings: return backToSettings
        default:
            return nil
        }
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
    
    // Manage transaction in progress flag
    private func withTransactionInProgress<T>(_ work: () async -> T) async -> T {
        setTransactionStatus(transactionStatus)
        defer {
            setTransactionStatus(.idle)
        }
        return await work()
    }
    
    private func resetSubscriptionFlow() {
        setTransactionError(nil)
    }
        
    private func setTransactionError(_ error: UseSubscriptionError?) {
        transactionError = error
    }
    
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        transactionStatus = status
    }

    
    // MARK: Broker Methods (Called from WebView via UserScripts)
    func getSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        let authToken = AccountManager().authToken ?? Constants.empty
        return [Constants.token: authToken]
    }
    
    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async -> Encodable? {
        
        await withTransactionInProgress {
            
            setTransactionStatus(.purchasing)
            resetSubscriptionFlow()
                        
            switch await AppStorePurchaseFlow.subscriptionOptions() {
            case .success(let subscriptionOptions):
                return subscriptionOptions
            case .failure:
                os_log("Failed to obtain subscription options", log: .subscription, type: .error)
                setTransactionError(.failedToGetSubscriptionOptions)
                return nil
            }
                        
        }
    }
    
    // swiftlint:disable:next function_body_length
    func subscriptionSelected(params: Any, original: WKScriptMessage) async -> Encodable? {
        
        await withTransactionInProgress {
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseAttempt)
            setTransactionError(nil)
            setTransactionStatus(.purchasing)
            resetSubscriptionFlow()
            
            struct SubscriptionSelection: Decodable {
                let id: String
            }
            
            let message = original
            guard let subscriptionSelection: SubscriptionSelection = DecodableHelper.decode(from: params) else {
                assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionSelection")
                return nil
            }
            
            // Check for active subscriptions
            if await PurchaseManager.hasActiveSubscription() {
                setTransactionError(.hasActiveSubscription)
                return nil
            }
            
            let emailAccessToken = try? EmailManager().getToken()
            let purchaseTransactionJWS: String

            switch await AppStorePurchaseFlow.purchaseSubscription(with: subscriptionSelection.id,
                                                                   emailAccessToken: emailAccessToken,
                                                                   subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs)) {
            case .success(let transactionJWS):
                purchaseTransactionJWS = transactionJWS

            case .failure(let error):
                
                switch error {
                case .cancelledByUser:
                    setTransactionError(.cancelledByUser)
                    await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate(type: "canceled"))
                    return nil
                case .accountCreationFailed:
                    setTransactionError(.accountCreationFailed)
                case .activeSubscriptionAlreadyPresent:
                    setTransactionError(.hasActiveSubscription)
                    Pixel.fire(pixel: .privacyProRestoreAfterPurchaseAttempt)
                default:
                    setTransactionError(.purchaseFailed)
                }
                originalMessage = original
                setTransactionStatus(.idle)
                return nil
            }
            
            setTransactionStatus(.polling)
            switch await AppStorePurchaseFlow.completeSubscriptionPurchase(with: purchaseTransactionJWS,
                                                                           subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs)) {
            case .success(let purchaseUpdate):
                DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseSuccess)
                UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
                await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: purchaseUpdate)
            case .failure:
                setTransactionError(.missingEntitlements)
                await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate(type: "completed"))
            }
            return nil
        }
    }

    func setSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        guard let subscriptionValues: SubscriptionValues = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            setTransactionError(.generalError)
            return nil
        }

        let authToken = subscriptionValues.token
        let accountManager = AccountManager()
        if case let .success(accessToken) = await accountManager.exchangeAuthTokenToAccessToken(authToken),
           case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
            accountManager.storeAuthToken(token: authToken)
            accountManager.storeAccount(token: accessToken, email: accountDetails.email, externalID: accountDetails.externalID)
            onSetSubscription?()
        } else {
            os_log("Failed to obtain subscription options", log: .subscription, type: .error)
            setTransactionError(.failedToSetSubscription)
        }

        return nil
    }

    func activateSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        Pixel.fire(pixel: .privacyProRestorePurchaseOfferPageEntry, debounce: 2)
        onActivateSubscription?()
        return nil
    }

    func featureSelected(params: Any, original: WKScriptMessage) async -> Encodable? {
        guard let featureSelection: FeatureSelection = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of FeatureSelection")
            return nil
        }

        guard let featureSelection = SubscriptionFeatureSelection(featureName: featureSelection.feature) else {
            assertionFailure("SubscriptionPagesUserScript: unexpected feature name value")
            setTransactionError(.generalError)
            return nil
        }

        onFeatureSelected?(featureSelection)
        
        return nil
    }
    
    func backToSettings(params: Any, original: WKScriptMessage) async -> Encodable? {
           let accountManager = AccountManager()
           if let accessToken = accountManager.accessToken,
              case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
               switch await SubscriptionService.getSubscription(accessToken: accessToken) {
                   
               case .success:
                   accountManager.storeAccount(token: accessToken,
                                               email: accountDetails.email,
                                               externalID: accountDetails.externalID)
                   onBackToSettings?()
               default:
                   break
               }
                                  
           } else {
               os_log("General error. Could not get account Details", log: .subscription, type: .error)
               setTransactionError(.generalError)
           }
           return nil
       }

    // MARK: Push actions (Push Data back to WebViews)
    enum SubscribeActionName: String {
        case onPurchaseUpdate
    }

    @MainActor
    func pushPurchaseUpdate(originalMessage: WKScriptMessage, purchaseUpdate: PurchaseUpdate) async {
        pushAction(method: .onPurchaseUpdate, webView: originalMessage.webView!, params: purchaseUpdate)
    }

    func pushAction(method: SubscribeActionName, webView: WKWebView, params: Encodable) {
        let broker = UserScriptMessageBroker(context: SubscriptionPagesUserScript.context, requiresRunInPageContentWorld: true )
        broker.push(method: method.rawValue, params: params, for: self, into: webView)
    }
    
    
    // MARK: Native methods - Called from ViewModels
    func restoreAccountFromAppStorePurchase() async throws {
        setTransactionStatus(.restoring)
        
        let result = await AppStoreRestoreFlow.restoreAccountFromPastPurchase(subscriptionAppGroup: Bundle.main.appGroup(bundle: .subs))
        switch result {
        case .success:
            setTransactionStatus(.idle)
        case .failure(let error):
            let mappedError = mapAppStoreRestoreErrorToTransactionError(error)
            setTransactionStatus(.idle)
            throw mappedError
        }
    }
    
    // MARK: Utility Methods
    func mapAppStoreRestoreErrorToTransactionError(_ error: AppStoreRestoreFlow.Error) -> UseSubscriptionError {
        switch error {
        case .subscriptionExpired:
            return .subscriptionExpired
        case .missingAccountOrTransactions:
            return .subscriptionNotFound
        default:
            return .failedToRestorePastPurchase
        }
    }
    
    func cleanup() {
        setTransactionStatus(.idle)
        setTransactionError(nil)
        broker = nil
    }
    
}

#endif

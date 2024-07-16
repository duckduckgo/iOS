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
        // Pixels related events
        static let subscriptionsMonthlyPriceClicked = "subscriptionsMonthlyPriceClicked"
        static let subscriptionsYearlyPriceClicked = "subscriptionsYearlyPriceClicked"
        static let subscriptionsUnknownPriceClicked = "subscriptionsUnknownPriceClicked"
        static let subscriptionsAddEmailSuccess = "subscriptionsAddEmailSuccess"
        static let subscriptionsWelcomeFaqClicked = "subscriptionsWelcomeFaqClicked"
        static let getAccessToken = "getAccessToken"
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
    
    private let subscriptionAttributionOrigin: String?
    private let subscriptionManager: SubscriptionManager
    private var accountManager: AccountManager { subscriptionManager.accountManager }
    private let appStorePurchaseFlow: AppStorePurchaseFlow
    private let appStoreRestoreFlow: AppStoreRestoreFlow
    private let appStoreAccountManagementFlow: AppStoreAccountManagementFlow

    init(subscriptionManager: SubscriptionManager,
         subscriptionAttributionOrigin: String?,
         appStorePurchaseFlow: AppStorePurchaseFlow,
         appStoreRestoreFlow: AppStoreRestoreFlow,
         appStoreAccountManagementFlow: AppStoreAccountManagementFlow) {
        self.subscriptionManager = subscriptionManager
        self.appStorePurchaseFlow = appStorePurchaseFlow
        self.appStoreRestoreFlow = appStoreRestoreFlow
        self.appStoreAccountManagementFlow = appStoreAccountManagementFlow
        self.subscriptionAttributionOrigin = subscriptionAttributionOrigin
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
        // Pixel related events
        case Handlers.subscriptionsMonthlyPriceClicked: return subscriptionsMonthlyPriceClicked
        case Handlers.subscriptionsYearlyPriceClicked: return subscriptionsYearlyPriceClicked
        case Handlers.subscriptionsUnknownPriceClicked: return subscriptionsUnknownPriceClicked
        case Handlers.subscriptionsAddEmailSuccess: return subscriptionsAddEmailSuccess
        case Handlers.subscriptionsWelcomeFaqClicked: return subscriptionsWelcomeFaqClicked
        case Handlers.getAccessToken: return getAccessToken
        default:
            os_log("Unhandled web message: %s", log: .subscription, type: .error, methodName)
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
        await appStoreAccountManagementFlow.refreshAuthTokenIfNeeded()
        let authToken = accountManager.authToken ?? Constants.empty

        return [Constants.token: authToken]
    }
    
    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async -> Encodable? {
        resetSubscriptionFlow()
        if let subscriptionOptions = await subscriptionManager.storePurchaseManager().subscriptionOptions() {
            if AppDependencyProvider.shared.subscriptionFeatureAvailability.isSubscriptionPurchaseAllowed {
                return subscriptionOptions
            } else {
                return SubscriptionOptions.empty
            }
        } else {
            os_log("Failed to obtain subscription options", log: .subscription, type: .error)
            setTransactionError(.failedToGetSubscriptionOptions)
            return nil
        }
    }
    
    func subscriptionSelected(params: Any, original: WKScriptMessage) async -> Encodable? {

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
            setTransactionStatus(.idle)
            return nil
        }
        
        // Check for active subscriptions
        if await subscriptionManager.storePurchaseManager().hasActiveSubscription() {
            setTransactionError(.hasActiveSubscription)
            Pixel.fire(pixel: .privacyProRestoreAfterPurchaseAttempt)
            setTransactionStatus(.idle)
            return nil
        }
        
        let emailAccessToken = try? EmailManager().getToken()
        let purchaseTransactionJWS: String

        switch await appStorePurchaseFlow.purchaseSubscription(with: subscriptionSelection.id,
                                                               emailAccessToken: emailAccessToken) {
        case .success(let transactionJWS):
            purchaseTransactionJWS = transactionJWS

        case .failure(let error):
            setTransactionStatus(.idle)
            switch error {
            case .cancelledByUser:
                setTransactionError(.cancelledByUser)
                await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate(type: "canceled"))
                return nil
            case .accountCreationFailed:
                setTransactionError(.accountCreationFailed)
            case .activeSubscriptionAlreadyPresent:
                setTransactionError(.hasActiveSubscription)
            default:
                setTransactionError(.purchaseFailed)
            }
            originalMessage = original
            return nil
        }
        
        setTransactionStatus(.polling)
        switch await appStorePurchaseFlow.completeSubscriptionPurchase(with: purchaseTransactionJWS) {
        case .success(let purchaseUpdate):
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseSuccess)
            UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            await Pixel.fireAttribution(pixel: .privacyProSuccessfulSubscriptionAttribution, origin: subscriptionAttributionOrigin)
            setTransactionStatus(.idle)
            await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: purchaseUpdate)
        case .failure:
            setTransactionStatus(.idle)
            setTransactionError(.missingEntitlements)
            await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate(type: "completed"))
        }
        return nil
        
    }

    func setSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        guard let subscriptionValues: SubscriptionValues = DecodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            setTransactionError(.generalError)
            return nil
        }

        // Clear subscription Cache
        subscriptionManager.subscriptionEndpointService.signOut()

        let authToken = subscriptionValues.token
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
        if let accessToken = accountManager.accessToken,
           case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
            switch await subscriptionManager.subscriptionEndpointService.getSubscription(accessToken: accessToken) {

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
    
    func getAccessToken(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        if let accessToken = subscriptionManager.accountManager.accessToken {
            return [Constants.token: accessToken]
        } else {
            return [String: String]()
        }
    }

    // MARK: Pixel related actions

    func subscriptionsMonthlyPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        Pixel.fire(pixel: .privacyProOfferMonthlyPriceClick)
        return nil
    }

    func subscriptionsYearlyPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        Pixel.fire(pixel: .privacyProOfferYearlyPriceClick)
        return nil
    }

    func subscriptionsUnknownPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        // Not used
        return nil
    }

    func subscriptionsAddEmailSuccess(params: Any, original: WKScriptMessage) async -> Encodable? {
        UniquePixel.fire(pixel: .privacyProAddEmailSuccess)
        return nil
    }

    func subscriptionsWelcomeFaqClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        UniquePixel.fire(pixel: .privacyProWelcomeFAQClick)
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
        let result = await appStoreRestoreFlow.restoreAccountFromPastPurchase()
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
    func mapAppStoreRestoreErrorToTransactionError(_ error: AppStoreRestoreFlowError) -> UseSubscriptionError {
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
        onFeatureSelected = nil
        onSetSubscription = nil
        onActivateSubscription = nil
        onBackToSettings = nil
    }

}

private extension Pixel {

    enum AttributionParameters {
        static let origin = "origin"
        static let locale = "locale"
    }

    static func fireAttribution(pixel: Pixel.Event, origin: String?, locale: Locale = .current) async {
        var parameters: [String: String] = [:]
        parameters[AttributionParameters.locale] = locale.identifier
        if let origin {
            parameters[AttributionParameters.origin] = origin
        }
        Self.fire(
            pixel: pixel,
            withAdditionalParameters: parameters.merging(await DefaultPrivacyProDataReporter.shared.randomizedParameters(for: .origin(origin))) { $1 }
        )
    }

}

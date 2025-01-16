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
import os.log
import Networking

enum SubscriptionTransactionStatus: String {
    case idle, purchasing, restoring, polling
}

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
    private let appStorePurchaseFlow: AppStorePurchaseFlow
    private let appStoreRestoreFlow: AppStoreRestoreFlow
    private let subscriptionFeatureAvailability: SubscriptionFeatureAvailability
    private let privacyProDataReporter: PrivacyProDataReporting?
    private let freeTrialsExperiment: any FreeTrialsFeatureFlagExperimenting

    init(subscriptionManager: SubscriptionManager,
         subscriptionFeatureAvailability: SubscriptionFeatureAvailability,
         subscriptionAttributionOrigin: String?,
         appStorePurchaseFlow: AppStorePurchaseFlow,
         appStoreRestoreFlow: AppStoreRestoreFlow,
         privacyProDataReporter: PrivacyProDataReporting? = nil,
         freeTrialsExperiment: any FreeTrialsFeatureFlagExperimenting = FreeTrialsFeatureFlagExperiment()) {
        self.subscriptionManager = subscriptionManager
        self.subscriptionFeatureAvailability = subscriptionFeatureAvailability
        self.appStorePurchaseFlow = appStorePurchaseFlow
        self.appStoreRestoreFlow = appStoreRestoreFlow
        self.subscriptionAttributionOrigin = subscriptionAttributionOrigin
        self.privacyProDataReporter = subscriptionAttributionOrigin != nil ? privacyProDataReporter : nil
        self.freeTrialsExperiment = freeTrialsExperiment
    }

    // Transaction Status and errors are observed from ViewModels to handle errors in the UI
    @Published private(set) var transactionStatus: SubscriptionTransactionStatus = .idle
    @Published private(set) var transactionError: UseSubscriptionError?
    
    // Subscription Activation Actions
    var onSetSubscription: (() -> Void)?
    var onBackToSettings: (() -> Void)?
    var onFeatureSelected: ((SubscriptionEntitlement) -> Void)?
    var onActivateSubscription: (() -> Void)?
    
    struct FeatureSelection: Codable {
        let productFeature: SubscriptionEntitlement
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
        Logger.subscription.debug("WebView handler: \(methodName)")

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
            Logger.subscription.error("Unhandled web message: \(methodName)")
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
        if status != transactionStatus {
            Logger.subscription.log("Transaction state updated: \(status.rawValue)")
            transactionStatus = status
        }
    }

    // MARK: Broker Methods (Called from WebView via UserScripts)

    /// Returns the auth token
    func getSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        do {
            let accessToken = try await subscriptionManager.getTokenContainer(policy: .localValid).accessToken
            return [Constants.token: accessToken]
        } catch {
            Logger.subscription.debug("No subscription available: \(error)")
            return [Constants.token: Constants.empty]
        }
    }

    func getSubscriptionOptions(params: Any, original: WKScriptMessage) async -> Encodable? {
        resetSubscriptionFlow()

        var subscriptionOptions: SubscriptionOptions?

        if let freeTrialsCohort = freeTrialCohortIfApplicable() {
            freeTrialsExperiment.incrementPaywallViewCountIfWithinConversionWindow()
            freeTrialsExperiment.firePaywallImpressionPixel()

            subscriptionOptions = await freeTrialSubscriptionOptions(for: freeTrialsCohort)
        } else {
            subscriptionOptions = await subscriptionManager.storePurchaseManager().subscriptionOptions()
        }

        if let subscriptionOptions {
            Logger.subscription.debug("Subscription options retrieved: \(String(describing: subscriptionOptions), privacy: .public)")
            if subscriptionFeatureAvailability.isSubscriptionPurchaseAllowed {
                return subscriptionOptions
            } else {
                Logger.subscription.log("Subscription purchase not allowed")
                return subscriptionOptions.withoutPurchaseOptions()
            }
        } else {
            Logger.subscription.error("Failed to obtain subscription options")
            setTransactionError(.failedToGetSubscriptionOptions)
            return SubscriptionOptions.empty
        }
    }
    
    func subscriptionSelected(params: Any, original: WKScriptMessage) async -> Encodable? {

        DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseAttempt,
                                     pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
        setTransactionError(nil)
        setTransactionStatus(.purchasing)
        resetSubscriptionFlow()
        
        struct SubscriptionSelection: Decodable {
            let id: String
        }
        
        let message = original
        guard let subscriptionSelection: SubscriptionSelection = CodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionSelection")
            Logger.subscription.error("SubscriptionPagesUserScript: expected JSON representation of SubscriptionSelection")
            setTransactionStatus(.idle)
            return nil
        }
        
        // Check for active subscriptions
        if await subscriptionManager.storePurchaseManager().hasActiveSubscription() {
            Logger.subscription.log("Subscription already active")
            setTransactionError(.hasActiveSubscription)
            Pixel.fire(pixel: .privacyProRestoreAfterPurchaseAttempt)
            setTransactionStatus(.idle)
            return nil
        }
        
        let purchaseTransactionJWS: String

        switch await appStorePurchaseFlow.purchaseSubscription(with: subscriptionSelection.id) {
        case .success(let transactionJWS):
            Logger.subscription.log("Subscription purchased successfully")
            purchaseTransactionJWS = transactionJWS

        case .failure(let error):
            Logger.subscription.error("App store purchase error: \(error.localizedDescription)")
            setTransactionStatus(.idle)
            switch error {
            case .cancelledByUser:
                setTransactionError(.cancelledByUser)
                await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate.canceled)
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

        guard purchaseTransactionJWS.isEmpty == false else {
            Logger.subscription.fault("Purchase transaction JWS is empty")
            assertionFailure("Purchase transaction JWS is empty")
            setTransactionStatus(.idle)
            return nil
        }

        // Free Trials Experiment Pixels
        fireFreeTrialSubscriptionPurchasePixelIfApplicable(for: subscriptionSelection.id)

        switch await appStorePurchaseFlow.completeSubscriptionPurchase(with: purchaseTransactionJWS,
                                                                       additionalParams: completeSubscriptionFreeTrialParameters) {
        case .success:
            Logger.subscription.log("Subscription purchase completed successfully")
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseSuccess,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            Pixel.fireAttribution(pixel: .privacyProSuccessfulSubscriptionAttribution, origin: subscriptionAttributionOrigin, privacyProDataReporter: privacyProDataReporter)

            setTransactionStatus(.idle)
            await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate.completed)
        case .failure(let error):
            Logger.subscription.error("App store complete subscription purchase error: \(error, privacy: .public)")

            await subscriptionManager.signOut(notifyUI: true)

            setTransactionStatus(.idle)
            setTransactionError(.missingEntitlements)
            await pushPurchaseUpdate(originalMessage: message, purchaseUpdate: PurchaseUpdate.completed)
        }
        return nil
    }

    func setSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        // Note: This is called by the web FE when a subscription is retrieved, `params` contains an auth token V1 that will need to be exchanged for a V2. This is a temporary workaround until the FE fully supports v2 auth.

        guard let subscriptionValues: SubscriptionValues = CodableHelper.decode(from: params) else {
            Logger.subscription.fault("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of SubscriptionValues")
            setTransactionError(.generalError)
            return nil
        }

        // Clear subscription Cache
        await subscriptionManager.signOut(notifyUI: false)

        let authToken = subscriptionValues.token
        do {
            _ = try await subscriptionManager.exchange(tokenV1: authToken)
            Logger.subscription.log("v1 token exchanged for v2")

            onSetSubscription?()
        } catch {
            Logger.subscription.error("Failed to exchange v1 token for v2")
            setTransactionError(.failedToSetSubscription)
        }
        return nil
    }

    func activateSubscription(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Activating Subscription")
        Pixel.fire(pixel: .privacyProRestorePurchaseOfferPageEntry, debounce: 2)
        onActivateSubscription?()
        return nil
    }

    func featureSelected(params: Any, original: WKScriptMessage) async -> Encodable? {
        guard let featureSelection: FeatureSelection = CodableHelper.decode(from: params) else {
            assertionFailure("SubscriptionPagesUserScript: expected JSON representation of FeatureSelection")
            Logger.subscription.error("SubscriptionPagesUserScript: expected JSON representation of FeatureSelection")
            return nil
        }

        onFeatureSelected?(featureSelection.productFeature)

        return nil
    }

    func backToSettings(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Back to settings")
//        guard let accessToken = accountManager.accessToken else {
//            Logger.subscription.error("Missing access token")
//            return nil
//        }
//
//        switch await accountManager.fetchAccountDetails(with: accessToken) {
//        case .success(let accountDetails):
//            switch await subscriptionManager.subscriptionEndpointService.getSubscription(accessToken: accessToken) {
//            case .success:
//                accountManager.storeAccount(token: accessToken,
//                                            email: accountDetails.email,
//                                            externalID: accountDetails.externalID)
//                onBackToSettings?()
//            case .failure(let error):
//                Logger.subscription.error("Error retrieving subscription details: \(error.localizedDescription)")
//            }
//        case .failure(let error):
//            Logger.subscription.error("Could not get account Details: \(error.localizedDescription)")
//            setTransactionError(.generalError)
//        }
//        return nil
        _ = try? await subscriptionManager.getTokenContainer(policy: .localForceRefresh)
        onBackToSettings?()
        return nil
    }

    func getAccessToken(params: Any, original: WKScriptMessage) async throws -> Encodable? {
        do {
            let accessToken = try await subscriptionManager.getTokenContainer(policy: .localValid).accessToken
            return [Constants.token: accessToken]
        } catch {
            Logger.subscription.debug("No access token available: \(error)")
            return [String: String]()
        }
    }

    // MARK: Pixel related actions

    func subscriptionsMonthlyPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Web function called: \(#function)")
        Pixel.fire(pixel: .privacyProOfferMonthlyPriceClick)

        if userIsEnrolledInFreeTrialsExperiment {
            freeTrialsExperiment.fireOfferSelectionMonthlyPixel()
        }

        return nil
    }

    func subscriptionsYearlyPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Web function called: \(#function)")
        Pixel.fire(pixel: .privacyProOfferYearlyPriceClick)

        if userIsEnrolledInFreeTrialsExperiment {
            freeTrialsExperiment.fireOfferSelectionYearlyPixel()
        }

        return nil
    }

    func subscriptionsUnknownPriceClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        // Not used
        Logger.subscription.log("Web function called: \(#function)")
        return nil
    }

    func subscriptionsAddEmailSuccess(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Web function called: \(#function)")
        UniquePixel.fire(pixel: .privacyProAddEmailSuccess)
        return nil
    }

    func subscriptionsWelcomeFaqClicked(params: Any, original: WKScriptMessage) async -> Encodable? {
        Logger.subscription.log("Web function called: \(#function)")
        UniquePixel.fire(pixel: .privacyProWelcomeFAQClick)
        return nil
    }

    // MARK: Push actions (Push Data back to WebViews)
    
    enum SubscribeActionName: String {
        case onPurchaseUpdate
    }

    @MainActor
    func pushPurchaseUpdate(originalMessage: WKScriptMessage, purchaseUpdate: PurchaseUpdate) async {
        guard let webView = originalMessage.webView else { return }

        pushAction(method: .onPurchaseUpdate, webView: webView, params: purchaseUpdate)
    }

    func pushAction(method: SubscribeActionName, webView: WKWebView, params: Encodable) {
        let broker = UserScriptMessageBroker(context: SubscriptionPagesUserScript.context, requiresRunInPageContentWorld: true )
        broker.push(method: method.rawValue, params: params, for: self, into: webView)
    }

    // MARK: Native methods - Called from ViewModels
    
    func restoreAccountFromAppStorePurchase() async throws {
        setTransactionStatus(.restoring)
        let result = await appStoreRestoreFlow.restoreAccountFromPastPurchase()

        setTransactionStatus(.idle)
        switch result {
        case .success:
            Logger.subscription.log("Subscription restored successfully from App Store purchase")
        case .failure(let error):
            Logger.subscription.error("Failed to restore subscription from App Store purchase: \(error.localizedDescription)")
            let mappedError = mapAppStoreRestoreErrorToTransactionError(error)
            throw mappedError
        }
    }

    func cancelRestoreAccountFromAppStorePurchase() async throws {
        setTransactionStatus(.idle)
        await subscriptionManager.signOut(notifyUI: false)
    }


    // MARK: Utility Methods
    
    func mapAppStoreRestoreErrorToTransactionError(_ error: AppStoreRestoreFlowError) -> UseSubscriptionError {
        Logger.subscription.error("\(#function): \(error.localizedDescription)")
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

private extension SubscriptionPagesUseSubscriptionFeature {

    /// Retrieves the parameters for completing a subscription free trial if applicable.
    ///
    /// This property checks if the user is part of a valid free trial cohort. If the user is in a cohort,
    /// it returns the associated free trial parameters, provided these parameters have not been returned previously.
    /// If the user is not in a cohort or the parameters have already been returned, the property returns `nil`.
    ///
    /// - Returns: A dictionary of free trial parameters (`[String: String]`) if applicable, or `nil` otherwise.
    var completeSubscriptionFreeTrialParameters: [String: String]? {
        guard let cohort = freeTrialCohortIfApplicable() else { return nil }
        return freeTrialsExperiment.freeTrialParametersIfNotPreviouslyReturned(for: cohort)
    }
    
    /// Determines whether a user is enrolled in the Free Trials experiment
    /// - Returns: `true` if the user is part of a free trial cohort, otherwise `false`.
    var userIsEnrolledInFreeTrialsExperiment: Bool {
        freeTrialCohortIfApplicable() != nil
    }

    /// Fires a subscription purchase pixel for a free trial if applicable.
    ///
    /// This method checks if the user is part of a free trial cohort and fires
    /// the appropriate pixel based on the subscription type (monthly or yearly).
    ///
    /// - Parameter id: The subscription identifier used to determine the type of subscription.
    func fireFreeTrialSubscriptionPurchasePixelIfApplicable(for id: String) {
        // Check if the pixel should be fired; exit early if not applicable
        guard userIsEnrolledInFreeTrialsExperiment else { return }

        /*
         Logic based on strings is obviously not ideal, but acceptable for this temporary
         experiment.
        */
        if id.contains("month") {
            freeTrialsExperiment.fireSubscriptionStartedMonthlyPixel()
        } else if id.contains("year") {
            freeTrialsExperiment.fireSubscriptionStartedYearlyPixel()
        }
    }

    /// Retrieves the free trial cohort for the user, if applicable.
    ///
    /// Cohorts are determined based on the feature flag configuration, user authentication status,
    /// and whether the user can make purchases.
    ///
    /// - Returns: A `FreeTrialsFeatureFlagExperiment.Cohort` if the user is part of a cohort, otherwise `nil`.
    func freeTrialCohortIfApplicable() -> FreeTrialsFeatureFlagExperiment.Cohort? {
        // Check if the user is authenticated; free trials are not applicable for authenticated users
        guard !subscriptionManager.isUserAuthenticated else { return nil }
        // Ensure that the user can make purchases
        guard subscriptionManager.canPurchase else { return nil }

        // Retrieve the cohort if the feature flag is enabled
        guard let cohort = freeTrialsExperiment.getCohortIfEnabled() as? FreeTrialsFeatureFlagExperiment.Cohort else { return nil }

        return cohort
    }

    /// Retrieves the appropriate subscription options based on the free trial cohort.
    ///
    /// - Parameter freeTrialsCohort: The cohort the user belongs to (`control` or `treatment`).
    /// - Returns: A `SubscriptionOptions` object containing the relevant subscription options.
    func freeTrialSubscriptionOptions(for freeTrialsCohort: FreeTrialsFeatureFlagExperiment.Cohort) async -> SubscriptionOptions? {
        var subscriptionOptions: SubscriptionOptions?

        switch freeTrialsCohort {
        case .control:
            subscriptionOptions = await subscriptionManager.storePurchaseManager().subscriptionOptions()
        case .treatment:
            subscriptionOptions = await subscriptionManager.storePurchaseManager().freeTrialSubscriptionOptions()

            /*
                Fallback to standard subscription options if nil.
                This could occur if the Free Trial offer in AppStoreConnect had an end date in the past.
             */
            if subscriptionOptions == nil {
                subscriptionOptions = await subscriptionManager.storePurchaseManager().subscriptionOptions()
            }
        }

        return subscriptionOptions
    }
}

private extension Pixel {

    enum AttributionParameters {
        static let origin = "origin"
        static let locale = "locale"
    }

    static func fireAttribution(pixel: Pixel.Event, origin: String?, locale: Locale = .current, privacyProDataReporter: PrivacyProDataReporting?) {
        var parameters: [String: String] = [:]
        parameters[AttributionParameters.locale] = locale.identifier
        if let origin {
            parameters[AttributionParameters.origin] = origin
        }
        Self.fire(
            pixel: pixel,
            withAdditionalParameters: privacyProDataReporter?.mergeRandomizedParameters(for: .origin(origin), with: parameters) ?? parameters
        )
    }

}

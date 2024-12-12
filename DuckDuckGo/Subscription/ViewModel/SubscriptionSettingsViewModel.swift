//
//  SubscriptionSettingsViewModel.swift
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
import SwiftUI
import StoreKit
import Subscription
import Core
import os.log
import BrowserServicesKit
import Networking

final class SubscriptionSettingsViewModel: ObservableObject {
    
    private let subscriptionManager: SubscriptionManager
    private var signOutObserver: Any?
    
    private var externalAllowedDomains = ["stripe.com"]
    
    struct State {
        var subscriptionDetails: String = ""
        var subscriptionEmail: String?
        var isShowingRemovalNotice: Bool = false
        var shouldDismissView: Bool = false
        var isShowingGoogleView: Bool = false
        var isShowingFAQView: Bool = false
        var isShowingLearnMoreView: Bool = false
        var subscriptionInfo: PrivacyProSubscription?
        var isLoadingSubscriptionInfo: Bool = false
        var isLoadingEmailInfo: Bool = false

        // Used to display stripe WebUI
        var stripeViewModel: SubscriptionExternalLinkViewModel?
        var isShowingStripeView: Bool = false
        
        // Display error
        var isShowingConnectionError: Bool = false
        
        // Used to display the FAQ WebUI
        var faqViewModel: SubscriptionExternalLinkViewModel
        var learnMoreViewModel: SubscriptionExternalLinkViewModel

        init(faqURL: URL, learnMoreURL: URL) {
            self.faqViewModel = SubscriptionExternalLinkViewModel(url: faqURL)
            self.learnMoreViewModel = SubscriptionExternalLinkViewModel(url: learnMoreURL)
        }
    }

    // Publish the currently selected feature
    @Published var selectedFeature: SettingsViewModel.SettingsDeepLinkSection?
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state: State

    public let usesUnifiedFeedbackForm: Bool

    init(subscriptionManager: SubscriptionManager = AppDependencyProvider.shared.subscriptionManager) {
        self.subscriptionManager = subscriptionManager
        let subscriptionFAQURL = subscriptionManager.url(for: .faq)
        let learnMoreURL = subscriptionFAQURL.appendingPathComponent("adding-email")
        self.state = State(faqURL: subscriptionFAQURL, learnMoreURL: learnMoreURL)
        self.usesUnifiedFeedbackForm = subscriptionManager.isUserAuthenticated
        setupNotificationObservers()
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func onFirstAppear() {
        Task {
            // Load initial state from the cache
            async let loadedEmailFromCache = await self.fetchAndUpdateAccountEmail(cachePolicy: .returnCacheDataDontLoad,
                                                                                   loadingIndicator: false)
            async let loadedSubscriptionFromCache = await self.fetchAndUpdateSubscriptionDetails(cachePolicy: .returnCacheDataDontLoad,
                                                                                                 loadingIndicator: false)
            let (hasLoadedEmailFromCache, hasLoadedSubscriptionFromCache) = await (loadedEmailFromCache, loadedSubscriptionFromCache)

            // Reload remote subscription and email state
            async let reloadedEmail = await self.fetchAndUpdateAccountEmail(cachePolicy: .reloadIgnoringLocalCacheData,
                                                                            loadingIndicator: !hasLoadedEmailFromCache)
            async let reloadedSubscription = await self.fetchAndUpdateSubscriptionDetails(cachePolicy: .reloadIgnoringLocalCacheData,
                                                                                          loadingIndicator: !hasLoadedSubscriptionFromCache)
            let (hasReloadedEmail, hasReloadedSubscription) = await (reloadedEmail, reloadedSubscription)

            // In case any fetch fails show an error
            if !hasReloadedEmail || !hasReloadedSubscription {
                self.showConnectionError(true)
            }
        }
    }

    private func fetchAndUpdateSubscriptionDetails(cachePolicy: SubscriptionCachePolicy, loadingIndicator: Bool) async -> Bool {
        Logger.subscription.log("Fetch and update subscription details")

        if loadingIndicator { displaySubscriptionLoader(true) }

        if let subscription = try? await self.subscriptionManager.currentSubscription(refresh: cachePolicy != SubscriptionCachePolicy.returnCacheDataDontLoad) {
            DispatchQueue.main.async {
                self.state.subscriptionInfo = subscription
                if loadingIndicator { self.displaySubscriptionLoader(false) }
            }
            await updateSubscriptionsStatusMessage(status: subscription.status,
                                                   date: subscription.expiresOrRenewsAt,
                                                   product: subscription.productId,
                                                   billingPeriod: subscription.billingPeriod)
        }
        return true
    }

    func fetchAndUpdateAccountEmail(cachePolicy: SubscriptionCachePolicy = .returnCacheDataElseLoad, loadingIndicator: Bool) async -> Bool {
        Logger.subscription.log("Fetch and update account email")
        var tokensPolicy: TokensCachePolicy = .local
        switch cachePolicy {
        case .reloadIgnoringLocalCacheData:
            tokensPolicy = .localForceRefresh
        case .returnCacheDataElseLoad:
            tokensPolicy = .localValid
        case .returnCacheDataDontLoad:
            tokensPolicy = .local
        }

        if let tokenContainer = try? await subscriptionManager.getTokenContainer(policy: tokensPolicy) {
            DispatchQueue.main.async {
                self.state.subscriptionEmail = tokenContainer.decodedAccessToken.email
                if loadingIndicator { self.displayEmailLoader(true) }
            }
            return true
        }
        return false
    }

    private func displaySubscriptionLoader(_ show: Bool) {
        DispatchQueue.main.async {
            self.state.isLoadingSubscriptionInfo = show
        }
    }

    private func displayEmailLoader(_ show: Bool) {
        DispatchQueue.main.async {
            self.state.isLoadingEmailInfo = show
        }
    }

    func manageSubscription() {
        Logger.subscription.log("User action: \(#function)")
        switch state.subscriptionInfo?.platform {
        case .apple:
            Task { await manageAppleSubscription() }
        case .google:
            displayGoogleView(true)
        case .stripe:
            Task { await manageStripeSubscription() }
        default:
            return
        }
    }
    
    // MARK: -
    
    private func setupNotificationObservers() {
        signOutObserver = NotificationCenter.default.addObserver(forName: .accountDidSignOut, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                self?.state.shouldDismissView = true
            }
        }
    }
    
    @MainActor
    private func updateSubscriptionsStatusMessage(status: PrivacyProSubscription.Status, date: Date, product: String, billingPeriod: PrivacyProSubscription.BillingPeriod) {
        Logger.subscription.log("Update subscription status: \(status.rawValue)")
//        let billingPeriod = billingPeriod == .monthly ? UserText.subscriptionMonthlyBillingPeriod : UserText.subscriptionAnnualBillingPeriod
        let date = dateFormatter.string(from: date)

        switch status {
        case .autoRenewable:
            state.subscriptionDetails = UserText.renewingSubscriptionInfo(billingPeriod: billingPeriod, renewalDate: date)
        case .expired, .inactive:
            state.subscriptionDetails = UserText.expiredSubscriptionInfo(expiration: date)
        default:
            state.subscriptionDetails = UserText.expiringSubscriptionInfo(billingPeriod: billingPeriod, expiryDate: date)
        }
    }
    
    func removeSubscription() {
        Logger.subscription.log("Remove subscription")

        Task {
            await subscriptionManager.signOut()
            _ = await ActionMessageView()
            await ActionMessageView.present(message: UserText.subscriptionRemovalConfirmation,
                                      presentationLocation: .withoutBottomBar)
        }
    }
    
    func displayGoogleView(_ value: Bool) {
        Logger.subscription.log("Show google")
        if value != state.isShowingGoogleView {
            state.isShowingGoogleView = value
        }
    }
    
    func displayStripeView(_ value: Bool) {
        Logger.subscription.log("Show stripe")
        if value != state.isShowingStripeView {
            state.isShowingStripeView = value
        }
    }
    
    func displayRemovalNotice(_ value: Bool) {
        if value != state.isShowingRemovalNotice {
            state.isShowingRemovalNotice = value
        }
    }
    
    func displayFAQView(_ value: Bool) {
        Logger.subscription.log("Show faq")
        if value != state.isShowingFAQView {
            state.isShowingFAQView = value
        }
    }

    func displayLearnMoreView(_ value: Bool) {
        Logger.subscription.log("Show learn more")
        if value != state.isShowingLearnMoreView {
            state.isShowingLearnMoreView = value
        }
    }

    func showConnectionError(_ value: Bool) {
        if value != state.isShowingConnectionError {
            DispatchQueue.main.async {
                self.state.isShowingConnectionError = value
            }
        }
    }

    @MainActor
    func showTermsOfService() {
        Logger.subscription.log("Show terms of service")
        self.openURL(SettingsSubscriptionView.ViewConstants.privacyPolicyURL)
    }

    // MARK: -
    
    @MainActor private func manageAppleSubscription() async {
        Logger.subscription.log("Managing Apple Subscription")
        if state.subscriptionInfo?.isActive ?? false {
            let url = subscriptionManager.url(for: .manageSubscriptionsInAppStore)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                do {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                } catch {
                    self.openURL(url)
                }
            } else {
                self.openURL(url)
            }
        }
    }
         
    private func manageStripeSubscription() async {
        Logger.subscription.log("Managing Stripe Subscription")
        do {
            // Get Stripe Customer Portal URL and update the model
            let url = try await subscriptionManager.getCustomerPortalURL()
            if let existingModel = state.stripeViewModel {
                existingModel.url = url
            } else {
                let model = SubscriptionExternalLinkViewModel(url: url, allowedDomains: externalAllowedDomains)
                DispatchQueue.main.async {
                    self.state.stripeViewModel = model
                }
            }
            DispatchQueue.main.async {
                self.displayStripeView(true)
            }
        } catch {
            Logger.subscription.error("\(error.localizedDescription)")
        }
    }

    @MainActor
    private func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        signOutObserver = nil
    }
}

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

@available(iOS 15.0, *)
final class SubscriptionSettingsViewModel: ObservableObject {
    
    private let subscriptionManager: SubscriptionManaging
    private var signOutObserver: Any?
    
    private var externalAllowedDomains = ["stripe.com"]
    
    struct State {
        var subscriptionDetails: String = ""
        var subscriptionEmail: String?
        var isShowingRemovalNotice: Bool = false
        var shouldDismissView: Bool = false
        var isShowingGoogleView: Bool = false
        var isShowingFAQView: Bool = false
        var subscriptionInfo: Subscription?
        var isLoadingSubscriptionInfo: Bool = false
        var isLoadingEmailInfo: Bool = false

        // Used to display stripe WebUI
        var stripeViewModel: SubscriptionExternalLinkViewModel?
        var isShowingStripeView: Bool = false
        
        // Display error
        var isShowingConnectionError: Bool = false
        
        // Used to display the FAQ WebUI
        var faqViewModel: SubscriptionExternalLinkViewModel

        init(faqURL: URL) {
            self.faqViewModel = SubscriptionExternalLinkViewModel(url: faqURL)
        }
    }

    // Publish the currently selected feature
    @Published var selectedFeature: SettingsViewModel.SettingsDeepLinkSection?
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state: State

    
    init(subscriptionManager: SubscriptionManaging = AppDependencyProvider.shared.subscriptionManager) {
        self.subscriptionManager = subscriptionManager
        let subscriptionFAQURL = subscriptionManager.url(for: .faq)
        self.state = State(faqURL: subscriptionFAQURL)

        setupNotificationObservers()
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
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

    private func fetchAndUpdateSubscriptionDetails(cachePolicy: SubscriptionService.CachePolicy, loadingIndicator: Bool) async -> Bool {
        guard let token = self.subscriptionManager.accountManager.accessToken else { return false }

        if loadingIndicator { displaySubscriptionLoader(true) }
        let subscriptionResult = await self.subscriptionManager.subscriptionService.getSubscription(accessToken: token, cachePolicy: cachePolicy)
        switch subscriptionResult {
        case .success(let subscription):
            DispatchQueue.main.async {
                self.state.subscriptionInfo = subscription
                if loadingIndicator { self.displaySubscriptionLoader(false) }
            }
            await updateSubscriptionsStatusMessage(status: subscription.status,
                                                   date: subscription.expiresOrRenewsAt,
                                                   product: subscription.productId,
                                                   billingPeriod: subscription.billingPeriod)
            return true
        default:
            DispatchQueue.main.async {
                if loadingIndicator { self.displaySubscriptionLoader(true) }
            }
            return false
        }
    }

    func fetchAndUpdateAccountEmail(cachePolicy: SubscriptionService.CachePolicy = .returnCacheDataElseLoad, loadingIndicator: Bool) async -> Bool {
        guard let token = self.subscriptionManager.accountManager.accessToken else { return false }

        if loadingIndicator { displayEmailLoader(true) }
        switch await self.subscriptionManager.accountManager.fetchAccountDetails(with: token) {
        case .success(let details):
            DispatchQueue.main.async {
                self.state.subscriptionEmail = details.email
                if loadingIndicator { self.displayEmailLoader(false) }
            }

            // If fetched email is different then update accountManager
            if details.email != subscriptionManager.accountManager.email {
                let externalID = subscriptionManager.accountManager.externalID
                subscriptionManager.accountManager.storeAccount(token: token, email: details.email, externalID: externalID)
            }
            return true
        default:
            DispatchQueue.main.async {
                if loadingIndicator { self.displayEmailLoader(true) }
            }
            return false
        }
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
    private func updateSubscriptionsStatusMessage(status: Subscription.Status, date: Date, product: String, billingPeriod: Subscription.BillingPeriod) {
        let billingPeriod = billingPeriod == .monthly ? UserText.subscriptionMonthlyBillingPeriod : UserText.subscriptionAnnualBillingPeriod
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
        subscriptionManager.accountManager.signOut()
        _ = ActionMessageView()
        ActionMessageView.present(message: UserText.subscriptionRemovalConfirmation,
                                  presentationLocation: .withoutBottomBar)
    }
    
    func displayGoogleView(_ value: Bool) {
        if value != state.isShowingGoogleView {
            state.isShowingGoogleView = value
        }
    }
    
    func displayStripeView(_ value: Bool) {
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
        if value != state.isShowingFAQView {
            state.isShowingFAQView = value
        }
    }
    
    func showConnectionError(_ value: Bool) {
        if value != state.isShowingConnectionError {
            DispatchQueue.main.async {
                self.state.isShowingConnectionError = value
            }
        }
    }
    
    // MARK: -
    
    @MainActor private func manageAppleSubscription() async {
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
        guard let token = subscriptionManager.accountManager.accessToken,
                let externalID = subscriptionManager.accountManager.externalID else { return }
        let serviceResponse = await  subscriptionManager.subscriptionService.getCustomerPortalURL(accessToken: token, externalID: externalID)

        // Get Stripe Customer Portal URL and update the model
        if case .success(let response) = serviceResponse {
            guard let url = URL(string: response.customerPortalUrl) else { return }
            if let existingModel = state.stripeViewModel {
                existingModel.url = url
            } else {
                let model = SubscriptionExternalLinkViewModel(url: url, allowedDomains: externalAllowedDomains)
                DispatchQueue.main.async {
                    self.state.stripeViewModel = model
                }
            }
        }
        DispatchQueue.main.async {
            self.displayStripeView(true)
        }
    }

    @MainActor
    private func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    deinit {
        signOutObserver = nil
    }
}

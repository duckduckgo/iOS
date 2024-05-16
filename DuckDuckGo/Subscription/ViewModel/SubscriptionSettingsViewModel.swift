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
    private var subscriptionUpdateTimer: Timer?
    private var signOutObserver: Any?
    
    private var externalAllowedDomains = ["stripe.com"]
    
    struct State {
        var subscriptionDetails: String = ""
        var subscriptionType: String = ""
        var isShowingRemovalNotice: Bool = false
        var shouldDismissView: Bool = false
        var isShowingGoogleView: Bool = false
        var isShowingFAQView: Bool = false
        var subscriptionInfo: Subscription?
        var isLoadingSubscriptionInfo: Bool = false
        
        // Used to display stripe WebUI
        var stripeViewModel: SubscriptionExternalLinkViewModel?
        var isShowingStripeView: Bool = false
        
        // Display error
        var isShowingConnectionError: Bool = false
        
        // Used to display the FAQ WebUI
        var FAQViewModel: SubscriptionExternalLinkViewModel

        init(faqURL: URL) {
            self.FAQViewModel = SubscriptionExternalLinkViewModel(url: faqURL)
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

        setupSubscriptionUpdater()
        setupNotificationObservers()
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    func onFirstAppear() {
        self.fetchAndUpdateSubscriptionDetails(cachePolicy: .returnCacheDataElseLoad)
    }
    
    private func fetchAndUpdateSubscriptionDetails(cachePolicy: SubscriptionService.CachePolicy = .returnCacheDataElseLoad,
                                                   loadingIndicator: Bool = true) {
        Task {
            if loadingIndicator { displayLoader(true) }
            guard let token = self.subscriptionManager.accountManager.accessToken else { return }
            let subscriptionResult = await self.subscriptionManager.subscriptionService.getSubscription(accessToken: token, cachePolicy: cachePolicy)
            switch subscriptionResult {
            case .success(let subscription):
                DispatchQueue.main.async {
                    self.state.subscriptionInfo = subscription
                    if loadingIndicator { self.displayLoader(false) }
                }
                await updateSubscriptionsStatusMessage(status: subscription.status,
                                                date: subscription.expiresOrRenewsAt,
                                                product: subscription.productId,
                                                billingPeriod: subscription.billingPeriod)
            default:
                DispatchQueue.main.async {
                    if loadingIndicator { self.displayLoader(true) }
                    self.showConnectionError(true)
                }
                
                subscriptionUpdateTimer?.invalidate()
            }
        }
    }
    
    private func displayLoader(_ show: Bool) {
        DispatchQueue.main.async {
            self.state.isLoadingSubscriptionInfo = show
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
    
    // Re-fetch subscription from server ignoring cache
    // This ensure that if the user re-subscribed or changed plan on the Apple view, state is updated
    private func setupSubscriptionUpdater() {
        subscriptionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
                strongSelf.fetchAndUpdateSubscriptionDetails(cachePolicy: .reloadIgnoringLocalCacheData, loadingIndicator: false)
        }
    }
    
    @MainActor
    private func updateSubscriptionsStatusMessage(status: Subscription.Status, date: Date, product: String, billingPeriod: Subscription.BillingPeriod) {
        let date = dateFormatter.string(from: date)
        let expiredStates: [Subscription.Status] = [.expired, .inactive]
        if expiredStates.contains(status) {
            state.subscriptionDetails = UserText.expiredSubscriptionInfo(expiration: date)
        } else {
            let statusString = (status == .autoRenewable) ? UserText.subscriptionRenews : UserText.subscriptionExpires
            state.subscriptionDetails = UserText.subscriptionInfo(status: statusString, expiration: date)
            state.subscriptionType = billingPeriod == .monthly ? UserText.subscriptionMonthly : UserText.subscriptionAnnual
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
        subscriptionUpdateTimer?.invalidate()
        signOutObserver = nil
    }
}

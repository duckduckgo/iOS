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

#if SUBSCRIPTION
import Subscription
@available(iOS 15.0, *)
final class SubscriptionSettingsViewModel: ObservableObject {
    
    enum Constants {
        static let monthlyProductID = "ios.subscription.1month"
        static let yearlyProductID = "ios.subscription.1year"
        static let updateFrequency: Float = 10
    }
    
    let accountManager: AccountManager
    private var subscriptionUpdateTimer: Timer?
    private var signOutObserver: Any?
    
    @Published var subscriptionDetails: String = ""
    @Published var subscriptionType: String = ""
    @Published var shouldDisplayRemovalNotice: Bool = false
    @Published var shouldDismissView: Bool = false
    
    init(accountManager: AccountManager = AccountManager()) {
        self.accountManager = accountManager
        Task { await fetchAndUpdateSubscriptionDetails() }
        setupSubscriptionUpdater()
        setupNotificationObservers()
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    @MainActor
    func fetchAndUpdateSubscriptionDetails(cachePolicy: SubscriptionService.CachePolicy = .returnCacheDataElseLoad) {
        Task {
            guard let token = self.accountManager.accessToken else { return }
            let subscriptionResult = await SubscriptionService.getSubscription(accessToken: token, cachePolicy: cachePolicy)
            switch subscriptionResult {
            case .success(let subscription):
                updateSubscriptionDetails(status: subscription.status, date: subscription.expiresOrRenewsAt, product: subscription.productId)
            case .failure(let error):
                AccountManager().signOut()
                shouldDismissView = true
            }
        }
    }
    
    private func setupNotificationObservers() {
        signOutObserver = NotificationCenter.default.addObserver(forName: .accountDidSignOut, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                self?.shouldDismissView = true
            }
        }
    }
    
    // Re-fetch subscription from server ignoring cache
    // This ensure that if the user changed something on the Apple view, state will be updated
    private func setupSubscriptionUpdater() {
        subscriptionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let strongSelf = self else { return }
            Task {
                await strongSelf.fetchAndUpdateSubscriptionDetails(cachePolicy: .reloadIgnoringLocalCacheData)
            }
        }
    }

    
    private func updateSubscriptionDetails(status: Subscription.Status, date: Date, product: String) {
        let statusString = (status == .autoRenewable) ? UserText.subscriptionRenews : UserText.subscriptionExpires
        self.subscriptionDetails = UserText.subscriptionInfo(status: statusString, expiration: dateFormatter.string(from: date))
        self.subscriptionType = product == Constants.monthlyProductID ? UserText.subscriptionMonthly : UserText.subscriptionAnnual
    }
    
    func removeSubscription() {
        AccountManager().signOut()
        _ = ActionMessageView()
        ActionMessageView.present(message: UserText.subscriptionRemovalConfirmation,
                                  presentationLocation: .withoutBottomBar)
    }
    
    func manageSubscription() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                Task {
                    do {
                        try await AppStore.showManageSubscriptions(in: windowScene)
                    } catch {
                        openSubscriptionManagementURL()
                    }
                }
            } else {
                openSubscriptionManagementURL()
            }
        }

    private func openSubscriptionManagementURL() {
        let url = URL.manageSubscriptionsInAppStoreAppURL
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    deinit {
        subscriptionUpdateTimer?.invalidate()
        signOutObserver = nil
    }
    
    
}
#endif

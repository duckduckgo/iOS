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

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionSettingsViewModel: ObservableObject {
    
    private let accountManager: AccountManager
    
    var subscriptionDetails: String = ""
    @Published var shouldDisplayRemovalNotice: Bool = false
    
    init(accountManager: AccountManager = AccountManager()) {
        self.accountManager = accountManager
        fetchAndUpdateSubscriptionDetails()
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy" // Jan 12, 2024"
        return formatter
    }()
    
    private func fetchAndUpdateSubscriptionDetails() {
        Task {
            guard let token = accountManager.accessToken else { return }

            if let cachedDate = SubscriptionService.cachedSubscriptionDetailsResponse?.expiresOrRenewsAt {
                updateSubscriptionDetails(date: cachedDate)
            }

            if case .success(let response) = await SubscriptionService.getSubscriptionDetails(token: token) {
                if !response.isSubscriptionActive {
                    AccountManager().signOut()
                    return
                }
            }
        }
    }
    
    private func updateSubscriptionDetails(date: Date) {
        self.subscriptionDetails = UserText.privacyProSubscriptionInfo(expiration: dateFormatter.string(from: date))
    }
    
    func removeSubscription() {
        AccountManager().signOut()
    }
    
    func manageSubscription() {
        let url = URL.manageSubscriptionsIniOSAppStoreAppURL
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}
#endif

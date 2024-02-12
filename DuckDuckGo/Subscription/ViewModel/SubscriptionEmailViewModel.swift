//
//  SubscriptionEmailViewModel.swift
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
import UserScript
import Combine
import Core
import Subscription

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionEmailViewModel: ObservableObject {
    
    let accountManager: AccountManager
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    
    var emailURL = URL.activateSubscriptionViaEmail
    var viewTitle = UserText.subscriptionRestoreEmail
    @Published var subscriptionEmail: String?
    @Published var shouldReloadWebView = false
    @Published var activateSubscription = false
    @Published var managingSubscriptionEmail = false
    @Published var webViewModel: AsyncHeadlessWebViewViewModel
    
    private var cancellables = Set<AnyCancellable>()
            
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         accountManager: AccountManager = AccountManager()) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.accountManager = accountManager
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false))
        initializeView()
        setupTransactionObservers()
    }
    
    private func initializeView() {
        if accountManager.isUserAuthenticated {
            // If user is authenticated, we want to "Add or manage email" instead of activating
            emailURL = accountManager.email == nil ? URL.addEmailToSubscription : URL.manageSubscriptionEmail
            viewTitle = accountManager.email == nil ?  UserText.subscriptionRestoreAddEmailTitle : UserText.subscriptionManageEmailTitle
            
            // Also we assume subscription requires managing, and not activation
            managingSubscriptionEmail = true
        }
    }
    
    private func setupTransactionObservers() {
        subFeature.$emailActivationComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.completeActivation()
                }
            }
            .store(in: &cancellables)
    }
    
    private func completeActivation() {
        subFeature.emailActivationComplete = false
        activateSubscription = true
    }
    
    func loadURL() {
        webViewModel.navigationCoordinator.navigateTo(url: emailURL )
    }

}
#endif

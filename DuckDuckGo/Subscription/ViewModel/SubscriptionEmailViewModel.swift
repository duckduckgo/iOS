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

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionEmailViewModel: ObservableObject {
    
    let accountManager: AccountManager
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    
    var emailURL = URL.addEmailToSubscription
    var viewTitle = UserText.subscriptionRestoreAddEmailTitle
    @Published var subscriptionEmail: String?
    @Published var shouldReloadWebView = false
    @Published var subscriptionActive = false
    
    private var cancellables = Set<AnyCancellable>()
            
    init(userScript: SubscriptionPagesUserScript,
         subFeature: SubscriptionPagesUseSubscriptionFeature,
         accountManager: AccountManager) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.accountManager = accountManager
        initializeView()
        setupTransactionObservers()
    }
    
    func initializeView() {
        subscriptionEmail = accountManager.email
        if subscriptionEmail != nil {
            emailURL = URL.activateSubscriptionViaEmail
        }
    }
    
    func setupTransactionObservers() {
        subFeature.$emailActivationComplete
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.subFeature.emailActivationComplete = false
                    self?.subscriptionActive = true
                }
            }
            .store(in: &cancellables)
    }
}
#endif

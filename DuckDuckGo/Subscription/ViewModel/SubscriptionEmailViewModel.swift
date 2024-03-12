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
import Subscription
@available(iOS 15.0, *)
final class SubscriptionEmailViewModel: ObservableObject {
    
    let accountManager: AccountManaging
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    
    var emailURL = URL.activateSubscriptionViaEmail
    var viewTitle = UserText.subscriptionActivateEmail
    @Published var subscriptionEmail: String?
    @Published var shouldReloadWebView = false
    @Published var activateSubscription = false
    @Published var managingSubscriptionEmail = false
    @Published var transactionError: SubscriptionRestoreError?
    @Published var navigationError: Bool = false
    @Published var shouldDisplayInactiveError: Bool = false
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    private static let allowedDomains = [
        "duckduckgo.com",
        "microsoftonline.com",
        "duosecurity.com",
    ]
    
    enum SubscriptionRestoreError: Error {
        case failedToRestoreFromEmail,
             subscriptionExpired,
             generalError
    }

    private var cancellables = Set<AnyCancellable>()

    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         accountManager: AccountManaging = AppDependencyProvider.shared.subscriptionManager.accountManager) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.accountManager = accountManager
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false,
                                                                                                 allowedDomains: Self.allowedDomains,
                                                                                                 contentBlocking: false))
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
        
        subFeature.$transactionError
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                if let value {
                    strongSelf.handleTransactionError(error: value)
                }
            }
        .store(in: &cancellables)
        
        webViewModel.$navigationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.navigationError = error != nil ? true : false
                }
                
            }
            .store(in: &cancellables)
    }
    
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        
        case .subscriptionExpired:
            transactionError = .subscriptionExpired
        default:
            transactionError = .generalError
        }
        shouldDisplayInactiveError = true
    }
    
    private func completeActivation() {
        DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseEmailSuccess)
        subFeature.emailActivationComplete = false
        activateSubscription = true
    }
    
    func loadURL() {
        webViewModel.navigationCoordinator.navigateTo(url: emailURL )
    }
    
    deinit {
        cancellables.removeAll()
       
    }

}
#endif

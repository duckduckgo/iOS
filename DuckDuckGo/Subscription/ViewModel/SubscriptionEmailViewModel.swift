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
    
    let accountManager: AccountManager
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    
    private var canGoBackCancellable: AnyCancellable?
    
    var emailURL = URL.activateSubscriptionViaEmail
    var viewTitle = UserText.subscriptionActivateEmailTitle
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    struct State {
        var subscriptionEmail: String?
        var managingSubscriptionEmail = false
        var transactionError: SubscriptionRestoreError?
        var shouldDisplaynavigationError: Bool = false
        var shouldDisplayInactiveError: Bool = false
        var canNavigateBack: Bool = false
        var shouldDismissView: Bool = false
        var shouldDismissStack: Bool = false
        var subscriptionActive: Bool = false
    }
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state = State()
    
    // Publish the currently selected feature
    @Published var selectedFeature: SettingsViewModel.SettingsDeepLinkSection?
    
    private static let allowedDomains = [ "duckduckgo.com" ]
    
    enum SubscriptionRestoreError: Error {
        case failedToRestoreFromEmail,
             subscriptionExpired,
             generalError
    }

    private var cancellables = Set<AnyCancellable>()

    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         accountManager: AccountManager = AccountManager()) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.accountManager = accountManager
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false,
                                                                                                 allowedDomains: Self.allowedDomains,
                                                                                                 contentBlocking: false))
        
        Task {
            await initializeView()
            await setupSubscribers()
        }
        setupObservers()
    }
    
    @MainActor
    func navigateBack() async {
        if state.canNavigateBack {
            await webViewModel.navigationCoordinator.goBack()
        } else {
            state.shouldDismissView = true
        }
    }
    
    func resetDismissalState() {
        state.shouldDismissView = false
    }
    
    func onAppear() {
        Task { await initializeView() }
        webViewModel.navigationCoordinator.navigateTo(url: emailURL )
    }
    
    @MainActor
    private func initializeView() {
        if accountManager.isUserAuthenticated {
            // If user is authenticated, we want to "Add or manage email" instead of activating
            emailURL = accountManager.email == nil ? URL.addEmailToSubscription : URL.manageSubscriptionEmail
            viewTitle = accountManager.email == nil ?  UserText.subscriptionRestoreAddEmailTitle : UserText.subscriptionManageEmailTitle
            
            // Also we assume subscription requires managing, and not activation
            state.managingSubscriptionEmail = true
        }
    }
    
    private func setupSubscribers() async {
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.state.canNavigateBack = false
                if self?.webViewModel.url != URL.activateSubscriptionViaEmail.forComparison() {
                    self?.state.canNavigateBack = value
                }
            }
    }
    
    private func setupObservers() {
        // Feature Callback
        subFeature.onSetSubscription = {
            DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseEmailSuccess)
            UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            DispatchQueue.main.async {
                self.state.subscriptionActive = true
            }
        }
        
        subFeature.onBackToSettings = {
            self.dismissView()
        }
        
        subFeature.onFeatureSelected = { feature in
            DispatchQueue.main.async {
                switch feature {
                case .netP:
                    UniquePixel.fire(pixel: .privacyProWelcomeVPN)
                    self.selectedFeature = .netP
                case .itr:
                    UniquePixel.fire(pixel: .privacyProWelcomePersonalInformationRemoval)
                    self.selectedFeature = .itr
                case .dbp:
                    UniquePixel.fire(pixel: .privacyProWelcomeIdentityRestoration)
                    self.selectedFeature = .dbp
                }
                self.state.shouldDismissStack = true
                
                // Reset shouldDismissStack after dismissal to ensure it can be triggered again
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.state.shouldDismissStack = false
                }
            }
            
        }
          
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
                    strongSelf.state.shouldDisplaynavigationError = error != nil ? true : false
                }
                
            }
            .store(in: &cancellables)
    }
    
    func shouldDisplayBackButton() -> Bool {
        // Hide the back button after activation
        if state.subscriptionActive &&
            (webViewModel.url == URL.subscriptionActivateSuccess.forComparison() ||
             webViewModel.url == URL.subscriptionPurchase.forComparison()) {
            return false
        }
        return true
    }
    
    // MARK: -
    
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        
        case .subscriptionExpired:
            state.transactionError = .subscriptionExpired
        default:
            state.transactionError = .generalError
        }
        state.shouldDisplayInactiveError = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.state.shouldDismissView = true
        }
    }
    
    deinit {
        cancellables.removeAll()
       
    }

}
#endif

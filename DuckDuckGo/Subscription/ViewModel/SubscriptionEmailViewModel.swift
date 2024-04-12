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
    private var urlCancellable: AnyCancellable?
    
    var emailURL = URL.activateSubscriptionViaEmail
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    enum SelectedFeature {
        case netP, dbp, itr, none
    }
    
    struct State {
        var subscriptionEmail: String?
        var managingSubscriptionEmail = false
        var transactionError: SubscriptionRestoreError?
        var shouldDisplaynavigationError: Bool = false
        var isPresentingInactiveError: Bool = false
        var canNavigateBack: Bool = false
        var shouldDismissView: Bool = false
        var subscriptionActive: Bool = false
        var isWelcomePageVisible: Bool = false
        var backButtonTitle: String = UserText.backButtonTitle
        var selectedFeature: SelectedFeature = .none
        var shouldPopToSubscriptionSettings: Bool = false
        var shouldPopToAppSettings: Bool = false
        var viewTitle = UserText.subscriptionActivateEmailTitle
    }
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state = State()
    
    private static let allowedDomains = [ "duckduckgo.com" ]
    
    enum SubscriptionRestoreError: Error {
        case failedToRestoreFromEmail,
             subscriptionExpired,
             generalError
    }

    private var cancellables = Set<AnyCancellable>()
    
    private var isWelcomePageOrSuccessPage: Bool {
        webViewModel.url?.forComparison() == URL.subscriptionActivateSuccess.forComparison() ||
        webViewModel.url?.forComparison() == URL.subscriptionPurchase.forComparison()
    }

    init(userScript: SubscriptionPagesUserScript,
         subFeature: SubscriptionPagesUseSubscriptionFeature,
         accountManager: AccountManager = AccountManager()) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.accountManager = accountManager
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false,
                                                                                                 allowedDomains: Self.allowedDomains,
                                                                                                 contentBlocking: false))
    }
    
    @MainActor
    func navigateBack() async {
        if state.canNavigateBack {
            await webViewModel.navigationCoordinator.goBack()
        } else {
            // If not in the Welcome page, dismiss the view, otherwise, assume we
            // came from Activation, so dismiss the entire stack
            if webViewModel.url?.forComparison() != URL.subscriptionPurchase.forComparison() {
                state.shouldDismissView = true
            } else {
                state.shouldPopToAppSettings = true
            }
        }
    }
    
    func resetDismissalState() {
        state.shouldDismissView = false
    }
    
    @MainActor
    func onFirstAppear() {
        setupWebObservers()
        setupFeatureObservers()
    }
    
    private func cleanUp() {
        canGoBackCancellable?.cancel()
        cancellables.removeAll()
    }
    
    func onAppear() {
        state.shouldDismissView = false
        // If the user is Authenticated & not in the Welcome page
        if accountManager.isUserAuthenticated && !isWelcomePageOrSuccessPage {
            // If user is authenticated, we want to "Add or manage email" instead of activating
            emailURL = accountManager.email == nil ? URL.addEmailToSubscription : URL.manageSubscriptionEmail
            state.viewTitle = accountManager.email == nil ?  UserText.subscriptionRestoreAddEmailTitle : UserText.subscriptionManageEmailTitle
            
            // Also we assume subscription requires managing, and not activation
            state.managingSubscriptionEmail = true
        }
        // Load the Email Management URL unless the user has activated a subscription or is on the welcome page
        if !isWelcomePageOrSuccessPage {
            self.webViewModel.navigationCoordinator.navigateTo(url: self.emailURL)
        }
    }
    
    private func setupFeatureObservers() {
        
        // Feature Callback
        subFeature.onSetSubscription = {
            DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseEmailSuccess)
            UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            DispatchQueue.main.async {
                self.state.subscriptionActive = true
            }
            self.dismissStack()
        }
        
        subFeature.onBackToSettings = {
            self.dismissStack()
        }
        
        subFeature.onFeatureSelected = { feature in
            DispatchQueue.main.async {
                switch feature {
                case .netP:
                    UniquePixel.fire(pixel: .privacyProWelcomeVPN)
                    self.state.selectedFeature = .netP
                case .itr:
                    UniquePixel.fire(pixel: .privacyProWelcomePersonalInformationRemoval)
                    self.state.selectedFeature = .itr
                case .dbp:
                    UniquePixel.fire(pixel: .privacyProWelcomeIdentityRestoration)
                    self.state.selectedFeature = .dbp
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
    }
        
    private func setupWebObservers() {
        
        // Webview navigation
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.updateBackButton(canNavigateBack: value)
            }
        
        // Webview navigation
        urlCancellable = webViewModel.$url
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.isWelcomePageOrSuccessPage ?? false {
                    self?.state.viewTitle = UserText.subscriptionTitle
                }
            }
        
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
    
    private func updateBackButton(canNavigateBack: Bool) {
        
        // If the view is not Activation Success, or Welcome page, allow WebView Back Navigation
        if !isWelcomePageOrSuccessPage {
            self.state.canNavigateBack = canNavigateBack
            self.state.backButtonTitle = UserText.backButtonTitle
        } else {
            self.state.canNavigateBack = false
            self.state.backButtonTitle = UserText.settingsTitle
        }
        
        
    }
    
    // MARK: -
    
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        
        case .subscriptionExpired:
            state.transactionError = .subscriptionExpired
        default:
            state.transactionError = .generalError
        }
        state.isPresentingInactiveError = true
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.state.shouldDismissView = true
        }
    }
    
    func dismissStack() {
        DispatchQueue.main.async {
            self.state.shouldPopToSubscriptionSettings = true
        }
    }
    
    deinit {
        cleanUp()
        canGoBackCancellable = nil
        
    }

}
#endif

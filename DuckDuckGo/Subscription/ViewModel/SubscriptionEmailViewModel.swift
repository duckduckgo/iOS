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

final class SubscriptionEmailViewModel: ObservableObject {
    
    private let subscriptionManager: SubscriptionManager
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    
    private var canGoBackCancellable: AnyCancellable?
    private var urlCancellable: AnyCancellable?
    
    private var emailURL: URL
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
    var accountManager: AccountManager { subscriptionManager.accountManager }

    private var isWelcomePageOrSuccessPage: Bool {
        let subscriptionActivateSuccessURL = subscriptionManager.url(for: .activateSuccess)
        let subscriptionPurchaseURL = subscriptionManager.url(for: .purchase)
        return webViewModel.url?.forComparison() == subscriptionActivateSuccessURL.forComparison() ||
        webViewModel.url?.forComparison() == subscriptionPurchaseURL.forComparison()
    }

    private var isVerifySubscriptionPage: Bool {
        let confirmSubscriptionURL = subscriptionManager.url(for: .baseURL).appendingPathComponent("confirm")
        return webViewModel.url?.forComparison() == confirmSubscriptionURL.forComparison()
    }

    init(userScript: SubscriptionPagesUserScript,
         subFeature: SubscriptionPagesUseSubscriptionFeature,
         subscriptionManager: SubscriptionManager) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.subscriptionManager = subscriptionManager
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false,
                                                                                                 allowedDomains: Self.allowedDomains,
                                                                                                 contentBlocking: false))
        self.emailURL = subscriptionManager.url(for: .activateViaEmail)
    }
    
    @MainActor
    func navigateBack() async {
        if state.canNavigateBack {
            await webViewModel.navigationCoordinator.goBack()
        } else {
            // If not in the Welcome page, dismiss the view, otherwise, assume we
            // came from Activation, so dismiss the entire stack
            let subscriptionPurchaseURL = subscriptionManager.url(for: .purchase)
            if webViewModel.url?.forComparison() != subscriptionPurchaseURL.forComparison() {
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
            let addEmailToSubscriptionURL = subscriptionManager.url(for: .addEmail)
            let manageSubscriptionEmailURL = subscriptionManager.url(for: .manageEmail)
            emailURL = accountManager.email == nil ? addEmailToSubscriptionURL : manageSubscriptionEmailURL
            state.viewTitle = accountManager.email == nil ?  UserText.subscriptionRestoreAddEmailTitle : UserText.subscriptionEditEmailTitle
            
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
            DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseEmailSuccess,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
            UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            DispatchQueue.main.async {
                self.state.subscriptionActive = true
            }
        }
        
        subFeature.onBackToSettings = {
            if self.state.managingSubscriptionEmail {
                self.backToSubscriptionSettings()
            } else {
                self.backToAppSettings()
            }
        }
        
        subFeature.onFeatureSelected = { feature in
            DispatchQueue.main.async {
                switch feature {
                case .networkProtection:
                    UniquePixel.fire(pixel: .privacyProWelcomeVPN)
                    self.state.selectedFeature = .netP
                case .dataBrokerProtection:
                    UniquePixel.fire(pixel: .privacyProWelcomePersonalInformationRemoval)
                    self.state.selectedFeature = .itr
                case .identityTheftRestoration, .identityTheftRestorationGlobal:
                    UniquePixel.fire(pixel: .privacyProWelcomeIdentityRestoration)
                    self.state.selectedFeature = .dbp
                case .unknown:
                    break
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
        if !isWelcomePageOrSuccessPage && !isVerifySubscriptionPage {
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
    
    func backToSubscriptionSettings() {
        DispatchQueue.main.async {
            self.state.shouldPopToSubscriptionSettings = true
        }
    }
    
    func backToAppSettings() {
        DispatchQueue.main.async {
            self.state.shouldPopToAppSettings = true
        }
    }
    
    deinit {
        cleanUp()
        canGoBackCancellable = nil
        
    }

}

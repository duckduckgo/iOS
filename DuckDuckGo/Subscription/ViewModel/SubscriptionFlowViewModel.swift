//
//  SubscriptionFlowViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
final class SubscriptionFlowViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    let viewTitle = UserText.settingsPProSection
    var purchaseURL = URL.subscriptionPurchase
    
    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?
    
    enum Constants {
        static let navigationBarHideThreshold = 80.0
    }
    
    
    struct State {
        var hasActiveSubscription = false
        var transactionStatus: SubscriptionTransactionStatus = .idle
        var userTappedRestoreButton = false
        var activateSubscriptionOnLoad: Bool = false
        var shouldDismissView = false
        var shouldShowNavigationBar: Bool = false
        var canNavigateBack: Bool = false
        var transactionError: SubscriptionPurchaseError?
    }

    // Publish the currently selected feature
    @Published var selectedFeature: SettingsViewModel.SettingsDeepLinkSection?
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state = State()

    private static let allowedDomains = [ "duckduckgo.com" ]
    
    private var webViewSettings =  AsyncHeadlessWebViewSettings(bounces: false,
                                                                allowedDomains: allowedDomains,
                                                                contentBlocking: false)
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         selectedFeature: SettingsViewModel.SettingsDeepLinkSection? = nil) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
        self.selectedFeature = selectedFeature
        self.webViewModel = AsyncHeadlessWebViewViewModel(userScript: userScript,
                                                          subFeature: subFeature,
                                                          settings: webViewSettings)
    }
    
    // Observe transaction status
    private func setupTransactionObserver() async {
        
        subFeature.$transactionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let strongSelf = self else { return }
                Task {
                    await strongSelf.setTransactionStatus(status)
                }
            }
            .store(in: &cancellables)
        
        
        subFeature.onBackToSettings = {
            self.webViewModel.navigationCoordinator.navigateTo(url: URL.subscriptionPurchase)
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
                 self.state.shouldDismissView = true
             }
         }
        
        subFeature.$transactionError
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                if let value {
                    Task { await strongSelf.handleTransactionError(error: value) }
                }
            }
        .store(in: &cancellables)
       
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    @MainActor
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {

        var isStoreError = false
        var isBackendError = false

        switch error {
        case .purchaseFailed:
            isStoreError = true
            state.transactionError = .purchaseFailed
        case .missingEntitlements:
            isBackendError = true
            state.transactionError = .missingEntitlements
        case .failedToGetSubscriptionOptions:
            isStoreError = true
            state.transactionError = .failedToGetSubscriptionOptions
        case .failedToSetSubscription:
            isBackendError = true
            state.transactionError = .failedToSetSubscription
        case .failedToRestoreFromEmail, .failedToRestoreFromEmailSubscriptionInactive:
            isBackendError = true
            state.transactionError = .generalError
        case .failedToRestorePastPurchase:
            isStoreError = true
            state.transactionError = .failedToRestorePastPurchase
        case .subscriptionNotFound:
            isStoreError = true
            state.transactionError = .generalError
        case .subscriptionExpired:
            isStoreError = true
            state.transactionError = .subscriptionExpired
        case .hasActiveSubscription:
            isStoreError = true
            isBackendError = true
            state.transactionError = .hasActiveSubscription
        case .cancelledByUser:
            state.transactionError = nil
        case .accountCreationFailed:
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseFailureAccountNotCreated)
            state.transactionError = .generalError
        default:
            state.transactionError = .generalError
        }

        if isStoreError {
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseFailureStoreError)
        }

        if isBackendError {
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseFailureBackendError)
        }

        if state.transactionError != .hasActiveSubscription &&
           state.transactionError != .cancelledByUser {
            // The observer of `transactionError` does the same calculation, if the error is anything else than .hasActiveSubscription then shows a "Something went wrong" alert
            DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseFailure)
        }
    }
    
    private func setupWebViewObservers() async {
        webViewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.state.shouldShowNavigationBar = value.y > Constants.navigationBarHideThreshold
                }
            }
            .store(in: &cancellables)
        
        webViewModel.$navigationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.state.transactionError = error != nil ? .generalError : nil
                }
                
            }
            .store(in: &cancellables)
        
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.state.canNavigateBack = false
                guard let currentURL = self?.webViewModel.url else { return }
                if strongSelf.backButtonForURL(currentURL: currentURL) {
                    DispatchQueue.main.async {
                        strongSelf.state.canNavigateBack = value
                    }
                }
            }
    }
    
    private func backButtonForURL(currentURL: URL) -> Bool {
        return currentURL != URL.subscriptionBaseURL.forComparison() &&
            currentURL != URL.subscriptionActivateSuccess.forComparison() &&
            currentURL != URL.subscriptionPurchase.forComparison()
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        self.state.transactionStatus = status
    }
        
    @MainActor
    private func backButtonEnabled(_ enabled: Bool) {
        state.canNavigateBack = enabled
    }
    
    func initializeViewData() async {
        Pixel.fire(pixel: .privacyProOfferScreenImpression, debounce: 2)
        await self.setupTransactionObserver()
        await self .setupWebViewObservers()
        DispatchQueue.main.async {
            self.webViewModel.navigationCoordinator.navigateTo(url: self.purchaseURL )
            self.selectedFeature = nil
            self.state.shouldDismissView = false
        }
    }
    
    @MainActor
    func finalizeSubscriptionFlow() {
        self.state.shouldDismissView = true
    }
    
    deinit {
        canGoBackCancellable?.cancel()
        selectedFeature = nil
        subFeature.cleanup()
        cancellables.removeAll()
    }

    @MainActor
    func restoreAppstoreTransaction() {
        clearTransactionError()
        Task {
            do {
                try await subFeature.restoreAccountFromAppStorePurchase()
                backButtonEnabled(false)
                await webViewModel.navigationCoordinator.reload()
                backButtonEnabled(true)
            } catch let error {
                if let specificError = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError {
                    handleTransactionError(error: specificError)
                }
            }
        }
    }
    
    @MainActor
    func navigateBack() async {
        await webViewModel.navigationCoordinator.goBack()
    }
    
    @MainActor
    func clearTransactionError() {
        state.transactionError = nil
    }
       
}
#endif

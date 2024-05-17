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
import Subscription

@available(iOS 15.0, *)
// swiftlint:disable type_body_length
final class SubscriptionFlowViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    var webViewModel: AsyncHeadlessWebViewViewModel
    let purchaseURL: URL

    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?
    private var urlCancellable: AnyCancellable?
    private var transactionStatusTimer: Timer?
    
    enum Constants {
        static let navigationBarHideThreshold = 80.0
    }
    
    enum SelectedFeature {
        case netP, dbp, itr, none
    }
        
    struct State {
        var hasActiveSubscription = false
        var transactionStatus: SubscriptionTransactionStatus = .idle
        var userTappedRestoreButton = false
        var shouldActivateSubscription = false
        var canNavigateBack: Bool = false
        var transactionError: SubscriptionPurchaseError?
        var shouldHideBackButton = false
        var selectedFeature: SelectedFeature = .none
        var viewTitle: String = UserText.subscriptionTitle
        var shouldGoBackToSettings: Bool = false
    }
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state = State()

    private static let allowedDomains = [ "duckduckgo.com" ]
    
    private var webViewSettings =  AsyncHeadlessWebViewSettings(bounces: false,
                                                                allowedDomains: allowedDomains,
                                                                contentBlocking: false)
        
    init(origin: String?,
         userScript: SubscriptionPagesUserScript,
         subFeature: SubscriptionPagesUseSubscriptionFeature,
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         selectedFeature: SettingsViewModel.SettingsDeepLinkSection? = nil) {
        if let origin {
            purchaseURL = URL.subscriptionPurchase.appendingParameter(name: AttributionParameter.origin, value: origin)
        } else {
            purchaseURL = URL.subscriptionPurchase
        }
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
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
            self.state.shouldGoBackToSettings = true
        }
        
        subFeature.onActivateSubscription = {
            DispatchQueue.main.async {
                self.state.shouldActivateSubscription = true
                self.setTransactionStatus(.idle)
            }
        }
        
         subFeature.onFeatureSelected = { feature in
             DispatchQueue.main.async {
                 switch feature {
                 case .netP:
                     UniquePixel.fire(pixel: .privacyProWelcomeVPN)
                     self.state.selectedFeature = .netP
                 case .dbp:
                     UniquePixel.fire(pixel: .privacyProWelcomePersonalInformationRemoval)
                     self.state.selectedFeature = .dbp
                 case .itr:
                     UniquePixel.fire(pixel: .privacyProWelcomeIdentityRestoration)
                     self.state.selectedFeature = .itr
                 }
             }
         }
        
        subFeature.$transactionError
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                Task { await strongSelf.setTransactionStatus(.idle) }
                if let value {
                    Task { await strongSelf.handleTransactionError(error: value) }
                }
            }
        .store(in: &cancellables)
       
    }
    
    // swiftlint:disable cyclomatic_complexity
    @MainActor
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {

        var isStoreError = false
        var isBackendError = false

        // Reset the transaction Status
        self.setTransactionStatus(.idle)
        
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
    // swiftlint:enable cyclomatic_complexity
    
    private func setupWebViewObservers() async {
        webViewModel.$navigationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.state.transactionError = error != nil ? .generalError : nil
                    strongSelf.setTransactionStatus(.idle)
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
        
        urlCancellable = webViewModel.$url
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.state.canNavigateBack = false
                guard let currentURL = self?.webViewModel.url else { return }
                Task { await strongSelf.setTransactionStatus(.idle) }
                if currentURL.forComparison() == URL.addEmailToSubscription.forComparison() ||
                    currentURL.forComparison() == URL.addEmailToSubscriptionSuccess.forComparison() ||
                    currentURL.forComparison() == URL.addEmailToSubscriptionSuccess.forComparison() {
                    strongSelf.state.viewTitle = UserText.subscriptionRestoreAddEmailTitle
                } else {
                    strongSelf.state.viewTitle = UserText.subscriptionTitle
                }
            }
        
    }
    
    private func backButtonForURL(currentURL: URL) -> Bool {
        return currentURL.forComparison() != URL.subscriptionBaseURL.forComparison() &&
        currentURL.forComparison() != URL.subscriptionActivateSuccess.forComparison() &&
        currentURL.forComparison() != URL.subscriptionPurchase.forComparison()
    }
    
    private func cleanUp() {
        transactionStatusTimer?.invalidate()
        canGoBackCancellable?.cancel()
        urlCancellable?.cancel()
        cancellables.removeAll()
    }

    @MainActor
    func resetState() {
        self.setTransactionStatus(.idle)
        self.state = State()
    }
    
    deinit {
        cleanUp()
        transactionStatusTimer = nil
        canGoBackCancellable = nil
        urlCancellable = nil
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        self.state.transactionStatus = status
        
        // Invalidate existing timer if any
        transactionStatusTimer?.invalidate()
        
        if status != .idle {
            // Schedule a new timer
            transactionStatusTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.transactionStatusTimer?.invalidate()
                strongSelf.transactionStatusTimer = nil
            }
        }
    }
        
    @MainActor
    private func backButtonEnabled(_ enabled: Bool) {
        state.canNavigateBack = enabled
    }

    // MARK: -
    
    func onAppear() {
        self.state.selectedFeature = .none
        self.state.shouldGoBackToSettings = false
    }
    
    func onFirstAppear() async {
        DispatchQueue.main.async {
            self.resetState()
        }
        if webViewModel.url != URL.subscriptionPurchase.forComparison() {
            self.webViewModel.navigationCoordinator.navigateTo(url: self.purchaseURL)
        }
        await self.setupTransactionObserver()
        await self.setupWebViewObservers()
        Pixel.fire(pixel: .privacyProOfferScreenImpression)
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
// swiftlint:enable type_body_length

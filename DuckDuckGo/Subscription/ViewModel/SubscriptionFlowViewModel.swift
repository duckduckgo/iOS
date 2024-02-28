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
    let viewTitle = UserText.settingsPProSection
    var webViewModel: AsyncHeadlessWebViewViewModel
    
    enum Constants {
        static let navigationBarHideThreshold = 80.0
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var canGoBackCancellable: AnyCancellable?
    
    // State variables
    var purchaseURL = URL.subscriptionPurchase
    
    enum FeatureName {
        static let netP = "vpn"
        static let itr = "identity-theft-restoration"
        static let dbp = "personal-information-removal"
    }
    
    enum SubscriptionPurchaseError: Error {
        case purchaseFailed,
             missingEntitlements,
             failedToGetSubscriptionOptions,
             failedToSetSubscription,
             failedToRestorePastPurchase,
             subscriptionExpired,
             hasActiveSubscription,
             cancelledByUser,
             generalError
    }

    // Published properties
    @Published var hasActiveSubscription = false
    @Published var transactionStatus: SubscriptionTransactionStatus = .idle
    @Published var userTappedRestoreButton = false
    @Published var activateSubscriptionOnLoad: Bool = false
    @Published var shouldDismissView = false
    @Published var shouldShowNavigationBar: Bool = false
    @Published var selectedFeature: SettingsViewModel.SettingsSection?
    @Published var canNavigateBack: Bool = false
    @Published var transactionError: SubscriptionPurchaseError?

    private static let allowedDomains = [
        "duckduckgo.com",
        "microsoftonline.com",
        "duosecurity.com",
    ]
    
    private var webViewSettings =  AsyncHeadlessWebViewSettings(bounces: false,
                                                                allowedDomains: allowedDomains,
                                                                contentBlocking: false)
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         selectedFeature: SettingsViewModel.SettingsSection? = nil) {
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
                
        subFeature.$activateSubscription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.userTappedRestoreButton = true
                }
            }
            .store(in: &cancellables)
        
        subFeature.$selectedFeature
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value != nil {
                    switch value?.feature {
                    case FeatureName.netP:
                        self?.selectedFeature = .netP
                    case FeatureName.itr:
                        self?.selectedFeature = .itr
                    case FeatureName.dbp:
                        self?.selectedFeature = .dbp
                    default:
                        break
                    }
                    self?.finalizeSubscriptionFlow()
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
       
    }
    
    private func handleTransactionError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        
        case .purchaseFailed:
            transactionError = .purchaseFailed
        case .missingEntitlements:
            transactionError = .missingEntitlements
        case .failedToGetSubscriptionOptions:
            transactionError = .failedToGetSubscriptionOptions
        case .failedToSetSubscription:
            transactionError = .failedToSetSubscription
        case .failedToRestorePastPurchase:
            transactionError = .failedToRestorePastPurchase
        case .subscriptionExpired:
            transactionError = .subscriptionExpired
        case .hasActiveSubscription:
            transactionError = .hasActiveSubscription
        case .cancelledByUser:
            transactionError = nil
        default:
            transactionError = .generalError
        }
    }
    
    private func setupWebViewObservers() async {
        webViewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.shouldShowNavigationBar = value.y > Constants.navigationBarHideThreshold
                }
            }
            .store(in: &cancellables)
        
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canNavigateBack = value
            }
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        self.transactionStatus = status
    }
        
    @MainActor
    private func disableGoBack() {
        canGoBackCancellable?.cancel()
        canNavigateBack = false
    }
    
    func initializeViewData() async {
        await self.setupTransactionObserver()
        await self .setupWebViewObservers()
        await self.updateSubscriptionStatus()
        webViewModel.navigationCoordinator.navigateTo(url: purchaseURL )
    }
    
    func finalizeSubscriptionFlow() {
        canGoBackCancellable?.cancel()
        subFeature.selectedFeature = nil
        hasActiveSubscription = false
        transactionStatus = .idle
        userTappedRestoreButton = false
        shouldShowNavigationBar = false
        selectedFeature = nil
        canNavigateBack = false
        shouldDismissView = true
        subFeature.cleanup()
    }
    
    deinit {
        cancellables.removeAll()
    }

    @MainActor
    func restoreAppstoreTransaction() {
        transactionError = nil
        Task {
            do {
                try await subFeature.restoreAccountFromAppStorePurchase()
                disableGoBack()
                await webViewModel.navigationCoordinator.reload()
            } catch let error {
                if let specificError = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError {
                    handleTransactionError(error: specificError)
                }
            }
        }
    }
    
    func updateSubscriptionStatus() async {
        if AccountManager().isUserAuthenticated && hasActiveSubscription == false {
            await disableGoBack()
            await webViewModel.navigationCoordinator.reload()
        }
    }
    
    @MainActor
    func navigateBack() async {
        await webViewModel.navigationCoordinator.goBack()
    }
    
}
#endif

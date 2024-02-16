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
    
    enum Constants {
        static let navigationBarHideThreshold = 40.0
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

    // Published properties
    @Published var hasActiveSubscription = false
    @Published var transactionStatus: SubscriptionPagesUseSubscriptionFeature.TransactionStatus = .idle
    @Published var activatingSubscription = false
    @Published var shouldDismissView = false
    @Published var webViewModel: AsyncHeadlessWebViewViewModel
    @Published var shouldShowNavigationBar: Bool = false
    @Published var selectedFeature: SettingsViewModel.SettingsSection?
    @Published var canNavigateBack: Bool = false
    
    private var allowedDomains = [
        "duckduckgo.com",
        "microsoftonline.com",
        "duosecurity.com",
    ]
        
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
                                                          settings: AsyncHeadlessWebViewSettings(bounces: false,
                                                                                                 allowedDomains: allowedDomains, contentBlocking: false))
    }
    
    // Observe transaction status
    private func setupTransactionObserver() async {
        
        subFeature.$transactionStatus
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { await self.setTransactionStatus(status) }

            }
            .store(in: &cancellables)
        
        subFeature.$hasActiveSubscription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.hasActiveSubscription = value
            }
            .store(in: &cancellables)
        
        subFeature.$activateSubscription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if value {
                    self?.subFeature.activateSubscription = false
                    self?.activatingSubscription = true
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
        
        webViewModel.$scrollPosition
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.shouldShowNavigationBar = value.y > Constants.navigationBarHideThreshold
            }
            .store(in: &cancellables)
        
        canGoBackCancellable = webViewModel.$canGoBack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.canNavigateBack = value
            }
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionPagesUseSubscriptionFeature.TransactionStatus) {
        self.transactionStatus = status
    }
        
    @MainActor
    private func disableGoBack() {
        canGoBackCancellable?.cancel()
        canNavigateBack = false
    }
    
    func initializeViewData() async {
        await self.setupTransactionObserver()
        await self.updateSubscriptionStatus()
        webViewModel.navigationCoordinator.navigateTo(url: purchaseURL )
    }
    
    func finalizeSubscriptionFlow() {
        canGoBackCancellable?.cancel()
        cancellables.removeAll()
        subFeature.selectedFeature = nil
        hasActiveSubscription = false
        transactionStatus = .idle
        activatingSubscription = false
        shouldShowNavigationBar = false
        selectedFeature = nil
        canNavigateBack = false
        shouldDismissView = true
    }

    func restoreAppstoreTransaction() {
        Task {
            if await subFeature.restoreAccountFromAppStorePurchase() {
                await disableGoBack()
                await webViewModel.navigationCoordinator.reload()
            } else {
                await MainActor.run {
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

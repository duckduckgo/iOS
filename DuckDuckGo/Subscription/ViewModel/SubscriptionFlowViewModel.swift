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
@available(iOS 15.0, *)
final class SubscriptionFlowViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    
    let viewTitle = UserText.settingsPProSection
    
    private var cancellables = Set<AnyCancellable>()
    
    // State variables
    var purchaseURL = URL.purchaseSubscription
    
    // Closure passed to navigate to a specific section
    // after returning to settings
    var onFeatureSelected: ((SettingsViewModel.SettingsSection) -> Void)
    
    enum FeatureName {
        static let netP = "vpn"
        static let itp = "identity-theft-restoration"
        static let dbp = "personal-information-removal"
    }
    
    
    // Published properties
    @Published var hasActiveSubscription = false
    @Published var transactionStatus: SubscriptionPagesUseSubscriptionFeature.TransactionStatus = .idle
    @Published var shouldReloadWebView = false
    @Published var activatingSubscription = false
    @Published var shouldDismissView = false
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         onFeatureSelected: @escaping ((SettingsViewModel.SettingsSection) -> Void)) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
        self.onFeatureSelected = onFeatureSelected
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
                    self?.shouldDismissView = true
                    switch value?.feature {
                    case FeatureName.netP:
                        self?.onFeatureSelected(.netP)
                    case FeatureName.itp:
                        self?.onFeatureSelected(.itp)
                    case FeatureName.dbp:
                        self?.onFeatureSelected(.dbp)
                    default:
                        return
                    }
                }
            }
            .store(in: &cancellables)
  
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionPagesUseSubscriptionFeature.TransactionStatus) {
        self.transactionStatus = status
    }
    
    private func getFeatureName(feature: String) -> SettingsViewModel.SettingsSection {
        switch feature {
        case "vpn":
            return .netP
        case "identity-theft-protection":
            return .itp
        case "data-broker-protection":
            return .dbp
        default:
            return .none
        }
    }
    
    func initializeViewData() async {
        await self.setupTransactionObserver()
        await MainActor.run { shouldReloadWebView = true }
    }
    
    func restoreAppstoreTransaction() {
        Task {
            if await subFeature.restoreAccountFromAppStorePurchase() {
                await MainActor.run { shouldReloadWebView = true }
            } else {
                await MainActor.run {
                }
            }
        }
    }
    
}
#endif

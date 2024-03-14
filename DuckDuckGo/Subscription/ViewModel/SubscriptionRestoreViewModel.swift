//
//  SubscriptionRestoreViewModel.swift
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
final class SubscriptionRestoreViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    let accountManager: AccountManager
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SubscriptionActivationResult {
        case unknown, activated, expired, notFound, error
    }
    
    struct State {
        var isAddingDevice: Bool = false
        var transactionStatus: SubscriptionTransactionStatus = .idle
        var activationResult: SubscriptionActivationResult = .unknown
        var subscriptionEmail: String?
        var shouldNavigateToSubscriptionFlow = false
        var shouldNavigateToActivationFlow = false
        var shouldDismissView = false
    }
    
    // Publish the currently selected feature
    @Published var selectedFeature: SettingsViewModel.SettingsSection?
    
    // Read only View State - Should only be modified from the VM
    @Published private(set) var state = State()
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         accountManager: AccountManager = AccountManager(),
         isAddingDevice: Bool = false) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
        self.accountManager = accountManager
        self.state.isAddingDevice = false
    }
    
    func initializeView() {
        Pixel.fire(pixel: .privacyProSettingsAddDevice)
        Task { await setupTransactionObserver() }
        refreshState()
    }
    
    func refreshState() {
        state.subscriptionEmail = accountManager.email
        if accountManager.isUserAuthenticated {
            state.isAddingDevice = true
        }
        state.shouldNavigateToActivationFlow = false
    }
    
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
        
    }
    
    @MainActor
    private func handleRestoreError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        case .failedToRestorePastPurchase:
            state.activationResult = .error
        case .subscriptionExpired:
            state.activationResult = .expired
        case .subscriptionNotFound:
            state.activationResult = .notFound
        default:
            state.activationResult = .error
        }

        if state.activationResult == .notFound {
            DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseStoreFailureNotFound)
        } else {
            DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseStoreFailureOther)
        }
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        self.state.transactionStatus = status
    }
    
    @MainActor
    func restoreAppstoreTransaction() {
        DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseStoreStart)
        Task {
            state.activationResult = .unknown
            do {
                try await subFeature.restoreAccountFromAppStorePurchase()
                DailyPixel.fireDailyAndCount(pixel: .privacyProRestorePurchaseStoreSuccess)
                state.activationResult = .activated
                showSubscriptionFlow(true)
            } catch let error {
                if let specificError = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError {
                    handleRestoreError(error: specificError)
                }
            }
        }
    }
    
    @MainActor
    func showActivationFlow(_ visible: Bool) {
        self.state.shouldNavigateToActivationFlow = visible
    }
    
    @MainActor
    func showSubscriptionFlow(_ visible: Bool) {
        self.state.shouldNavigateToSubscriptionFlow = visible
    }
    
    @MainActor
    func dismissView() {
        state.shouldDismissView = true
    }
    
    
}
#endif

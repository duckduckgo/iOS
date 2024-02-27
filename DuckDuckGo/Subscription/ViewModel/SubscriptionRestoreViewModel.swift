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
    var isAddingDevice: Bool
    private var cancellables = Set<AnyCancellable>()
    
    enum SubscriptionActivationResult {
        case unknown, activated, notFound, error
    }
    
    @Published var transactionStatus: SubscriptionTransactionStatus = .idle
    @Published var activationResult: SubscriptionActivationResult = .unknown
    @Published var subscriptionEmail: String?
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared,
         accountManager: AccountManager = AccountManager(),
         isAddingDevice: Bool = false) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
        self.accountManager = accountManager
        self.isAddingDevice = isAddingDevice
        initializeView()
    }
    
    func initializeView() {
        subscriptionEmail = accountManager.email
        if accountManager.isUserAuthenticated {
            isAddingDevice = true
        }
        Task { await setupTransactionObserver() }
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
        
        subFeature.$transactionError
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] value in
                guard let strongSelf = self, let error = value else { return }
                
                Task { @MainActor in
                    strongSelf.handleRestoreError(error: error)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func handleRestoreError(error: SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError) {
        switch error {
        case .failedToRestorePastPurchase:
            activationResult = .error
        case .subscriptionExpired:
            activationResult = .notFound
        default:
            activationResult = .error
        }
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionTransactionStatus) {
        self.transactionStatus = status
    }
    
    @MainActor
    func restoreAppstoreTransaction() {
        Task {
            activationResult = .unknown
            do {
                try await subFeature.restoreAccountFromAppStorePurchase()
                activationResult = .activated
            }
        }
    }
    
    
}
#endif

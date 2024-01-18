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
@available(iOS 15.0, *)
final class SubscriptionRestoreViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    
    enum SubscriptionActivationResult {
        case unknown, activated, notFound, error
    }
    
    @Published var transactionStatus: SubscriptionPagesUseSubscriptionFeature.TransactionStatus = .idle
    @Published var activationResult: SubscriptionActivationResult = .unknown
        
    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
    }
    
    @MainActor
    private func setTransactionStatus(_ status: SubscriptionPagesUseSubscriptionFeature.TransactionStatus) {
        self.transactionStatus = status
    }
    
    @MainActor
    func restoreAppstoreTransaction() {
        Task {
            transactionStatus = .restoring
            activationResult = .unknown
            if await subFeature.restoreAccountFromAppStorePurchase() {
                activationResult = .activated
            } else {
                activationResult = .notFound
            }
            transactionStatus = .idle
        }
    }
    
}
#endif

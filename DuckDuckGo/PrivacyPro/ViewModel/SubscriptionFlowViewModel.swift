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

#if SUBSCRIPTION
@available(iOS 15.0, *)
final class SubscriptionFlowViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: SubscriptionPagesUseSubscriptionFeature
    let purchaseManager: PurchaseManager
    
    let purchaseURL = URL.purchaseSubscription
    let viewTitle = UserText.settingsPProSection
        
    @Published var transactionInProgress = false
    private var cancellables = Set<AnyCancellable>()

    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: SubscriptionPagesUseSubscriptionFeature = SubscriptionPagesUseSubscriptionFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
    }
    
    // Observe transaction status
    private func setupTransactionObserver() async {
        subFeature.$transactionInProgress
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { await self.setTransactionInProgress(status) }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func setTransactionInProgress(_ inProgress: Bool) {
        self.transactionInProgress = inProgress
    }
    
    func initializeViewData() async {
        await self.setupTransactionObserver()
    }
    
}
#endif

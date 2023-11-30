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

class SubscriptionFlowViewModel: ObservableObject {
    
    let userScript: SubscriptionPagesUserScript
    let subFeature: Subfeature
    let purchaseURL = URL.purchaseSubscription
    let viewTitle = SubscriptionUserText.navigationTitle
    let purchaseManager = PurchaseManager.shared
    
    @Published var isLoadingProducts = true
    private var cancellables = Set<AnyCancellable>()

    init(userScript: SubscriptionPagesUserScript = SubscriptionPagesUserScript(),
         subFeature: Subfeature = SubscriptionPagesUseSubscriptionFeature()) {
        self.userScript = userScript
        self.subFeature = subFeature
        Task { await setupProductObserver() }
    }
    
    // Fetch available Products from the AppStore
    private func setupProductObserver() async {
        purchaseManager.$availableProducts
            .dropFirst()
            .sink { [weak self] products in
                guard let self = self else { return }
                if !products.isEmpty {
                    Task { await self.setProductsLoading(false) }
                } else {
                    assertionFailure("Could not load products from the App Store")
                }
            }
            .store(in: &cancellables)
        await purchaseManager.updateAvailableProducts()
    }
    
    @MainActor
    private func setProductsLoading(_ isLoading: Bool) {
        self.isLoadingProducts = isLoading
    }
}

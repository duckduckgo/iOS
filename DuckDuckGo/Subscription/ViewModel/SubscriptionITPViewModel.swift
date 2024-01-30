//
//  SubscriptionITPViewModel.swift
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
final class SubscriptionITPViewModel: ObservableObject {
    
    let userScript: IdentityTheftRestorationPagesUserScript
    let subFeature: IdentityTheftRestorationPagesFeature
    let purchaseManager: PurchaseManager
    let viewTitle = UserText.settingsPProSection
    private var cancellables = Set<AnyCancellable>()
    
    // State variables
    var itpURL = URL.manageITP
    @Published var shouldReloadWebView = false
    
    init(userScript: IdentityTheftRestorationPagesUserScript = IdentityTheftRestorationPagesUserScript(),
         subFeature: IdentityTheftRestorationPagesFeature = IdentityTheftRestorationPagesFeature(),
         purchaseManager: PurchaseManager = PurchaseManager.shared) {
        self.userScript = userScript
        self.subFeature = subFeature
        self.purchaseManager = purchaseManager
    }
    
    // Observe transaction status
    private func setupTransactionObserver() async {
        
    }
    
}
#endif

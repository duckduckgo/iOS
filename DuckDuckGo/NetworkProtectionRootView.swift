//
//  NetworkProtectionRootView.swift
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

#if NETWORK_PROTECTION

import SwiftUI
import NetworkProtection
import Subscription

@available(iOS 15, *)
struct NetworkProtectionRootView: View {
    let statusViewModel: NetworkProtectionStatusViewModel

    init() {
        let accountManager = AppDependencyProvider.shared.subscriptionManager.accountManager
        let locationListRepository = NetworkProtectionLocationListCompositeRepository(accountManager: accountManager)
        statusViewModel = NetworkProtectionStatusViewModel(tunnelController: AppDependencyProvider.shared.networkProtectionTunnelController,
                                                           settings: AppDependencyProvider.shared.vpnSettings,
                                                           statusObserver: AppDependencyProvider.shared.connectionObserver,
                                                           locationListRepository: locationListRepository)
    }
    var body: some View {
        if AppDependencyProvider.shared.vpnFeatureVisibility.isPrivacyProLaunched() {
            NetworkProtectionStatusView(
                statusModel: statusViewModel
            )
        }
    }
}

#endif

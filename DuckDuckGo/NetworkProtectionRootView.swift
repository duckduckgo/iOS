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

@available(iOS 15, *)
struct NetworkProtectionRootView: View {
    let model = NetworkProtectionRootViewModel()
    let inviteCompletion: () -> Void

    var body: some View {
        let inviteViewModel = NetworkProtectionInviteViewModel(
            redemptionCoordinator: NetworkProtectionCodeRedemptionCoordinator(),
            completion: inviteCompletion
        )
        switch model.initialViewKind {
        case .invite:
            NetworkProtectionInviteView(model: inviteViewModel)
        case .status:
            NetworkProtectionStatusView(
                statusModel: NetworkProtectionStatusViewModel()
            )
        }
    }
}

#endif

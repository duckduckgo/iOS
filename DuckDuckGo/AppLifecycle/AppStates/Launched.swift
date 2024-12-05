//
//  Launched.swift
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

import UIKit

struct Launched: AppState {

    let appContext: AppContext
    let appDependencies: AppDependencies

    init(appContext: AppContext) {
        self.appContext = appContext
        let accountManager = AppDependencyProvider.shared.accountManager
        let tunnelController = AppDependencyProvider.shared.networkProtectionTunnelController
        let vpnWorkaround = VPNRedditSessionWorkaround(accountManager: accountManager, tunnelController: tunnelController)
        let vpnFeatureVisibility = AppDependencyProvider.shared.vpnFeatureVisibility
        self.appDependencies = AppDependencies(accountManager: accountManager,
                                               vpnWorkaround: vpnWorkaround,
                                               vpnFeatureVisibility: vpnFeatureVisibility)

        // handle application(_:didFinishLaunchingWithOptions:) logic here
    }

}

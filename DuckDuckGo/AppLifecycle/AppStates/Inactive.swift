//
//  Inactive.swift
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

struct Inactive: AppState {

    private let application: UIApplication
    private let appDependencies: AppDependencies

    var urlToOpen: URL?

    init(stateContext: Active.StateContext) {
        application = stateContext.application
        appDependencies = stateContext.appDependencies

        let vpnFeatureVisibility = appDependencies.vpnFeatureVisibility
        let subscriptionManager = appDependencies.subscriptionManager
        let vpnWorkaround = appDependencies.vpnWorkaround
        Task { @MainActor [application] in
            await application.refreshVPNShortcuts(vpnFeatureVisibility: vpnFeatureVisibility,
                                                  subscriptionManager: subscriptionManager)
            await vpnWorkaround.removeRedditSessionWorkaround()
        }
    }

}

extension Inactive {

    struct StateContext {

        let application: UIApplication
        let urlToOpen: URL?
        let appDependencies: AppDependencies

    }

    func makeStateContext() -> StateContext {
        .init(application: application,
              urlToOpen: urlToOpen,
              appDependencies: appDependencies)
    }

}

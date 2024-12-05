//
//  Active.swift
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

struct Active: AppState {

    var appContext: AppContext
    let appDependencies: AppDependencies

    init(appContext: AppContext,
         transitionContext: TransitionContext,
         appDependencies: AppDependencies) {
        self.appContext = appContext
        self.appDependencies = appDependencies

        if transitionContext.sourceState is Background {
            // handle applicationWillEnterForeground(_:) logic here
        }

        if let url = appContext.urlToOpen {
            openURL(url)
        }


        /*
         only once! on sourceState is Launched!
         let privacyConfigurationManager = ContentBlocking.shared.privacyConfigurationManager

         // Enable subscriptionCookieManager if feature flag is present
         if privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(PrivacyProSubfeature.setAccessTokenCookieForSubscriptionDomains) {
             subscriptionCookieManager.enableSettingSubscriptionCookie()
         }

         // Keep track of feature flag changes
         let subscriptionCookieManagerFeatureFlagCancellable = privacyConfigurationManager.updatesPublisher // TODO: should we move it to Active State?
             .receive(on: DispatchQueue.main)
             .sink { /*[weak self, weak privacyConfigurationManager] in */
 //                 guard let self, !self.appIsLaunching, let privacyConfigurationManager else { return } // TODO
 //
 //                let isEnabled = privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(PrivacyProSubfeature.setAccessTokenCookieForSubscriptionDomains)
 //
 //                Task { @MainActor [weak self] in
 //                    if isEnabled {
 //                        self?.subscriptionCookieManager.enableSettingSubscriptionCookie()
 //                    } else {
 //                        await self?.subscriptionCookieManager.disableSettingSubscriptionCookie()
 //                    }
 //                }
             }
         */

        // handle applicationDidBecomeActive(_:) logic here
    }

    private mutating func openURL(_ url: URL) {
        defer {
            appContext.urlToOpen = nil
        }

        // handle application(_:open:options:) logic here
    }

}

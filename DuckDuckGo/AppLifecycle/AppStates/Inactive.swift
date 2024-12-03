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
import Subscription

struct Inactive: AppState {

    let application: UIApplication

    init(application: UIApplication,
         accountManager: AccountManager,
         vpnFeatureVisibility: DefaultNetworkProtectionVisibility,
         vpnWorkaround: VPNRedditSessionWorkaround) {
        self.application = application
        Task { @MainActor in
            await refreshVPNShortcuts()
            await vpnWorkaround.removeRedditSessionWorkaround()
        }
    }

    // TODO: move elsewhere - it is used in launching too
    @MainActor
    func refreshVPNShortcuts() async {
        guard vpnFeatureVisibility.shouldShowVPNShortcut() else {
            application.shortcutItems = nil
            return
        }

        if case .success(true) = await accountManager.hasEntitlement(forProductName: .networkProtection, cachePolicy: .returnCacheDataDontLoad) {
            application.shortcutItems = [
                UIApplicationShortcutItem(type: ShortcutKey.openVPNSettings,
                                          localizedTitle: UserText.netPOpenVPNQuickAction,
                                          localizedSubtitle: nil,
                                          icon: UIApplicationShortcutIcon(templateImageName: "VPN-16"),
                                          userInfo: nil)
            ]
        } else {
            application.shortcutItems = nil
        }
    }

}

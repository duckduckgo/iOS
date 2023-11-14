//
//  NetworkProtectionConvenienceInitialisers.swift
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

import NetworkProtection
import UIKit
import Common

extension ConnectionStatusObserverThroughSession {
    convenience init() {
        self.init(platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension ConnectionErrorObserverThroughSession {
    convenience init() {
        self.init(platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension ConnectionServerInfoObserverThroughSession {
    convenience init() {
        self.init(platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension NetworkProtectionKeychainTokenStore {
    convenience init() {
        self.init(keychainType: .dataProtection(.unspecified),
                  serviceName: "\(Bundle.main.bundleIdentifier!).authToken",
                  errorEvents: .networkProtectionAppDebugEvents)
    }
}

extension NetworkProtectionCodeRedemptionCoordinator {
    convenience init() {
        let tunnelSettings = TunnelSettings(defaults: .networkProtectionGroupDefaults)
        self.init(environment: tunnelSettings.selectedEnvironment, tokenStore: NetworkProtectionKeychainTokenStore(), errorEvents: .networkProtectionAppDebugEvents)
    }
}

extension NetworkProtectionVPNNotificationsViewModel {
    convenience init() {
        let notificationsSettingsStore = NetworkProtectionNotificationsSettingsUserDefaultsStore(userDefaults: .networkProtectionGroupDefaults)
        self.init(
            notificationsAuthorization: NotificationsAuthorizationController(),
            notificationsSettingsStore: notificationsSettingsStore
        )
    }
}

extension NetworkProtectionVPNSettingsViewModel {
    convenience init() {
        self.init(
            tunnelSettings: TunnelSettings(defaults: .networkProtectionGroupDefaults)
        )
    }
}

extension NetworkProtectionVPNLocationViewModel {
    convenience init() {
        let tunnelSettings = TunnelSettings(defaults: .networkProtectionGroupDefaults)
        let locationListRepository = NetworkProtectionLocationListCompositeRepository(
            environment: tunnelSettings.selectedEnvironment,
            tokenStore: NetworkProtectionKeychainTokenStore()
        )
        self.init(
            locationListRepository: locationListRepository,
            tunnelSettings: TunnelSettings(defaults: .networkProtectionGroupDefaults)
        )
    }
}

#endif

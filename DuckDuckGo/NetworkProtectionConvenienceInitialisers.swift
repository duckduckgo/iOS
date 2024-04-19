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
import NetworkExtension
import Subscription


private class DefaultTunnelSessionProvider: TunnelSessionProvider {
    func activeSession() async -> NETunnelProviderSession? {
        try? await ConnectionSessionUtilities.activeSession()
    }
}

extension ConnectionStatusObserverThroughSession {
    convenience init() {
        self.init(tunnelSessionProvider: DefaultTunnelSessionProvider(),
                  platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension ConnectionErrorObserverThroughSession {
    convenience init() {
        self.init(tunnelSessionProvider: DefaultTunnelSessionProvider(),
                  platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension ConnectionServerInfoObserverThroughSession {
    convenience init() {
        self.init(tunnelSessionProvider: DefaultTunnelSessionProvider(),
                  platformNotificationCenter: .default,
                  platformDidWakeNotification: UIApplication.didBecomeActiveNotification)
    }
}

extension NetworkProtectionKeychainTokenStore {
    convenience init() {
        let featureVisibility = DefaultNetworkProtectionVisibility.forTokenStore()
        let isSubscriptionEnabled = featureVisibility.isPrivacyProLaunched()
        let accessTokenProvider: () -> String? = {
        if featureVisibility.shouldMonitorEntitlement() {
            return { AccountManager().accessToken }
        }
        return { nil }
    }()

        self.init(keychainType: .dataProtection(.unspecified),
                  serviceName: "\(Bundle.main.bundleIdentifier!).authToken",
                  errorEvents: .networkProtectionAppDebugEvents,
                  isSubscriptionEnabled: isSubscriptionEnabled,
                  accessTokenProvider: accessTokenProvider)
    }
}

extension NetworkProtectionCodeRedemptionCoordinator {
    convenience init(isManualCodeRedemptionFlow: Bool = false) {
        let settings = VPNSettings(defaults: .networkProtectionGroupDefaults)
        self.init(
            environment: settings.selectedEnvironment,
            tokenStore: NetworkProtectionKeychainTokenStore(),
            isManualCodeRedemptionFlow: isManualCodeRedemptionFlow,
            errorEvents: .networkProtectionAppDebugEvents,
            isSubscriptionEnabled: DefaultNetworkProtectionVisibility().isPrivacyProLaunched()
        )
    }
}

extension NetworkProtectionVPNSettingsViewModel {
    convenience init() {
        self.init(
            notificationsAuthorization: NotificationsAuthorizationController(),
            settings: VPNSettings(defaults: .networkProtectionGroupDefaults)
        )
    }
}

extension NetworkProtectionLocationListCompositeRepository {
    convenience init() {
        let settings = VPNSettings(defaults: .networkProtectionGroupDefaults)
        self.init(
            environment: settings.selectedEnvironment,
            tokenStore: NetworkProtectionKeychainTokenStore(),
            errorEvents: .networkProtectionAppDebugEvents,
            isSubscriptionEnabled: DefaultNetworkProtectionVisibility().isPrivacyProLaunched()
        )
    }
}

extension NetworkProtectionVPNLocationViewModel {
    convenience init() {
        let locationListRepository = NetworkProtectionLocationListCompositeRepository()
        self.init(
            locationListRepository: locationListRepository,
            settings: VPNSettings(defaults: .networkProtectionGroupDefaults)
        )
    }
}

#endif

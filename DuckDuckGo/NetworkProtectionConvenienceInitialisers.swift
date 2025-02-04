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

import NetworkProtection
import UIKit
import Common
import NetworkExtension
import Subscription


private class DefaultTunnelSessionProvider: TunnelSessionProvider {
    func activeSession() async -> NETunnelProviderSession? {
        return await AppDependencyProvider.shared.networkProtectionTunnelController.activeSession()
    }
}

extension ConnectionStatusObserverThroughSession {
    convenience init() {
        self.init(tunnelSessionProvider: DefaultTunnelSessionProvider(),
                  platformSnoozeTimingStore: NetworkProtectionSnoozeTimingStore(userDefaults: .networkProtectionGroupDefaults),
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

extension NetworkProtectionVPNSettingsViewModel {
    convenience init() {
        self.init(
            notificationsAuthorization: NotificationsAuthorizationController(),
            controller: AppDependencyProvider.shared.networkProtectionTunnelController,
            settings: AppDependencyProvider.shared.vpnSettings
        )
    }
}

extension NetworkProtectionLocationListCompositeRepository {
    
    convenience init(accountManager: AccountManager) {
        let settings = AppDependencyProvider.shared.vpnSettings
        self.init(
            environment: settings.selectedEnvironment,
            tokenHandler: AppDependencyProvider.shared.networkProtectionKeychainTokenStore,
            errorEvents: .networkProtectionAppDebugEvents
        )
    }
}

extension NetworkProtectionVPNLocationViewModel {
    
    convenience init(accountManager: AccountManager) {
        let locationListRepository = NetworkProtectionLocationListCompositeRepository(accountManager: accountManager)
        self.init(
            locationListRepository: locationListRepository,
            settings: AppDependencyProvider.shared.vpnSettings
        )
    }
}

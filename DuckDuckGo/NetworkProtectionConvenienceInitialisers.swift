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
        // Error events to be added as part of https://app.asana.com/0/1203137811378537/1205112639044115/f
        self.init(keychainType: .dataProtection(.unspecified), errorEvents: nil)
    }
}

extension NetworkProtectionCodeRedemptionCoordinator {
    private static var errorEvents: EventMapping<NetworkProtectionError> = .init { _, _, _, _ in
    }

    // Error events to be added as part of https://app.asana.com/0/1203137811378537/1205112639044115/f
    convenience init() {
        self.init(tokenStore: NetworkProtectionKeychainTokenStore(), errorEvents: Self.errorEvents)
    }
}

#endif

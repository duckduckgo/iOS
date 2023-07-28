//
//  NetworkProtectionRedemptionCoordinatorTestExtensions.swift
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

import Foundation
import NetworkProtection
import Common

extension NetworkProtectionCodeRedemptionCoordinator {
    private static var errorEvents: EventMapping<NetworkProtectionError> = .init { _, _, _, _ in
    }

    class func stubbed() -> NetworkProtectionCodeRedemptionCoordinator {
        whereRedeemSucceeds()
    }

    class func whereRedeemSucceeds(returning token: String = "") -> NetworkProtectionCodeRedemptionCoordinator {
        let client = MockNetworkProtectionClient()
        client.stubRedeem = .success(token)
        let tokenStore = MockNetworkProtectionTokenStorage()
        return NetworkProtectionCodeRedemptionCoordinator(networkClient: client, tokenStore: tokenStore, errorEvents: errorEvents)
    }

    class func whereRedeemFails(returning error: NetworkProtectionClientError = .failedToEncodeRedeemRequest) -> NetworkProtectionCodeRedemptionCoordinator {
        let client = MockNetworkProtectionClient()
        client.stubRedeem = .failure(error)
        let tokenStore = MockNetworkProtectionTokenStorage()
        return NetworkProtectionCodeRedemptionCoordinator(networkClient: client, tokenStore: tokenStore, errorEvents: errorEvents)
    }
}

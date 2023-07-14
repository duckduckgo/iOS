//
//  NetworkProtectionPacketTunnelProvider.swift
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

// Initial implementation for initial Network Protection tests. Will be fleshed out with https://app.asana.com/0/1203137811378537/1204630829332227/f
final class NetworkProtectionPacketTunnelProvider: PacketTunnelProvider {

    private static var packetTunnelProviderEvents: EventMapping<PacketTunnelProvider.Event> = .init { _, _, _, _ in
    }

    @objc init() {
        super.init(notificationCenter: NotificationCenter.default,
                   notificationsPresenter: DefaultNotificationPresenter(),
                   useSystemKeychain: false,
                   debugEvents: nil,
                   providerEvents: Self.packetTunnelProviderEvents)
    }
}

final class DefaultNotificationPresenter: NetworkProtectionNotificationsPresenter {

    func showTestNotification() {
    }

    func showReconnectedNotification() {
    }

    func showReconnectingNotification() {
    }

    func showConnectionFailureNotification() {
    }

    func showSupersededNotification() {
    }
}

// MARK: - NetworkProtectionNotificationPosting

extension NotificationCenter: NetworkProtectionNotificationPosting {
    public func post(_ networkProtectionNotification: NetworkProtection.NetworkProtectionNotification, object: String?, log: Common.OSLog) {
    }
}

//
//  NetworkProtectionVPNNotificationsViewModel.swift
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

import Combine
import UserNotifications
import NetworkProtection

enum NetworkProtectionNotificationsViewKind: Equatable {
    case loading
    case unauthorized
    case authorized
}

final class NetworkProtectionVPNNotificationsViewModel: ObservableObject {
    private var notificationsAuthorization: NotificationsAuthorizationControlling
    private var settings: VPNSettings
    @Published var viewKind: NetworkProtectionNotificationsViewKind = .loading
    var alertsEnabled: Bool {
        self.settings.notifyStatusChanges
    }

    init(notificationsAuthorization: NotificationsAuthorizationControlling,
         settings: VPNSettings) {
        self.notificationsAuthorization = notificationsAuthorization
        self.settings = settings
        self.notificationsAuthorization.delegate = self
    }

    @MainActor
    func onViewAppeared() async {
        let status = await notificationsAuthorization.authorizationStatus
        updateViewKind(for: status)
    }

    func turnOnNotifications() {
        notificationsAuthorization.requestAlertAuthorization()
    }

    func didToggleAlerts(to enabled: Bool) {
        settings.notifyStatusChanges = enabled
    }

    private func updateViewKind(for authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined, .denied:
            viewKind = .unauthorized
        case .authorized, .ephemeral, .provisional:
            viewKind = .authorized
        @unknown default:
            assertionFailure("Unhandled enum case")
        }
    }
}

extension NetworkProtectionVPNNotificationsViewModel: NotificationsPermissionsControllerDelegate {
    func authorizationStateDidChange(toStatus status: UNAuthorizationStatus) {
        updateViewKind(for: status)
    }
}

#endif

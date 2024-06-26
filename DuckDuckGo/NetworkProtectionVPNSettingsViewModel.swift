//
//  NetworkProtectionVPNSettingsViewModel.swift
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

import Foundation
import UserNotifications
import NetworkProtection
import Combine

enum NetworkProtectionNotificationsViewKind: Equatable {
    case loading
    case unauthorized
    case authorized
}

final class NetworkProtectionVPNSettingsViewModel: ObservableObject {
    private let settings: VPNSettings
    private var cancellables: Set<AnyCancellable> = []

    private var notificationsAuthorization: NotificationsAuthorizationControlling
    @Published var viewKind: NetworkProtectionNotificationsViewKind = .loading

    var alertsEnabled: Bool {
        self.settings.notifyStatusChanges
    }

    @Published public var excludeLocalNetworks: Bool = true
    @Published public var usesCustomDNS = false
    @Published public var dnsServers: String = UserText.vpnSettingDNSServerDefaultValue

    init(notificationsAuthorization: NotificationsAuthorizationControlling, settings: VPNSettings) {
        self.settings = settings
        self.notificationsAuthorization = notificationsAuthorization
        
        settings.excludeLocalNetworksPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.excludeLocalNetworks, onWeaklyHeld: self)
            .store(in: &cancellables)
        settings.dnsSettingsPublisher
            .receive(on: DispatchQueue.main)
            .map { $0.usesCustomDNS }
            .assign(to: \.usesCustomDNS, onWeaklyHeld: self)
            .store(in: &cancellables)
        settings.dnsSettingsPublisher
            .receive(on: DispatchQueue.main)
            .map { String(describing: $0) }
            .assign(to: \.dnsServers, onWeaklyHeld: self)
            .store(in: &cancellables)
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

    func toggleExcludeLocalNetworks() {
        settings.excludeLocalNetworks.toggle()
    }

    private static func localizedString(forRegionCode: String) -> String {
        Locale.current.localizedString(forRegionCode: forRegionCode) ?? forRegionCode.capitalized
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

extension NetworkProtectionVPNSettingsViewModel: NotificationsPermissionsControllerDelegate {
    func authorizationStateDidChange(toStatus status: UNAuthorizationStatus) {
        updateViewKind(for: status)
    }
}

#endif

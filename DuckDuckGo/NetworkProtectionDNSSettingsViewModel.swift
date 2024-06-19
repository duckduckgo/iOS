//
//  NetworkProtectionDNSSettingsViewModel.swift
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
import Combine
import NetworkProtection
import Core

final class NetworkProtectionDNSSettingsViewModel: ObservableObject {
    private let settings: VPNSettings
    private var cancellables: Set<AnyCancellable> = []

    @Published public var dnsSettings: NetworkProtectionDNSSettings = .default

    @Published public var isCustomDNSSelected = false
    
    @Published public var customDNSServers = ""

    @Published public var isApplyButtonEnabled = false

    init(settings: VPNSettings) {
        self.settings = settings

        settings.dnsSettingsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.dnsSettings, onWeaklyHeld: self)
            .store(in: &cancellables)

        isCustomDNSSelected = settings.dnsSettings.usesCustomDNS
        customDNSServers = settings.dnsSettings.dnsServersText
    }

    func toggleDNSSettings() {
        isCustomDNSSelected.toggle()
    }

    func applyDNSSettings() {
        if isCustomDNSSelected {
            settings.dnsSettings = .custom([customDNSServers])
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionDNSUpdateCustom)
        } else {
            settings.dnsSettings = .default
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionDNSUpdateDefault)
        }
    }

    func updateApplyButtonState() {
        if isCustomDNSSelected {
            isApplyButtonEnabled = !customDNSServers.isEmpty && customDNSServers.isValidIpv4Host
        } else {
            isApplyButtonEnabled = true
        }
    }
}

extension NetworkProtectionDNSSettings {
    fileprivate var dnsServersText: String {
        switch self {
        case .default: return ""
        case .custom(let servers): return servers.joined(separator: ", ")
        }
    }
}

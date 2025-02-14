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
import BrowserServicesKit

final class NetworkProtectionDNSSettingsViewModel: ObservableObject {
    private let settings: VPNSettings
    private let controller: TunnelController
    private let featureFlagger: FeatureFlagger
    private var cancellables: Set<AnyCancellable> = []

    @Published public var dnsSettings: NetworkProtectionDNSSettings

    @Published public var isCustomDNSSelected: Bool

    @Published var isBlockRiskyDomainsOn: Bool {
        didSet {
            applyDNSSettings()
        }
    }

    @Published public var customDNSServers: String

    @Published public var isApplyButtonEnabled = false

    var isRiskySitesProtectionFeatureEnabled: Bool {
        featureFlagger.isFeatureOn(.networkProtectionRiskyDomainsProtection)
    }

    init(settings: VPNSettings, controller: TunnelController, featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.settings = settings
        self.controller = controller
        self.featureFlagger = featureFlagger

        dnsSettings = settings.dnsSettings
        isBlockRiskyDomainsOn = settings.isBlockRiskyDomainsOn
        isCustomDNSSelected = settings.dnsSettings.usesCustomDNS
        customDNSServers = settings.customDnsServers.joined(separator: ", ")

        subscribeToDNSSettingsChanges()
    }

    func subscribeToDNSSettingsChanges() {
        settings.dnsSettingsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.dnsSettings, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    func toggleDNSSettings() {
        isCustomDNSSelected.toggle()
    }

    func toggleIsBlockRiskyDomainsOn() {
        isBlockRiskyDomainsOn.toggle()
    }

    func applyDNSSettings() {
        if isCustomDNSSelected {
            settings.dnsSettings = .custom([customDNSServers])
        } else {
            settings.dnsSettings = .ddg(blockRiskyDomains: isBlockRiskyDomainsOn)
        }
        reloadVPN()

        /// Updating `dnsSettings` does an IPv4 conversion before actually commiting the change,
        /// so we do a final check to see which outcome the user ends up with
        if settings.dnsSettings.usesCustomDNS {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionDNSUpdateCustom, pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
        } else {
            DailyPixel.fireDailyAndCount(pixel: .networkProtectionDNSUpdateDefault, pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes)
        }
    }

    func updateApplyButtonState() {
        if isCustomDNSSelected {
            isApplyButtonEnabled = !customDNSServers.isEmpty && customDNSServers.isValidIpv4Host
        } else {
            isApplyButtonEnabled = true
        }
    }

    private func reloadVPN() {
        Task {
            // We need to allow some time for the setting to propagate
            try await Task.sleep(interval: 0.1)
            try await controller.command(.restartAdapter)
        }
    }
}

extension NetworkProtectionDNSSettings {
    fileprivate var dnsServersText: String {
        switch self {
        case .ddg: return ""
        case .custom(let servers): return servers.joined(separator: ", ")
        }
    }
}

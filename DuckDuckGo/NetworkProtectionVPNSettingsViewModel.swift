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
import NetworkProtection
import Combine

final class NetworkProtectionVPNSettingsViewModel: ObservableObject {
    private let tunnelSettings: TunnelSettings
    private var cancellable: AnyCancellable?

    @Published public var preferredLocation: String = UserText.netPPreferredLocationNearest

    init(tunnelSettings: TunnelSettings) {
        self.tunnelSettings = tunnelSettings
        cancellable = tunnelSettings.selectedLocationPublisher.map { selectedLocation in
            guard let selectedLocation = selectedLocation.location else {
                return UserText.netPPreferredLocationNearest
            }
            guard let city = selectedLocation.city else {
                return Self.localizedString(forRegionCode: selectedLocation.country)
            }
            return "\(city), \(Self.localizedString(forRegionCode: selectedLocation.country))"
        }.assign(to: \.preferredLocation, onWeaklyHeld: self)
    }

    private static func localizedString(forRegionCode: String) -> String {
        Locale.current.localizedString(forRegionCode: forRegionCode) ?? forRegionCode.capitalized
    }
}

#endif

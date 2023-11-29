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
    private let settings: VPNSettings
    private var cancellables: Set<AnyCancellable> = []

    @Published public var preferredLocation: NetworkProtectionLocationSettingsItemModel
    @Published public var excludeLocalNetworks: Bool = true

    init(settings: VPNSettings) {
        self.settings = settings
        self.preferredLocation = NetworkProtectionLocationSettingsItemModel(selectedLocation: settings.selectedLocation)
        settings.selectedLocationPublisher
            .receive(on: DispatchQueue.main)
            .map(NetworkProtectionLocationSettingsItemModel.init(selectedLocation:))
            .assign(to: \.preferredLocation, onWeaklyHeld: self)
            .store(in: &cancellables)
        
        settings.excludeLocalNetworksPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.excludeLocalNetworks, onWeaklyHeld: self)
            .store(in: &cancellables)
    }

    func toggleExcludeLocalNetworks() {
        settings.excludeLocalNetworks.toggle()
    }

    private static func localizedString(forRegionCode: String) -> String {
        Locale.current.localizedString(forRegionCode: forRegionCode) ?? forRegionCode.capitalized
    }
}

struct NetworkProtectionLocationSettingsItemModel {
    enum LocationIcon {
        case defaultIcon
        case emoji(String)
    }

    let title: String
    let icon: LocationIcon

    init(selectedLocation: VPNSettings.SelectedLocation) {
        switch selectedLocation {
        case .nearest:
            title = UserText.netPPreferredLocationNearest
            icon = .defaultIcon
        case .location(let location):
            let countryLabelsModel = NetworkProtectionVPNCountryLabelsModel(country: location.country)
            if let city = location.city {
                title = UserText.netPVPNSettingsLocationSubtitleFormattedCityAndCountry(
                    city: city,
                    country: countryLabelsModel.title
                )
            } else {
                title = countryLabelsModel.title
            }
            icon = .emoji(countryLabelsModel.emoji)
        }
    }
}

#endif

//
//  NetworkProtectionVPNLocationViewModel.swift
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
import Combine
import NetworkProtection

@MainActor
final class NetworkProtectionVPNLocationViewModel: ObservableObject {
    private let locationListRepository: NetworkProtectionLocationListRepository
    private let tunnelSettings: TunnelSettings
    @Published public var state: LoadingState

    enum LoadingState {
        case loading
        case loaded(isNearestSelected: Bool, countryItems: [NetworkProtectionVPNCountryItemModel])
    }

    init(locationListRepository: NetworkProtectionLocationListRepository, tunnelSettings: TunnelSettings) {
        self.locationListRepository = locationListRepository
        self.tunnelSettings = tunnelSettings
        state = .loading
    }

    func onViewAppeared() async {
        await reloadList()
    }

    func onNearestItemSelection() async {
        tunnelSettings.selectedLocation = .nearest
        await reloadList()
    }

    func onCountryItemSelection(id: String) async {
        let location = NetworkProtectionSelectedLocation(country: id)
        tunnelSettings.selectedLocation = .location(location)
        await reloadList()
    }

    private func reloadList() async {
        guard let list = try? await locationListRepository.fetchLocationList() else { return }
        let selectedLocation = self.tunnelSettings.selectedLocation
        let isNearestSelected = selectedLocation == .nearest
        let countryItems = list.map { currentLocation in
            let isSelected: Bool
            if case .location(let location) = selectedLocation {
                isSelected = location.country == currentLocation.country
            } else {
                isSelected = false
            }
            return NetworkProtectionVPNCountryItemModel(netPLocation: currentLocation, isSelected: isSelected)
        }
        state = .loaded(isNearestSelected: isNearestSelected, countryItems: countryItems)
    }
}

struct NetworkProtectionVPNCountryItemModel: Identifiable {
    let isSelected: Bool
    var id: String
    let emoji: String
    let localizedName: String
    let cities: String?

    init(netPLocation: NetworkProtectionLocation, isSelected: Bool) {
        self.isSelected = isSelected
        self.id = netPLocation.country
        self.localizedName = Locale.current.localizedString(forRegionCode: id) ?? id
        self.cities = netPLocation.cities.count > 1 ? "\(netPLocation.cities.count) cities" : nil
        self.emoji = Self.flag(country: netPLocation.country)
    }

    static func flag(country: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value

        let flag = country
            .uppercased()
            .unicodeScalars
            .compactMap({ UnicodeScalar(flagBase + $0.value)?.description })
            .joined()
        return flag
    }
}

#endif

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

    func onCountryItemSelection(id: String, cityId: String? = nil) async {
        let location = NetworkProtectionSelectedLocation(country: id, city: cityId)
        tunnelSettings.selectedLocation = .location(location)
        await reloadList()
    }
    
    @MainActor
    private func reloadList() async {
        guard let list = try? await locationListRepository.fetchLocationList() else { return }
        let selectedLocation = self.tunnelSettings.selectedLocation
        let isNearestSelected = selectedLocation == .nearest
        let countryItems = list.map { currentLocation in
            let isCountrySelected: Bool
            let isNearestCitySelected: Bool
            var cityPickerItems: [CityItem]
            if case .location(let location) = selectedLocation {
                isCountrySelected = location.country == currentLocation.country
                isNearestCitySelected = location.city == nil && isCountrySelected
                cityPickerItems = currentLocation.cities.map { currentCity in
                    let isCitySelected = currentCity.name == location.city
                    return CityItem(city: currentCity, isSelected: isCitySelected)
                }
            } else {
                isCountrySelected = false
                isNearestCitySelected = false
                cityPickerItems = currentLocation.cities.map { currentCity in
                    CityItem(city: currentCity, isSelected: false)
                }
            }
            let nearestItem = CityItem(
                city: nil,
                isSelected: isNearestCitySelected
            )
            cityPickerItems.insert(nearestItem, at: 0)
            return NetworkProtectionVPNCountryItemModel(
                netPLocation: currentLocation,
                isSelected: isCountrySelected,
                cityPickerItems: cityPickerItems
            )
        }

        state = .loaded(isNearestSelected: isNearestSelected, countryItems: countryItems)
    }
}

private typealias CountryItem = NetworkProtectionVPNCountryItemModel
private typealias CityItem = NetworkProtectionVPNCityItemModel

struct NetworkProtectionVPNCountryItemModel: Identifiable {
    let isSelected: Bool
    var id: String
    let emoji: String
    let title: String
    let subtitle: String?
    let cityPickerItems: [NetworkProtectionVPNCityItemModel]
    let shouldShowPicker: Bool

    fileprivate init(netPLocation: NetworkProtectionLocation, isSelected: Bool, cityPickerItems: [NetworkProtectionVPNCityItemModel]) {
        self.isSelected = isSelected
        self.id = netPLocation.country
        self.title = Locale.current.localizedString(forRegionCode: id) ?? id
        let hasMultipleCities = netPLocation.cities.count > 1
        self.subtitle = hasMultipleCities ? UserText.netPVPNLocationCountryItemFormattedCitiesCount(netPLocation.cities.count) : nil
        self.cityPickerItems = cityPickerItems
        self.emoji = Self.flag(country: netPLocation.country)
        self.shouldShowPicker = hasMultipleCities
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

struct NetworkProtectionVPNCityItemModel: Identifiable {
    static let nearestItemId = "nearestItemId"
    let id: String?
    let name: String
    let isSelected: Bool

    fileprivate init(city: NetworkProtectionLocation.City?, isSelected: Bool) {
        self.id = city?.name ?? Self.nearestItemId
        self.name = city?.name ?? UserText.netPPreferredLocationNearest
        self.isSelected = isSelected
    }
}

#endif

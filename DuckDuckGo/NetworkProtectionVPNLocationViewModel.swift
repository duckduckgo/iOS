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
    private let settings: VPNSettings
    @Published public var state: LoadingState
    @Published public var isNearestSelected: Bool

    enum LoadingState {
        case loading
        case loaded(countryItems: [NetworkProtectionVPNCountryItemModel])

        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            case .loaded:
                return false
            }
        }
    }

    init(locationListRepository: NetworkProtectionLocationListRepository, settings: VPNSettings) {
        self.locationListRepository = locationListRepository
        self.settings = settings
        state = .loading
        self.isNearestSelected = settings.selectedLocation == .nearest
    }

    func onViewAppeared() async {
        await reloadList()
    }

    func onNearestItemSelection() async {
        settings.selectedLocation = .nearest
        await reloadList()
    }

    func onCountryItemSelection(id: String, cityId: String? = nil) async {
        let location = NetworkProtectionSelectedLocation(country: id, city: cityId)
        settings.selectedLocation = .location(location)
        await reloadList()
    }
    
    @MainActor
    private func reloadList() async {
        guard let list = try? await locationListRepository.fetchLocationList() else { return }
        let selectedLocation = self.settings.selectedLocation
        let isNearestSelected = selectedLocation == .nearest

        let countryItems = list.map { currentLocation in
            let isCountrySelected: Bool
            let isNearestCitySelected: Bool
            var cityPickerItems: [CityItem]

            switch selectedLocation {
            case .location(let location):
                isCountrySelected = location.country == currentLocation.country
                isNearestCitySelected = location.city == nil && isCountrySelected
                cityPickerItems = currentLocation.cities.map { currentCity in
                    let isCitySelected = currentCity.name == location.city
                    return CityItem(city: currentCity, isSelected: isCitySelected)
                }
            case .nearest:
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
        self.isNearestSelected = isNearestSelected
        state = .loaded(countryItems: countryItems)
    }
}

private typealias CountryItem = NetworkProtectionVPNCountryItemModel
private typealias CityItem = NetworkProtectionVPNCityItemModel

struct NetworkProtectionVPNCountryItemModel: Identifiable {
    private let labelsModel: NetworkProtectionVPNCountryLabelsModel

    var emoji: String {
        labelsModel.emoji
    }
    var title: String {
        labelsModel.title
    }
    let isSelected: Bool
    var id: String
    let subtitle: String?
    let cityPickerItems: [NetworkProtectionVPNCityItemModel]
    let shouldShowPicker: Bool

    fileprivate init(netPLocation: NetworkProtectionLocation, isSelected: Bool, cityPickerItems: [NetworkProtectionVPNCityItemModel]) {
        self.labelsModel = .init(country: netPLocation.country)
        self.isSelected = isSelected
        self.id = netPLocation.country
        let hasMultipleCities = netPLocation.cities.count > 1
        self.subtitle = hasMultipleCities ? UserText.netPVPNLocationCountryItemFormattedCitiesCount(netPLocation.cities.count) : nil
        self.cityPickerItems = cityPickerItems
        self.shouldShowPicker = hasMultipleCities
    }
}

struct NetworkProtectionVPNCityItemModel: Identifiable {
    let id: String?
    let name: String
    let isSelected: Bool

    fileprivate init(city: NetworkProtectionLocation.City?, isSelected: Bool) {
        self.id = city?.name
        self.name = city?.name ?? UserText.netPPreferredLocationNearest
        self.isSelected = isSelected
    }
}

#endif

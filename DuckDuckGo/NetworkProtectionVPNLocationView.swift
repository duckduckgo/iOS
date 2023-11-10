//
//  NetworkProtectionVPNLocationView.swift
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
import SwiftUI

@available(iOS 15, *)
struct NetworkProtectionVPNLocationView: View {
    @StateObject var model = NetworkProtectionVPNLocationViewModel()

    var body: some View {
        List {
            Text("⚠️ THIS FEATURE IS STILL WORK IN PROGRESS ⚠️")
            Section {
                Button(action: model.onNearestItemSelection) {
                    Text(UserText.netPPreferredLocationNearest)
                }
            }
            Section {
                ForEach(model.countryItems) { item in
                    Button(action: {
                        model.onCountryItemSelection(countryID: item.countryID)
                    }) {
                        Text(item.localizedName)
                    }
                }
            }
        }
        .animation(.default, value: model.countryItems.isEmpty)
        .applyInsetGroupedListStyle()
        .navigationTitle("VPN Location").onAppear {
            Task {
                await model.onViewAppeared()
            }
        }
    }
}

import NetworkProtection

final class NetworkProtectionVPNLocationViewModel: ObservableObject {
    private let locationListRepository: NetworkProtectionLocationListRepository
    private let tunnelSettings: TunnelSettings
    @Published public var countryItems: [NetworkProtectionVPNCountryItemModel] = []

    init(locationListRepository: NetworkProtectionLocationListRepository, tunnelSettings: TunnelSettings) {
        self.locationListRepository = locationListRepository
        self.tunnelSettings = tunnelSettings
    }

    @MainActor
    func onViewAppeared() async {
        guard let list = try? await locationListRepository.fetchLocationList() else { return }
        self.countryItems = list.map(NetworkProtectionVPNCountryItemModel.init(netPLocation:))
    }

    func onNearestItemSelection() {
        tunnelSettings.selectedLocation = .nearest
    }

    func onCountryItemSelection(countryID: String) {
        let location = NetworkProtectionSelectedLocation(country: countryID)
        tunnelSettings.selectedLocation = .location(location)
    }
}

struct NetworkProtectionVPNCountryItemModel: Identifiable {
    let countryID: String
    let localizedName: String
    let cities: [String]
    var id: String {
        "\(countryID) - \(cities.count) cities"
    }

    init(netPLocation: NetworkProtectionLocation) {
        self.countryID = netPLocation.country
        self.localizedName = Locale.current.localizedString(forRegionCode: countryID) ?? countryID
        self.cities = netPLocation.cities.map(\.name)
    }
}

#endif

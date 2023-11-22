//
//  NetworkProtectionVPNLocationViewModelTests.swift
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

import XCTest
import NetworkProtection
import NetworkExtension
import NetworkProtectionTestUtils
@testable import DuckDuckGo

// swiftlint:disable type_body_length

final class NetworkProtectionVPNLocationViewModelTests: XCTestCase {
    private var listRepository: MockNetworkProtectionLocationListRepository!
    private var tunnelSettings: TunnelSettings!
    private var viewModel: NetworkProtectionVPNLocationViewModel!

    @MainActor
    override func setUp() {
        super.setUp()
        listRepository = MockNetworkProtectionLocationListRepository()
        let testDefaults = UserDefaults(suiteName: "com.duckduckgo.\(String(describing: type(of: self)))")!
        tunnelSettings = TunnelSettings(defaults: testDefaults)
        viewModel = NetworkProtectionVPNLocationViewModel(locationListRepository: listRepository, tunnelSettings: tunnelSettings)
    }

    override func tearDown() {
        tunnelSettings.selectedLocation = .nearest
        tunnelSettings = nil
        listRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: onViewAppeared

    @MainActor
    func test_onViewAppeared_setsCorrectCountryTitle() async throws {
        let titlesForLocationsIDs = [
            "NL": "Netherlands",
            "DE": "Germany",
            "SE": "Sweden"
        ]
        let locationIds = Array(titlesForLocationsIDs.keys)
        let countries: [NetworkProtectionLocation] = try locationIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()

        let items = try loadedItems()

        for i in 0..<locationIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertEqual(items[i].title, titlesForLocationsIDs[locationIds[i]])
            }
        }
    }

    @MainActor
    func test_onViewAppeared_setsCountryID() async throws {
        let iDsForLocationsIDs = [
            "NL": "NL",
            "DE": "DE",
            "SE": "SE"
        ]
        let locationIds = Array(iDsForLocationsIDs.keys)
        let countries: [NetworkProtectionLocation] = try locationIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()

        let items = try loadedItems()

        for i in 0..<locationIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertEqual(items[i].id, iDsForLocationsIDs[locationIds[i]])
            }
        }
    }

    @MainActor
    func test_onViewAppeared_setsCorrectEmoji() async throws {
        let emojisForLocationsIDs = [
            "NL": "🇳🇱",
            "DE": "🇩🇪",
            "SE": "🇸🇪"
        ]
        let locationIds = Array(emojisForLocationsIDs.keys)
        let countries: [NetworkProtectionLocation] = try locationIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()

        let items = try loadedItems()

        for i in 0..<locationIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertEqual(items[i].emoji, emojisForLocationsIDs[locationIds[i]])
            }
        }
    }

    @MainActor
    func test_onViewAppeared_selectedCountryFromSettings_isSelectedSetToTrue() async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries

        for i in 0..<countryIds.count {
            tunnelSettings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: countryIds[i]))
            await viewModel.onViewAppeared()

            let items = try loadedItems()

            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertTrue(items[i].isSelected)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_NOTSelectedCountryFromSettings_isSelectedSetToFalse() async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
        tunnelSettings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: "US"))
        await viewModel.onViewAppeared()

        for i in 0..<countryIds.count {
            let items = try loadedItems()

            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertFalse(items[i].isSelected)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_nearestSelectedInSettings_isNearestSelectedSetToTrue() async throws {
        let countries: [NetworkProtectionLocation] = try ["NL", "DE", "SE"].map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
        tunnelSettings.selectedLocation = .nearest
        await viewModel.onViewAppeared()
        guard case .loaded(let isNearestSelected, _) = viewModel.state else {
            throw TestError.notLoadedState
        }

        XCTAssertTrue(isNearestSelected)
    }

    @MainActor
    func test_onViewAppeared_nearestNOTSelectedInSettings_isNearestSelectedSetToFalse() async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries

        for i in 0..<countryIds.count {
            tunnelSettings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: countryIds[i]))
            await viewModel.onViewAppeared()

            try XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                guard case .loaded(let isNearestSelected, _) = viewModel.state else {
                    throw TestError.notLoadedState
                }
                XCTAssertFalse(isNearestSelected)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_countryHas1City_subtitleIsNil() async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id, cityNames: ["A city"])
        }
        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()
        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertNil(items[i].subtitle)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_countryHas1City_shouldShowPickerIsFalse() async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id, cityNames: ["A city"])
        }
        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()
        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertFalse(items[i].shouldShowPicker)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_countryHasMoreThan1City_shouldShowPickerIsTrue() async throws {
        let countryIds = ["NL", "DE", "SE"]
        var countries = [NetworkProtectionLocation]()

        for i in 0..<countryIds.count {
            var cities = [String]()
            // Add an increasing number of cities above 2
            for j in 0..<i+2 {
                cities.append("City \(j)")
            }
            let country = try NetworkProtectionLocation.testData(country: countryIds[i], cityNames: cities)
            countries.append(country)
        }

        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()
        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertTrue(items[i].shouldShowPicker)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_countryHasMoreThan1City_subtitleShowsCityCount() async throws {
        struct TestCase {
            let countryId: String
            let citiesCount: Int
            let expectedSubtitle: String
        }
        let testCases: [TestCase] = [
            .init(countryId: "NL", citiesCount: 2, expectedSubtitle: "2 cities"),
            .init(countryId: "DE", citiesCount: 3, expectedSubtitle: "3 cities"),
            .init(countryId: "SE", citiesCount: 14, expectedSubtitle: "14 cities")
        ]
        let countries: [NetworkProtectionLocation] = try testCases.map { testCase in
            var cities = [String]()
            for i in 0..<testCase.citiesCount {
                cities.append("City \(i)")
            }
            return try .testData(country: testCase.countryId, cityNames: cities)
        }

        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()
        let items = try loadedItems()

        for i in 0..<testCases.count {
            XCTContext.runActivity(named: "Country List index: \(i)") { _ in
                XCTAssertEqual(items[i].subtitle, testCases[i].expectedSubtitle)
            }
        }
    }

    @MainActor
    func test_onViewAppeared_showsCityTitles() async throws {
        struct TestCase {
            let countryId: String
            let cityTitles: [String]
        }
        let testCases: [TestCase] = [
            .init(countryId: "NL", cityTitles: ["Rotterdam", "Amsterdam"]),
            .init(countryId: "DE", cityTitles: ["Berlin", "Frankfurt", "Bremen"])
        ]
        let countries: [NetworkProtectionLocation] = try testCases.map { testCase in
            return try .testData(country: testCase.countryId, cityNames: testCase.cityTitles)
        }

        listRepository.stubLocationList = countries
        await viewModel.onViewAppeared()
        let items = try loadedItems()

        for testCaseIndex in 0..<testCases.count {
            let testCase = testCases[testCaseIndex]
            let countryItem = items[testCaseIndex]
            for cityIndex in 0..<testCase.cityTitles.count {
                XCTContext.runActivity(named: "Country List index: \(testCaseIndex), City Index: \(cityIndex)") { _ in
                    // First cityPickerItem title is always nearest
                    XCTAssertEqual(testCase.cityTitles[cityIndex], countryItem.cityPickerItems[cityIndex+1].name)
                }
            }
        }
    }

    @MainActor
    func test_onViewAppeared_cityIsSelected_itemIsSelected() async throws {
        let countries: [NetworkProtectionLocation] = [
            try .testData(country: "NL", cityNames: ["Rotterdam", "Amsterdam"]),
            try .testData(country: "DE", cityNames: ["Berlin", "Frankfurt", "Bremen"])
        ]

        let selectionTestCases: [NetworkProtectionSelectedLocation] = [
            .init(country: "NL", city: "Amsterdam"),
            .init(country: "DE", city: "Frankfurt")
        ]

        listRepository.stubLocationList = countries

        for testCase in selectionTestCases {
            tunnelSettings.selectedLocation = .location(testCase)
            await viewModel.onViewAppeared()
            let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
            XCTAssertEqual(selectedItems.count, 1)
            XCTAssertEqual(selectedItems.first?.id, testCase.city)
        }
    }

    @MainActor
    func test_onViewAppeared_cityIsNOTSelected_itemIsNOTSelected() async throws {
        let countries: [NetworkProtectionLocation] = [
            try .testData(country: "NL", cityNames: ["Rotterdam", "Amsterdam"]),
            try .testData(country: "DE", cityNames: ["Berlin", "Frankfurt", "Bremen"])
        ]

        listRepository.stubLocationList = countries
        tunnelSettings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: "US", city: "New York"))
        await viewModel.onViewAppeared()
        let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
        XCTAssertEqual(selectedItems.count, 0)
    }

    @MainActor
    func test_onViewAppeared_countryWithoutCityIsSelected_nearestItemIsSelected() async throws {
        let countries: [NetworkProtectionLocation] = [
            try .testData(country: "NL", cityNames: ["Rotterdam", "Amsterdam"]),
            try .testData(country: "DE", cityNames: ["Berlin", "Frankfurt", "Bremen"]),
            try .testData(country: "SE", cityNames: ["Stockholm", "Malmö", "Helsingborg"])
        ]

        let selectionTestCases: [NetworkProtectionSelectedLocation] = [
            .init(country: "NL"),
            .init(country: "SE")
        ]

        listRepository.stubLocationList = countries

        for testCase in selectionTestCases {
            tunnelSettings.selectedLocation = .location(testCase)
            await viewModel.onViewAppeared()
            let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
            XCTAssertEqual(selectedItems.count, 1)
            XCTAssertEqual(selectedItems.first?.id, NetworkProtectionVPNCityItemModel.nearestItemId)
        }
    }

    private func loadedItems(file: StaticString = #file, line: UInt = #line) throws -> [NetworkProtectionVPNCountryItemModel] {
        guard case .loaded(_, countryItems: let items) = viewModel.state else {
            throw TestError.notLoadedState
        }
        return items
    }

    private enum TestError: Error {
        case notLoadedState
    }
}

// swiftlint:enable type_body_length

final class MockNetworkProtectionLocationListRepository: NetworkProtectionLocationListRepository {
    var stubLocationList: [NetworkProtectionLocation] = []
    var stubError: Error?
    func fetchLocationList() async throws -> [NetworkProtectionLocation] {
        if let stubError {
            throw stubError
        }
        return stubLocationList
    }
}

extension NetworkProtectionLocation {
    static func testData(country: String = "", cityNames: [String] = []) throws -> Self {
        let cities = cityNames.map { ["name": $0] }
        let dict: [String: Encodable] = ["country": country, "cities": cities]
        let wrappedDict = dict.mapValues(EncodableWrapper.init(wrapped:))
        let data = try JSONEncoder().encode(wrappedDict)
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

struct EncodableWrapper: Encodable {
    let wrapped: Encodable

    func encode(to encoder: Encoder) throws {
        try self.wrapped.encode(to: encoder)
    }
}

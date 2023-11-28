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
// swiftlint:disable file_length

final class NetworkProtectionVPNLocationViewModelTests: XCTestCase {
    private var listRepository: MockNetworkProtectionLocationListRepository!
    private var settings: VPNSettings!
    private var viewModel: NetworkProtectionVPNLocationViewModel!

    @MainActor
    override func setUp() {
        super.setUp()
        listRepository = MockNetworkProtectionLocationListRepository()
        let testDefaults = UserDefaults(suiteName: #file + Thread.current.debugDescription)!
        settings = VPNSettings(defaults: testDefaults)
        viewModel = NetworkProtectionVPNLocationViewModel(locationListRepository: listRepository, settings: settings)
    }

    override func tearDown() {
        settings.selectedLocation = .nearest
        settings = nil
        listRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: onViewAppeared

    func test_onViewAppeared_setsCorrectCountryTitle() async throws {
        try await assertOnListLoadSetsCorrectCountryTitle { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_setsCountryID() async throws {
        try await assertOnListLoadSetsCorrectCountryID { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_setsCorrectEmoji() async throws {
        try await assertOnListLoadSetsCorrectEmoji { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_selectedCountryFromSettings_isSelectedSetToTrue() async throws {
        try await assertOnListLoad_countryIsSelected { [weak self] testCaseCountryId in
            self?.settings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: testCaseCountryId))
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_NOTSelectedCountryFromSettings_isSelectedSetToFalse() async throws {
        try await assertOnListLoad_isSelectedSetToFalse { [weak self] in
            self?.settings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: "US"))
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_nearestSelectedInSettings_isNearestSelectedSetToTrue() async throws {
        try await assertNearestSelectedSetToTrue { [weak self] in
            self?.settings.selectedLocation = .nearest
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_nearestNOTSelectedInSettings_isNearestSelectedSetToFalse() async throws {
        try await assertNearestSelectedSetToFalse { [weak self] testCaseCountryId in
            self?.settings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: testCaseCountryId))
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_countryHas1City_subtitleIsNil() async throws {
        try await assertOnListLoad_countryWith1City_hasNilSubtitle { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_countryHas1City_shouldShowPickerIsFalse() async throws {
        try await assertOnListLoad_countryWith1City_shouldShowPickerIsFalse { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_countryHasMoreThan1City_shouldShowPickerIsTrue() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_shouldShowPickerIsTrue { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_countryHasMoreThan1City_subtitleShowsCityCount() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_subtitleShowsCityCount { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_showsCityTitles() async throws {
        try await assertOnListLoad_showsCityTitles { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_cityIsSelected_itemIsSelected() async throws {
        try await assertOnListLoad_itemIsSelected { [weak self] testCase in
            self?.settings.selectedLocation = .location(testCase)
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onViewAppeared_cityIsNOTSelected_itemIsNOTSelected() async throws {
        let countries: [NetworkProtectionLocation] = [
            try .testData(country: "NL", cityNames: ["Rotterdam", "Amsterdam"]),
            try .testData(country: "DE", cityNames: ["Berlin", "Frankfurt", "Bremen"])
        ]

        listRepository.stubLocationList = countries
        settings.selectedLocation = .location(NetworkProtectionSelectedLocation(country: "US", city: "New York"))
        await viewModel.onViewAppeared()
        let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
        XCTAssertEqual(selectedItems.count, 0)
    }

    func test_onViewAppeared_countryWithoutCityIsSelected_nearestItemIsSelected() async throws {
        try await assertOnListLoad_nearestItemIsSelected { [weak self] testCase in
            self?.settings.selectedLocation = .location(testCase)
            await self?.viewModel.onViewAppeared()
        }
    }

    // MARK: onNearestItemSelection

    func test_onNearestItemSelection_setsCorrectCountryTitle() async throws {
        try await assertOnListLoadSetsCorrectCountryTitle { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_setsCountryID() async throws {
        try await assertOnListLoadSetsCorrectCountryID { [weak self] in
            await self?.viewModel.onViewAppeared()
        }
    }

    func test_onNearestItemSelection_setsCorrectEmoji() async throws {
        try await assertOnListLoadSetsCorrectEmoji { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_isNearestSelectedSetToTrue() async throws {
        try await assertNearestSelectedSetToTrue { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_countryHas1City_subtitleIsNil() async throws {
        try await assertOnListLoad_countryWith1City_hasNilSubtitle { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_countryHas1City_shouldShowPickerIsFalse() async throws {
        try await assertOnListLoad_countryWith1City_shouldShowPickerIsFalse { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_countryHasMoreThan1City_shouldShowPickerIsTrue() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_shouldShowPickerIsTrue { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_countryHasMoreThan1City_subtitleShowsCityCount() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_subtitleShowsCityCount { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    func test_onNearestItemSelection_showsCityTitles() async throws {
        try await assertOnListLoad_showsCityTitles { [weak self] in
            await self?.viewModel.onNearestItemSelection()
        }
    }

    // MARK: onCountryItemSelection

    func test_onCountryItemSelection_setsCorrectCountryTitle() async throws {
        try await assertOnListLoadSetsCorrectCountryTitle { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_setsCountryID() async throws {
        try await assertOnListLoadSetsCorrectCountryID { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_setsCorrectEmoji() async throws {
        try await assertOnListLoadSetsCorrectEmoji { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_selectedCountryFromSettings_isSelectedSetToTrue() async throws {
        try await assertOnListLoad_countryIsSelected { [weak self] testCaseCountryId in
            await self?.viewModel.onCountryItemSelection(id: testCaseCountryId)
        }
    }

    func test_onCountryItemSelection_NOTSelectedCountry_isSelectedSetToFalse() async throws {
        try await assertOnListLoad_isSelectedSetToFalse { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "US")
        }
    }

    func test_onCountryItemSelection_isNearestSelectedSetToFalse() async throws {
        try await assertNearestSelectedSetToFalse { [weak self] testCaseCountryId in
            await self?.viewModel.onCountryItemSelection(id: testCaseCountryId)
        }
    }

    func test_onCountryItemSelection_countryHas1City_subtitleIsNil() async throws {
        try await assertOnListLoad_countryWith1City_hasNilSubtitle { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_countryHas1City_shouldShowPickerIsFalse() async throws {
        try await assertOnListLoad_countryWith1City_shouldShowPickerIsFalse { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_countryHasMoreThan1City_shouldShowPickerIsTrue() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_shouldShowPickerIsTrue { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_countryHasMoreThan1City_subtitleShowsCityCount() async throws {
        try await assertOnListLoad_countryHasMoreThan1City_subtitleShowsCityCount { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_showsCityTitles() async throws {
        try await assertOnListLoad_showsCityTitles { [weak self] in
            await self?.viewModel.onCountryItemSelection(id: "NL", cityId: "Rotterdam")
        }
    }

    func test_onCountryItemSelection_cityIsSelected_itemIsSelected() async throws {
        try await assertOnListLoad_itemIsSelected { [weak self] testCase in
            await self?.viewModel.onCountryItemSelection(id: testCase.country, cityId: testCase.city)
        }
    }

    func test_onCountryItemSelection_countryWithoutCityIsSelected_nearestItemIsSelected() async throws {
        try await assertOnListLoad_nearestItemIsSelected { [weak self] testCase in
            await self?.viewModel.onCountryItemSelection(id: testCase.country, cityId: testCase.city)
        }
    }

    // MARK: Assertions

    func assertOnListLoadSetsCorrectCountryTitle(when functionUnderTest: () async -> Void,
                                                 file: StaticString = #file,
                                                 line: UInt = #line) async throws {
        let titlesForLocationsIDs = [
            "NL": "Netherlands",
            "DE": "Germany",
            "SE": "Sweden"
        ]
        let countryIds = Array(titlesForLocationsIDs.keys)
        try stubLocationList(with: countryIds)

        await functionUnderTest()

        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertEqual(items[i].title, titlesForLocationsIDs[countryIds[i]], file: file, line: line)
        }
    }

    func assertOnListLoadSetsCorrectCountryID(when functionUnderTest: () async -> Void,
                                              file: StaticString = #file,
                                              line: UInt = #line) async throws {
        let iDsForLocationsIDs = [
            "NL": "NL",
            "DE": "DE",
            "SE": "SE"
        ]
        let countryIds = Array(iDsForLocationsIDs.keys)
        try stubLocationList(with: countryIds)

        await functionUnderTest()

        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertEqual(items[i].id, iDsForLocationsIDs[countryIds[i]], file: file, line: line)
        }
    }

    func assertOnListLoadSetsCorrectEmoji(when functionUnderTest: () async -> Void,
                                          file: StaticString = #file,
                                          line: UInt = #line) async throws {
        let emojisForLocationsIDs = [
            "NL": "🇳🇱",
            "DE": "🇩🇪",
            "SE": "🇸🇪"
        ]
        let countryIds = Array(emojisForLocationsIDs.keys)
        try stubLocationList(with: countryIds)

        await functionUnderTest()

        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertEqual(items[i].emoji, emojisForLocationsIDs[countryIds[i]], file: file, line: line)
        }
    }

    func assertOnListLoad_countryIsSelected(when functionUnderTestWithTestCaseID: (String) async -> Void,
                                            file: StaticString = #file,
                                            line: UInt = #line) async throws {
        let countryIds = ["NL", "DE", "SE"]
        try stubLocationList(with: countryIds)

        for i in 0..<countryIds.count {
            await functionUnderTestWithTestCaseID(countryIds[i])

            let items = try loadedItems()

            XCTAssertTrue(items[i].isSelected, file: file, line: line)
        }
    }

    func assertNearestSelectedSetToTrue(when functionUnderTest: () async -> Void,
                                        file: StaticString = #file,
                                        line: UInt = #line) async throws {
        try stubLocationList(with: ["NL", "DE", "SE"])

        await functionUnderTest()

        XCTAssertTrue(viewModel.isNearestSelected, file: file, line: line)
    }

    func assertNearestSelectedSetToFalse(when functionUnderTestWithTestCaseID: (String) async -> Void,
                                         file: StaticString = #file,
                                         line: UInt = #line) async throws {
        let countryIds = ["NL", "DE", "SE"]
        try stubLocationList(with: countryIds)

        for i in 0..<countryIds.count {
            await functionUnderTestWithTestCaseID(countryIds[i])

            XCTAssertFalse(viewModel.isNearestSelected, file: file, line: line)
        }
    }

    func assertOnListLoad_countryWith1City_hasNilSubtitle(when functionUnderTest: () async -> Void,
                                                          file: StaticString = #file,
                                                          line: UInt = #line) async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id, cityNames: ["A city"])
        }
        listRepository.stubLocationList = countries

        await functionUnderTest()

        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertNil(items[i].subtitle, file: file, line: line)
        }
    }

    func assertOnListLoad_countryWith1City_shouldShowPickerIsFalse(when functionUnderTest: () async -> Void,
                                                                   file: StaticString = #file,
                                                                   line: UInt = #line) async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id, cityNames: ["A city"])
        }
        listRepository.stubLocationList = countries
        await functionUnderTest()
        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertFalse(items[i].shouldShowPicker, file: file, line: line)
        }
    }

    func assertOnListLoad_countryHasMoreThan1City_shouldShowPickerIsTrue(when functionUnderTest: () async -> Void,
                                                                         file: StaticString = #file,
                                                                         line: UInt = #line) async throws {
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
        await functionUnderTest()
        let items = try loadedItems()

        for i in 0..<countryIds.count {
            XCTAssertTrue(items[i].shouldShowPicker, file: file, line: line)
        }
    }

    func assertOnListLoad_countryHasMoreThan1City_subtitleShowsCityCount(when functionUnderTest: () async -> Void,
                                                                         file: StaticString = #file,
                                                                         line: UInt = #line) async throws {
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

        await functionUnderTest()

        let items = try loadedItems()

        for i in 0..<testCases.count {
            XCTAssertEqual(items[i].subtitle, testCases[i].expectedSubtitle, file: file, line: line)
        }
    }

    func assertOnListLoad_isSelectedSetToFalse(when functionUnderTest: () async -> Void,
                                               file: StaticString = #file,
                                               line: UInt = #line) async throws {
        let countryIds = ["NL", "DE", "SE"]
        let countries: [NetworkProtectionLocation] = try countryIds.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries

        await functionUnderTest()

        for i in 0..<countryIds.count {
            let items = try loadedItems()

            XCTAssertFalse(items[i].isSelected, file: file, line: line)
        }
    }

    func assertOnListLoad_showsCityTitles(when functionUnderTest: () async -> Void,
                                          file: StaticString = #file,
                                          line: UInt = #line) async throws {
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

        await functionUnderTest()

        let items = try loadedItems()

        for testCaseIndex in 0..<testCases.count {
            let testCase = testCases[testCaseIndex]
            let countryItem = items[testCaseIndex]
            for cityIndex in 0..<testCase.cityTitles.count {
                // First cityPickerItem title is always nearest
                XCTAssertEqual(testCase.cityTitles[cityIndex], countryItem.cityPickerItems[cityIndex+1].name, file: file, line: line)
            }
        }
    }

    func assertOnListLoad_itemIsSelected(when functionUnderTestWithTestCase: (NetworkProtectionSelectedLocation) async -> Void,
                                         file: StaticString = #file,
                                         line: UInt = #line) async throws {
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
            await functionUnderTestWithTestCase(testCase)
            let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
            XCTAssertEqual(selectedItems.count, 1, file: file, line: line)
            XCTAssertEqual(selectedItems.first?.id, testCase.city, file: file, line: line)
        }
    }

    func assertOnListLoad_nearestItemIsSelected(when functionUnderTestWithTestCase: (NetworkProtectionSelectedLocation) async -> Void,
                                                file: StaticString = #file,
                                                line: UInt = #line) async throws {
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
            await functionUnderTestWithTestCase(testCase)
            let selectedItems = try loadedItems().flatMap { $0.cityPickerItems }.filter(\.isSelected)
            XCTAssertEqual(selectedItems.count, 1, file: file, line: line)
            XCTAssertNil(selectedItems.first?.id, file: file, line: line)
            XCTAssertEqual(
                selectedItems.first?.name,
                UserText.netPVPNLocationNearestAvailableItemTitle,
                file: file,
                line: line
            )
        }
    }

    // MARK: Helpers

    private func stubLocationList(with countryIDs: [String]) throws {
        let countries: [NetworkProtectionLocation] = try countryIDs.map { id in
            try .testData(country: id)
        }
        listRepository.stubLocationList = countries
    }

    private func loadedItems() throws -> [NetworkProtectionVPNCountryItemModel] {
        guard case .loaded(let items) = viewModel.state else {
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
    var didCallFetchLocationList: Bool = false

    func fetchLocationList() async throws -> [NetworkProtectionLocation] {
        didCallFetchLocationList = true
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

// swiftlint:enable file_length

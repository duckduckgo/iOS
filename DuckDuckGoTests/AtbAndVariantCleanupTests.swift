//
//  AtbAndVariantCleanupTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import XCTest
@testable import DuckDuckGo
@testable import Core

class AtbAndVariantCleanupTests: XCTestCase {

    struct Constants {

        static let atb = "atb"
        static let variant = "variant"

    }

    let mockStorage = MockStatisticsStore()
    let mockVariantManager = MockVariantManager()

    func testWhenAtbHasVariantThenAtbStoredWithVariantRemoved() {

        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertEqual(Constants.atb, mockStorage.atb)

    }

    func testWhenVariantIsNotInCurrentExperimentThenVariantRemovedFromStorage() {

        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertNil(mockStorage.variant)

    }

    func testWhenVariantIsInCurrentExperimentThenVariantIsNotRemovedFromStorage() {

        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant, weight: 100, features: []))

        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertEqual(Constants.variant, mockStorage.variant)

    }

    func testWhenPreviousVariantIsHomePageExperimentThenSettingsAreUpdatedCorrectly() {
        
        let cases: [String: HomePageConfiguration.ConfigName] = [
            "": .simple,
            "mk": .simple,
            "ml": .centerSearchAndFavorites,
            "mm": .centerSearchAndFavorites,
            "mn": .centerSearch]

        for testCase in cases {
            let mockSettings = MockAppSettings()
            mockStorage.variant = testCase.key
            AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager, settings: mockSettings)
            XCTAssertEqual(mockSettings.homePageConfig, testCase.value)
        }
        
    }
    
}

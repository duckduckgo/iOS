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
@testable import BrowserServicesKit

class AtbAndVariantCleanupTests: XCTestCase {

    struct Constants {

        static let atb = "atb"
        static let variant = "variant"

    }

    let mockStorage = MockStatisticsStore()
    let mockVariantManager = MockVariantManager()

    override func setUp() {
        super.setUp()
        setupUserDefault(with: #file)
    }

    func testWhenAtbHasVariantThenAtbStoredWithVariantRemoved() {

        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertEqual(Constants.atb, mockStorage.atb)

    }

    func testWhenAtbHasDifferentVariantThenAtbStoredWithVariantIsNotRemoved() {

        let otherVariant = "\(Constants.atb)otherVariant"
        mockStorage.atb = otherVariant
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertEqual(mockStorage.atb, otherVariant)

    }

    func testWhenVariantIsNotInCurrentExperimentThenVariantRemovedFromStorage() {

        let mockVariantManager = MockVariantManager(currentVariant: nil)
        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertNil(mockStorage.variant)

    }

    func testWhenVariantIsInCurrentExperimentThenVariantIsNotRemovedFromStorage() {

        let variant = VariantIOS(name: Constants.variant, weight: 100, isIncluded: VariantIOS.When.always, features: [])
        let mockVariantManager = MockVariantManager(currentVariant: variant)

        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)

        XCTAssertEqual(Constants.variant, mockStorage.variant)

    }
    
}

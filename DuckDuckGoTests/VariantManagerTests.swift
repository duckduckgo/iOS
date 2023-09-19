//
//  VariantManagerTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import Core
@testable import BrowserServicesKit

class VariantManagerTests: XCTestCase {

    let testVariants = [
        VariantIOS(name: "mb", weight: 50, isIncluded: VariantIOS.When.always, features: []),
        VariantIOS(name: "mc", weight: 25, isIncluded: VariantIOS.When.always, features: []),
        VariantIOS(name: "mt", weight: VariantIOS.doNotAllocate, isIncluded: VariantIOS.When.always, features: []),
        VariantIOS(name: "md", weight: 25, isIncluded: VariantIOS.When.always, features: []),
        VariantIOS(name: "excluded", weight: 1000, isIncluded: { return false }, features: [.dummy])
    ]

    func testWhenVariantIsExcludedThenItIsNotInVariantList() {
        
        let subject = DefaultVariantManager(variants: testVariants, storage: MockStatisticsStore(), rng: MockVariantRNG(returnValue: 500),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        XCTAssertTrue(!subject.isSupported(feature: .dummy))
        
    }
    
    func testWhenCurrentVariantSupportsFeatureThenIsSupportedReturnsTrue() {

        let testVariants = [
            VariantIOS(name: "test", weight: 50, isIncluded: VariantIOS.When.always, features: [ .dummy ])
        ]

        let mockStore = MockStatisticsStore()
        mockStore.variant = "test"
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())

        // temporarily use this feature name
        XCTAssertTrue(subject.isSupported(feature: .dummy))

    }

    func testWhenVariantIsMarkedDoNotAllocateThenItIsNotAllocated() {

        let mockStore = MockStatisticsStore()
        mockStore.atb = "atb"
        mockStore.appRetentionAtb = "aatb"
        mockStore.searchRetentionAtb = "satb"
        
        for i in 0 ..< 100 {
            
            let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: i),
                                                returningUserMeasurement: MockReturningUserMeasurement())
            subject.assignVariantIfNeeded { _ in }
            XCTAssertNotEqual("mt", subject.currentVariant?.name)

        }
        
    }
    
    func testWhenExistingUserThenAssignIfNeededDoesNothing() {

        let mockStore = MockStatisticsStore()
        mockStore.atb = "atb"

        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        subject.assignVariantIfNeeded { _ in }
        XCTAssertNil(subject.currentVariant)

    }

    func testWhenVariantAssignedAndUsingDefaultRNGThenReturnsValidVariant() {

        let variant = VariantIOS(name: "anything", weight: 100, isIncluded: VariantIOS.When.always, features: [])
        let subject = DefaultVariantManager(variants: [variant], storage: MockStatisticsStore(), rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        subject.assignVariantIfNeeded { _ in }
        XCTAssertEqual(variant.name, subject.currentVariant?.name)

    }

    func testWhenAlreadyInitialsedThenReturnsPreviouslySelectedVariant() {

        let mockStore = MockStatisticsStore()
        mockStore.variant = "mb"
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        XCTAssertEqual("mb", subject.currentVariant?.name)
        XCTAssertEqual("mb", mockStore.variant)

    }

    func testWhenVariantAssignedWithDefaultVariantsThenReturnsRandomVariant() {
        XCTAssertEqual("mb", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 0)).currentVariant?.name)
        XCTAssertEqual("mb", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 49)).currentVariant?.name)
        XCTAssertEqual("mc", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 50)).currentVariant?.name)
        XCTAssertEqual("mc", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 74)).currentVariant?.name)
        XCTAssertEqual("md", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 75)).currentVariant?.name)
        XCTAssertEqual("md", assignedVariantManager(withRNG: MockVariantRNG(returnValue: 99)).currentVariant?.name)
    }

    func testWhenVariantAssignedThenReturnsRandomVariantAndSavesIt() {

        let mockStore = MockStatisticsStore()
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        subject.assignVariantIfNeeded { _ in }
        XCTAssertEqual("mb", subject.currentVariant?.name)
        XCTAssertEqual("mb", mockStore.variant)

    }

    func testWhenNewThenCurrentVariantIsNil() {

        let mockStore = MockStatisticsStore()
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        XCTAssertNil(subject.currentVariant)

    }

    func testWhenNoVariantsThenAssignsNothing() {
        let subject = DefaultVariantManager(variants: [], storage: MockStatisticsStore(), rng: MockVariantRNG(returnValue: 0),
                                            returningUserMeasurement: MockReturningUserMeasurement())
        XCTAssertNil(subject.currentVariant)
    }

    private func assignedVariantManager(withRNG rng: VariantRNG) -> VariantManager {
        let variantManager = DefaultVariantManager(variants: testVariants, storage: MockStatisticsStore(), rng: rng,
                                                   returningUserMeasurement: MockReturningUserMeasurement())
        variantManager.assignVariantIfNeeded { _ in }
        return variantManager
    }

}

struct MockVariantRNG: VariantRNG {

    let returnValue: Int

    func nextInt(upperBound: Int) -> Int {
        return returnValue
    }
    
}

class MockReturningUserMeasurement: ReturnUserMeasurement {
    var isReturningUser: Bool = false
    func installCompletedWithATB(_ atb: Core.Atb) {
    }
    func updateStoredATB(_ atb: Core.Atb) {
    }
}

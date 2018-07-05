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

class VariantManagerTests: XCTestCase {

    let testVariants = [
        Variant(name: "mb", percent: 50, features: []),
        Variant(name: "mc", percent: 25, features: []),
        Variant(name: "md", percent: 25, features: [])
    ]

    func testWhenExistingUserThenAssignIfNeededDoesNothing() {

        let mockStore = MockStatisticsStore()
        mockStore.atb = "atb"
        mockStore.retentionAtb = "ratb"

        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0))
        subject.assignVariantIfNeeded()
        XCTAssertNil(subject.currentVariant)

    }

    func testWhenVariantAssignedAndUsingDefaultRNGThenReturnsValidVariant() {

        let variant = Variant(name: "anything", percent: 100, features: [])
        let subject = DefaultVariantManager(variants: [variant], storage: MockStatisticsStore())
        subject.assignVariantIfNeeded()
        XCTAssertEqual(variant.name, subject.currentVariant?.name)

    }

    func testWhenAlreadyInitialsedThenReturnsPreviouslySelectedVariant() {

        let mockStore = MockStatisticsStore()
        mockStore.variant = "mb"
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore)
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
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0))
        subject.assignVariantIfNeeded()
        XCTAssertEqual("mb", subject.currentVariant?.name)
        XCTAssertEqual("mb", mockStore.variant)

    }

    func testWhenNewThenCurrentVariantIsNil() {

        let mockStore = MockStatisticsStore()
        let subject = DefaultVariantManager(variants: testVariants, storage: mockStore, rng: MockVariantRNG(returnValue: 0))
        XCTAssertNil(subject.currentVariant)

    }

    func testWhenNoVariantsThenAssignsNothing() {
        let subject = DefaultVariantManager(variants: [], storage: MockStatisticsStore())
        XCTAssertNil(subject.currentVariant)
    }

    private func assignedVariantManager(withRNG rng: VariantRNG) -> VariantManager {
        let variantManager = DefaultVariantManager(variants: testVariants, storage: MockStatisticsStore(), rng: rng)
        variantManager.assignVariantIfNeeded()
        return variantManager
    }

}

struct MockVariantRNG: VariantRNG {

    let returnValue: Int

    func nextInt(upperBound: Int) -> Int {
        return returnValue
    }

}

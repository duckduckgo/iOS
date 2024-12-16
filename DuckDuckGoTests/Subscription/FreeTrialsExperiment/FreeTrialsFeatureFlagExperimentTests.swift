//
//  FreeTrialsFeatureFlagExperimentTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
import PixelExperimentKit
import PixelKit
import BrowserServicesKit

final class FreeTrialsFeatureFlagExperimentTests: XCTestCase {

    private var mockUserDefaults: UserDefaults!

    private var sut: FreeTrialsFeatureFlagExperiment!

    private var mockSuiteName: String {
        String(describing: self)
    }

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: mockSuiteName)
        mockUserDefaults.removePersistentDomain(forName: mockSuiteName)

        sut = FreeTrialsFeatureFlagExperiment(storage: mockUserDefaults, experimentPixelFirer: MockExperimentPixelFirer.self)
        MockExperimentPixelFirer.reset()
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: mockSuiteName)
        mockUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    func testIncrementPaywallViewCount_incrementsCorrectly() {
        // Given
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 0)

        // When
        sut.incrementPaywallViewCount()

        // Then
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 1)
    }

    func testFirePaywallImpressionPixel_triggersPixelWithCorrectValues() {
        // Given
        sut.incrementPaywallViewCount()

        // When
        sut.firePaywallImpressionPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricPaywallImpressions)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "1")
    }

    func testFireOfferSelectionMonthlyPixel_triggersPixelWithCorrectValues() {
        // Given
        sut.incrementPaywallViewCount()

        // When
        sut.fireOfferSelectionMonthlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricStartClickedMonthly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "1")
    }

    func testFireOfferSelectionYearlyPixel_triggersPixelWithCorrectValues() {
        // Given
        sut.incrementPaywallViewCount()

        // When
        sut.fireOfferSelectionYearlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricStartClickedYearly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "1")
    }

    func testFireSubscriptionStartedMonthlyPixel_triggersPixelWithCorrectValues() {
        // Given
        sut.incrementPaywallViewCount()

        // When
        sut.fireSubscriptionStartedMonthlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricSubscriptionStartedMonthly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "1")
    }

    func testFireSubscriptionStartedYearlyPixel_triggersPixelWithCorrectValues() {
        // Given
        sut.incrementPaywallViewCount()

        // When
        sut.fireSubscriptionStartedYearlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricSubscriptionStartedYearly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "1")
    }
}

private final class MockExperimentPixelFirer: ExperimentPixelFiring {
    struct FiredPixel {
        let subfeatureID: SubfeatureID
        let metric: String
        let conversionWindow: ConversionWindow
        let value: String
    }

    static private(set) var firedMetrics: [FiredPixel] = []

    static func fireExperimentPixel(for subfeatureID: SubfeatureID,
                                    metric: String,
                                    conversionWindowDays: ConversionWindow,
                                    value: String) {
        let firedPixel = FiredPixel(
            subfeatureID: subfeatureID,
            metric: metric,
            conversionWindow: conversionWindowDays,
            value: value
        )
        firedMetrics.append(firedPixel)
    }

    static func reset() {
        firedMetrics.removeAll()
    }
}

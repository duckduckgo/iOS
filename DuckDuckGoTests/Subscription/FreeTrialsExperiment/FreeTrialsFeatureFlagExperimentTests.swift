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
import Core

final class FreeTrialsFeatureFlagExperimentTests: XCTestCase {

    private var mockUserDefaults: UserDefaults!
    private var mockFeatureFlagger: MockFeatureFlagger!
    private var mockBucketer: MockBucketer!
    private var sut: FreeTrialsFeatureFlagExperiment!

    private var mockSuiteName: String {
        String(describing: self)
    }

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: mockSuiteName)
        mockUserDefaults.removePersistentDomain(forName: mockSuiteName)

        mockFeatureFlagger = MockFeatureFlagger()
        mockBucketer = MockBucketer()

        sut = FreeTrialsFeatureFlagExperiment(
            storage: mockUserDefaults,
            experimentPixelFirer: MockExperimentPixelFirer.self,
            bucketer: mockBucketer,
            featureFlagger: mockFeatureFlagger
        )

        MockExperimentPixelFirer.reset()
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: mockSuiteName)
        mockUserDefaults = nil
        mockFeatureFlagger = nil
        mockBucketer = nil
        sut = nil
        super.tearDown()
    }

    func testIncrementPaywallViewCount_incrementsWhenInConversionWindow() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        let enrollmentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockFeatureFlagger.mockActiveExperiments = [
            FreeTrialsFeatureFlagExperiment.Constants.subfeatureIdentifier: ExperimentData(
                parentID: "testParentID",
                cohortID: cohort.rawValue,
                enrollmentDate: enrollmentDate
            )
        ]
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 0)

        // When
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // Then
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 1)
    }

    func testIncrementPaywallViewCount_doesNotIncrementWhenNotInConversionWindow() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        let enrollmentDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        mockFeatureFlagger.mockActiveExperiments = [
            FreeTrialsFeatureFlagExperiment.Constants.subfeatureIdentifier: ExperimentData(
                parentID: "testParentID",
                cohortID: cohort.rawValue,
                enrollmentDate: enrollmentDate
            )
        ]
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 0)

        // When
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // Then
        XCTAssertEqual(mockUserDefaults.integer(forKey: FreeTrialsFeatureFlagExperiment.Constants.paywallViewCountKey), 0)
    }

    func testFirePaywallImpressionPixel_triggersPixelWithBucketedValue() {
        // Given
        mockBucketer.mockBucket = "6-10"
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // When
        sut.firePaywallImpressionPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricPaywallImpressions)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "6-10")
    }

    func testFireOfferSelectionMonthlyPixel_triggersPixelWithBucketedValue() {
        // Given
        mockBucketer.mockBucket = "6-10"
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // When
        sut.fireOfferSelectionMonthlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricStartClickedMonthly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "6-10")
    }

    func testFireOfferSelectionYearlyPixel_triggersPixelWithBucketedValue() {
        // Given
        mockBucketer.mockBucket = "11-15"
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // When
        sut.fireOfferSelectionYearlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricStartClickedYearly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "11-15")
    }

    func testFireSubscriptionStartedMonthlyPixel_triggersPixelWithBucketedValue() {
        // Given
        mockBucketer.mockBucket = "16-20"
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // When
        sut.fireSubscriptionStartedMonthlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricSubscriptionStartedMonthly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "16-20")
    }

    func testFireSubscriptionStartedYearlyPixel_triggersPixelWithBucketedValue() {
        // Given
        mockBucketer.mockBucket = "21-25"
        sut.incrementPaywallViewCountIfWithinConversionWindow()

        // When
        sut.fireSubscriptionStartedYearlyPixel()

        // Then
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.count, 1)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.metric, FreeTrialsFeatureFlagExperiment.Constants.metricSubscriptionStartedYearly)
        XCTAssertEqual(MockExperimentPixelFirer.firedMetrics.first?.value, "21-25")
    }

    func testFreeTrialParametersIfApplicable_returnsParametersWithinConversionWindow() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        let enrollmentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockFeatureFlagger.mockActiveExperiments = [
            FreeTrialsFeatureFlagExperiment.Constants.subfeatureIdentifier: ExperimentData(
                parentID: "testParentID",
                cohortID: cohort.rawValue,
                enrollmentDate: enrollmentDate
            )
        ]

        // When
        let parameters = sut.oneTimeParameters(for: cohort)

        // Then
        XCTAssertEqual(parameters?[FreeTrialsFeatureFlagExperiment.Constants.freeTrialParameterExperimentName], FreeTrialsFeatureFlagExperiment.Constants.subfeatureIdentifier)
        XCTAssertEqual(parameters?[FreeTrialsFeatureFlagExperiment.Constants.freeTrialParameterExperimentCohort], cohort.rawValue)
    }

    func testFreeTrialParametersIfApplicable_appendsOutsideWhenNotInConversionWindow() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        let enrollmentDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        mockFeatureFlagger.mockActiveExperiments = [
            FreeTrialsFeatureFlagExperiment.Constants.subfeatureIdentifier: ExperimentData(
                parentID: "testParentID",
                cohortID: cohort.rawValue,
                enrollmentDate: enrollmentDate
            )
        ]

        // When
        let parameters = sut.oneTimeParameters(for: cohort)

        // Then
        XCTAssertEqual(parameters?[FreeTrialsFeatureFlagExperiment.Constants.freeTrialParameterExperimentCohort],
                       "\(cohort.rawValue)_outside",
                       "Cohort value should include '_outside' when not in conversion window")
    }

    func testFreeTrialParametersIfApplicable_doesNotReturnParametersIfAlreadyReturned() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        mockUserDefaults.set(true, forKey: FreeTrialsFeatureFlagExperiment.Constants.hasReturnedFreeTrialParametersKey)

        // When
        let parameters = sut.oneTimeParameters(for: cohort)

        // Then
        XCTAssertNil(parameters, "Parameters should not be returned if they have already been returned")
    }

    func testFreeTrialParametersIfApplicable_updatesUserDefaultsCorrectly() {
        // Given
        let cohort: PrivacyProFreeTrialExperimentCohort = .treatment
        mockFeatureFlagger.cohortToReturn = cohort

        // When
        _ = sut.oneTimeParameters(for: cohort)

        // Then
        XCTAssertTrue(mockUserDefaults.bool(forKey: FreeTrialsFeatureFlagExperiment.Constants.hasReturnedFreeTrialParametersKey),
                      "UserDefaults should indicate that parameters have been returned")
    }

    func testGetCohortIfEnabled_returnsTreatmentCohortWhenOverrideEnabled() {
        // Given
        mockUserDefaults.set(true, forKey: FreeTrialsFeatureFlagExperiment.Constants.featureFlagOverrideKey)

        // When
        let cohort = sut.getCohortIfEnabled() as? PrivacyProFreeTrialExperimentCohort

        // Then
        XCTAssertEqual(cohort, .treatment, "Should return the 'treatment' cohort when the override is enabled.")
    }

    func testGetCohortIfEnabled_returnsNilWhenFeatureFlagDisabled() {
        // Given
        mockUserDefaults.set(false, forKey: FreeTrialsFeatureFlagExperiment.Constants.featureFlagOverrideKey)
        mockFeatureFlagger.mockActiveExperiments = [:]

        // When
        let cohort = sut.getCohortIfEnabled()

        // Then
        XCTAssertNil(cohort, "Should return nil when the feature flag is disabled and no override is present.")
    }

    func testGetCohortIfEnabled_returnsCohortFromFeatureFlaggerWhenEnabled() {
        // Given
        let expectedCohort: PrivacyProFreeTrialExperimentCohort = .control
        mockUserDefaults.set(false, forKey: FreeTrialsFeatureFlagExperiment.Constants.featureFlagOverrideKey)
        mockFeatureFlagger.cohortToReturn = expectedCohort

        // When
        let cohort = sut.getCohortIfEnabled() as? PrivacyProFreeTrialExperimentCohort

        // Then
        XCTAssertEqual(cohort, expectedCohort, "Should return the cohort from the feature flagger when the feature flag is enabled.")
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

private final class MockBucketer: Bucketer {
    var mockBucket: String = "Unknown"

    func bucket(for value: Int) -> String {
        return mockBucket
    }
}

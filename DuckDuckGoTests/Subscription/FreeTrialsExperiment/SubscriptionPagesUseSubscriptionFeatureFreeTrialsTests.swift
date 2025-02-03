//
//  SubscriptionPagesUseSubscriptionFeatureFreeTrialsTests.swift
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
import BrowserServicesKit
import SubscriptionTestingUtilities
import Core
@testable import Subscription
@testable import DuckDuckGo


final class SubscriptionPagesUseSubscriptionFeatureFreeTrialsTests: XCTestCase {

    private var sut: SubscriptionPagesUseSubscriptionFeature!

    private var mockSubscriptionManager: SubscriptionManagerMock!
    private var mockAccountManager: AccountManagerMock!
    private var mockStorePurchaseManager: StorePurchaseManagerMock!
    private var mockFreeTrialsFeatureFlagExperiment: MockFreeTrialsFeatureFlagExperiment!
    private var mockAppStorePurchaseFlow: AppStorePurchaseFlowMock!

    override func setUpWithError() throws {
        mockAccountManager = AccountManagerMock()
        mockStorePurchaseManager = StorePurchaseManagerMock()
        mockSubscriptionManager = SubscriptionManagerMock(accountManager: mockAccountManager,
                                                      subscriptionEndpointService: SubscriptionEndpointServiceMock(),
                                                      authEndpointService: AuthEndpointServiceMock(),
                                                          storePurchaseManager: mockStorePurchaseManager,
                                                      currentEnvironment: SubscriptionEnvironment(serviceEnvironment: .production, purchasePlatform: .appStore),
                                                      canPurchase: true,
                                                      subscriptionFeatureMappingCache: SubscriptionFeatureMappingCacheMock())

        mockAppStorePurchaseFlow = AppStorePurchaseFlowMock()
        mockFreeTrialsFeatureFlagExperiment = MockFreeTrialsFeatureFlagExperiment()

        sut = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: mockSubscriptionManager,
                                                      subscriptionFeatureAvailability: SubscriptionFeatureAvailabilityMock.enabled,
                                                      subscriptionAttributionOrigin: nil,
                                                      appStorePurchaseFlow: mockAppStorePurchaseFlow,
                                                      appStoreRestoreFlow: AppStoreRestoreFlowMock(),
                                                      appStoreAccountManagementFlow: AppStoreAccountManagementFlowMock(),
                                                      freeTrialsExperiment: mockFreeTrialsFeatureFlagExperiment)
    }

    func testWhenFreeTrialsCohortIsControl_thenStandardSubscriptionOptionsAreReturned() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockStorePurchaseManager.subscriptionOptionsResult = .mockStandard

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .mockStandard)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.incrementPaywallViewCountCalled)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.firePaywallImpressionPixelCalled)
    }

    func testWhenFreeTrialsCohortIsTreatment_thenFreeTrialSubscriptionOptionsAreReturned() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockStorePurchaseManager.freeTrialSubscriptionOptionsResult = .mockFreeTrial

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .mockFreeTrial)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.incrementPaywallViewCountCalled)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.firePaywallImpressionPixelCalled)
    }

    func testWhenUserIsAuthenticated_thenStandardSubscriptionOptionsAreReturned() async throws {
        // Given
        mockAccountManager.accessToken = "token"
        mockSubscriptionManager.canPurchase = true
        mockStorePurchaseManager.subscriptionOptionsResult = .mockStandard

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .mockStandard)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.incrementPaywallViewCountCalled)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.firePaywallImpressionPixelCalled)
    }

    func testWhenUserCannotPurchase_thenStandardSubscriptionOptionsAreReturned() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = false
        mockStorePurchaseManager.subscriptionOptionsResult = .mockStandard

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .mockStandard)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.incrementPaywallViewCountCalled)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.firePaywallImpressionPixelCalled)
    }

    func testWhenFailedToFetchSubscriptionOptions_thenEmptyOptionsAreReturned() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockStorePurchaseManager.subscriptionOptionsResult = nil

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .empty)
        XCTAssertEqual(sut.transactionError, .failedToGetSubscriptionOptions)
    }

    func testWhenFreeTrialsCohortIsTreatmentAndFreeTrialOptionsAreNil_thenFallbackToStandardOptions() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockStorePurchaseManager.freeTrialSubscriptionOptionsResult = nil
        mockStorePurchaseManager.subscriptionOptionsResult = .mockStandard

        // When
        let result = await sut.getSubscriptionOptions(params: "", original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertEqual(result as? SubscriptionOptions, .mockStandard, "Should return standard subscription options as a fallback when free trial options are nil.")
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.incrementPaywallViewCountCalled, "Paywall view count should be incremented.")
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.firePaywallImpressionPixelCalled, "Paywall impression pixel should be fired.")
    }

    func testWhenMonthlySubscribeSucceedsForTreatment_thenSubscriptionPurchasedMonthlyPixelFired() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "monthly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedMonthlyPixelCalled)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedYearlyPixelCalled)
    }

    func testWhenYearlySubscribeSucceedsForTreatment_thenSubscriptionPurchasedYearlyPixelFired() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "yearly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedMonthlyPixelCalled)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedYearlyPixelCalled)
    }

    func testWhenMonthlySubscribeSucceedsForControl_thenSubscriptionPurchasedMonthlyPixelFired() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "monthly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedMonthlyPixelCalled)
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedYearlyPixelCalled)
    }

    func testWhenYearlySubscribeSucceedsForControl_thenSubscriptionPurchasedYearlyPixelFired() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "yearly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertFalse(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedMonthlyPixelCalled)
        XCTAssertTrue(mockFreeTrialsFeatureFlagExperiment.fireSubscriptionStartedYearlyPixelCalled)
    }

    func testWhenMonthlySubscribeSucceedsForTreatment_thenCompletePurchaseIncludesAdditionalParams() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "monthly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertNotNil(mockAppStorePurchaseFlow.completeSubscriptionAdditionalParams)
    }

    func testWhenYearlySubscribeSucceedsForTreatment_thenCompletePurchaseIncludesAdditionalParams() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "yearly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertNotNil(mockAppStorePurchaseFlow.completeSubscriptionAdditionalParams)
    }

    func testWhenMonthlySubscribeSucceedsForControl_thenCompletePurchaseIncludesAdditionalParams() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "monthly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertNotNil(mockAppStorePurchaseFlow.completeSubscriptionAdditionalParams)
    }

    func testWhenYearlySubscribeSucceedsForControl_thenCompletePurchaseIncludesAdditionalParams() async throws {
        // Given
        mockAccountManager.accessToken = nil
        mockSubscriptionManager.canPurchase = true
        mockFreeTrialsFeatureFlagExperiment.cohortToReturn = PrivacyProFreeTrialExperimentCohort.control
        mockAppStorePurchaseFlow.purchaseSubscriptionResult = .success("")
        mockAppStorePurchaseFlow.completeSubscriptionPurchaseResult = .success(.completed)
        mockAppStorePurchaseFlow.purchaseSubscriptionBlock = { self.mockAccountManager.accessToken = "token" }

        let params: [String: Any] = ["id": "yearly-free-trial"]

        // When
        _ = await sut.subscriptionSelected(params: params, original: MockWKScriptMessage(name: "", body: ""))

        // Then
        XCTAssertNotNil(mockAppStorePurchaseFlow.completeSubscriptionAdditionalParams)
    }
}

private extension SubscriptionOptions {
    static let mockStandard = SubscriptionOptions(platform: .ios,
                                                   options: [
                                                       SubscriptionOption(id: "1",
                                                                          cost: SubscriptionOptionCost(displayPrice: "9", recurrence: "monthly")),
                                                       SubscriptionOption(id: "2",
                                                                          cost: SubscriptionOptionCost(displayPrice: "99", recurrence: "yearly"))
                                                   ],
                                                   features: [
                                                       SubscriptionFeature(name: .networkProtection),
                                                       SubscriptionFeature(name: .dataBrokerProtection),
                                                       SubscriptionFeature(name: .identityTheftRestoration)
                                                   ])

    static let mockFreeTrial = SubscriptionOptions(platform: .ios,
                                                    options: [
                                                        SubscriptionOption(id: "3",
                                                                           cost: SubscriptionOptionCost(displayPrice: "0", recurrence: "monthly-free-trial"), offer: .init(type: .freeTrial, id: "1", durationInDays: 4, isUserEligible: true)),
                                                        SubscriptionOption(id: "4",
                                                                           cost: SubscriptionOptionCost(displayPrice: "0", recurrence: "yearly-free-trial"), offer: .init(type: .freeTrial, id: "1", durationInDays: 4, isUserEligible: true))
                                                    ],
                                                    features: [
                                                        SubscriptionFeature(name: .networkProtection)
                                                    ])
}

private final class MockFreeTrialsFeatureFlagExperiment: FreeTrialsFeatureFlagExperimenting {
    
    typealias CohortType = PrivacyProFreeTrialExperimentCohort
    var rawValue: String = "MockFreeTrialsFeatureFlagExperiment"
    var source: FeatureFlagSource = .remoteReleasable(.subfeature(PrivacyProSubfeature.privacyProFreeTrialJan25))

    var incrementPaywallViewCountCalled = false
    var firePaywallImpressionPixelCalled = false
    var fireOfferSelectionMonthlyPixelCalled = false
    var fireOfferSelectionYearlyPixelCalled = false
    var fireSubscriptionStartedMonthlyPixelCalled = false
    var fireSubscriptionStartedYearlyPixelCalled = false
    var cohortToReturn = PrivacyProFreeTrialExperimentCohort.treatment

    func getCohortIfEnabled() -> (any FeatureFlagCohortDescribing)? {
        cohortToReturn
    }

    func oneTimeParameters(for cohort: any FeatureFlagCohortDescribing) -> [String: String]? {
        [
            FreeTrialsFeatureFlagExperiment.Constants.freeTrialParameterExperimentName: rawValue,
            FreeTrialsFeatureFlagExperiment.Constants.freeTrialParameterExperimentCohort: cohortToReturn.rawValue
        ]
    }

    func incrementPaywallViewCountIfWithinConversionWindow() {
        incrementPaywallViewCountCalled = true
    }

    func firePaywallImpressionPixel() {
        firePaywallImpressionPixelCalled = true
    }

    func fireOfferSelectionMonthlyPixel() {
        fireOfferSelectionMonthlyPixelCalled = true
    }

    func fireOfferSelectionYearlyPixel() {
        fireOfferSelectionYearlyPixelCalled = true
    }

    func fireSubscriptionStartedMonthlyPixel() {
        fireSubscriptionStartedMonthlyPixelCalled = true
    }

    func fireSubscriptionStartedYearlyPixel() {
        fireSubscriptionStartedYearlyPixelCalled = true
    }
}

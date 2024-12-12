//
//  SubscriptionPagesUseSubscriptionFeatureTests.swift
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
@testable import Core
@testable import Subscription
import SubscriptionTestingUtilities
import Common
import WebKit
import BrowserServicesKit
import OHHTTPStubs
import OHHTTPStubsSwift
import os.log
import Networking
import TestUtils

final class SubscriptionPagesUseSubscriptionFeatureTests: XCTestCase {

    private struct Constants {
        static let userDefaultsSuiteName = "SubscriptionPagesUseSubscriptionFeatureTests"

        static let authToken = UUID().uuidString
        static let accessToken = UUID().uuidString
        static let externalID = UUID().uuidString

        static let email = "dax@duck.com"

        static let entitlements: [SubscriptionEntitlement] = [.dataBrokerProtection,
                                                              .identityTheftRestoration,
                                                              .networkProtection]

        static let mostRecentTransactionJWS = "dGhpcyBpcyBub3QgYSByZWFsIEFw(...)cCBTdG9yZSB0cmFuc2FjdGlvbiBKV1M="

        static let subscriptionOptions = SubscriptionOptions(platform: SubscriptionPlatformName.ios,
                                                             options: [
                                                                SubscriptionOption(id: "1",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "9 USD", recurrence: "monthly")),
                                                                SubscriptionOption(id: "2",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "99 USD", recurrence: "yearly"))
                                                             ],
                                                             availableEntitlements: [.networkProtection, .dataBrokerProtection, .identityTheftRestoration])

        static let mockParams: [String: String] = [:]
        @MainActor static let mockScriptMessage = MockWKScriptMessage(name: "", body: "", webView: WKWebView() )
    }

    var userDefaults: UserDefaults!

//    var subscriptionService: SubscriptionEndpointServiceMock!

    var storePurchaseManager: StorePurchaseManagerMock!
    var subscriptionEnvironment: SubscriptionEnvironment!

    var subscriptionFeatureMappingCache: SubscriptionFeatureMappingCacheMock!
    var subscriptionFeatureFlagger: FeatureFlaggerMapping<SubscriptionFeatureFlags>!

    var appStorePurchaseFlow: AppStorePurchaseFlow!
    var appStoreRestoreFlow: AppStoreRestoreFlow!
    var subscriptionManager: SubscriptionManagerMock!
    var subscriptionFeatureAvailability = SubscriptionFeatureAvailabilityMock.enabled

    var feature: SubscriptionPagesUseSubscriptionFeature!

    var pixelsFired: [String] = []

    override func setUpWithError() throws {
        throw XCTSkip("Potentially flaky")
        // Pixels
        Pixel.isDryRun = false
        stub(condition: isHost("improving.duckduckgo.com")) { request -> HTTPStubsResponse in
            if let path = request.url?.path {
                let pixelName = path.dropping(prefix: "/t/")
                    .dropping(suffix: "_ios_phone")
                    .dropping(suffix: "_ios_tablet")
                self.pixelsFired.append(pixelName)
            }

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        // Reset all daily pixel storage
        [Pixel.storage, DailyPixel.storage, UniquePixel.storage].forEach { storage in
            storage.dictionaryRepresentation().keys.forEach(storage.removeObject(forKey:))
        }

        // Mocks
        storePurchaseManager = StorePurchaseManagerMock()
        subscriptionEnvironment = SubscriptionEnvironment(serviceEnvironment: .production,
                                                           purchasePlatform: .appStore)
        userDefaults = UserDefaults(suiteName: Constants.userDefaultsSuiteName)!
        userDefaults.removePersistentDomain(forName: Constants.userDefaultsSuiteName)

        subscriptionManager = SubscriptionManagerMock()
        // Real Flows
        appStoreRestoreFlow = DefaultAppStoreRestoreFlow(subscriptionManager: subscriptionManager,
                                                         storePurchaseManager: storePurchaseManager)
        appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionManager: subscriptionManager,
                                                           storePurchaseManager: storePurchaseManager,
                                                           appStoreRestoreFlow: appStoreRestoreFlow)
        feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                          subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                          subscriptionAttributionOrigin: nil,
                                                          appStorePurchaseFlow: appStorePurchaseFlow,
                                                          appStoreRestoreFlow: appStoreRestoreFlow)
    }

    override func tearDownWithError() throws {
        Pixel.isDryRun = true
        pixelsFired.removeAll()
        HTTPStubs.removeAllStubs()
        storePurchaseManager = nil
        subscriptionEnvironment = nil
        userDefaults = nil
        appStorePurchaseFlow = nil
        appStoreRestoreFlow = nil
        subscriptionManager = nil
        feature = nil
    }

    // MARK: - Tests for getSubscription

    func testGetSubscriptionSuccessRefreshingAuthToken() async throws {
        // Given
        ensureUserAuthenticatedState()
        subscriptionManager.resultTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
        // When
        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])

        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], subscriptionManager.resultTokenContainer?.accessToken)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetSubscriptionSuccessErrorWhenUnauthenticated() async throws {
        // Given
        ensureUserUnauthenticatedState()
        storePurchaseManager.mostRecentTransactionResult = nil
        subscriptionManager.resultTokenContainer = nil
        // When
        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])

        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], SubscriptionPagesUseSubscriptionFeature.Constants.empty)
        XCTAssertFalse(subscriptionManager.isUserAuthenticated)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for getSubscriptionOptions

    func testGetSubscriptionOptionsSuccess() async throws {
        // Given
        storePurchaseManager.subscriptionOptionsResult = Constants.subscriptionOptions

        // When
        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let subscriptionOptionsResult = try XCTUnwrap(result as? SubscriptionOptions)

        XCTAssertEqual(subscriptionOptionsResult, Constants.subscriptionOptions)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetSubscriptionOptionsReturnsEmptyOptionsWhenNoSubscriptionOptions() async throws {
        // Given
        storePurchaseManager.subscriptionOptionsResult = nil

        // When
        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let subscriptionOptionsResult = try XCTUnwrap(result as? SubscriptionOptions)
        XCTAssertEqual(subscriptionOptionsResult, SubscriptionOptions.empty)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .failedToGetSubscriptionOptions)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetSubscriptionOptionsReturnsEmptyOptionsWhenPurchaseNotAllowed() async throws {
        // Given
        let subscriptionFeatureAvailabilityWithoutPurchaseAllowed = SubscriptionFeatureAvailabilityMock(
            isFeatureAvailable: true,
            isSubscriptionPurchaseAllowed: false,
            usesUnifiedFeedbackForm: true
        )

        feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                          subscriptionFeatureAvailability: subscriptionFeatureAvailabilityWithoutPurchaseAllowed,
                                                          subscriptionAttributionOrigin: nil,
                                                          appStorePurchaseFlow: appStorePurchaseFlow,
                                                          appStoreRestoreFlow: appStoreRestoreFlow)

        storePurchaseManager.subscriptionOptionsResult = Constants.subscriptionOptions

        // When
        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let subscriptionOptionsResult = try XCTUnwrap(result as? SubscriptionOptions)
        XCTAssertEqual(subscriptionOptionsResult, SubscriptionOptions.empty)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for subscriptionSelected

    func testSubscriptionSelectedSuccessWhenPurchasingFirstTime() async throws {
        // Given
        ensureUserUnauthenticatedState()

        XCTAssertFalse(subscriptionManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
        storePurchaseManager.mostRecentTransactionResult = nil

//        authService.createAccountResult = .success(CreateAccountResponse(authToken: Constants.authToken,
//                                                                         externalID: Constants.externalID,
//                                                                         status: "created"))
//        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
//        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
//        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
//                                                                                     subscription: SubscriptionMockFactory.subscription))
        subscriptionManager.resultSubscription = SubscriptionMockFactory.subscription
        subscriptionManager.resultTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_d",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_c",
                                           Pixel.Event.privacyProSubscriptionActivated.name,
                                           Pixel.Event.privacyProSuccessfulSubscriptionAttribution.name])
    }

    func testSubscriptionSelectedSuccessWhenRepurchasingForExpiredAppleSubscription() async throws {
        // Given
        ensureUserAuthenticatedState()

        XCTAssertTrue(subscriptionManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredSubscription)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.expiredSubscription

//        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
//                                                                   email: Constants.email,
//                                                                   externalID: Constants.externalID,
//                                                                   id: 1,
//                                                                   status: "authenticated"))
//        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
//        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionManager.resultTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()

        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
//        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
//                                                                                     subscription: SubscriptionMockFactory.subscription))

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
//        XCTAssertFalse(authService.createAccountCalled)
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_d",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_c",
                                           Pixel.Event.privacyProSubscriptionActivated.name,
                                           Pixel.Event.privacyProSuccessfulSubscriptionAttribution.name])
    }

    func testSubscriptionSelectedSuccessWhenRepurchasingForExpiredStripeSubscription() async throws {
        // Given
        ensureUserAuthenticatedState()

        XCTAssertTrue(subscriptionManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.expiredStripeSubscription
        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
//        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
//                                                                                     subscription: SubscriptionMockFactory.subscription))

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
//        XCTAssertFalse(authService.createAccountCalled)
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)
        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_d",
                                           Pixel.Event.privacyProPurchaseSuccess.name + "_c",
                                           Pixel.Event.privacyProSubscriptionActivated.name,
                                           Pixel.Event.privacyProSuccessfulSubscriptionAttribution.name])
    }

    func testSubscriptionSelectedErrorWhenPurchasingWhenHavingActiveSubscription() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = true

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .hasActiveSubscription)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c",
                                           Pixel.Event.privacyProRestoreAfterPurchaseAttempt.name])
    }

    func testSubscriptionSelectedErrorWhenPurchasingWhenUnauthenticatedAndHavingActiveSubscriptionOnAppleID() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = true

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .hasActiveSubscription)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c",
                                           Pixel.Event.privacyProRestoreAfterPurchaseAttempt.name])
    }

    func testSubscriptionSelectedErrorWhenUnauthenticatedAndAccountCreationFails() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
        storePurchaseManager.mostRecentTransactionResult = nil

//        authService.createAccountResult = .failure(Constants.invalidTokenError)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .accountCreationFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenPurchaseCancelledByUser() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.purchaseCancelledByUser)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .cancelledByUser)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenProductNotFound() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.productNotFound)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenExternalIDIsNotValidUUID() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.externalIDisNotAValidUUID)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenPurchaseFailed() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.purchaseFailed)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenTransactionCannotBeVerified() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.transactionCannotBeVerified)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorWhenTransactionPendingAuthentication() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.transactionPendingAuthentication)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    func testSubscriptionSelectedErrorDueToUnknownPurchaseError() async throws {
        // Given
        ensureUserAuthenticatedState()

        storePurchaseManager.hasActiveSubscriptionResult = false
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .failure(StorePurchaseManagerError.unknownError)

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertTrue(storePurchaseManager.purchaseSubscriptionCalled)

        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .purchaseFailed)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProPurchaseAttempt.name + "_d",
                                           Pixel.Event.privacyProPurchaseAttempt.name + "_c"])
    }

    // MARK: - Tests for setSubscription

    func testSetSubscriptionSuccess() async throws {
        // Given
        ensureUserUnauthenticatedState()

//        authService.getAccessTokenResult = .success(.init(accessToken: Constants.accessToken))
//        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.subscription
        subscriptionManager.resultExchangeTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        // When
        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        let tokens = try await subscriptionManager.getTokenContainer(policy: .local)
        // Then
        XCTAssertEqual(tokens, subscriptionManager.resultExchangeTokenContainer)

        await fulfillment(of: [onSetSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testSetSubscriptionErrorWhenFailedToExchangeToken() async throws {
        // Given
        ensureUserUnauthenticatedState()

//        subscriptionManager.resultSubscription = SubscriptionMockFactory.subscription
        subscriptionManager.resultExchangeTokenContainer = nil

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        onSetSubscriptionCalled.isInverted = true
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        // When
        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(subscriptionManager.isUserAuthenticated)

        await fulfillment(of: [onSetSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .failedToSetSubscription)

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for activateSubscription

    func testActivateSubscriptionTokenSuccess() async throws {
        // Given
        ensureUserAuthenticatedState()

        let onActivateSubscriptionCalled = expectation(description: "onActivateSubscription")
        feature.onActivateSubscription = {
            onActivateSubscriptionCalled.fulfill()
        }

        // When
        let result = await feature.activateSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        await fulfillment(of: [onActivateSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        await XCTAssertPrivacyPixelsFired([Pixel.Event.privacyProRestorePurchaseOfferPageEntry.name])
    }

    // MARK: - Tests for featureSelected

    func testFeatureSelectedSuccess() async throws {
        // Given
        ensureUserAuthenticatedState()

        let onFeatureSelectedCalled = expectation(description: "onFeatureSelected")
        feature.onFeatureSelected = { selection in
            onFeatureSelectedCalled.fulfill()
            XCTAssertEqual(selection, .identityTheftRestoration)
        }

        // When
        let featureSelectionParams = ["productFeature": SubscriptionEntitlement.identityTheftRestoration.rawValue]
        let result = await feature.featureSelected(params: featureSelectionParams, original: Constants.mockScriptMessage)

        // Then
        await fulfillment(of: [onFeatureSelectedCalled], timeout: 0.5)
        XCTAssertNil(result)

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for backToSettings

    func testBackToSettingsSuccess() async throws {
        // Given
        ensureUserAuthenticatedState()

        XCTAssertNil(subscriptionManager.userEmail)

        let onBackToSettingsCalled = expectation(description: "onBackToSettings")
        feature.onBackToSettings = {
            onBackToSettingsCalled.fulfill()
        }

//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.subscription)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.subscription

        // When
        let result = await feature.backToSettings(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        await fulfillment(of: [onBackToSettingsCalled], timeout: 0.5)

        XCTAssertEqual(subscriptionManager.userEmail, Constants.email)
        XCTAssertNil(result)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testBackToSettingsErrorOnFetchingAccountDetails() async throws {
        // Given
        ensureUserAuthenticatedState()

        let onBackToSettingsCalled = expectation(description: "onBackToSettings")
        onBackToSettingsCalled.isInverted = true
        feature.onBackToSettings = {
            onBackToSettingsCalled.fulfill()
        }

//        authService.validateTokenResult = .failure(Constants.invalidTokenError)

        // When
        let result = await feature.backToSettings(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        await fulfillment(of: [onBackToSettingsCalled], timeout: 0.5)

        XCTAssertEqual(feature.transactionError, .generalError)
        XCTAssertNil(result)

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for getAccessToken
    func testGetAccessTokenSuccess() async throws {
        // Given
        ensureUserAuthenticatedState()

        // When
        let result = try await feature.getAccessToken(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], Constants.accessToken)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetAccessTokenEmptyOnMissingToken() async throws {
        // Given
        ensureUserUnauthenticatedState()
        XCTAssertFalse(subscriptionManager.isUserAuthenticated)

        // When
        let result = try await feature.getAccessToken(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])
        XCTAssertEqual(resultDictionary, [String: String]())

        await XCTAssertPrivacyPixelsFired([])
    }

    // MARK: - Tests for restoreAccountFromAppStorePurchase

    func testRestoreAccountFromAppStorePurchaseSuccess() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
//        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
//                                                                   email: Constants.email,
//                                                                   externalID: Constants.externalID,
//                                                                   id: 1, status: "authenticated"))
//        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
//        authService.validateTokenResult = .success(Constants.validateTokenResponse)
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.subscription)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.subscription
        subscriptionManager.resultExchangeTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()
        // When
        try await feature.restoreAccountFromAppStorePurchase()

        // Then
        XCTAssertTrue(subscriptionManager.isUserAuthenticated)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testRestoreAccountFromAppStorePurchaseErrorDueToExpiredSubscription() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
//        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
//                                                                   email: Constants.email,
//                                                                   externalID: Constants.externalID,
//                                                                   id: 1, status: "authenticated"))
//        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
//        authService.validateTokenResult = .success(Constants.validateTokenResponse)
//        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredSubscription)
        subscriptionManager.resultSubscription = SubscriptionMockFactory.expiredSubscription
        subscriptionManager.resultExchangeTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()

        do {
            // When
            try await feature.restoreAccountFromAppStorePurchase()
            XCTFail("Unexpected success")
        } catch let error {
            // Then
            guard let error = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError else {
                XCTFail("Unexpected error type")
                return
            }

            XCTAssertEqual(error, .subscriptionExpired)
            XCTAssertFalse(subscriptionManager.isUserAuthenticated)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)

            await XCTAssertPrivacyPixelsFired([])
        }
    }

    func testRestoreAccountFromAppStorePurchaseErrorDueToNoTransaction() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = nil

        do {
            // When
            try await feature.restoreAccountFromAppStorePurchase()
            XCTFail("Unexpected success")
        } catch let error {
            // Then
            guard let error = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError else {
                XCTFail("Unexpected error type")
                return
            }

            XCTAssertEqual(error, .subscriptionNotFound)
            XCTAssertFalse(subscriptionManager.isUserAuthenticated)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)

            await XCTAssertPrivacyPixelsFired([])
        }
    }

    func testRestoreAccountFromAppStorePurchaseErrorDueToOtherError() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
//        authService.storeLoginResult = .failure(Constants.invalidTokenError)

        do {
            // When
            try await feature.restoreAccountFromAppStorePurchase()
            XCTFail("Unexpected success")
        } catch let error {
            // Then
            guard let error = error as? SubscriptionPagesUseSubscriptionFeature.UseSubscriptionError else {
                XCTFail("Unexpected error type")
                return
            }

            XCTAssertEqual(error, .failedToRestorePastPurchase)
            XCTAssertFalse(subscriptionManager.isUserAuthenticated)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)

            await XCTAssertPrivacyPixelsFired([])
        }
    }
}

extension SubscriptionPagesUseSubscriptionFeatureTests {

    func ensureUserAuthenticatedState() {
        subscriptionManager.resultExchangeTokenContainer = OAuthTokensFactory.makeValidTokenContainerWithEntitlements()
    }

    func ensureUserUnauthenticatedState() {
        subscriptionManager.resultExchangeTokenContainer = nil
    }

    public func XCTAssertPrivacyPixelsFired(_ pixels: [String], file: StaticString = #file, line: UInt = #line) async {
        try? await Task.sleep(interval: 0.1)

        let pixelsFired = Set(pixelsFired)
        let expectedPixels = Set(pixels)

        // Assert expected pixels were fired
        XCTAssertTrue(expectedPixels.isSubset(of: pixelsFired),
                      "Expected Privacy Pro pixels were not fired: \(expectedPixels.subtracting(pixelsFired))",
                      file: file,
                      line: line)

        // Assert no other Privacy Pro pixels were fired except the expected
        let privacyProPixelPrefix = "m_privacy-pro"
        let otherPixels = pixelsFired.subtracting(expectedPixels)
        let otherPrivacyProPixels = otherPixels.filter { $0.hasPrefix(privacyProPixelPrefix) }
        XCTAssertTrue(otherPrivacyProPixels.isEmpty,
                      "Unexpected Privacy Pro pixels fired: \(otherPrivacyProPixels)",
                      file: file,
                      line: line)
    }
}

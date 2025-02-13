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

final class SubscriptionPagesUseSubscriptionFeatureTests: XCTestCase {

    private struct Constants {
        static let userDefaultsSuiteName = "SubscriptionPagesUseSubscriptionFeatureTests"

        static let authToken = UUID().uuidString
        static let accessToken = UUID().uuidString
        static let externalID = UUID().uuidString

        static let email = "dax@duck.com"

        static let entitlements = [Entitlement(product: .dataBrokerProtection),
                                   Entitlement(product: .identityTheftRestoration),
                                   Entitlement(product: .networkProtection)]

        static let mostRecentTransactionJWS = "dGhpcyBpcyBub3QgYSByZWFsIEFw(...)cCBTdG9yZSB0cmFuc2FjdGlvbiBKV1M="

        static let subscriptionOptions = SubscriptionOptions(platform: SubscriptionPlatformName.ios,
                                                             options: [
                                                                SubscriptionOption(id: "1",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "9 USD", recurrence: "monthly")),
                                                                SubscriptionOption(id: "2",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "99 USD", recurrence: "yearly"))
                                                             ],
                                                             features: [
                                                                SubscriptionFeature(name: .networkProtection),
                                                                SubscriptionFeature(name: .dataBrokerProtection),
                                                                SubscriptionFeature(name: .identityTheftRestoration)
                                                             ])

        static let validateTokenResponse = ValidateTokenResponse(account: ValidateTokenResponse.Account(email: Constants.email,
                                                                                                        entitlements: Constants.entitlements,
                                                                                                        externalID: Constants.externalID))

        static let mockParams: [String: String] = [:]
        @MainActor static let mockScriptMessage = MockWKScriptMessage(name: "", body: "", webView: WKWebView() )

        static let invalidTokenError = APIServiceError.serverError(statusCode: 401, error: "invalid_token")
    }

    var userDefaults: UserDefaults!

    var accountStorage: AccountKeychainStorageMock!
    var accessTokenStorage: SubscriptionTokenKeychainStorageMock!
    var entitlementsCache: UserDefaultsCache<[Entitlement]>!

    var subscriptionService: SubscriptionEndpointServiceMock!
    var authService: AuthEndpointServiceMock!

    var storePurchaseManager: StorePurchaseManagerMock!
    var subscriptionEnvironment: SubscriptionEnvironment!

    var subscriptionFeatureMappingCache: SubscriptionFeatureMappingCacheMock!

    var appStorePurchaseFlow: AppStorePurchaseFlow!
    var appStoreRestoreFlow: AppStoreRestoreFlow!
    var appStoreAccountManagementFlow: AppStoreAccountManagementFlow!

    var accountManager: AccountManager!
    var subscriptionManager: SubscriptionManager!
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
        subscriptionService = SubscriptionEndpointServiceMock()
        authService = AuthEndpointServiceMock()

        storePurchaseManager = StorePurchaseManagerMock()
        subscriptionEnvironment = SubscriptionEnvironment(serviceEnvironment: .production,
                                                           purchasePlatform: .appStore)
        accountStorage = AccountKeychainStorageMock()
        accessTokenStorage = SubscriptionTokenKeychainStorageMock()

        userDefaults = UserDefaults(suiteName: Constants.userDefaultsSuiteName)!
        userDefaults.removePersistentDomain(forName: Constants.userDefaultsSuiteName)

        entitlementsCache = UserDefaultsCache<[Entitlement]>(userDefaults: userDefaults,
                                                             key: UserDefaultsCacheKey.subscriptionEntitlements,
                                                             settings: UserDefaultsCacheSettings(defaultExpirationInterval: .minutes(20)))

        subscriptionFeatureMappingCache = SubscriptionFeatureMappingCacheMock()

        // Real AccountManager
        accountManager = DefaultAccountManager(storage: accountStorage,
                                               accessTokenStorage: accessTokenStorage,
                                               entitlementsCache: entitlementsCache,
                                               subscriptionEndpointService: subscriptionService,
                                               authEndpointService: authService)

        // Real Flows
        appStoreRestoreFlow = DefaultAppStoreRestoreFlow(accountManager: accountManager,
                                                         storePurchaseManager: storePurchaseManager,
                                                         subscriptionEndpointService: subscriptionService,
                                                         authEndpointService: authService)

        appStorePurchaseFlow = DefaultAppStorePurchaseFlow(subscriptionEndpointService: subscriptionService,
                                                           storePurchaseManager: storePurchaseManager,
                                                           accountManager: accountManager,
                                                           appStoreRestoreFlow: appStoreRestoreFlow,
                                                           authEndpointService: authService)

        appStoreAccountManagementFlow = DefaultAppStoreAccountManagementFlow(authEndpointService: authService,
                                                                             storePurchaseManager: storePurchaseManager,
                                                                             accountManager: accountManager)
        // Real SubscriptionManager
        subscriptionManager = DefaultSubscriptionManager(storePurchaseManager: storePurchaseManager,
                                                         accountManager: accountManager,
                                                         subscriptionEndpointService: subscriptionService,
                                                         authEndpointService: authService,
                                                         subscriptionFeatureMappingCache: subscriptionFeatureMappingCache,
                                                         subscriptionEnvironment: subscriptionEnvironment)

        feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                          subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                          subscriptionAttributionOrigin: nil,
                                                          appStorePurchaseFlow: appStorePurchaseFlow,
                                                          appStoreRestoreFlow: appStoreRestoreFlow,
                                                          appStoreAccountManagementFlow: appStoreAccountManagementFlow)
    }

    override func tearDownWithError() throws {
        Pixel.isDryRun = true
        pixelsFired.removeAll()
        HTTPStubs.removeAllStubs()

        subscriptionService = nil
        authService = nil
        storePurchaseManager = nil
        subscriptionEnvironment = nil

        userDefaults = nil

        accountStorage = nil
        accessTokenStorage = nil

        entitlementsCache?.reset()
        entitlementsCache = nil

        accountManager = nil

        // Real Flows
        appStorePurchaseFlow = nil
        appStoreRestoreFlow = nil
        appStoreAccountManagementFlow = nil

        subscriptionManager = nil

        feature = nil
    }

    // MARK: - Tests for getSubscription

    func testGetSubscriptionSuccessRefreshingAuthToken() async throws {
        // Given
        ensureUserAuthenticatedState()

        let newAuthToken = UUID().uuidString

        authService.validateTokenResult = .failure(Constants.invalidTokenError)
        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
        authService.storeLoginResult = .success(StoreLoginResponse(authToken: newAuthToken,
                                                                   email: Constants.email,
                                                                   externalID: Constants.externalID,
                                                                   id: 1, status: "authenticated"))

        // When
        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])

        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], newAuthToken)
        XCTAssertEqual(accountManager.authToken, newAuthToken)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetSubscriptionSuccessWithoutRefreshingAuthToken() async throws {
        // Given
        ensureUserAuthenticatedState()

        authService.validateTokenResult = .success(Constants.validateTokenResponse)

        // When
        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])

        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], Constants.authToken)
        XCTAssertEqual(accountManager.authToken, Constants.authToken)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testGetSubscriptionSuccessErrorWhenUnauthenticated() async throws {
        // Given
        ensureUserUnauthenticatedState()

        authService.validateTokenResult = .failure(Constants.invalidTokenError)
        storePurchaseManager.mostRecentTransactionResult = nil

        // When
        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        let resultDictionary = try XCTUnwrap(result as? [String: String])

        XCTAssertEqual(resultDictionary[SubscriptionPagesUseSubscriptionFeature.Constants.token], SubscriptionPagesUseSubscriptionFeature.Constants.empty)
        XCTAssertFalse(accountManager.isUserAuthenticated)

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
            isSubscriptionPurchaseAllowed: false,
            usesUnifiedFeedbackForm: true
        )

        feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                          subscriptionFeatureAvailability: subscriptionFeatureAvailabilityWithoutPurchaseAllowed,
                                                          subscriptionAttributionOrigin: nil,
                                                          appStorePurchaseFlow: appStorePurchaseFlow,
                                                          appStoreRestoreFlow: appStoreRestoreFlow,
                                                          appStoreAccountManagementFlow: appStoreAccountManagementFlow)

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

        XCTAssertFalse(accountManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
        storePurchaseManager.mostRecentTransactionResult = nil

        authService.createAccountResult = .success(CreateAccountResponse(authToken: Constants.authToken,
                                                                         externalID: Constants.externalID,
                                                                         status: "created"))
        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
                                                                                     entitlements: Constants.entitlements,
                                                                                     subscription: SubscriptionMockFactory.appleSubscription))

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

        XCTAssertTrue(accountManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredSubscription)

        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
                                                                   email: Constants.email,
                                                                   externalID: Constants.externalID,
                                                                   id: 1,
                                                                   status: "authenticated"))
        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
                                                                                     entitlements: Constants.entitlements,
                                                                                     subscription: SubscriptionMockFactory.appleSubscription))

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(authService.createAccountCalled)
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

        XCTAssertTrue(accountManager.isUserAuthenticated)

        storePurchaseManager.hasActiveSubscriptionResult = false
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
        storePurchaseManager.purchaseSubscriptionResult = .success(Constants.mostRecentTransactionJWS)
        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
                                                                                     entitlements: Constants.entitlements,
                                                                                     subscription: SubscriptionMockFactory.appleSubscription))

        // When
        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertFalse(authService.createAccountCalled)
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

        authService.createAccountResult = .failure(Constants.invalidTokenError)

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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredStripeSubscription)
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

        authService.getAccessTokenResult = .success(.init(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        // When
        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertEqual(accountManager.authToken, Constants.authToken)
        XCTAssertEqual(accountManager.accessToken, Constants.accessToken)
        XCTAssertEqual(accountManager.email, Constants.email)
        XCTAssertEqual(accountManager.externalID, Constants.externalID)

        await fulfillment(of: [onSetSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testSetSubscriptionErrorWhenFailedToExchangeToken() async throws {
        // Given
        ensureUserUnauthenticatedState()

        authService.getAccessTokenResult = .failure(Constants.invalidTokenError)

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        onSetSubscriptionCalled.isInverted = true
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        // When
        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertNil(accountManager.authToken)
        XCTAssertFalse(accountManager.isUserAuthenticated)

        await fulfillment(of: [onSetSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, .failedToSetSubscription)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testSetSubscriptionErrorWhenFailedToFetchAccountDetails() async throws {
        // Given
        ensureUserUnauthenticatedState()

        authService.getAccessTokenResult = .success(.init(accessToken: Constants.accessToken))
        authService.validateTokenResult = .failure(Constants.invalidTokenError)

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        onSetSubscriptionCalled.isInverted = true
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        // When
        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        // Then
        XCTAssertNil(accountManager.authToken)
        XCTAssertFalse(accountManager.isUserAuthenticated)

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
        let featureSelectionParams = ["productFeature": Entitlement.ProductName.identityTheftRestoration.rawValue]
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
        accountStorage.email = nil

        XCTAssertNil(accountManager.email)

        let onBackToSettingsCalled = expectation(description: "onBackToSettings")
        feature.onBackToSettings = {
            onBackToSettingsCalled.fulfill()
        }

        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.appleSubscription)

        // When
        let result = await feature.backToSettings(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // Then
        await fulfillment(of: [onBackToSettingsCalled], timeout: 0.5)

        XCTAssertEqual(accountManager.email, Constants.email)
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

        authService.validateTokenResult = .failure(Constants.invalidTokenError)

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
        XCTAssertNil(accountManager.accessToken)

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
        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
                                                                   email: Constants.email,
                                                                   externalID: Constants.externalID,
                                                                   id: 1, status: "authenticated"))
        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.appleSubscription)

        // When
        try await feature.restoreAccountFromAppStorePurchase()

        // Then
        XCTAssertTrue(accountManager.isUserAuthenticated)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)

        await XCTAssertPrivacyPixelsFired([])
    }

    func testRestoreAccountFromAppStorePurchaseErrorDueToExpiredSubscription() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
        authService.storeLoginResult = .success(StoreLoginResponse(authToken: Constants.authToken,
                                                                   email: Constants.email,
                                                                   externalID: Constants.externalID,
                                                                   id: 1, status: "authenticated"))
        authService.getAccessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.expiredSubscription)


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
            XCTAssertFalse(accountManager.isUserAuthenticated)

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
            XCTAssertFalse(accountManager.isUserAuthenticated)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)

            await XCTAssertPrivacyPixelsFired([])
        }
    }

    func testRestoreAccountFromAppStorePurchaseErrorDueToOtherError() async throws {
        // Given
        ensureUserUnauthenticatedState()

        storePurchaseManager.mostRecentTransactionResult = Constants.mostRecentTransactionJWS
        authService.storeLoginResult = .failure(Constants.invalidTokenError)

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
            XCTAssertFalse(accountManager.isUserAuthenticated)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)

            await XCTAssertPrivacyPixelsFired([])
        }
    }
}

extension SubscriptionPagesUseSubscriptionFeatureTests {

    func ensureUserAuthenticatedState() {
        accountStorage.authToken = Constants.authToken
        accountStorage.email = Constants.email
        accountStorage.externalID = Constants.externalID
        accessTokenStorage.accessToken = Constants.accessToken
    }

    func ensureUserUnauthenticatedState() {
        try? accessTokenStorage.removeAccessToken()
        try? accountStorage.clearAuthenticationState()
    }

    public func XCTAssertPrivacyPixelsFired(_ pixels: [String], file: StaticString = #file, line: UInt = #line) async {
        try? await Task.sleep(seconds: 0.1)

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

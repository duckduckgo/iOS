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
@testable import Subscription
import SubscriptionTestingUtilities
import Common
import WebKit
import BrowserServicesKit

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
//
        static let mostRecentTransactionJWS = "dGhpcyBpcyBub3QgYSByZWFsIEFw(...)cCBTdG9yZSB0cmFuc2FjdGlvbiBKV1M="

        static let subscriptionOptions = SubscriptionOptions(platform: SubscriptionPlatformName.ios.rawValue,
                                                             options: [
                                                                SubscriptionOption(id: "1",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "9 USD", recurrence: "monthly")),
                                                                SubscriptionOption(id: "2",
                                                                                   cost: SubscriptionOptionCost(displayPrice: "99 USD", recurrence: "yearly"))
                                                             ],
                                                             features: [
                                                                SubscriptionFeature(name: "vpn"),
                                                                SubscriptionFeature(name: "personal-information-removal"),
                                                                SubscriptionFeature(name: "identity-theft-restoration")
                                                             ])
//        static let storeLoginResponse = StoreLoginResponse(authToken: Constants.authToken,
//                                                           email: "",
//                                                           externalID: Constants.externalID,
//                                                           id: 1,
//                                                           status: "ok")
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

    var appStorePurchaseFlow: AppStorePurchaseFlow!
    var appStoreRestoreFlow: AppStoreRestoreFlow!
    var appStoreAccountManagementFlow: AppStoreAccountManagementFlow!

//    var accountManager: AccountManagerMock!
//    var subscriptionManager: SubscriptionManagerMock!

    var accountManager: AccountManager!
    var subscriptionManager: SubscriptionManager!

    var feature: SubscriptionPagesUseSubscriptionFeature!

    override func setUpWithError() throws {
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
                                                         subscriptionEnvironment: subscriptionEnvironment)

        feature = SubscriptionPagesUseSubscriptionFeature(subscriptionManager: subscriptionManager,
                                                          subscriptionAttributionOrigin: nil,
                                                          appStorePurchaseFlow: appStorePurchaseFlow,
                                                          appStoreRestoreFlow: appStoreRestoreFlow,
                                                          appStoreAccountManagementFlow: appStoreAccountManagementFlow)
    }

    override func tearDownWithError() throws {
        AppDependencyProvider.shared = AppDependencyProvider()

        subscriptionService = nil
        authService = nil
        storePurchaseManager = nil
        subscriptionEnvironment = nil

        userDefaults = nil

        accountStorage = nil
        accessTokenStorage = nil

        entitlementsCache.reset()
        entitlementsCache = nil

        // Real AccountManager
        accountManager = nil

        // Real Flows
        appStorePurchaseFlow = nil
        appStoreRestoreFlow = nil
        appStoreAccountManagementFlow = nil
        // Real SubscriptionManager
        subscriptionManager = nil

        feature = nil
    }

    // MARK: - Tests for getSubscription

    func testGetSubscription() async throws {
        ensureUserAuthenticatedState()

        let newAuthToken = UUID().uuidString

        authService.validateTokenResult = .failure(Constants.invalidTokenError)
        storePurchaseManager.onMostRecentTransaction = { Constants.mostRecentTransactionJWS }
        authService.storeLoginResult = .success(StoreLoginResponse(authToken: newAuthToken,
                                                                   email: Constants.email,
                                                                   externalID: Constants.externalID,
                                                                   id: 1, status: "ok"))

        let result = await feature.getSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? [String: String] {
            XCTAssertEqual(result[SubscriptionPagesUseSubscriptionFeature.Constants.token], newAuthToken)
            XCTAssertEqual(accountManager.authToken, newAuthToken)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)
        } else {
            XCTFail("Incorrect return type")
        }
    }

    // MARK: - Tests for getSubscriptionOptions

    func testGetSubscriptionOptionsSuccess() async throws {
        storePurchaseManager.subscriptionOptionsResult = Constants.subscriptionOptions

        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? SubscriptionOptions {
            XCTAssertEqual(result, Constants.subscriptionOptions)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)
        } else {
            XCTFail("Incorrect return type")
        }
    }

    func testGetSubscriptionOptionsReturnsEmptyOptionsWhenNoSubscriptionOptions() async throws {
        storePurchaseManager.subscriptionOptionsResult = nil

        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? SubscriptionOptions {
            XCTAssertEqual(result, SubscriptionOptions.empty)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, .failedToGetSubscriptionOptions)
        } else {
            XCTFail("Incorrect return type")
        }
    }

    func testGetSubscriptionOptionsReturnsEmptyOptionsWhenPurchaseNotAllowed() async throws {
        let mockDependencyProvider = MockDependencyProvider()
        mockDependencyProvider.subscriptionFeatureAvailability = SubscriptionFeatureAvailabilityMock(isFeatureAvailable: true,
                                                                                                     isSubscriptionPurchaseAllowed: false,
                                                                                                     usesUnifiedFeedbackForm: true)
        AppDependencyProvider.shared = mockDependencyProvider

        storePurchaseManager.subscriptionOptionsResult = Constants.subscriptionOptions

        let result = await feature.getSubscriptionOptions(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? SubscriptionOptions {
            XCTAssertEqual(result, SubscriptionOptions.empty)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)
        } else {
            XCTFail("Incorrect return type")
        }
    }

    // MARK: - Tests for subscriptionSelected

    func testSubscriptionSelectedSuccessWhenPurchasingFirstTime() async throws {
        ensureUserUnauthenticatedState()

        XCTAssertFalse(accountManager.isUserAuthenticated)

        storePurchaseManager.onHasActiveSubscription = { false }
        storePurchaseManager.onMostRecentTransaction = { nil }

        authService.createAccountResult = .success(CreateAccountResponse(authToken: Constants.authToken,
                                                                         externalID: Constants.externalID,
                                                                         status: ""))
        authService.accessTokenResult = .success(AccessTokenResponse(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        storePurchaseManager.onPurchaseSubscription = { _, _ in .success(Constants.mostRecentTransactionJWS) }
        subscriptionService.confirmPurchaseResult = .success(ConfirmPurchaseResponse(email: Constants.email,
                                                                                     entitlements: Constants.entitlements,
                                                                                     subscription: SubscriptionMockFactory.subscription))

        let subscriptionSelectedParams = ["id": "some-subscription-id"]
        let result = await feature.subscriptionSelected(params: subscriptionSelectedParams, original: Constants.mockScriptMessage)
        // TODO: Check pixel fired: DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseAttempt)
            // DailyPixel.fireDailyAndCount(pixel: .privacyProPurchaseSuccess)
            // UniquePixel.fire(pixel: .privacyProSubscriptionActivated)
            // Pixel.fireAttribution(pixel: .privacyProSuccessfulSubscriptionAttribution, origin: subscriptionAttributionOrigin, privacyProDataReporter: privacyProDataReporter)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)
    }

    // MARK: - Tests for setSubscription

    func testSetSubscriptionTokenSuccess() async throws {
        ensureUserUnauthenticatedState()

        authService.accessTokenResult = .success(.init(accessToken: Constants.accessToken))
        authService.validateTokenResult = .success(Constants.validateTokenResponse)

        let onSetSubscriptionCalled = expectation(description: "onSetSubscription")
        feature.onSetSubscription = {
            onSetSubscriptionCalled.fulfill()
        }

        let setSubscriptionParams = ["token": Constants.authToken]
        let result = await feature.setSubscription(params: setSubscriptionParams, original: Constants.mockScriptMessage)

        XCTAssertEqual(accountManager.authToken, Constants.authToken)
        XCTAssertEqual(accountManager.accessToken, Constants.accessToken)
        XCTAssertEqual(accountManager.email, Constants.email)
        XCTAssertEqual(accountManager.externalID, Constants.externalID)

        await fulfillment(of: [onSetSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)

        XCTAssertEqual(feature.transactionStatus, .idle)
        XCTAssertEqual(feature.transactionError, nil)
    }

    // MARK: - Tests for activateSubscription

    func testActivateSubscriptionTokenSuccess() async throws {
        ensureUserAuthenticatedState()

        let onActivateSubscriptionCalled = expectation(description: "onActivateSubscription")
        feature.onActivateSubscription = {
            onActivateSubscriptionCalled.fulfill()
        }

        let result = await feature.activateSubscription(params: Constants.mockParams, original: Constants.mockScriptMessage)

        // TODO: Check pixel fired: Pixel.fire(pixel: .privacyProRestorePurchaseOfferPageEntry, debounce: 2)
        await fulfillment(of: [onActivateSubscriptionCalled], timeout: 0.5)
        XCTAssertNil(result)
    }

    // MARK: - Tests for featureSelected

    func testFeatureSelectedSuccess() async throws {
        
        struct FeatureSelection: Codable {
            let feature: String
        }

        ensureUserAuthenticatedState()

        let onFeatureSelectedCalled = expectation(description: "onFeatureSelected")
        feature.onFeatureSelected = { selection in
            onFeatureSelectedCalled.fulfill()
            XCTAssertEqual(selection, SubscriptionFeatureSelection.itr)
        }

        let featureSelectionParams = ["feature": SubscriptionFeatureName.itr]
        let result = await feature.featureSelected(params: featureSelectionParams, original: Constants.mockScriptMessage)

        await fulfillment(of: [onFeatureSelectedCalled], timeout: 0.5)
        XCTAssertNil(result)
    }

    // MARK: - Tests for backToSettings

    func testBackToSettingsSuccess() async throws {
        ensureUserAuthenticatedState()
        accountStorage.email = nil

        XCTAssertNil(accountManager.email)

        let onBackToSettingsCalled = expectation(description: "onBackToSettings")
        feature.onBackToSettings = {
            onBackToSettingsCalled.fulfill()
        }

        authService.validateTokenResult = .success(Constants.validateTokenResponse)
        subscriptionService.getSubscriptionResult = .success(SubscriptionMockFactory.subscription)

        let result = await feature.backToSettings(params: Constants.mockParams, original: Constants.mockScriptMessage)

        await fulfillment(of: [onBackToSettingsCalled], timeout: 0.5)

        XCTAssertEqual(accountManager.email, Constants.email)
        XCTAssertNil(result)
    }


    // MARK: - Tests for getAccessToken
    func testGetAccessTokenSuccess() async throws {
        ensureUserAuthenticatedState()

        let result = try await feature.getAccessToken(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? [String: String] {
            XCTAssertEqual(result[SubscriptionPagesUseSubscriptionFeature.Constants.token], Constants.accessToken)

            XCTAssertEqual(feature.transactionStatus, .idle)
            XCTAssertEqual(feature.transactionError, nil)
        } else {
            XCTFail("Incorrect return type")
        }
    }

    func testGetAccessTokenEmptyOnMissingToken() async throws {
        ensureUserUnauthenticatedState()
        XCTAssertNil(accountManager.accessToken)

        let result = try await feature.getAccessToken(params: Constants.mockParams, original: Constants.mockScriptMessage)

        if let result = result as? [String: String] {
            XCTAssertEqual(result, [String: String]())
        } else {
            XCTFail("Incorrect return type")
        }
    }

    // MARK: - Tests for restoreAccountFromAppStorePurchase

    func testRestoreAccountFromAppStorePurchaseSuccess() async throws {
        // uses appStoreRestoreFlow
        // TODO:

        ensureUserAuthenticatedState()
    }

    // MARK: - Tests for mapAppStoreRestoreErrorToTransactionError

    func testMapAppStoreRestoreErrorToTransactionErrorSuccess() async throws {
        // TODO:

        ensureUserAuthenticatedState()
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
}

class SubscriptionFeatureAvailabilityMock: SubscriptionFeatureAvailability {
    var isFeatureAvailable: Bool
    var isSubscriptionPurchaseAllowed: Bool
    var usesUnifiedFeedbackForm: Bool

    init(isFeatureAvailable: Bool, isSubscriptionPurchaseAllowed: Bool, usesUnifiedFeedbackForm: Bool) {
        self.isFeatureAvailable = isFeatureAvailable
        self.isSubscriptionPurchaseAllowed = isSubscriptionPurchaseAllowed
        self.usesUnifiedFeedbackForm = usesUnifiedFeedbackForm
    }

}

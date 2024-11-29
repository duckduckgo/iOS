//
//  StorePurchaseManagerTests.swift
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
@testable import Subscription
import SubscriptionTestingUtilities
import StoreKitTest

final class StorePurchaseManagerTests: XCTestCase {

    private struct Constants {
        static let externalID = UUID().uuidString
        static let monthlySubscriptionID = "ios.subscription.1month"
        static let yearlySubscriptionID = "ios.subscription.1year"
    }

    var session: SKTestSession!
    var storePurchaseManager: StorePurchaseManager!

    override func setUpWithError() throws {
        throw XCTSkip("Possibly flaky")
        let path = Bundle.main.url(forResource: "Subscription", withExtension: "storekit")

        session = try SKTestSession(contentsOf: path!)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()

        let subscriptionFeatureMappingCache = SubscriptionFeatureMappingCacheMock()
        storePurchaseManager = DefaultStorePurchaseManager(subscriptionFeatureMappingCache: subscriptionFeatureMappingCache)
    }

    override func tearDownWithError() throws {
        storePurchaseManager = nil
        session = nil
    }

    func testSubscriptionOptionsWhenNoCachedProducts() async throws {
        // When
        let subscriptionOptions = await storePurchaseManager.subscriptionOptions()

        // Then
        XCTAssertNil(subscriptionOptions)
        XCTAssertFalse(storePurchaseManager.areProductsAvailable)
    }

    func testSubscriptionOptionsWhenAvailableProductsWereUpdated() async throws {
        // Given
        await storePurchaseManager.updateAvailableProducts()

        // When
        guard let subscriptionOptions = await storePurchaseManager.subscriptionOptions() else {
            XCTFail("Expected subscription options")
            return
        }

        // Then
        XCTAssertEqual(subscriptionOptions.options.count, 2)
        XCTAssertEqual(subscriptionOptions.features.count, 3)
        XCTAssertTrue(storePurchaseManager.areProductsAvailable)

        let optionIDs = subscriptionOptions.options.map { $0.id }
        XCTAssertTrue(optionIDs.contains(Constants.monthlySubscriptionID))
        XCTAssertTrue(optionIDs.contains(Constants.yearlySubscriptionID))
    }

    func testHasActiveSubscriptionIsFalseWithoutPurchase() async throws {
        // When
        let hasActiveSubscription = await storePurchaseManager.hasActiveSubscription()
        
        // Then
        XCTAssertFalse(hasActiveSubscription)
    }

    func testPurchaseSubscription() async throws {
        // Given
        await storePurchaseManager.updateAvailableProducts()

        XCTAssertEqual(storePurchaseManager.purchasedProductIDs, [])

        // When
        let result = await storePurchaseManager.purchaseSubscription(with: Constants.yearlySubscriptionID, externalID: Constants.externalID)

        // Then
        switch result {
        case .success:
            XCTAssertTrue(storePurchaseManager.purchaseQueue.isEmpty)
            XCTAssertEqual(storePurchaseManager.purchasedProductIDs, [Constants.yearlySubscriptionID])

            let transactions = await StoreKitHelpers.currentEntitlements()
            XCTAssertEqual(transactions.count, 1)
            XCTAssertEqual(transactions.first!.appAccountToken?.uuidString, Constants.externalID)

            let hasActiveSubscription = await storePurchaseManager.hasActiveSubscription()
            XCTAssertTrue(hasActiveSubscription)
        case .failure:
            XCTFail("Unexpected failure")
        }
    }

    func testPurchaseSubscriptionFailureWithoutValidProductID() async throws {
        // Given
        await storePurchaseManager.updateAvailableProducts()

        // When
        let result = await storePurchaseManager.purchaseSubscription(with: "", externalID: Constants.externalID)

        // Then
        switch result {
        case .success:
            XCTFail("Unexpected success")
        case .failure(let error):
            XCTAssertEqual(error, StorePurchaseManagerError.productNotFound)
        }
    }

    func testPurchaseSubscriptionFailureWithoutValidUUID() async throws {
        // Given
        await storePurchaseManager.updateAvailableProducts()

        let invalidUUID = "a"
        XCTAssertNil(UUID(uuidString: invalidUUID))

        // When
        let result = await storePurchaseManager.purchaseSubscription(with: Constants.yearlySubscriptionID, externalID: invalidUUID)

        // Then
        switch result {
        case .success:
            XCTFail("Unexpected success")
        case .failure(let error):
            XCTAssertEqual(error, StorePurchaseManagerError.externalIDisNotAValidUUID)
        }
    }

    @available(iOS 17.0, *)
    func testPurchaseSubscriptionFailure() async throws {
        // Given
        try? await session.setSimulatedError(SKTestFailures.Purchase.purchase(.productUnavailable),
                                             forAPI: StoreKitPurchaseAPI.purchase)

        await storePurchaseManager.updateAvailableProducts()

        // When
        let result = await storePurchaseManager.purchaseSubscription(with: Constants.yearlySubscriptionID, externalID: Constants.externalID)

        // Then
        switch result {
        case .success:
            XCTFail("Unexpected success")
        case .failure(let error):
            XCTAssertEqual(error, StorePurchaseManagerError.purchaseFailed)
        }
    }
}

private final class StoreKitHelpers {

    static func currentEntitlements() async -> [Transaction] {
        return await Transaction.currentEntitlements.compactMap { result in
            try? checkVerified(result)
        }.reduce(into: [], { $0.append($1) })
    }

    static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
}

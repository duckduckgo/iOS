//
//  AppStorePurchaseFlow.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import StoreKit

@available(macOS 12.0, iOS 15.0, *)
public final class AppStorePurchaseFlow {

    public enum Error: Swift.Error {
        case noProductsFound

        case activeSubscriptionAlreadyPresent
        case authenticatingWithTransactionFailed
        case accountCreationFailed
        case purchaseFailed

        case missingEntitlements

        case somethingWentWrong
    }

    public static func subscriptionOptions() async -> Result<SubscriptionOptions, AppStorePurchaseFlow.Error> {

        let products = PurchaseManager.shared.availableProducts

        let monthly = products.first(where: { $0.id.contains("1month") })
        let yearly = products.first(where: { $0.id.contains("1year") })

        guard let monthly, let yearly else { return .failure(.noProductsFound) }

        let options = [SubscriptionOption(id: monthly.id, cost: .init(displayPrice: monthly.displayPrice, recurrence: "monthly")),
                       SubscriptionOption(id: yearly.id, cost: .init(displayPrice: yearly.displayPrice, recurrence: "yearly"))]

        let features = SubscriptionFeatureName.allCases.map { SubscriptionFeature(name: $0.rawValue) }

        return .success(SubscriptionOptions(platform: SubscriptionPlatformName.macos.rawValue,
                                            options: options,
                                            features: features))
    }

    public static func purchaseSubscription(with subscriptionIdentifier: String, emailAccessToken: String?) async -> Result<Void, AppStorePurchaseFlow.Error> {
        let accountManager = AccountManager()
        let externalID: String

        // Check for past transactions most recent
        switch await AppStoreRestoreFlow.restoreAccountFromPastPurchase() {
        case .success:
            return .failure(.activeSubscriptionAlreadyPresent)
        case .failure(let error):
            switch error {
            case .subscriptionExpired(let expiredAccountDetails):
                externalID = expiredAccountDetails.externalID
                accountManager.storeAuthToken(token: expiredAccountDetails.authToken)
                accountManager.storeAccount(token: expiredAccountDetails.accessToken,
                                            email: expiredAccountDetails.email,
                                            externalID: expiredAccountDetails.externalID)
            case .missingAccountOrTransactions, .pastTransactionAuthenticationError:
                // No history, create new account
                switch await AuthService.createAccount(emailAccessToken: emailAccessToken) {
                case .success(let response):
                    externalID = response.externalID

                    if case let .success(accessToken) = await accountManager.exchangeAuthTokenToAccessToken(response.authToken),
                       case let .success(accountDetails) = await accountManager.fetchAccountDetails(with: accessToken) {
                        accountManager.storeAuthToken(token: response.authToken)
                        accountManager.storeAccount(token: accessToken, email: accountDetails.email, externalID: accountDetails.externalID)
                    }
                case .failure:
                    return .failure(.accountCreationFailed)
                }
            default:
                return .failure(.authenticatingWithTransactionFailed)
            }
        }

        // Make the purchase
        switch await PurchaseManager.shared.purchaseSubscription(with: subscriptionIdentifier, externalID: externalID) {
        case .success:
            return .success(())
        case .failure(let error):
            print("Something went wrong, reason: \(error)")
            AccountManager().signOut()
            return .failure(.purchaseFailed)
        }
    }

    @discardableResult
    public static func completeSubscriptionPurchase() async -> Result<PurchaseUpdate, AppStorePurchaseFlow.Error> {

        let result = await checkForEntitlements(wait: 2.0, retry: 30)

        return result ? .success(PurchaseUpdate(type: "completed")) : .failure(.missingEntitlements)
    }

    @discardableResult
    public static func checkForEntitlements(wait waitTime: Double, retry retryCount: Int) async -> Bool {
        var count = 0
        var hasEntitlements = false

        repeat {
            hasEntitlements = await !AccountManager().fetchEntitlements().isEmpty

            if hasEntitlements {
                break
            } else {
                count += 1
                try? await Task.sleep(seconds: waitTime)
            }
        } while !hasEntitlements && count < retryCount

        return hasEntitlements
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

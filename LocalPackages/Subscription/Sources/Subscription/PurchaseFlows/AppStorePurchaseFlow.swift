//
//  AppStorePurchaseFlow.swift
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
import Purchase
import Account

@available(macOS 12.0, *)
public final class AppStorePurchaseFlow {

    public enum Error: Swift.Error {
        case appStoreAuthenticationFailed
        case authenticatingWithTransactionFailed
        case accountCreationFailed
        case purchaseFailed
        case somethingWentWrong
    }

    public static func purchaseSubscription(with identifier: String, emailAccessToken: String?) async -> Result<Void, AppStorePurchaseFlow.Error> {
        // Trigger sign in pop-up
        switch await PurchaseManager.shared.syncAppleIDAccount() {
        case .success:
            break
        case .failure:
            return .failure(.appStoreAuthenticationFailed)
        }

        let externalID: String

        // Check for past transactions most recent
        switch await AppStoreRestoreFlow.restoreAccountFromPastPurchase() {
        case .success(let existingExternalID):
            externalID = existingExternalID
        case .failure(let error):
            switch error {
            case .missingAccountOrTransactions:
                // No history, create new account
                switch await AuthService.createAccount(emailAccessToken: emailAccessToken) {
                case .success(let response):
                    externalID = response.externalID
                    await AccountManager().exchangeAndStoreTokens(with: response.authToken)
                case .failure:
                    return .failure(.accountCreationFailed)
                }
            default:
                return .failure(.authenticatingWithTransactionFailed)
            }
        }

        // Make the purchase
        switch await PurchaseManager.shared.purchaseSubscription(with: identifier, externalID: externalID) {
        case .success:
            return .success(())
        case .failure(let error):
            print("Something went wrong, reason: \(error)")
            AccountManager().signOut()
            return .failure(.purchaseFailed)
        }
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

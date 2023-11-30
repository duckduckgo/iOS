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

@available(macOS 12.0, iOS 15.0, *)
public final class AppStoreRestoreFlow {

    public typealias Success = (externalID: String, isActive: Bool)

    public enum Error: Swift.Error {
        case missingAccountOrTransactions
        case pastTransactionAuthenticationFailure
        case accessTokenObtainingError
//        case subscriptionExpired
        case somethingWentWrong
    }

    public static func restoreAccountFromPastPurchase() async -> Result<AppStoreRestoreFlow.Success, AppStoreRestoreFlow.Error> {
        guard let lastTransactionJWSRepresentation = await PurchaseManager.mostRecentTransaction() else { return .failure(.missingAccountOrTransactions) }

        // Do the store login to get short-lived token
        let authToken: String

        switch await AuthService.storeLogin(signature: lastTransactionJWSRepresentation) {
        case .success(let response):
            authToken = response.authToken
        case .failure:
            return .failure(.pastTransactionAuthenticationFailure)
        }

        let externalID: String

        switch await AccountManager().exchangeAndStoreTokens(with: authToken) {
        case .success(let existingExternalID):
            externalID = existingExternalID
        case .failure:
            return .failure(.accessTokenObtainingError)
        }

        let accessToken = AccountManager().accessToken ?? ""
        var isActive = false

        switch await SubscriptionService.getSubscriptionInfo(token: accessToken) {
        case .success(let response):
            isActive = response.status != "Expired" && response.status != "Inactive"
        case .failure:
            return .failure(.somethingWentWrong)
        }

        // TOOD: Fix this by probably splitting/changing result of exchangeAndStoreTokens
        return .success((externalID: externalID, isActive: isActive))
    }
}

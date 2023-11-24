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
public final class AppStoreRestoreFlow {

    public enum Error: Swift.Error {
        case missingAccountOrTransactions
        case pastTransactionAuthenticationFailure
        case accessTokenObtainingError
        case somethingWentWrong
    }

    public static func restoreAccountFromPastPurchase() async -> Result<String, AppStoreRestoreFlow.Error> {
        guard let lastTransactionJWSRepresentation = await PurchaseManager.mostRecentTransaction() else { return .failure(.missingAccountOrTransactions) }

        // Do the store login to get short-lived token
        let authToken: String

        switch await AuthService.storeLogin(signature: lastTransactionJWSRepresentation) {
        case .success(let response):
            authToken = response.authToken
        case .failure:
            return .failure(.pastTransactionAuthenticationFailure)
        }

        switch await AccountManager().exchangeAndStoreTokens(with: authToken) {
        case .success(let externalID):
            return .success(externalID)
        case .failure:
            return .failure(.accessTokenObtainingError)
        }
    }
}

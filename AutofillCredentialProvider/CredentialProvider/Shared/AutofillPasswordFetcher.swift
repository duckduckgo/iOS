//
//  AutofillPasswordFetcher.swift
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

import Foundation
import AuthenticationServices
import BrowserServicesKit
import Core
import SecureStorage

class CredentialFetcher {

    private let secureVault: (any AutofillSecureVault)?

    init(secureVault: (any AutofillSecureVault)?) {
        self.secureVault = secureVault
    }

    func fetchCredential(for account: SecureVaultModels.WebsiteAccount) -> ASPasswordCredential {
        let password = fetchPassword(for: account)
        return ASPasswordCredential(user: account.username ?? "", password: password)
    }

    private func fetchPassword(for account: SecureVaultModels.WebsiteAccount) -> String {
        do {
            if let accountID = account.id, let accountIdInt = Int64(accountID), let vault = secureVault {
                if let credential = try vault.websiteCredentialsFor(accountId: accountIdInt) {
                    return credential.password.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                }
            }
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
        }

        return ""
    }
}

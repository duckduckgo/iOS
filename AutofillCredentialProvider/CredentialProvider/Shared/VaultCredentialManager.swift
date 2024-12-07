//
//  VaultCredentialManager.swift
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

protocol VaultCredentialManaging: AnyObject {
    func fetchCredential(for account: SecureVaultModels.WebsiteAccount) -> ASPasswordCredential
    func fetchCredential(for identity: ASPasswordCredentialIdentity) -> ASPasswordCredential?
    @available(iOS 17.0, *)
    func fetchCredential(for identity: ASCredentialIdentity) -> ASPasswordCredential?
}

final class VaultCredentialManager: VaultCredentialManaging {

    private let secureVault: (any AutofillSecureVault)?
    private let credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging

    init(secureVault: (any AutofillSecureVault)?,
         credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging) {
        self.secureVault = secureVault
        self.credentialIdentityStoreManager = credentialIdentityStoreManager
    }

    func fetchCredential(for account: SecureVaultModels.WebsiteAccount) -> ASPasswordCredential {
        let password = retrievePassword(for: account)

        updateLastUsed(for: account)

        return ASPasswordCredential(user: account.username ?? "", password: password)
    }

    func fetchCredential(for identity: ASPasswordCredentialIdentity) -> ASPasswordCredential? {
        return fetchCredentialHelper(for: identity.user, recordIdentifier: identity.recordIdentifier)
    }

    @available(iOS 17.0, *)
    func fetchCredential(for identity: ASCredentialIdentity) -> ASPasswordCredential? {
        return fetchCredentialHelper(for: identity.user, recordIdentifier: identity.recordIdentifier)
    }

    // MARK: - Private

    private func retrievePassword(for account: SecureVaultModels.WebsiteAccount) -> String {
        guard let accountID = account.id, let accountIdInt = Int64(accountID), let credentials = retrieveCredentials(for: accountIdInt) else {
            return ""
        }

        return credentials.password.flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }

    private func fetchCredentialHelper(for user: String, recordIdentifier: String?) -> ASPasswordCredential? {
        guard let recordIdentifier = recordIdentifier,
              let accountIdInt = Int64(recordIdentifier),
              let credentials = retrieveCredentials(for: accountIdInt) else {
            return nil
        }

        let passwordCredential = ASPasswordCredential(user: user,
                                                      password: credentials.password.flatMap { String(data: $0, encoding: .utf8) } ?? "")

        updateLastUsed(for: credentials.account)

        return passwordCredential
    }

    private func retrieveCredentials(for accountId: Int64) -> SecureVaultModels.WebsiteCredentials? {
        guard let vault = secureVault else { return nil }
        do {
            return try vault.websiteCredentialsFor(accountId: accountId)
        } catch {
            Pixel.fire(pixel: .secureVaultError, error: error)
            return nil
        }
    }

    private func updateLastUsed(for account: SecureVaultModels.WebsiteAccount) {
        if let accountID = account.id, let accountIdInt = Int64(accountID), let vault = secureVault {
            do {
                try vault.updateLastUsedFor(accountId: accountIdInt)

                Task {
                    if let domain = account.domain {
                        await credentialIdentityStoreManager.updateCredentialStore(for: domain)
                    }
                }
            } catch {
                Pixel.fire(pixel: .secureVaultError, error: error)
            }
        }
    }
}

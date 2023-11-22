//
//  SaveAutofillLoginManager.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

protocol SaveAutofillLoginManagerProtocol {
    
    var username: String { get }
    var visiblePassword: String { get }
    var isNewAccount: Bool { get }
    var accountDomain: String { get }
    var isPasswordOnlyAccount: Bool { get }
    var hasOtherCredentialsOnSameDomain: Bool { get }
    var hasSavedMatchingPasswordWithoutUsername: Bool { get }
    var hasSavedMatchingUsername: Bool { get }
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: AutofillVaultFactory) throws -> Int64
}

final class SaveAutofillLoginManager: SaveAutofillLoginManagerProtocol {
    private(set) var credentials: SecureVaultModels.WebsiteCredentials
    let vaultManager: SecureVaultManager
    let autofillScript: AutofillUserScript
    private var domainStoredCredentials: [SecureVaultModels.WebsiteCredentials] = []
    
    internal init(credentials: SecureVaultModels.WebsiteCredentials,
                  vaultManager: SecureVaultManager,
                  autofillScript: AutofillUserScript) {
        self.credentials = credentials
        self.vaultManager = vaultManager
        self.autofillScript = autofillScript
        
    }
    
    // If we have a stored credential with the same password on an empty username account
    // we want to update it instead of creating a new one
    private func useStoredCredentialIfNecessary() {
        if var storedCredential = savedMatchingPasswordWithoutUsername {
            storedCredential.account.username = credentials.account.username
            credentials = storedCredential
        }
    }
    
    var username: String {
        credentials.account.username ?? ""
    }
    
    var visiblePassword: String {
        credentials.password.flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
    
    var isNewAccount: Bool {
        credentials.account.id == nil
    }
    
    var accountDomain: String {
        credentials.account.domain ?? ""
    }

    var isPasswordOnlyAccount: Bool {
        !visiblePassword.isEmpty && username.isEmpty
    }
    
    var hasSavedMatchingPasswordWithoutUsername: Bool {
        savedMatchingPasswordWithoutUsername != nil
    }
    
    var hasSavedMatchingUsername: Bool {
        savedMatchingUsernameCredential != nil
    }
    
    func prepareData(completion: @escaping () -> Void) {
        fetchDomainStoredCredentials { [weak self] credentials in
            self?.domainStoredCredentials = credentials
            self?.useStoredCredentialIfNecessary()
            completion()
        }
    }

    func isNeverPromptWebsiteForDomain() -> Bool {
        guard let domain = credentials.account.domain else {
            return false
        }
        return AppDependencyProvider.shared.autofillNeverPromptWebsitesManager.hasNeverPromptWebsitesFor(domain: domain)
    }

    private var savedMatchingPasswordWithoutUsername: SecureVaultModels.WebsiteCredentials? {
        let credentialsWithSamePassword = domainStoredCredentials.filter { storedCredentials in
            storedCredentials.password == credentials.password && (storedCredentials.account.username?.count ?? 0) == 0
        }
        return credentialsWithSamePassword.first
    }
    
    private var savedMatchingUsernameCredential: SecureVaultModels.WebsiteCredentials? {
        let credentialsWithSameUsername = domainStoredCredentials.filter { $0.account.username == credentials.account.username }
        return credentialsWithSameUsername.first
    }
    
    private func fetchDomainStoredCredentials(completion: @escaping ([SecureVaultModels.WebsiteCredentials]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            var result = [SecureVaultModels.WebsiteCredentials]()
            
            self.vaultManager.autofillUserScript(self.autofillScript,
                                                 didRequestAccountsForDomain: self.accountDomain) { [weak self] accounts, _ in
                guard let self = self else { return }
                accounts.forEach { account in
                    
                    if let credentialID = account.id {
                        self.vaultManager.autofillUserScript(self.autofillScript,
                                                             didRequestCredentialsForAccount: credentialID) { credentials, _ in
                            
                            if let credentials = credentials {
                                result.append(credentials)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }

    var hasOtherCredentialsOnSameDomain: Bool {
        domainStoredCredentials.count > 0
    }
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: AutofillVaultFactory) throws -> Int64 {
        do {
            return try AutofillSecureVaultFactory.makeVault(errorReporter: SecureVaultErrorReporter.shared).storeWebsiteCredentials(credentials)
        } catch {
            throw error
        }
    }
}

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
    var hasSavedMatchingPassword: Bool { get }
    var hasSavedMatchingUsername: Bool { get }
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws -> Int64
}

struct SaveAutofillLoginManager: SaveAutofillLoginManagerProtocol {
    private(set) var credentials: SecureVaultModels.WebsiteCredentials
    let vaultManager: SecureVaultManager
    let autofillScript: AutofillUserScript
    
    internal init(credentials: SecureVaultModels.WebsiteCredentials, vaultManager: SecureVaultManager, autofillScript: AutofillUserScript) {
        self.credentials = credentials
        self.vaultManager = vaultManager
        self.autofillScript = autofillScript
        
        useStoredCredentialIfNecessary()
    }
    
    // If we have stored credential with the same password we want to update it instead of creating a new one
    private mutating func useStoredCredentialIfNecessary() {
        if savedMatchingPasswordCredential != nil {
            var storedCredential = savedMatchingPasswordCredential!
            storedCredential.account.username = credentials.account.username
            credentials = storedCredential
        }
    }
    
    var username: String {
        credentials.account.username
    }
    
    var visiblePassword: String {
        String(data: credentials.password, encoding: .utf8) ?? ""
    }
    
    var isNewAccount: Bool {
        credentials.account.id == nil
    }
    
    var accountDomain: String {
        credentials.account.domain
    }

    var isPasswordOnlyAccount: Bool {
        !visiblePassword.isEmpty && username.isEmpty
    }
    
    var hasSavedMatchingPassword: Bool {
        savedMatchingPasswordCredential != nil
    }
    
    var hasSavedMatchingUsername: Bool {
        savedMatchingUsernameCredential != nil
    }
    
    private var savedMatchingPasswordCredential: SecureVaultModels.WebsiteCredentials? {
        let credentialsWithSamePassword = domainStoredCredentials.filter { $0.password == credentials.password }
        return credentialsWithSamePassword.first
    }
    
    private var savedMatchingUsernameCredential: SecureVaultModels.WebsiteCredentials? {
        let credentialsWithSameUsername = domainStoredCredentials.filter { $0.account.username == credentials.account.username }
        return credentialsWithSameUsername.first
    }
    
    private var domainStoredCredentials: [SecureVaultModels.WebsiteCredentials] {
        let semaphore = DispatchSemaphore(value: 0)
        var result = [SecureVaultModels.WebsiteCredentials]()
        
        vaultManager.autofillUserScript(autofillScript, didRequestAccountsForDomain: accountDomain) { accounts in
            accounts.forEach { account in
                
                if let credentialID = account.id {
                    vaultManager.autofillUserScript(autofillScript, didRequestCredentialsForAccount: credentialID) { credentials in
                        
                        if let credentials = credentials {
                            result.append(credentials)
                        }
                    }
                }
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    var hasOtherCredentialsOnSameDomain: Bool {
        domainStoredCredentials.count > 0
    }
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws -> Int64 {

        do {
            return try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared).storeWebsiteCredentials(credentials)
        } catch {
            throw error
        }
    }
}

//
//  AutofillCredentialManager.swift
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

protocol AutofillCredentialManagerProtocol {
    
    var username: String { get }
    var visiblePassword: String { get }
    var isNewAccount: Bool { get }
    var accountDomain: String { get }
    var isUsernameOnlyAccount: Bool { get }
    var isPasswordOnlyAccount: Bool { get }
    var hasOtherCredentialsOnSameDomain: Bool { get }
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws
}

struct AutofillCredentialManager: AutofillCredentialManagerProtocol {
    let credentials: SecureVaultModels.WebsiteCredentials
    let vaultManager: SecureVaultManager
    let autofillScript: AutofillUserScript
    
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

    var isUsernameOnlyAccount: Bool {
        visiblePassword.isEmpty && !username.isEmpty
    }
    
    var isPasswordOnlyAccount: Bool {
        !visiblePassword.isEmpty && username.isEmpty
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
    
    static func saveCredentials(_ credentials: SecureVaultModels.WebsiteCredentials, with factory: SecureVaultFactory) throws {
        try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared).storeWebsiteCredentials(credentials)
    }
}

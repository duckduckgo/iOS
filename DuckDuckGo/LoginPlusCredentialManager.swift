//
//  LoginPlusCredentialManager.swift
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

struct LoginPlusCredentialManager {
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
    
    var hiddenPassword: String {
        String(visiblePassword.map { _ in "*" })
    }
    
    var accountDomain: String {
        credentials.account.domain
    }
    
    var isLoginOnlyAccount: Bool {
        visiblePassword.isEmpty && !username.isEmpty
    }
    
    var isPasswordOnlyAccount: Bool {
        !visiblePassword.isEmpty && username.isEmpty
    }
    
    func test() {
        vaultManager.autofillUserScript(autofillScript, didRequestAccountsForDomain: accountDomain) { accounts in
            accounts.forEach { account in
                print("ACCOUNT \(account.username) DOMAIN \(account.domain)")
                
                if let accountID = account.id {
                    vaultManager.autofillUserScript(autofillScript, didRequestCredentialsForAccount: accountID) { credential in
                      
                        if let credential = credential {
                            let pass = String(data: credential.password, encoding: .utf8) ?? ""
                            print("USER \(credential.account.username) PASS \(pass)")
                        }
                    }
                } 
            }
        }
    }
}

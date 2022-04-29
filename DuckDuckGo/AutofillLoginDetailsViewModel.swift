//
//  AutofillLoginDetailsViewModel.swift
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

final class AutofillLoginDetailsViewModel: ObservableObject {
    let account: SecureVaultModels.WebsiteAccount
    @Published var username: String
    @Published var password: String
    
    internal init(account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        self.username = account.username
        self.password = ""
    }
    
    func save() {
        print("USER \(username) PASS \(password)")
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                                                                 
                if var credential = try vault.websiteCredentialsFor(accountId: accountID) {
                    credential.account.username = username
                    try vault.storeWebsiteCredentials(credential)
                }
            }
            
        } catch {
            
        }
    }
}

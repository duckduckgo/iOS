//
//  AutofillLoginListItemViewModel.swift
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
import UIKit
import Common

final class AutofillLoginListItemViewModel: Identifiable, Hashable {
    
    var preferredFaviconLetters: String {
        let accountName = self.account.name(tld: tld, autofillDomainNameUrlMatcher: urlMatcher)
        let accountTitle = (account.title?.isEmpty == false) ? account.title! : "#"
        return tld.eTLDplus1(accountName) ?? accountTitle
    }
    
    let account: SecureVaultModels.WebsiteAccount
    let title: String
    let subtitle: String
    let id = UUID()
    let tld: TLD
    let urlMatcher: AutofillDomainNameUrlMatcher

    internal init(account: SecureVaultModels.WebsiteAccount,
                  tld: TLD,
                  autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher,
                  autofillDomainNameUrlSort: AutofillDomainNameUrlSort) {
        self.account = account
        self.tld = tld
        self.title = account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        self.subtitle = account.username ?? ""
        self.urlMatcher = autofillDomainNameUrlMatcher
    }
    
    static func == (lhs: AutofillLoginListItemViewModel, rhs: AutofillLoginListItemViewModel) -> Bool {
        lhs.account.id == rhs.account.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account.id)
    }
}

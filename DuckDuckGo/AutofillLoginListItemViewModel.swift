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
    @Published var image = UIImage(systemName: "globe")!
    
    let account: SecureVaultModels.WebsiteAccount
    let title: String
    let subtitle: String
    let preferredFaviconLetter: String?
    let id = UUID()
    let tld: TLD

    internal init(account: SecureVaultModels.WebsiteAccount,
                  tld: TLD,
                  autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher,
                  autofillDomainNameUrlSort: AutofillDomainNameUrlSort) {
        self.account = account
        self.tld = tld
        self.title = account.name(tld: tld, autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher)
        self.subtitle = account.username
        self.preferredFaviconLetter = account.faviconLetter(tld: tld, autofillDomainNameUrlSort: autofillDomainNameUrlSort)

        fetchImage()
    }
    
    private func fetchImage() {
        FaviconsHelper.loadFaviconSync(forDomain: account.domain,
                                       usingCache: .tabs,
                                       useFakeFavicon: true,
                                       preferredFakeFaviconLetter: preferredFaviconLetter) { image, _ in
            if let image = image {
                self.image = image
            } else {
                self.image = UIImage(systemName: "globe")!
            }
        }
    }
    
    static func == (lhs: AutofillLoginListItemViewModel, rhs: AutofillLoginListItemViewModel) -> Bool {
        lhs.account.id == rhs.account.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(account.id)
    }
}

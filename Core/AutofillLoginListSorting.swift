//
//  AutofillLoginListSorting.swift
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
import BrowserServicesKit
import Common

public extension Array where Element == SecureVaultModels.WebsiteAccount {

    func groupedByFirstLetter(tld: TLD,
                              autofillDomainNameUrlMatcher: AutofillDomainNameUrlMatcher,
                              autofillDomainNameUrlSort: AutofillDomainNameUrlSort)
            -> [String: [AutofillLoginItem]] {
        reduce(into: [String: [AutofillLoginItem]]()) { result, account in

            // Unfortunetly, folding doesn't produce perfect results despite respecting the system locale
            // E.g. Romainian should treat letters with diacritics as seperate letters, but folding doesn't
            // Apple's own apps (e.g. contacts) seem to suffer from the same problem
            let key: String
            if let firstChar = autofillDomainNameUrlSort.firstCharacterForGrouping(account, tld: tld),
               let deDistinctionedChar = String(firstChar).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).first,
               deDistinctionedChar.isLetter {

                key = String(deDistinctionedChar)
            } else {
                key = AutofillLoginListSectionType.miscSectionHeading
            }

            return result[key, default: []].append(AutofillLoginItem(account: account,
                                                                   tld: tld,
                                                                   autofillDomainNameUrlMatcher: autofillDomainNameUrlMatcher,
                                                                   autofillDomainNameUrlSort: autofillDomainNameUrlSort))
        }
    }
}

public extension Dictionary where Key == String, Value == [AutofillLoginItem] {

    func sortedIntoSections(_ autofillDomainNameUrlSort: AutofillDomainNameUrlSort,
                            tld: TLD) -> [AutofillLoginListSectionType] {
        map { dictionaryItem -> AutofillLoginListSectionType in
            let sortedGroup = dictionaryItem.value.sorted(by: {
                autofillDomainNameUrlSort.compareAccountsForSortingAutofill(lhs: $0.account, rhs: $1.account, tld: tld) == .orderedAscending
            })
            return AutofillLoginListSectionType.credentials(title: dictionaryItem.key,
                                                          items: sortedGroup)
        }.sorted()
    }
}

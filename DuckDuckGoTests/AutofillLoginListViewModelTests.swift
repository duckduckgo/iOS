//
//  AutofillLoginListViewModelTests.swift
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

import XCTest
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit

class AutofillLoginListSectionTypeTests: XCTestCase {
    
    func testWhenComparedThenSortedCorrectly() {
        let testData = [AutofillLoginListSectionType.credentials(title: "elephant", items: []),
                        AutofillLoginListSectionType.credentials(title: "èlephant", items: []),
                        AutofillLoginListSectionType.credentials(title: "Elephants", items: []),
                        AutofillLoginListSectionType.credentials(title: "felephants", items: [])]
        
        let result = testData.sorted()
        XCTAssertEqual(testData, result)
    }
}

class AutofillLoginListItemViewModelTests: XCTestCase {
    
    func testWhenCreatingViewModelsThenDiacriticsGroupedCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = [SecureVaultModels.WebsiteAccount(title: nil, username: "c", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "ç", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "C", domain: domain)]
        let result = testData.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter()
        // Diacritics should be grouped with the root letter (in most cases), and grouping should be case insensative
        XCTAssertEqual(result.count, 1)
    }
    
    func testWhenCreatingViewModelsThenNumbersAndSymbolsGroupCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = [SecureVaultModels.WebsiteAccount(title: nil, username: "1", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "0", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "#", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "9", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "3asdasfd", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "~", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "?????", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "&%$£$%", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "99999", domain: domain)]
        let result = testData.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter()
        // All non letters should be grouped together
        XCTAssertEqual(result.count, 1)
    }
}

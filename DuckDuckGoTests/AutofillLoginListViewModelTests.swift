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
        let testData = [AutofillLoginListSectionType.credentials(title: "e", items: []),
                        AutofillLoginListSectionType.credentials(title: "E", items: []),
                        AutofillLoginListSectionType.credentials(title: "è", items: []),
                        AutofillLoginListSectionType.credentials(title: "f", items: [])]
        
        let result = testData.sorted()
        XCTAssertEqual(testData, result)
    }
    
    func testWhenComparedThenSymbolsAreAtTheEnd() {
        func testWhenComparedThenSortedCorrectly() {
            let testData = [AutofillLoginListSectionType.credentials(title: "e", items: []),
                            AutofillLoginListSectionType.credentials(title: "è", items: []),
                            AutofillLoginListSectionType.credentials(title: "#", items: []),
                            AutofillLoginListSectionType.credentials(title: "f", items: [])]
            
            let result = testData.sorted()
            XCTAssertEqual(testData, result)
        }
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
    
    func testWhenCreatingViewModelsThenNumbersAndSymbolsGroupedCorrectly() {
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
    
    func testWhenCreatingSectionsThenTitlesWithinASectionAreSortedCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = ["e": [
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "elephant", username: "1", domain: domain)),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "elephants", username: "2", domain: domain)),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "Elephant", username: "3", domain: domain)),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "èlephant", username: "4", domain: domain)),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "è", username: "5", domain: domain)),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: nil, username: "ezy", domain: domain))]]
        let result = testData.autofillLoginListSectionsForViewModelsSortedByTitle()
        if case .credentials(_, let viewModels) = result[0] {
            XCTAssertEqual(viewModels[0].title, "è")
            XCTAssertEqual(viewModels[1].title, "elephant")
            XCTAssertEqual(viewModels[2].title, "Elephant")
            XCTAssertEqual(viewModels[3].title, "èlephant")
            XCTAssertEqual(viewModels[4].title, "elephants")
        } else {
            XCTFail("Expected section did not exist")
        }
    }
}

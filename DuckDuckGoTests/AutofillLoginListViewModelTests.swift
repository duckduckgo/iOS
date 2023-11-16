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
@testable import Common

// swiftlint:disable line_length
class AutofillLoginListViewModelTests: XCTestCase {

    private let tld = TLD()
    private let appSettings = AppUserDefaults()
    private let vault = (try? MockSecureVaultFactory.makeVault(errorReporter: nil))!
    private var manager: AutofillNeverPromptWebsitesManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        manager = AutofillNeverPromptWebsitesManager(secureVault: vault)
    }

    override func tearDownWithError() throws {
        manager = nil

        try super.tearDownWithError()
    }

    func testWhenOneLoginDeletedWithNoSuggestionsThenAlphabeticalSectionIsDeleted() {
        let accountIdToDelete = "1"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager)
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 1)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 0)
    }

    func testWhenOneLoginDeletedWithNoSuggestionsThenAlphabeticalRowIsDeleted() {
        let accountIdToDelete = "1"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager)
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 0)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 1)
    }

    func testWhenOneSuggestionDeletedThenSuggestedSectionAndAlphabeticalSectionDeleted() {
        let accountIdToDelete = "1"
        let testDomain = "testsite.com"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"))
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 2)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 0)
    }

    func testWhenOneSuggestionDeletedThenSuggestedSectionAndAlphabeticalRowDeleted() {
        let accountIdToDelete = "1"
        let testDomain = "testsite.com"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"))
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 1)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 1)
    }

    func testWhenOneSuggestionDeletedThenSuggestionRowAndAlphabeticalRowDeleted() {
        let accountIdToDelete = "1"
        let testDomain = "testsite.com"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "a@b.com", domain: testDomain, created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "b@c.com", domain: testDomain, created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"))
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 0)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 2)
    }

    func testWhenNoNeverPromptWebsitesSavedThenNeverPromptSectionIsNotShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager)
        XCTAssertEqual(model.rowsInSection(0), 1)
    }

    func testWhenOneNeverPromptWebsiteSavedThenNeverPromptSectionIsShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.com"))
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager)
        XCTAssertEqual(model.rowsInSection(0), 2)
    }

    func testWhenManyNeverPromptWebsiteSavedThenNeverPromptSectionIsShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.co.uk"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("duckduckgo.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("daxisawesome.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("123domain.com"))

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager)
        XCTAssertEqual(model.rowsInSection(0), 2)
    }
}

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

    let tld = TLD()
    let autofillUrlMatcher = AutofillDomainNameUrlMatcher()
    let autofillDomainNameUrlSort = AutofillDomainNameUrlSort()

    func testWhenCreatingViewModelsThenDiacriticsGroupedCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = [SecureVaultModels.WebsiteAccount(title: nil, username: "c", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "ç", domain: domain),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "C", domain: domain)]
        let result = testData.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: tld,
                                                                                             autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                                                                             autofillDomainNameUrlSort: autofillDomainNameUrlSort)
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
        let result = testData.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: tld,
                                                                                             autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                                                                             autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        // All non letters should be grouped together
        XCTAssertEqual(result.count, 1)
    }
    
    func testWhenCreatingSectionsThenTitlesWithinASectionAreSortedCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = ["e": [
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "elephant", username: "1", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "elephants", username: "2", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "Elephant", username: "3", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "èlephant", username: "4", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: "è", username: "5", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginListItemViewModel(account: SecureVaultModels.WebsiteAccount(title: nil, username: "ezy", domain: domain),
                                           tld: tld,
                                           autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                           autofillDomainNameUrlSort: autofillDomainNameUrlSort)]]
        let result = testData.autofillLoginListSectionsForViewModelsSortedByTitle(autofillDomainNameUrlSort,
                                                                                  tld: tld)
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

    func testWhenCreatingSectionsWithoutTitlesThenDomainsGroupedCorrectly() {
        let testData = [SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "example.com"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "sub.example.com"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "example.co.uk"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "example.fr"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "auth.example.fr"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "mylogin.example.co.uk"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "auth.test.example.com"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "https://www.auth.example.com"),
                        SecureVaultModels.WebsiteAccount(title: nil, username: "test", domain: "https://www.example.com")]
        let result = testData.autofillLoginListItemViewModelsForAccountsGroupedByFirstLetter(tld: tld,
                                                                                             autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                                                                             autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        // Diacritics should be grouped with the root letter (in most cases), and grouping should be case insensative
        XCTAssertEqual(result.count, 1)
    }
}
// swiftlint:enable line_length

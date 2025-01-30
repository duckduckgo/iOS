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
import Combine
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit
@testable import Common
@testable import PersistenceTestingUtils

class AutofillLoginListViewModelTests: XCTestCase {

    private let tld = TLD()
    private let appSettings = AppUserDefaults()
    private let vault = (try? MockSecureVaultFactory.makeVault(reporter: nil))!
    private var manager: AutofillNeverPromptWebsitesManager!
    private var cancellables: Set<AnyCancellable> = []
    var syncService: MockDDGSyncing!

    private let configEnabled = """
    {
        "features": {
            "autofillBreakageReporter": {
                "state": "enabled",
                "settings": {
                    "monitorIntervalDays": 42
                },
                "exceptions": [
                    {
                        "domain": "exception.com"
                    }
                ]
            },
            "autofillSurveys": {
                "state": "enabled",
                "settings": {
                    "surveys": [
                      {
                        "id": "123",
                        "url": "https://asurveyurl.com"
                      }
                    ]
                },
            },
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    private let configDisabled = """
    {
        "features": {
            "autofillBreakageReporter": {
                "state": "disabled",
                "settings": {
                    "monitorIntervalDays": 42
                },
                "exceptions": []
            },
             "autofillSurveys": {
                 "state": "disabled",
                 "settings": {
                     "surveys": [
                       {
                         "id": "240900",
                         "url": "https://asurveyurl.com"
                       }
                     ]
                 },
             },
        },
        "unprotectedTemporary": []
    }
    """.data(using: .utf8)!

    override func setUpWithError() throws {
        try super.setUpWithError()
        setupUserDefault(with: #file)
        manager = AutofillNeverPromptWebsitesManager(secureVault: vault)
        syncService = MockDDGSyncing(authState: .inactive, scheduler: CapturingScheduler(), isSyncInProgress: false)
    }

    override func tearDownWithError() throws {
        manager = nil
        cancellables.removeAll()
        syncService = nil

        try super.tearDownWithError()
    }

    func makePrivacyConfig(from rawConfig: Data) -> PrivacyConfiguration {
        let mockEmbeddedData = MockEmbeddedDataProvider(data: rawConfig, etag: "test")
        let mockProtectionStore = MockDomainsProtectionStore()

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: mockProtectionStore,
                                                  internalUserDecider: DefaultInternalUserDecider())
        return manager.privacyConfig
    }

    func testWhenOneLoginDeletedWithNoSuggestionsThenAlphabeticalSectionIsDeleted() {
        let accountIdToDelete = "1"
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: accountIdToDelete, title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
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

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
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

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"), syncService: syncService)
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

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"), syncService: syncService)
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

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"), syncService: syncService)
        let tableContentsToDelete = model.tableContentsToDelete(accountId: accountIdToDelete)
        XCTAssertEqual(tableContentsToDelete.sectionsToDelete.count, 0)
        XCTAssertEqual(tableContentsToDelete.rowsToDelete.count, 2)
    }

    func testWhenMultipleAccountsSavedAndClearAllThenNoAccountsAreShown() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 3)

        model.clearAllAccounts()

        XCTAssertEqual(model.sections.count, 1)
    }

    func testWhenMultipleAccountsSavedAndClearAllThenUndoThenAccountsAreShownAgain() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 3)

        model.clearAllAccounts()

        XCTAssertEqual(model.sections.count, 1)

        model.undoClearAllAccounts()

        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 3)
    }

    func testWhenOneAccountSavedAndClearAllThenUndoThenAccountIsShownAgain() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 1)

        model.clearAllAccounts()

        XCTAssertEqual(model.sections.count, 1)

        model.undoClearAllAccounts()

        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 1)
    }

    func testWhenMultipleAccountsSavedAndOneSuggestionAndClearAllThenUndoThenAccountsAndSuggestionsAreShown() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]
        let testDomain = "testsite.com"
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, currentTabUrl: URL(string: "https://\(testDomain)"), autofillNeverPromptWebsitesManager: manager, privacyConfig: makePrivacyConfig(from: configDisabled), syncService: syncService)
        XCTAssertEqual(model.sections.count, 3)
        XCTAssertEqual(model.rowsInSection(1), 1)
        XCTAssertEqual(model.rowsInSection(2), 3)

        model.clearAllAccounts()

        XCTAssertEqual(model.sections.count, 1)

        model.undoClearAllAccounts()

        XCTAssertEqual(model.sections.count, 3)
        XCTAssertEqual(model.rowsInSection(1), 1)
        XCTAssertEqual(model.rowsInSection(2), 3)
    }

    func testWhenInEditModeThenEnableAutofillSectionIsNotDisplayed() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)

        XCTAssertEqual(model.sections.count, 2)

        model.isEditing = true
        
        XCTAssertEqual(model.sections.count, 1)
    }

    func testWhenSearchingThenEnableAutofillSectionIsNotDisplayed() {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)

        XCTAssertEqual(model.sections.count, 2)

        model.isSearching = true
        model.filterData(with: "z")

        XCTAssertEqual(model.sections.count, 0)

        model.filterData(with: "t")

        XCTAssertEqual(model.sections.count, 1)
    }

    func testWhenOneAccountDeletedInEditModeThenAccountsCountPublisherUpdatesCorrectly() {
        let expectation = XCTestExpectation(description: "accountsCountPublisher emits an updated count")

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
        ]
        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)

        model.isEditing = true
        model.accountsCountPublisher.sink { count in
            XCTAssertEqual(count, model.accountsCount, "The published count should match the number accounts count")
           expectation.fulfill()
        }
        .store(in: &cancellables)

        _ = model.delete(at: IndexPath(row: 1, section: 0))
        wait(for: [expectation], timeout: 1.0)
    }

    func testWhenOneAccountSavedAndDeleteAllThenNoAccountsAreShownAndVaultIsEmpty() throws {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]
        for account in vault.storedAccounts {
            _ = try vault.storeWebsiteCredentials(SecureVaultModels.WebsiteCredentials(account: account, password: nil))
        }

        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(0), 1)
        XCTAssertEqual(model.rowsInSection(1), 1)
        XCTAssertEqual(vault.storedAccounts.count, 1)

        model.isEditing = true
        let result = model.deleteAllCredentials()
        if result {
            model.updateData()
        }
        
        XCTAssertEqual(model.sections.count, 0)
        XCTAssertEqual(vault.storedAccounts.count, 0)
    }

    func testWhenMultipleAccountsSavedAndDeleteAllThenNoAccountsAreShownAndVaultIsEmpty() throws {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite2.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "3", title: nil, username: "", domain: "testsite3.com", created: Date(), lastUpdated: Date())
        ]
        for account in vault.storedAccounts {
            _ = try vault.storeWebsiteCredentials(SecureVaultModels.WebsiteCredentials(account: account, password: nil))
        }

        let model
                = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.sections.count, 2)
        XCTAssertEqual(model.rowsInSection(1), 3)
        XCTAssertEqual(vault.storedAccounts.count, 3)

        model.isEditing = true
        let result = model.deleteAllCredentials()
        if result {
            model.updateData()
        }

        XCTAssertEqual(model.sections.count, 0)
        XCTAssertEqual(vault.storedAccounts.count, 0)
    }

    func testWhenNoNeverPromptWebsitesSavedThenNeverPromptSectionIsNotShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.rowsInSection(0), 1)
    }

    func testWhenOneNeverPromptWebsiteSavedThenNeverPromptSectionIsShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.com"))
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.rowsInSection(0), 2)
    }

    func testWhenManyNeverPromptWebsiteSavedThenNeverPromptSectionIsShown() {
        XCTAssertTrue(manager.deleteAllNeverPromptWebsites())
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("example.co.uk"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("duckduckgo.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("daxisawesome.com"))
        XCTAssertNoThrow(try manager.saveNeverPromptWebsite("123domain.com"))

        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        XCTAssertEqual(model.rowsInSection(0), 2)
    }

    func testWhenBreakageReporterConfigDisabledThenShowBreakageReporterIsFalse() {
        let testDomain = "testsite.com"

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: URL(string: "https://\(testDomain)"),
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configDisabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        XCTAssertFalse(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndCurrentTabUrlIsNilThenShowBreakageReporterIsFalse() {
        let testDomain = "testsite.com"

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: nil,
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        XCTAssertFalse(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndNoSuggestionsThenShowBreakageReporterIsFalse() {
        let testDomain = "testsite.com"

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "not-testsites.com", created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: URL(string: "https://\(testDomain)"),
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        XCTAssertFalse(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndCurrentTabUrlIsInExceptionListThenShowBreakageReporterIsFalse() {
        let testDomain = "exception.com"

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: URL(string: "https://\(testDomain)"),
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        XCTAssertFalse(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndReportAlreadyRecentlySavedThenShowBreakageReporterIsFalse() throws {
        throw XCTSkip("Flakey test")

        let testDomain = "testDomain.com"
        let currentTabUrl = URL(string: "https://\(testDomain)")

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: URL(string: "https://\(testDomain)"),
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        let identifier = currentTabUrl!.privacySafeDomainIdentifier
        model.breakageReporter.persistencyManager.set(value: "2024-07-16", forKey: identifier!, expiryDate: Date())

        XCTAssertFalse(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndNoReportsSavedThenShowBreakageReporterIsTrue() {
        let testDomain = "testDomain.com"
        let currentTabUrl = URL(string: "https://\(testDomain)")

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: currentTabUrl,
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        XCTAssertTrue(model.shouldShowBreakageReporter())
    }

    func testWhenBreakageReporterConfigEnabledAndNoReportsRecentlySavedThenShowBreakageReporterIsTrue() {
        let testDomain = "testDomain.com"
        let currentTabUrl = URL(string: "https://\(testDomain)")

        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: testDomain, created: Date(), lastUpdated: Date())
        ]

        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               currentTabUrl: URL(string: "https://\(testDomain)"),
                                               currentTabUid: "1",
                                               autofillNeverPromptWebsitesManager: manager,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               keyValueStore: MockKeyValueStore(),
                                               syncService: syncService)

        let identifier = currentTabUrl!.privacySafeDomainIdentifier
        model.breakageReporter.persistencyManager.set(value: "2024-01-01", forKey: identifier!, expiryDate: Date())

        XCTAssertEqual(model.sections.count, 3)
        XCTAssertEqual(model.rowsInSection(1), 2)
        XCTAssertEqual(model.rowsInSection(2), 1)

        XCTAssertTrue(model.shouldShowBreakageReporter())
    }

    func testWhenLocaleIsNotEnglishThenNoSurveyIsReturned() {
        let nonEnglishLocale = Locale(identifier: "es")
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService, locale: nonEnglishLocale)

        XCTAssertNil(model.getSurveyToPresent())
    }

    func testWhenViewStateIsIneligibleThenNoSurveyIsReturned() throws {
        vault.storedAccounts = [
            SecureVaultModels.WebsiteAccount(id: "1", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date()),
            SecureVaultModels.WebsiteAccount(id: "2", title: nil, username: "", domain: "testsite.com", created: Date(), lastUpdated: Date())
        ]
        for account in vault.storedAccounts {
            _ = try vault.storeWebsiteCredentials(SecureVaultModels.WebsiteCredentials(account: account, password: nil))
        }
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)

        XCTAssertNil(model.getSurveyToPresent())
    }

    func testWhenIsEditingThenNoSurveyIsReturned() {
        let model = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: vault, autofillNeverPromptWebsitesManager: manager, syncService: syncService)
        model.isEditing = true

        XCTAssertNil(model.getSurveyToPresent())
    }

    func testWhenSurveyConfigIsDisabledThenNoSurveyIsReturned() {
        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               privacyConfig: makePrivacyConfig(from: configDisabled),
                                               syncService: syncService)

        XCTAssertNil(model.getSurveyToPresent())
    }

    func testWhenAllConditionsAreMetThenSurveyIsReturnedAndWhenDismissedNotSurveyIsReturned() {
        let model = AutofillLoginListViewModel(appSettings: appSettings,
                                               tld: tld,
                                               secureVault: vault,
                                               privacyConfig: makePrivacyConfig(from: configEnabled),
                                               syncService: syncService)
        let survey = model.getSurveyToPresent()
        XCTAssertNotNil(survey)
        XCTAssertEqual(survey?.id, "123")
        XCTAssertEqual(survey?.url, "https://asurveyurl.com")

        model.dismissSurvey(id: "123")

        XCTAssertNil(model.getSurveyToPresent())
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
        let result = testData.groupedByFirstLetter(tld: tld,
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
        let result = testData.groupedByFirstLetter(tld: tld,
                                                   autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                                   autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        // All non letters should be grouped together
        XCTAssertEqual(result.count, 1)
    }
    
    func testWhenCreatingSectionsThenTitlesWithinASectionAreSortedCorrectly() {
        let domain = "whateverNotImportantForThisTest"
        let testData = ["e": [
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: "elephant", username: "1", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: "elephants", username: "2", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: "Elephant", username: "3", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: "èlephant", username: "4", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: "è", username: "5", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort),
            AutofillLoginItem(account: SecureVaultModels.WebsiteAccount(title: nil, username: "ezy", domain: domain),
                              tld: tld,
                              autofillDomainNameUrlMatcher: autofillUrlMatcher,
                              autofillDomainNameUrlSort: autofillDomainNameUrlSort)]]
        let result = testData.sortedIntoSections(autofillDomainNameUrlSort,
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
        let result = testData.groupedByFirstLetter(tld: tld,
                                                   autofillDomainNameUrlMatcher: autofillUrlMatcher,
                                                   autofillDomainNameUrlSort: autofillDomainNameUrlSort)
        // Diacritics should be grouped with the root letter (in most cases), and grouping should be case insensative
        XCTAssertEqual(result.count, 1)
    }
}

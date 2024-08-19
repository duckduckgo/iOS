//
//  HistoryManagerTests.swift
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
import XCTest
import BrowserServicesKit
import Persistence
import History
@testable import Core
import Common

final class HistoryManagerTests: XCTestCase {

    let privacyConfig = MockPrivacyConfiguration()
    let privacyConfigManager = MockPrivacyConfigurationManager()

    @MainActor
    func testWhenURLIsDeletedThenSiteIsRemovedFromHistory() async {
        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        let loadStoreExpectation = expectation(description: "loadStore")
        db.loadStore { _, _ in
            loadStoreExpectation.fulfill()
        }
        await fulfillment(of: [loadStoreExpectation], timeout: 5.0)

        let historyManager = makeHistoryManager(db)
        let loadHistoryExpectation = expectation(description: "loadHistory")
        historyManager.dbCoordinator.loadHistory {
            loadHistoryExpectation.fulfill()
        }

        await fulfillment(of: [loadHistoryExpectation], timeout: 5.0)

        let ddgURL = URL(string: "https://duckduckgo.com/")!
        let netflixURL = URL(string: "https://netflix.com/")!
        let exampleURL = URL(string: "https://example.com/")!

        [ exampleURL.appending("/1"),
          exampleURL.appending("/1"),
          exampleURL.appending("/1"),
          netflixURL,
          ddgURL,
        ].forEach {
            historyManager.historyCoordinator.addVisit(of: $0)
            historyManager.historyCoordinator.updateTitleIfNeeded(title: $0.absoluteString, url: $0)
            historyManager.historyCoordinator.commitChanges(url: $0)
        }

        await historyManager.deleteHistoryForURL(exampleURL.appending("/1"))

        XCTAssertEqual(2, historyManager.historyCoordinator.history?.count)
        XCTAssertTrue(historyManager.historyCoordinator.history?.contains(where: { $0.url == ddgURL }) ?? false)
        XCTAssertTrue(historyManager.historyCoordinator.history?.contains(where: { $0.url == netflixURL }) ?? false)
    }

    func testWhenEnabledInPrivacyConfig_ThenFeatureIsEnabled() {
        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let historyManager = makeHistoryManager(db)

        XCTAssertTrue(historyManager.isHistoryFeatureEnabled())
        XCTAssertTrue(historyManager.historyCoordinator is HistoryCoordinator)
    }

    func testWhenDisabledInPrivacyConfig_ThenFeatureIsDisabled() {
        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return false
        }
        
        privacyConfigManager.privacyConfig = privacyConfig

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let historyManager = makeHistoryManager(db)

        XCTAssertFalse(historyManager.isHistoryFeatureEnabled())
        XCTAssertTrue(historyManager.historyCoordinator is NullHistoryCoordinator)
    }

    func test_WhenUserHasDisabledAutocompleteSitesSetting_ThenDontStoreOrLoadHistory() {

        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        privacyConfigManager.privacyConfig = privacyConfig
        autocompleteEnabledByUser = false

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let historyManager = makeHistoryManager(db)

        XCTAssertTrue(historyManager.historyCoordinator is NullHistoryCoordinator)
    }

    func test_WhenUserHasDisabledRecentlyVisitedSitesSetting_ThenDontStoreOrLoadHistory() {

        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        privacyConfigManager.privacyConfig = privacyConfig
        recentlyVisitedSitesEnabledByUser = false

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let historyManager = makeHistoryManager(db)

        XCTAssertTrue(historyManager.historyCoordinator is NullHistoryCoordinator)
    }

    private func makeHistoryManager(_ db: CoreDataDatabase) -> HistoryManager {
        let eventMapper = HistoryStoreEventMapper()
        let store = HistoryStore(context: db.makeContext(concurrencyType: .privateQueueConcurrencyType), eventMapper: eventMapper)
        let dbCoordinator = HistoryCoordinator(historyStoring: store)

        return HistoryManager(privacyConfigManager: privacyConfigManager,
                              dbCoordinator: dbCoordinator,
                              tld: TLD(),
                              isAutocompleteEnabledByUser: self.autocompleteEnabledByUser,
                              isRecentlyVisitedSitesEnabledByUser: self.recentlyVisitedSitesEnabledByUser)
    }

    var autocompleteEnabledByUser = true
    var recentlyVisitedSitesEnabledByUser = true

}

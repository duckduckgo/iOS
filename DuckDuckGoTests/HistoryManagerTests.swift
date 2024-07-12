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

final class HistoryManagerTests: XCTestCase {

    let privacyConfig = MockPrivacyConfiguration()
    let privacyConfigManager = MockPrivacyConfigurationManager()

    func testWhenEnabledInPrivacyConfig_ThenFeatureIsEnabled() {
        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let historyManager = makeHistoryManager(db) {
            XCTFail("DB Error \($0)")
        }

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

        let historyManager = makeHistoryManager(db) {
            XCTFail("DB Error \($0)")
        }

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

        let historyManager = makeHistoryManager(db) {
            XCTFail("DB Error \($0)")
        }

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

        let historyManager = makeHistoryManager(db) {
            XCTFail("DB Error \($0)")
        }

        XCTAssertTrue(historyManager.historyCoordinator is NullHistoryCoordinator)
    }

    private func makeHistoryManager(_ db: CoreDataDatabase, onStoreLoadFailed: @escaping (Error) -> Void) -> HistoryManager {
        let eventMapper = HistoryStoreEventMapper()
        let store = HistoryStore(context: db.makeContext(concurrencyType: .privateQueueConcurrencyType), eventMapper: eventMapper)
        let dbCoordinator = HistoryCoordinator(historyStoring: store)

        return HistoryManager(privacyConfigManager: privacyConfigManager,
                              dbCoordinator: dbCoordinator,
                              isAutocompleteEnabledByUser: self.autocompleteEnabledByUser,
                              isRecentlyVisitedSitesEnabledByUser: self.recentlyVisitedSitesEnabledByUser)

    }

    var autocompleteEnabledByUser = true
    var recentlyVisitedSitesEnabledByUser = true

}

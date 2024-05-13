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
    var variantManager = MockVariantManager()
    let internalUserStore = MockInternalUserStoring()
    var enabledByUser = true

    func test() {

        struct Condition {

            let privacyConfig: Bool
            let variant: Bool
            let inRollOut: Bool
            let internalUser: Bool
            let expected: Bool

        }

        let conditions = [
            // Users in the experiment should get the feature
            Condition(privacyConfig: true, variant: true, inRollOut: false, internalUser: false, expected: true),
            Condition(privacyConfig: true, variant: true, inRollOut: true, internalUser: false, expected: true),

            // If not previously in the experiment then check for the rollout
            Condition(privacyConfig: true, variant: false, inRollOut: false, internalUser: false, expected: false),
            Condition(privacyConfig: true, variant: false, inRollOut: true, internalUser: false, expected: true),

            // Internal users also get the feature
            Condition(privacyConfig: true, variant: false, inRollOut: false, internalUser: true, expected: true),
            Condition(privacyConfig: true, variant: false, inRollOut: true, internalUser: true, expected: true),

            // Privacy config is the ultimate on/off switch though
            Condition(privacyConfig: false, variant: true, inRollOut: true, internalUser: true, expected: false),
        ]

        for index in conditions.indices {
            let condition = conditions[index]
            privacyConfig.isFeatureKeyEnabled = { feature, _ in
                XCTAssertEqual(feature, .history)
                return condition.privacyConfig
            }

            privacyConfig.isSubfeatureKeyEnabled = { subFeature, _ in
                XCTAssertEqual(subFeature as? HistorySubFeature, HistorySubFeature.onByDefault)
                return condition.inRollOut
            }

            internalUserStore.isInternalUser = condition.internalUser
            privacyConfigManager.privacyConfig = privacyConfig
            variantManager.isSupportedReturns = condition.variant

            let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
            let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
            let historyManager = makeHistoryManager(db) {
                XCTFail("DB Error \($0)")
            }

            RunLoop.main.run(until: .init() + 0.5)

            XCTAssertEqual(condition.expected, historyManager.isHistoryFeatureEnabled(), "\(index): \(condition)")

            // If not enabled, then the history manager should be using a "null" history coordinator
            XCTAssertEqual(!condition.expected, historyManager.historyCoordinator is NullHistoryCoordinator)
        }

    }

    func test_WhenUserHasDisabledSetting_ThenDontStoreOrLoadHistory() {

        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        internalUserStore.isInternalUser = true
        privacyConfigManager.privacyConfig = privacyConfig
        enabledByUser = false

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)

        let historyManager = makeHistoryManager(db) {
            XCTFail("DB Error \($0)")
        }

        XCTAssertTrue(historyManager.historyCoordinator is NullHistoryCoordinator)
    }

    func test_WhenManagerFailsToLoadStore_ThenThrowsError() {

        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        internalUserStore.isInternalUser = true
        privacyConfigManager.privacyConfig = privacyConfig

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: URL.aboutLink, model: model)

        var error: Error?
        _ = makeHistoryManager(db) {
            error = $0
        }

        XCTAssertNotNil(error)
    }

    private func makeHistoryManager(_ db: CoreDataDatabase, onStoreLoadFailed: @escaping (Error) -> Void) -> HistoryManager {
        let manager = HistoryManager(privacyConfigManager: privacyConfigManager,
                              variantManager: variantManager,
                              database: db,
                              internalUserDecider: DefaultInternalUserDecider(mockedStore: internalUserStore),
                              isEnabledByUser: self.isEnabledByUser())
        do {
            try manager.loadStore {
                //
            }
        } catch {
            onStoreLoadFailed(error)
        }
        return manager
    }

    private func isEnabledByUser() -> Bool {
        return enabledByUser
    }

}

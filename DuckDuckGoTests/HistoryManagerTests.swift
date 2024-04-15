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

    let privacyConfigManager = MockPrivacyConfigurationManager()
    var variantManager = MockVariantManager()

    func test() {

        struct Condition {

            let variant: Bool
            let privacy: Bool
            let expected: Bool

        }

        let conditions = [
            Condition(variant: true, privacy: true, expected: true),
            Condition(variant: false, privacy: true, expected: false),
            Condition(variant: true, privacy: false, expected: false),
        ]

        let privacyConfig = MockPrivacyConfiguration()
        let privacyConfigManager = MockPrivacyConfigurationManager()
        var variantManager = MockVariantManager()

        for condition in conditions {
            privacyConfig.isFeatureKeyEnabled = { feature, _ in
                XCTAssertEqual(feature, .history)
                return condition.privacy
            }

            privacyConfigManager.privacyConfig = privacyConfig
            variantManager.isSupportedReturns = condition.variant

            let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
            let db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)

            let historyManager = HistoryManager(privacyConfigManager: privacyConfigManager, variantManager: variantManager, database: db) {
                XCTFail("DB Error \($0)")
            }
            XCTAssertEqual(condition.expected, historyManager.isHistoryFeatureEnabled(), String(describing: condition))
        }

    }

    func test_WhenManagerFailsToLoadStore_ThenThrowsError() {
        let privacyConfig = MockPrivacyConfiguration()
        let privacyConfigManager = MockPrivacyConfigurationManager()
        var variantManager = MockVariantManager()

        privacyConfig.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }

        privacyConfigManager.privacyConfig = privacyConfig
        variantManager.isSupportedReturns = true

        let model = CoreDataDatabase.loadModel(from: History.bundle, named: "BrowsingHistory")!
        let db = CoreDataDatabase(name: "Test", containerLocation: URL.aboutLink, model: model)

        var error: Error?
        let historyManager = HistoryManager(privacyConfigManager: privacyConfigManager, variantManager: variantManager, database: db) {
            error = $0
        }
        _ = historyManager.historyCoordinator
        XCTAssertNotNil(error)
    }
}

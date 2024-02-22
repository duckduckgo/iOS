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
@testable import Core

final class HistoryManagerTests: XCTestCase {

    func testWhenFeatureIsEnabledInPrivacyConfigThenHistoryIsEnabled() {
        let config = MockPrivacyConfiguration()
        config.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return true
        }
        let historyManager = HistoryManager(privacyConfig: config)
        XCTAssertTrue(historyManager.isHistoryFeatureEnabled())
    }

    func testWhenFeatureIsNotEnabledInPrivacyConfigThenHistoryIsNotEnabled() {
        let config = MockPrivacyConfiguration()
        config.isFeatureKeyEnabled = { feature, _ in
            XCTAssertEqual(feature, .history)
            return false
        }
        let historyManager = HistoryManager(privacyConfig: config)
        XCTAssertFalse(historyManager.isHistoryFeatureEnabled())
    }

}

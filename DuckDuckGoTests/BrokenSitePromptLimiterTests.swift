//
//  BrokenSitePromptLimiterTests.swift
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

import XCTest
import BrowserServicesKit
@testable import DuckDuckGo
@testable import Core

final class BrokenSitePromptLimiterTests: XCTestCase {

    let configManager = PrivacyConfigurationManagerMock()
    var brokenSiteLimiter: BrokenSitePromptLimiter!

    override func setUp() {
        super.setUp()

        setupUserDefault(with: #file)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<String>.Key.lastBrokenSiteToastShownDate.rawValue)
        UserDefaults.app.removeObject(forKey: UserDefaultsWrapper<String>.Key.toastDismissStreakCounter.rawValue)

        (configManager.privacyConfig as? PrivacyConfigurationMock)?.enabledFeaturesForVersions[.brokenSitePrompt] = [AppVersionProvider().appVersion() ?? ""]

        brokenSiteLimiter = BrokenSitePromptLimiter(privacyConfigManager: configManager)
    }

    func testShouldNotShowPromptIfConfigDisabled() throws {
        (configManager.privacyConfig as? PrivacyConfigurationMock)?.enabledFeaturesForVersions[.brokenSitePrompt] = []
        XCTAssertFalse(brokenSiteLimiter.shouldShowToast(), "Toast should not show if disabled via config")
    }

    func testShouldShowPromptOnFirstActivationThenLimit() throws {
        XCTAssertTrue(brokenSiteLimiter.shouldShowToast(), "Toast should show on first activation")
        brokenSiteLimiter.didShowToast()
        XCTAssertFalse(brokenSiteLimiter.shouldShowToast(), "Subsequent call should not show toast due to limiting logic")
    }

    func testShouldShowPromptAgainAfter7days() throws {
        XCTAssertTrue(brokenSiteLimiter.shouldShowToast(), "Toast should show on first activation")
        brokenSiteLimiter.didShowToast()
        XCTAssertFalse(brokenSiteLimiter.shouldShowToast(), "Subsequent call should not show toast due to limiting logic")
        UserDefaults.app.set(Date().addingTimeInterval(-7 * 24 * 60 * 60 - 1), forKey: UserDefaultsWrapper<String>.Key.lastBrokenSiteToastShownDate.rawValue)
        XCTAssertTrue(brokenSiteLimiter.shouldShowToast(), "Toast should show again after 7 days")
    }

    func testShouldNotShowPromptAfter3Dismissals() throws {
        brokenSiteLimiter.didDismissToast()
        brokenSiteLimiter.didDismissToast()
        brokenSiteLimiter.didDismissToast()
        // Set last date 7 days back so the toast shows but doesn't reset dismiss counter
        UserDefaults.app.set(Date().addingTimeInterval(-7 * 24 * 60 * 60 - 1), forKey: UserDefaultsWrapper<String>.Key.lastBrokenSiteToastShownDate.rawValue)
        XCTAssertFalse(brokenSiteLimiter.shouldShowToast(), "Toast should not show again after 3 dismissals")
    }

    func testShouldResetDismissCounterAfter30Days() throws {
        brokenSiteLimiter.didDismissToast()
        brokenSiteLimiter.didDismissToast()
        brokenSiteLimiter.didDismissToast()
        var count = UserDefaults.app.integer(forKey: UserDefaultsWrapper<String>.Key.toastDismissStreakCounter.rawValue)
        XCTAssert(count == 3, "Dismiss count should be equal to 3 after 3 dismiss calls")
        XCTAssertTrue(brokenSiteLimiter.shouldShowToast(), "Toast should show after resetting counter")
        count = UserDefaults.app.integer(forKey: UserDefaultsWrapper<String>.Key.toastDismissStreakCounter.rawValue)
        XCTAssert(count == 0, "Dismiss count should be reset to 0 after 30 days")
    }

}

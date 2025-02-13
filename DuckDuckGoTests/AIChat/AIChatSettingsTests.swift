//
//  AIChatSettingsTests.swift
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
@testable import Core
@testable import DuckDuckGo
import BrowserServicesKit
import Combine

class AIChatSettingsTests: XCTestCase {

    private var mockPrivacyConfigurationManager: PrivacyConfigurationManagerMock!
    private var mockUserDefaults: UserDefaults!
    private var mockNotificationCenter: NotificationCenter!

    override func setUp() {
        super.setUp()
        mockPrivacyConfigurationManager = PrivacyConfigurationManagerMock()
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")
        mockNotificationCenter = NotificationCenter()
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
        mockPrivacyConfigurationManager = nil
        mockUserDefaults = nil
        mockNotificationCenter = nil
        super.tearDown()
    }

    func testAIChatURLReturnsDefaultWhenRemoteSettingsMissing() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.settings = [:]

        let expectedURL = URL(string: AIChatSettings.SettingsValue.aiChatURL.defaultValue)!
        XCTAssertEqual(settings.aiChatURL, expectedURL)
    }

    func testAIChatURLReturnsRemoteSettingWhenAvailable() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        let remoteURL = "https://example.com/ai-chat"
        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.settings = [
            .aiChat: [AIChatSettings.SettingsValue.aiChatURL.rawValue: remoteURL]
        ]

        XCTAssertEqual(settings.aiChatURL, URL(string: remoteURL))
    }

    func testIsAIChatFeatureEnabledWhenFeatureIsEnabled() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledFeaturesForVersions = [
            .aiChat: [AppVersionProvider().appVersion() ?? ""]
        ]

        XCTAssertTrue(settings.isAIChatFeatureEnabled)
    }

    func testEnableAIChatBrowsingMenuUserSettings() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledFeaturesForVersions = [
            .aiChat: [AppVersionProvider().appVersion() ?? ""]
        ]

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledSubfeaturesForVersions = [
            AIChatSubfeature.browsingToolbarShortcut.rawValue: [AppVersionProvider().appVersion() ?? ""]
        ]
        settings.enableAIChatBrowsingMenuUserSettings(enable: false)
        XCTAssertFalse(settings.isAIChatBrowsingMenuUserSettingsEnabled)

        settings.enableAIChatBrowsingMenuUserSettings(enable: true)
        XCTAssertTrue(settings.isAIChatBrowsingMenuUserSettingsEnabled)
    }

    func testEnableAIChatAddressBarUserSettings() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledFeaturesForVersions = [
            .aiChat: [AppVersionProvider().appVersion() ?? ""]
        ]

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledSubfeaturesForVersions = [
            AIChatSubfeature.addressBarShortcut.rawValue: [AppVersionProvider().appVersion() ?? ""]
        ]

        settings.enableAIChatAddressBarUserSettings(enable: false)
        XCTAssertFalse(settings.isAIChatAddressBarUserSettingsEnabled)

        settings.enableAIChatAddressBarUserSettings(enable: true)
        XCTAssertTrue(settings.isAIChatAddressBarUserSettingsEnabled)
    }

    func testNotificationPostedWhenSettingsChange() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        let expectation = self.expectation(description: "Notification should be posted")

        let observer = mockNotificationCenter.addObserver(forName: .aiChatSettingsChanged, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }

        settings.enableAIChatBrowsingMenuUserSettings(enable: false)
        waitForExpectations(timeout: 1, handler: nil)
        mockNotificationCenter.removeObserver(observer)
    }

    func testAIChatBrowsingMenuUserSettingsDisabledWhenToolbarShortcutFeatureDisabled() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledSubfeaturesForVersions = [
            AIChatSubfeature.browsingToolbarShortcut.rawValue: []
        ]

        settings.enableAIChatBrowsingMenuUserSettings(enable: true)

        XCTAssertFalse(settings.isAIChatBrowsingMenuUserSettingsEnabled)
    }

    func testAIChatAddressBarUserSettingsDisabledWhenAddressBarShortcutFeatureDisabled() {
        let settings = AIChatSettings(privacyConfigurationManager: mockPrivacyConfigurationManager,
                                      userDefaults: mockUserDefaults,
                                      notificationCenter: mockNotificationCenter)

        (mockPrivacyConfigurationManager.privacyConfig as? PrivacyConfigurationMock)?.enabledSubfeaturesForVersions = [
            AIChatSubfeature.addressBarShortcut.rawValue: []
        ]

        settings.enableAIChatAddressBarUserSettings(enable: true)

        XCTAssertFalse(settings.isAIChatAddressBarUserSettingsEnabled)
    }

}

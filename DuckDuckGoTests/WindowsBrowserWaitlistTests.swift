//
//  WindowsBrowserWaitlistTests.swift
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

import XCTest
import WaitlistMocks
@testable import DuckDuckGo
@testable import Core
import BrowserServicesKit

class WindowsBrowserWaitlistTests: XCTestCase {

    func testWhenUserHasNotJoinedWaitlist_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        let request = MockWaitlistRequest.failure()
        let waitlist = WindowsBrowserWaitlist(store: store, request: request, privacyConfigurationManager: PrivacyConfigurationManagerMock())

        XCTAssertEqual(waitlist.settingsSubtitle, UserText.windowsWaitlistBrowsePrivately)
    }

    func testWhenUserIsOnWaitlist_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        store.store(waitlistToken: "abcd")
        store.store(waitlistTimestamp: 12345)

        let request = MockWaitlistRequest.failure()
        let waitlist = WindowsBrowserWaitlist(store: store, request: request, privacyConfigurationManager: PrivacyConfigurationManagerMock())

        XCTAssertEqual(waitlist.settingsSubtitle, UserText.waitlistOnTheList)
    }

    func testWhenUserIsInvited_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        store.store(inviteCode: "code")

        let request = MockWaitlistRequest.failure()
        let waitlist = WindowsBrowserWaitlist(store: store, request: request, privacyConfigurationManager: PrivacyConfigurationManagerMock())

        XCTAssertEqual(waitlist.settingsSubtitle, UserText.waitlistDownloadAvailable)
    }

    func testWhenWindowsDownloadLinkEnabled_ThenSettingsSubtitleIsCorrect() {
        let store = MockWaitlistStorage()
        store.store(inviteCode: "code")

        let request = MockWaitlistRequest.failure()
        let privacyConfigurationManager: PrivacyConfigurationManagerMock = PrivacyConfigurationManagerMock()
        let privacyConfig = privacyConfigurationManager.privacyConfig as! PrivacyConfigurationMock // swiftlint:disable:this force_cast
        privacyConfig.enabledFeaturesForVersions[.windowsDownloadLink] = Set([AppVersionProvider().appVersion()!])

        let waitlist = WindowsBrowserWaitlist(store: store, request: request, privacyConfigurationManager: privacyConfigurationManager)

        XCTAssertEqual(waitlist.settingsSubtitle, UserText.windowsWaitlistBrowsePrivately)
    }

}

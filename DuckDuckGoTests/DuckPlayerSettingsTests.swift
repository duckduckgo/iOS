//
//  DuckPlayerSettingsTests.swift
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


class DuckPlayerSettingsTests: XCTestCase {
    
    private var mockAppSettings: AppSettingsMock!
    private var mockPrivacyConfig: PrivacyConfigurationManagerMock!
    private var mockInternalUserDecider: MockDuckPlayerInternalUserDecider!
    private var settings: DuckPlayerSettingsDefault!
    
    override func setUp() {
        super.setUp()
        mockAppSettings = AppSettingsMock()
        mockPrivacyConfig = PrivacyConfigurationManagerMock()
        mockInternalUserDecider = MockDuckPlayerInternalUserDecider()
        settings = DuckPlayerSettingsDefault(appSettings: mockAppSettings,
                                           privacyConfigManager: mockPrivacyConfig,
                                           internalUserDecider: mockInternalUserDecider)
    }
    
    override func tearDown() {
        mockAppSettings = nil
        mockInternalUserDecider = nil
        settings = nil
        super.tearDown()
    }
    
    func testNativeUIAndAutoplayDisabledForNonInternalUsers() {
        mockInternalUserDecider.mockIsInternalUser = false
        mockAppSettings.duckPlayerNativeUI = true
        mockAppSettings.duckPlayerAutoplay = true
        
        // Check nativeUI
        XCTAssertFalse(settings.nativeUI, "nativeUI should be false for non-internal users regardless of setting")
        
        // Check autoplay
        XCTAssertFalse(settings.autoplay, "autoplay should be false for non-internal users regardless of setting")
        
        // Verify settings stay false even after changes
        mockAppSettings.duckPlayerNativeUI = true
        mockAppSettings.duckPlayerAutoplay = true
        
        XCTAssertFalse(settings.nativeUI, "nativeUI should remain false after settings change")
        XCTAssertFalse(settings.autoplay, "autoplay should remain false after settings change")
    }
}

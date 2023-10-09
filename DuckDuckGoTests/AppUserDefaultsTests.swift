//
//  AppUserDefaultsTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
import BrowserServicesKit

class AppUserDefaultsTests: XCTestCase {

    let testGroupName = "test"
    var internalUserDeciderStore: MockInternalUserStoring!

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
        internalUserDeciderStore = MockInternalUserStoring()
    }

    override func tearDown() {
        internalUserDeciderStore = nil
        super.tearDown()
    }

    func testWhenLinkPreviewsIsSetThenItIsPersisted() {

        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.longPressPreviews = false
        XCTAssertFalse(appUserDefaults.longPressPreviews)

    }

    func testWhenSettingsIsNewThenDefaultForHideLinkPreviewsIsTrue() {

        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        XCTAssertTrue(appUserDefaults.longPressPreviews)

    }

    func testWhenAllowUniversalLinksIsSetThenItIsPersisted() {

        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.allowUniversalLinks = false
        XCTAssertFalse(appUserDefaults.allowUniversalLinks)

    }

    func testWhenSettingsIsNewThenDefaultForAllowUniversalLinksIsTrue() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        XCTAssertTrue(appUserDefaults.allowUniversalLinks)

    }

    func testWhenAutocompleteIsSetThenItIsPersisted() {

        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autocomplete = false
        XCTAssertTrue(!appUserDefaults.autocomplete)

    }

    func testWhenReadingAutocompleteDefaultThenTrueIsReturned() {

        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        XCTAssertTrue(appUserDefaults.autocomplete)

    }
    
    func testWhenCurrentThemeIsSetThenItIsPersisted() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.currentThemeName = .light
        XCTAssertEqual(appUserDefaults.currentThemeName, .light)
        
    }
    
    func testWhenReadingCurrentThemeDefaultThenSystemDefaultIsReturned() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        
        XCTAssertEqual(appUserDefaults.currentThemeName, .systemDefault)
    }

    func testDefaultAutofillStateIsFalse() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        XCTAssertFalse(appUserDefaults.autofillCredentialsEnabled)
    }

    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeWhenSavePromptShownThenDefaultAutofillStateIsFalse() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = true

        XCTAssertFalse(appUserDefaults.autofillCredentialsEnabled)
    }

    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeAndPromptHasNotBeenSeenAndIsNotNewInstallThenDefaultAutofillStateIsFalse() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = false
        appUserDefaults.autofillIsNewInstallForOnByDefault = false

        XCTAssertFalse(appUserDefaults.autofillCredentialsEnabled)
    }

    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeAndPromptHasNotBeenSeenAndIsNewInstallAndFeatureFlagDisabledThenDefaultAutofillStateIsFalse() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = false
        appUserDefaults.autofillIsNewInstallForOnByDefault = true
        let featureFlagger = createFeatureFlagger(withSubfeatureEnabled: false)
        appUserDefaults.featureFlagger = featureFlagger

        XCTAssertFalse(appUserDefaults.autofillCredentialsEnabled)
    }

    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeAndPromptHasNotBeenSeenAndIsNewInstallAndFeatureFlagEnabledThenDefaultAutofillStateIsTrue() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = false
        appUserDefaults.autofillIsNewInstallForOnByDefault = true
        let featureFlagger = createFeatureFlagger(withSubfeatureEnabled: true)
        appUserDefaults.featureFlagger = featureFlagger

        XCTAssertTrue(appUserDefaults.autofillCredentialsEnabled)
    }

    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeAndPromptHasBeenSeenThenAutofillCredentialsStaysDisabled() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsEnabled = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = true
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        XCTAssertEqual(appUserDefaults.autofillCredentialsEnabled, false)
    }
    
    func testWhenAutofillCredentialsIsDisabledAndButHasBeenTurnedOnAutomaticallyBeforeThenAutofillCredentialsStaysDisabled() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsEnabled = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = false
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = true
        XCTAssertEqual(appUserDefaults.autofillCredentialsEnabled, false)
    }


    // MARK: - Mock Creation

    private func createFeatureFlagger(withSubfeatureEnabled enabled: Bool) -> DefaultFeatureFlagger {
        let mockManager = MockPrivacyConfigurationManager()
        mockManager.privacyConfig = mockConfiguration(subfeatureEnabled: enabled)

        let internalUserDecider = DefaultInternalUserDecider(store: internalUserDeciderStore)
        return DefaultFeatureFlagger(internalUserDecider: internalUserDecider, privacyConfig: mockManager.privacyConfig)
    }

    private func mockConfiguration(subfeatureEnabled: Bool) -> PrivacyConfiguration {
        let mockPrivacyConfiguration = MockPrivacyConfiguration()
        mockPrivacyConfiguration.isSubfeatureKeyEnabled = { _, _ in
            return subfeatureEnabled
        }

        return mockPrivacyConfiguration
    }
    
}

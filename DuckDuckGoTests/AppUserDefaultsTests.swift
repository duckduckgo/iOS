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

class AppUserDefaultsTests: XCTestCase {

    let testGroupName = "test"

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
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
    
    /*
     These tests aren't required until we make autofill default to off, and then enable turning it on automatically
    func testWhenAutofillCredentialsIsDisabledAndHasNotBeenTurnedOnAutomaticallyBeforeThenAutofillCredentialsEnabled() {
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.autofillCredentialsEnabled = false
        appUserDefaults.autofillCredentialsSavePromptShowAtLeastOnce = false
        appUserDefaults.autofillCredentialsHasBeenEnabledAutomaticallyIfNecessary = false
        XCTAssertEqual(appUserDefaults.autofillCredentialsEnabled, true)
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
     */
    
}

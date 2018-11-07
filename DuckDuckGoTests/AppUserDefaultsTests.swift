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
        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
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
        XCTAssertTrue(appUserDefaults.currentThemeName == .light)
        
    }
    
    func testWhenReadingCurrentThemeDefaultThenDarkIsReturned() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        XCTAssert(appUserDefaults.currentThemeName == .dark)
        
    }

    func testWhenThemeSettingIsEmptyThenWeCanSetInitialValue() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        
        appUserDefaults.setInitialThemeNameIfNeeded(name: .dark)
        XCTAssert(appUserDefaults.currentThemeName == .dark)
        
        UserDefaults(suiteName: testGroupName)?.removePersistentDomain(forName: testGroupName)
        
        appUserDefaults.setInitialThemeNameIfNeeded(name: .light)
        XCTAssert(appUserDefaults.currentThemeName == .light)
    }
    
    func testWhenThemeSettingIsNotEmptyThenInitialValueCannotBeSet() {
        
        let appUserDefaults = AppUserDefaults(groupName: testGroupName)
        appUserDefaults.currentThemeName = .light
        
        appUserDefaults.setInitialThemeNameIfNeeded(name: .dark)
        XCTAssert(appUserDefaults.currentThemeName == .light)
        
    }
}

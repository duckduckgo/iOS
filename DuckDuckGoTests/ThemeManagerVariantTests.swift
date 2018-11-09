//
//  ThemeManagerVariantTests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class ThemeManagerVariantTests: XCTestCase {
    
    private class MockAppSettings: AppSettings {
        
        var onSetInitialLightThemeValueIfNeeded: ((ThemeName) -> Void)?
        
        var autocomplete = false
        var currentThemeName = ThemeName.dark
        
        func setInitialThemeNameIfNeeded(name: ThemeName) {
            onSetInitialLightThemeValueIfNeeded?(name)
        }
    }
    
    struct Constants {
        static let variant = "v"
    }

    func testWhenExperimentIsDisabledThenDarkThemeIsTheDefault() {
        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant,
                                                                            weight: 100,
                                                                            features: []))
        
        let noSettingsChangeExpectation = expectation(description: "App Settings changed")
        noSettingsChangeExpectation.isInverted = true
        
        let mockSettings = MockAppSettings()
        mockSettings.onSetInitialLightThemeValueIfNeeded = { _ in noSettingsChangeExpectation.fulfill() }

        XCTAssert(ThemeManager(variantManager: mockVariantManager,
                               settings: mockSettings).currentTheme is DarkTheme)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testWhenExperimentIsEnabledWithLightThemeFeatureThenLightThemeIsTheDefault() {
        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant,
                                                                            weight: 100,
                                                                            features: [.lightThemeByDefault]))
        
        let settingsChangedExpectation = expectation(description: "App Settings changed")
        
        let mockSettings = MockAppSettings()
        mockSettings.onSetInitialLightThemeValueIfNeeded = { [weak mockSettings] value in
            settingsChangedExpectation.fulfill()
            XCTAssert(value == .light)
            mockSettings?.currentThemeName = value
        }
        
        XCTAssert(ThemeManager(variantManager: mockVariantManager,
                               settings: mockSettings).currentTheme is LightTheme)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testWhenLightThemeFeatureIsEnabledButUserSetDarkThemeThenDarkThemeIsActive() {
        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant,
                                                                            weight: 100,
                                                                            features: [.lightThemeByDefault]))
        
        let mockSettings = MockAppSettings()
        mockSettings.currentThemeName = .dark
        
        XCTAssert(ThemeManager(variantManager: mockVariantManager,
                               settings: mockSettings).currentTheme is DarkTheme)
    }
    
    func testWhenExperimentIsEnabledWithDarkThemeFeatureThenDarkThemeIsTheDefault() {
        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant,
                                                                            weight: 100,
                                                                            features: [.darkThemeByDefault]))
        
        let settingsChangedExpectation = expectation(description: "App Settings changed")
        
        let mockSettings = MockAppSettings()
        mockSettings.onSetInitialLightThemeValueIfNeeded = { [weak mockSettings] value in
            settingsChangedExpectation.fulfill()
            XCTAssert(value == .dark)
            mockSettings?.currentThemeName = value
        }
        
        XCTAssert(ThemeManager(variantManager: mockVariantManager,
                               settings: mockSettings).currentTheme is DarkTheme)
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testWhenDarkThemeFeatureIsEnabledButUserSetLightThemeThenLightThemeIsActive() {
        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant,
                                                                            weight: 100,
                                                                            features: [.darkThemeByDefault]))
        
        let mockSettings = MockAppSettings()
        mockSettings.currentThemeName = .light
        
        XCTAssert(ThemeManager(variantManager: mockVariantManager,
                               settings: mockSettings).currentTheme is LightTheme)
    }
}

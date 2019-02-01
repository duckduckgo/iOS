//
//  SettingsViewControllerTests.swift
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

class SettingsViewControllerTests: XCTestCase {
    
    var mockDependencyProvider: MockDependencyProvider!
    
    override func setUp() {
        mockDependencyProvider = MockDependencyProvider()
        AppDependencyProvider.shared = mockDependencyProvider
    }
    
    override func tearDown() {
        AppDependencyProvider.shared = AppDependencyProvider()
    }
    
    func testWhenOpeningSettingsThenAutoClearStatusIsSetBasedOnAppSettings() {
        let appSettigns = AppUserDefaults()
        appSettigns.autoClearMode = 0
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            settingsController.viewWillAppear(true)
            XCTAssertEqual(settingsController.autoClearDataAccessoryText.text, "Off")
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
        
        appSettigns.autoClearMode = AutoClearDataSettings.Action.clearData.rawValue
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            settingsController.viewWillAppear(true)
            XCTAssertEqual(settingsController.autoClearDataAccessoryText.text, "On")
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
    }

    func testWhenOpeningSettingsThenLightThemeToggleIsSetBasedOnAppSettings() {
        let appSettigns = AppUserDefaults()
        appSettigns.currentThemeName = .dark
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            XCTAssertFalse(settingsController.lightThemeToggle.isOn)
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
        
        appSettigns.currentThemeName = .light
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            XCTAssert(settingsController.lightThemeToggle.isOn)
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
    }
    
    func testWhenLightThemeIsToggledThenAppSettingsAreUpdated() {
        let appSettings = AppUserDefaults()
        appSettings.currentThemeName = .dark
        
        guard let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController else {
                assertionFailure("Could not load Setting View Controller")
                return
        }
        
        settingsController.loadViewIfNeeded()
        settingsController.lightThemeToggle.isOn = true
        settingsController.lightThemeToggle.sendActions(for: .valueChanged)
        
        XCTAssert(appSettings.currentThemeName == .light)
        
        settingsController.lightThemeToggle.isOn = false
        settingsController.lightThemeToggle.sendActions(for: .valueChanged)
        
        XCTAssert(appSettings.currentThemeName == .dark)
    }
}

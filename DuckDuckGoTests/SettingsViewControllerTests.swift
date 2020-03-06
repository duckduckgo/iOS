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
        appSettigns.autoClearAction = []
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            settingsController.viewWillAppear(true)
            XCTAssertEqual(settingsController.autoClearAccessoryText.text, "Off")
        } else {
            XCTFail("Could not load Setting View Controller")
        }
        
        appSettigns.autoClearAction = .clearData
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            settingsController.viewWillAppear(true)
            XCTAssertEqual(settingsController.autoClearAccessoryText.text, "On")
        } else {
            XCTFail("Could not load Setting View Controller")
        }
    }

    func testWhenOpeningSettingsThenThemeAccessoryIsSetBasedOnAppSettings() {
        
        let assertAccessoryLabel: (String) -> Void = { expected in
            if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
                let settingsController = navController.topViewController as? SettingsViewController {
                settingsController.loadViewIfNeeded()
                XCTAssertEqual(settingsController.themeAccessoryText.text, expected)
            } else {
                XCTFail("Could not load Setting View Controller")
            }
        }
        
        let settings = AppUserDefaults()
        settings.currentThemeName = .dark
        assertAccessoryLabel("Dark")
        
        settings.currentThemeName = .light
        assertAccessoryLabel("Light")
        
        settings.currentThemeName = .systemDefault
        assertAccessoryLabel("System")
    }
}

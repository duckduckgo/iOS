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
@testable import DuckDuckGo

class SettingsViewControllerTests: XCTestCase {

    func testLightThemeToggleInitialState() {
        let appSettigns = AppUserDefaults()
        appSettigns.lightTheme = false
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            XCTAssertFalse(settingsController.lightThemeToggle.isOn)
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
        
        appSettigns.lightTheme = true
        
        if let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController {
            settingsController.loadViewIfNeeded()
            XCTAssert(settingsController.lightThemeToggle.isOn)
        } else {
            assertionFailure("Could not load Setting View Controller")
        }
    }
    
    func testLightThemeToggling() {
        let appSettigns = AppUserDefaults()
        appSettigns.lightTheme = false
        
        guard let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController else {
                assertionFailure("Could not load Setting View Controller")
                return
        }
        
        settingsController.loadViewIfNeeded()
        settingsController.lightThemeToggle.isOn = true
        settingsController.lightThemeToggle.sendActions(for: .valueChanged)
        
        XCTAssert(appSettigns.lightTheme)
        
        settingsController.lightThemeToggle.isOn = false
        settingsController.lightThemeToggle.sendActions(for: .valueChanged)
        
        XCTAssertFalse(appSettigns.lightTheme)
    }

    func testHidingLightThemeCell() {
        guard let navController = SettingsViewController.loadFromStoryboard() as? UINavigationController,
            let settingsController = navController.topViewController as? SettingsViewController else {
                assertionFailure("Could not load Setting View Controller")
                return
        }
        
        let height = settingsController.tableView(settingsController.tableView, heightForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(height, 0)
    }
    
    func testShowingLightThemeCellWhenRunningExperiment() {
        //TODO: Requires changing variant manager on Settings VC
    }
}

//
//  AutoClearSettingsScreenTests.swift
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

class AutoClearSettingsScreenTests: XCTestCase {
    
    var mockDependencyProvider: MockDependencyProvider!
    
    override func setUp() {
        mockDependencyProvider = MockDependencyProvider()
        AppDependencyProvider.shared = mockDependencyProvider
    }
    
    override func tearDown() {
        AppDependencyProvider.shared = AppDependencyProvider()
    }
    
    func testWhenOpeningSettingsThenClearDataToggleIsSetBasedOnAppSettings() {
        let appSettigns = AppUserDefaults()
        appSettigns.autoClearAction = []
        
        if let settingsController = AutoClearSettingsViewController.loadFromStoryboard() {
            settingsController.loadViewIfNeeded()
            XCTAssertFalse(settingsController.clearDataToggle.isOn)
        } else {
            assertionFailure("Could not load View Controller")
        }
        
        appSettigns.autoClearAction = .clearData
        
        if let settingsController = AutoClearSettingsViewController.loadFromStoryboard() {
            settingsController.loadViewIfNeeded()
            XCTAssert(settingsController.clearDataToggle.isOn)
        } else {
            assertionFailure("Could not load View Controller")
        }
    }
    
    func testWhenClearDataSwitchIsToggledThenTableIsUpdated() {
        let appSettings = AppUserDefaults()
        appSettings.autoClearAction = []
        
        guard let settingsController = AutoClearSettingsViewController.loadFromStoryboard() else {
                assertionFailure("Could not load View Controller")
                return
        }
        
        XCTAssertEqual(settingsController.numberOfSections(in: settingsController.tableView), 1)
        
        settingsController.loadViewIfNeeded()
        settingsController.clearDataToggle.isOn = true
        settingsController.clearDataToggle.sendActions(for: .valueChanged)
        
        XCTAssertEqual(settingsController.numberOfSections(in: settingsController.tableView), 3)
        
        settingsController.clearDataToggle.isOn = false
        settingsController.clearDataToggle.sendActions(for: .valueChanged)
        
        XCTAssertEqual(settingsController.numberOfSections(in: settingsController.tableView), 1)
    }
}

fileprivate extension AutoClearSettingsViewController {
    
    static func loadFromStoryboard() -> AutoClearSettingsViewController? {
        let controller = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "AutoClearSettingsViewController")
        return controller as? AutoClearSettingsViewController
    }
    
}

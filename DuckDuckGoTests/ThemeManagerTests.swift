//
//  ThemeManagerTests.swift
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
import UIKit
@testable import Core
@testable import DuckDuckGo

class ThemeManagerTests: XCTestCase {

    private class MockRootController: UIViewController {
        var onDecorate: XCTestExpectation?

        private func decorate() {
            let theme = ThemeManager.shared.currentTheme
            onDecorate?.fulfill()
        }
    }

    func testEnablingLightThemeModifiesSettings() {
        let defaults = AppUserDefaults(groupName: "com.duckduckgo.mobile.ios.Tests")
        let manager = ThemeManager(settings: defaults)

        manager.enableTheme(with: .light)

        XCTAssertEqual(defaults.currentThemeName, .light)
    }

    func testEnablingDarkThemeModifiesSettings() {
        let defaults = AppUserDefaults(groupName: "com.duckduckgo.mobile.ios.Tests")
        let manager = ThemeManager(settings: defaults)

        manager.enableTheme(with: .dark)

        XCTAssertEqual(defaults.currentThemeName, .dark)
    }

    func testEnablingSystemThemeModifiesSettings() {
        let defaults = AppUserDefaults(groupName: "com.duckduckgo.mobile.ios.Tests")
        let manager = ThemeManager(settings: defaults)

        manager.enableTheme(with: .systemDefault)

        XCTAssertEqual(defaults.currentThemeName, .systemDefault)
    }

    func testEnablingThemeOverridesUserInterfaceStyle() {
        let window = UIWindow()
        window.makeKeyAndVisible()

        let defaults = AppUserDefaults(groupName: "com.duckduckgo.mobile.ios.Tests")
        let manager = ThemeManager(settings: defaults)

        manager.enableTheme(with: .dark)
        XCTAssertEqual(window.traitCollection.userInterfaceStyle, .dark)

        manager.enableTheme(with: .light)
        XCTAssertEqual(window.traitCollection.userInterfaceStyle, .light)

        manager.enableTheme(with: .systemDefault)
        XCTAssertEqual(window.overrideUserInterfaceStyle, .unspecified)
    }
}

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
@testable import Core
@testable import DuckDuckGo

class ThemeManagerTests: XCTestCase {

    private class MockRootController: UIViewController, Themable {
        var onDecorate: XCTestExpectation?
        
        func decorate(with theme: Theme) {
            onDecorate?.fulfill()
        }
    }
    
    private class MockRootControllerProvider: RootControllerProvider {
        var rootController: UIViewController?
    }
    
    func testWhenApplyingThemeOnThemeChangeThenControllerShouldBeUpdated() {
        let expectDecoration = expectation(description: "Decorate called")
        expectDecoration.expectedFulfillmentCount = 2
        
        let mockRootController = MockRootController()
        mockRootController.onDecorate = expectDecoration
        
        let mockRootControllerProvider = MockRootControllerProvider()
        mockRootControllerProvider.rootController = mockRootController
        
        let manager = ThemeManager(variantManager: DefaultVariantManager(),
                                   settings: AppUserDefaults(),
                                   rootProvider: mockRootControllerProvider)
        manager.enableTheme(with: .light)
        manager.enableTheme(with: .dark)
        
        waitForExpectations(timeout: 0.5, handler: nil)
    }
}

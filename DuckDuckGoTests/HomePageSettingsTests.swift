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
@testable import DuckDuckGo
@testable import Core

class HomePageSettingsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: UserDefaultsWrapper<String>.Key.layout.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsWrapper<String>.Key.favorites.rawValue)
    }
    
    func testWhenNewThenDefaultLayoutIsNavigationBarAndFavoritesIsOn() {
        XCTAssertEqual(DefaultHomePageSettings().layout, .navigationBar)
        XCTAssertTrue(DefaultHomePageSettings().favorites)
    }
    
    func testWhenSettingsChangedThenTheyArePersisted() {
        let settings = DefaultHomePageSettings()
        settings.layout = .centered
        settings.favorites = false
        
        XCTAssertEqual(DefaultHomePageSettings().layout, .centered)
        XCTAssertFalse(DefaultHomePageSettings().favorites)
    }
    
}

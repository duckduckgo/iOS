//
//  HomePageConfigurationTests.swift
//  UnitTests
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

import Foundation
import XCTest
@testable import Core
@testable import DuckDuckGo

class HomePageConfigurationTests: XCTestCase {
    
    func testWhenHomePageIsDefaultThenNavigationBarSearchIsUsed() {
        let settings = MockAppSettings()
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual([ HomePageConfiguration.Component.navigationBarSearch ], config.components)
    }
    
    func testWhenHomePageIsType1ThenFixedCenteredSearchIsUsed() {
        let settings = MockAppSettings()
        settings.homePage = .centerSearch
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components, [ .centeredSearch(fixed: true), .empty ])
    }

    func testWhenHomePageIsType2ThenCenteredSearchAndFavoritesAreUsed() {
        let settings = MockAppSettings()
        settings.homePage = .centerSearchAndFavorites
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components, [ .centeredSearch(fixed: false), .favorites(withHeader: false), .padding ])
    }

}

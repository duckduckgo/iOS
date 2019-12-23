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
    
    var settings: MockAppSettings!

    override func setUp() {
        settings = MockAppSettings()
    }
  
    func testWhenHomePageIsDefaultThenNavigationBarSearchIsUsed() {
        settings.homePageConfig = .simple
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .navigationBarSearch, .logo(withOffset: false) ])
    }

    func testWhenHomePageIsType1ThenFixedCenteredSearchIsUsed() {
        settings.homePageConfig = .centerSearch
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .centeredSearch(fixed: true) ])
    }

    func testWhenHomePageIsType2ThenCenteredSearchAndFavoritesAreUsed() {
        let settings = MockAppSettings()
        settings.homePageConfig = .centerSearchAndFavorites
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .centeredSearch(fixed: true) ])
    }

    func testWhenHomePageIsCenterAndFavoritesEnabledThenCorrectConfigReturned() {
        let settings = MockAppSettings()
        settings.homePageConfig = .centerSearchAndFavorites
        settings.homePageFeatureFavorites = true
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .centeredSearch(fixed: false), .favorites(withHeader: false), .padding(withOffset: false) ])
    }

    func testWhenHomePageIsSimpleWithPrivacyStatsThenCorrectConfigReturned() {
        settings.homePageFeaturePrivacyStats = true
        settings.homePageConfig = .simple
        let config = HomePageConfiguration(settings: settings)

        XCTAssertEqual(config.components(),
                       [ .privacyProtection, .navigationBarSearch, .logo(withOffset: true) ])
    }
    
    func testWhenHomePageIsCenteredWithPrivacyStatusThenCorrectConfigIsReturned() {
        settings.homePageConfig = .centerSearch
        settings.homePageFeaturePrivacyStats = true
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .centeredSearch(fixed: true), .privacyProtection ])
    }
    
    func testWhenHomePageIsCenteredWithPrivacyStatsAndFavoritesThenCorrectConfigIsReturned() {
        settings.homePageConfig = .centerSearchAndFavorites
        settings.homePageFeaturePrivacyStats = true
        settings.homePageFeatureFavorites = true
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(),
                       [ .centeredSearch(fixed: false), .privacyProtection, .favorites(withHeader: true), .padding(withOffset: true) ])
    }
    
}

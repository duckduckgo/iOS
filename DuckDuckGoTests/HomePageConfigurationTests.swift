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

/*
class HomePageConfigurationTests: XCTestCase {
    
    var settings: MockAppSettings!
    var variantManager: MockVariantManager!
    
    override func setUp() {
        settings = MockAppSettings()
        variantManager = MockVariantManager()
    }
  
    func testWhenHomePageIsDefaultThenNavigationBarSearchIsUsed() {
        let config = HomePageConfiguration(settings: settings)
        
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .navigationBarSearch(withOffset: false) ])
    }

    func testWhenHomePageIsType1ThenFixedCenteredSearchIsUsed() {
        settings.homePage = .centerSearch
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .centeredSearch(fixed: true), .empty ])
    }

    func testWhenHomePageIsType2ThenCenteredSearchAndFavoritesAreUsed() {
        let settings = MockAppSettings()
        settings.homePage = .centerSearchAndFavorites
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .centeredSearch(fixed: false), .favorites(withHeader: false), .padding(withOffset: false) ])
    }

}

// MARK: Experiment
class HomePageWithPrivacyStatsConfigurationTests: XCTestCase {
    
    var settings: MockAppSettings!
    var variantManager: MockVariantManager!
    
    override func setUp() {
        settings = MockAppSettings()
        variantManager = MockVariantManager(isSupportedReturns: true)
    }
    
    func testWhenHomePageIsDefaultThenNavigationBarSearchIsUsed() {
        let config = HomePageConfiguration(settings: settings)
        
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .privacyProtection, .navigationBarSearch(withOffset: true) ])
    }
    
    func testWhenHomePageIsType1ThenFixedCenteredSearchIsUsed() {
        settings.homePage = .centerSearch
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .centeredSearch(fixed: true), .privacyProtection, .empty ])
    }
    
    func testWhenHomePageIsType2ThenCenteredSearchAndFavoritesAreUsed() {
        let settings = MockAppSettings()
        settings.homePage = .centerSearchAndFavorites
        let config = HomePageConfiguration(settings: settings)
        XCTAssertEqual(config.components(withVariantManger: variantManager),
                       [ .centeredSearch(fixed: false), .privacyProtection, .favorites(withHeader: true), .padding(withOffset: true) ])
    }
    
}
*/

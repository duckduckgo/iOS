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

    func testWhenAtbAlreadySetThenInstallAddsNoFavorites() {
        
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [ .singleFavorite, .additionalFavorites ])
        
        let mockStatisticsStore = MockStatisticsStore()
        mockStatisticsStore.atb = "atb"
        
        let mockBookmarksStore = MockBookmarkStore()
        let bookmarksManager = BookmarksManager(dataStore: mockBookmarksStore)
        HomePageConfiguration.installNewUserFavorites(statisticsStore: mockStatisticsStore,
                                                      bookmarksManager: bookmarksManager,
                                                      variantManager: mockVariantManager)
        
        XCTAssertEqual(0, mockBookmarksStore.addedFavorites.count)
        XCTAssertEqual(0, mockBookmarksStore.addedBookmarks.count)
    }

    func testWhenVariantContainsSingleAndAdditionalFavoritesFeatureThenInstallAddsAllFavorites() {
        
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [ .singleFavorite, .additionalFavorites ])
        
        let mockStatisticsStore = MockStatisticsStore()
        let mockBookmarksStore = MockBookmarkStore()
        let bookmarksManager = BookmarksManager(dataStore: mockBookmarksStore)
        HomePageConfiguration.installNewUserFavorites(statisticsStore: mockStatisticsStore,
                                                      bookmarksManager: bookmarksManager,
                                                      variantManager: mockVariantManager)
        
        XCTAssertEqual(3, mockBookmarksStore.addedFavorites.count)
        XCTAssertEqual(0, mockBookmarksStore.addedBookmarks.count)
    }

    func testWhenVariantContainsAdditionalFavoritesFeatureThenInstallAddsAdditionalFavorites() {
        
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [ .additionalFavorites ])
        
        let mockStatisticsStore = MockStatisticsStore()
        let mockBookmarksStore = MockBookmarkStore()
        let bookmarksManager = BookmarksManager(dataStore: mockBookmarksStore)
        HomePageConfiguration.installNewUserFavorites(statisticsStore: mockStatisticsStore,
                                                      bookmarksManager: bookmarksManager,
                                                      variantManager: mockVariantManager)
        
        XCTAssertEqual(2, mockBookmarksStore.addedFavorites.count)
        XCTAssertEqual(0, mockBookmarksStore.addedBookmarks.count)
    }
    
    func testWhenVariantContainsSingleFavoriteFeatureThenInstallAddsSingleFavorite() {
        
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [ .singleFavorite ])
        
        let mockStatisticsStore = MockStatisticsStore()
        let mockBookmarksStore = MockBookmarkStore()
        let bookmarksManager = BookmarksManager(dataStore: mockBookmarksStore)
        HomePageConfiguration.installNewUserFavorites(statisticsStore: mockStatisticsStore,
                                                      bookmarksManager: bookmarksManager,
                                                      variantManager: mockVariantManager)
        
        XCTAssertEqual(1, mockBookmarksStore.addedFavorites.count)
        XCTAssertEqual(0, mockBookmarksStore.addedBookmarks.count)
    }
    
    func testWhenVariantContainsHomeScreenFeatureThenComponentsContainsCenteredSearch() {
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [ .homeScreen ])
        let config = HomePageConfiguration(variantManager: mockVariantManager)
        XCTAssertTrue(config.components.contains( .centeredSearch ))
    }
    
    func testWhenVariantDoesNotContainHomeFeatureScreenThenOldHomeScreenShown() {
        var mockVariantManager = MockVariantManager()
        mockVariantManager.currentVariant = Variant(name: "any", weight: 0, features: [])
        let config = HomePageConfiguration(variantManager: mockVariantManager)
        XCTAssertEqual([ HomePageConfiguration.Component.navigationBarSearch ], config.components)
    }
    
}

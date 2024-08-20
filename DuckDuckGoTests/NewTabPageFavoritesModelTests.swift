//
//  NewTabPageFavoritesModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Bookmarks
import BrowserServicesKit
@testable import DuckDuckGo

final class NewTabPageFavoritesModelTests: XCTestCase {
    private let favoritesListInteracting = MockFavoritesListInteracting()
    
    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testFiresPixelWhenExpandingList() {
        let sut = createSUT()

        XCTAssertTrue(sut.isCollapsed)
        sut.toggleCollapse()

        XCTAssertEqual(PixelFiringMock.lastPixel, .newTabPageFavoritesSeeMore)
    }

    func testFiresPixelWhenCollapsingList() {
        let sut = createSUT()

        sut.toggleCollapse()

        XCTAssertFalse(sut.isCollapsed)
        sut.toggleCollapse()

        XCTAssertEqual(PixelFiringMock.lastPixel, .newTabPageFavoritesSeeLess)
    }

    func testFiresPixelsOnFavoriteSelected() {
        let sut = createSUT()

        sut.favoriteSelected(Favorite(id: "", title: "", domain: "", urlObject: URL(string: "https://foo.bar")))

        XCTAssertEqual(PixelFiringMock.lastPixel, .favoriteLaunchedNTP)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixel, .favoriteLaunchedNTPDaily)
    }

    func testFiresPixelOnFavoriteDeleted() {
        let bookmark = createStubBookmark()
        favoritesListInteracting.favorites = [bookmark]

        let sut = createSUT()

        sut.deleteFavorite(Favorite(id: bookmark.uuid!, title: "", domain: ""))

        XCTAssertEqual(PixelFiringMock.lastPixel, .homeScreenDeleteFavorite)
    }

    func testFiresPixelOnFavoriteEdited() {
        let bookmark = createStubBookmark()
        favoritesListInteracting.favorites = [bookmark]

        let sut = createSUT()

        sut.editFavorite(Favorite(id: bookmark.uuid!, title: "", domain: ""))

        XCTAssertEqual(PixelFiringMock.lastPixel, .homeScreenEditFavorite)
    }

    func testFiresPixelOnTappingPlaceholder() {
        let sut = createSUT()

        sut.placeholderTapped()

        XCTAssertEqual(PixelFiringMock.lastPixel, .newTabPageFavoritesPlaceholderTapped)
    }

    func testFiresPixelOnShowingTooltip() {
        let sut = createSUT()

        XCTAssertFalse(sut.isShowingTooltip)
        sut.toggleTooltip()

        XCTAssertEqual(PixelFiringMock.lastPixel, .newTabPageFavoritesInfoTooltip)
    }

    private func createStubBookmark() -> BookmarkEntity {
        let bookmarksDB = MockBookmarksDatabase.make()
        let context = bookmarksDB.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let root = BookmarkUtils.fetchRootFolder(context)!
        return BookmarkEntity.makeBookmark(title: "foo", url: "", parent: root, context: context)
    }

    private func createSUT() -> FavoritesDefaultModel {
        FavoritesDefaultModel(interactionModel: favoritesListInteracting,
                              pixelFiring: PixelFiringMock.self,
                              dailyPixelFiring: PixelFiringMock.self)
    }
}

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
import Combine
import Bookmarks
@testable import Core
@testable import DuckDuckGo

final class NewTabPageFavoritesModelTests: XCTestCase {
    private let favoriteDataSource = MockNewTabPageFavoriteDataSource()

    override func setUpWithError() throws {
        throw XCTSkip("Potentially flaky")

        try super.setUpWithError()
    }

    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testFiresPixelWhenExpandingList() {
        let sut = createSUT()

        XCTAssertTrue(sut.isCollapsed)
        sut.toggleCollapse()

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageFavoritesSeeMore.name)
    }

    func testFiresPixelWhenCollapsingList() {
        let sut = createSUT()

        sut.toggleCollapse()

        XCTAssertFalse(sut.isCollapsed)
        sut.toggleCollapse()

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageFavoritesSeeLess.name)
    }

    func testReturnsAllFavoritesWhenCustomizationDisabled() {
        favoriteDataSource.favorites.append(contentsOf: Array(repeating: Favorite.stub(), count: 10))
        let sut = createSUT(isNewTabPageCustomizationEnabled: false)
        
        XCTAssertEqual(sut.prefixedFavorites(for: 1).items.count, 10)
    }

    func testFiresPixelsOnFavoriteSelected() {
        let sut = createSUT()

        sut.favoriteSelected(Favorite(id: "", title: "", domain: "", urlObject: URL(string: "https://foo.bar")))

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.favoriteLaunchedNTP.name)
        XCTAssertEqual(PixelFiringMock.lastDailyPixelInfo?.pixelName, Pixel.Event.favoriteLaunchedNTPDaily.name)
    }

    func testFiresPixelOnFavoriteDeleted() {
        let favorite = Favorite.stub()
        favoriteDataSource.favorites = [favorite]

        let sut = createSUT()

        sut.deleteFavorite(favorite)

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.homeScreenDeleteFavorite.name)
    }

    func testFiresPixelOnFavoriteEdited() {
        let favorite = Favorite.stub()
        favoriteDataSource.favorites = [favorite]

        let sut = createSUT()

        sut.editFavorite(favorite)

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.homeScreenEditFavorite.name)
    }

    func testFiresPixelOnTappingPlaceholder() {
        let sut = createSUT()

        sut.placeholderTapped()

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageFavoritesPlaceholderTapped.name)
    }

    func testPrefixFavoritesCreatesRemainingPlaceholders() {
        let sut = createSUT()

        let slice = sut.prefixedFavorites(for: 3)

        XCTAssertEqual(slice.items.filter(\.isPlaceholder).count, 2)
        XCTAssertEqual(slice.items.count, 3)
        XCTAssertFalse(slice.isCollapsible)
    }

    func testPrefixFavoritesDoesNotCreatePlaceholdersWhenCustomizationDisabled() {
        let sut = createSUT(isNewTabPageCustomizationEnabled: false)

        let slice = sut.prefixedFavorites(for: 3)

        XCTAssertTrue(slice.items.filter(\.isPlaceholder).isEmpty)
        XCTAssertTrue(slice.items.isEmpty)
        XCTAssertFalse(slice.isCollapsible)
    }

    func testPrefixFavoritesLimitsToTwoRows() {
        favoriteDataSource.favorites.append(contentsOf: Array(repeating: Favorite.stub(), count: 10))
        let sut = createSUT()

        let slice = sut.prefixedFavorites(for: 4)

        XCTAssertEqual(slice.items.count, 8)
        XCTAssertTrue(slice.isCollapsible)
    }

    func testListNotCollapsibleWhenCustomizationDisabled() {
        favoriteDataSource.favorites.append(contentsOf: Array(repeating: Favorite.stub(), count: 10))

        let sut = createSUT(isNewTabPageCustomizationEnabled: false)

        let favorites = sut.prefixedFavorites(for: 1)
        XCTAssertFalse(favorites.isCollapsible)
        XCTAssertFalse(sut.isCollapsed)
    }

    func testAddItemIsLastWhenFavoritesPresent() throws {
        favoriteDataSource.favorites.append(contentsOf: Array(repeating: Favorite.stub(), count: 10))
        let sut = createSUT()
        
        let lastItem = try XCTUnwrap(sut.allFavorites.last)

        XCTAssertTrue(lastItem == .addFavorite)
    }

    func testAddItemIsFirstWhenFavoritesEmpty() throws {
        let sut = createSUT()
        
        let firstItem = try XCTUnwrap(sut.allFavorites.first)
        
        XCTAssertTrue(firstItem == .addFavorite)
    }

    func testDoesNotAppendAddItemWhenCustomizationDisabled() {
        let sut = createSUT(isNewTabPageCustomizationEnabled: false)

        XCTAssertNil(sut.allFavorites.first)

        favoriteDataSource.favorites.append(contentsOf: Array(repeating: Favorite.stub(), count: 10))

        XCTAssertNil(sut.allFavorites.first(where: { $0 == .addFavorite }))
    }

    private func createSUT(isNewTabPageCustomizationEnabled: Bool = true) -> FavoritesViewModel {
        FavoritesViewModel(isNewTabPageCustomizationEnabled: isNewTabPageCustomizationEnabled,
                           favoriteDataSource: favoriteDataSource,
                           faviconLoader: MockFavoritesFaviconLoading(),
                           faviconsCache: MockFavoritesFaviconCaching(),
                           pixelFiring: PixelFiringMock.self,
                           dailyPixelFiring: PixelFiringMock.self)
    }
}

private final class MockNewTabPageFavoriteDataSource: NewTabPageFavoriteDataSource {
    var externalUpdates: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher()
    var favorites: [DuckDuckGo.Favorite] = []

    func moveFavorite(_ favorite: DuckDuckGo.Favorite, fromIndex: Int, toIndex: Int) { }
    func favorite(at index: Int) throws -> DuckDuckGo.Favorite? { nil }
    func removeFavorite(_ favorite: DuckDuckGo.Favorite) { }
    func bookmarkEntity(for favorite: DuckDuckGo.Favorite) -> Bookmarks.BookmarkEntity? {
        createStubBookmark()
    }

    private func createStubBookmark() -> BookmarkEntity {
        let bookmarksDB = MockBookmarksDatabase.make()
        let context = bookmarksDB.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let root = BookmarkUtils.fetchRootFolder(context)!
        return BookmarkEntity.makeBookmark(title: "foo", url: "", parent: root, context: context)
    }
}

private extension Favorite {
    static func stub() -> Favorite {
        Favorite(id: UUID().uuidString, title: "foo", domain: "bar")
    }
}

private extension FavoriteItem {
    var isPlaceholder: Bool {
        switch self {
        case .placeholder: return true
        case .favorite, .addFavorite: return false
        }
    }
}

private final class MockFavoritesFaviconLoading: FavoritesFaviconLoading {
    func loadFavicon(for favorite: Favorite, size: CGFloat) async -> Favicon? {
        nil
    }

    func fakeFavicon(for favorite: Favorite, size: CGFloat) -> Favicon {
        Favicon(image: .init(), isUsingBorder: false, isFake: false)
    }

    func existingFavicon(for favorite: Favorite, size: CGFloat) -> Favicon? {
        nil
    }
}

private final class MockFavoritesFaviconCaching: FavoritesFaviconCaching {
    func populateFavicon(for domain: String, intoCache: FaviconsCacheType, fromCache: FaviconsCacheType?) {

    }
}

//
//  AddFavoriteViewModelTests.swift
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
import Persistence
@testable import DuckDuckGo
import Core
import CoreData

final class AddFavoriteViewModelTests: XCTestCase {

    let websiteSearching = MockWebsiteSearching()
    let favoritesCreating = MockMenuBookmarksInterating()
    let booksmarksSearch = MockBookmarksStringSearch()

    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testFiresPixelOnCustomWebsite() {
        let sut = createSUT()

        sut.addCustomWebsite()

        XCTAssertEqual(PixelFiringMock.lastPixel, .addFavoriteAddCustomWebsite)
        XCTAssertEqual(PixelFiringMock.lastParams, [:])
    }

    private func createSUT() -> AddFavoriteViewModel {
        AddFavoriteViewModel(websiteSearching: websiteSearching,
                             favoritesCreating: favoritesCreating,
                             booksmarksSearch: booksmarksSearch,
                             faviconLoading: FavoritesFaviconLoader(),
                             faviconUpdating: MockFaviconUpdating(),
                             pixelFiring: PixelFiringMock.self)
    }
}

final class MockMenuBookmarksInterating: MenuBookmarksInteracting {

    var stubEntity: BookmarkEntity?

    var favoritesDisplayMode: FavoritesDisplayMode = .displayNative(.mobile)

    func createOrToggleFavorite(title: String, url: URL) {

    }

    func createBookmark(title: String, url: URL) {

    }

    func favorite(for url: URL) -> BookmarkEntity? {
        stubEntity
    }

    func bookmark(for url: URL) -> BookmarkEntity? {
        stubEntity
    }
}

final class MockBookmarksStringSearch: BookmarksStringSearch {
    var hasData: Bool = false
    func search(query: String) -> [BookmarksStringSearchResult] {
        []
    }
}

final class MockWebsiteSearching: WebsiteSearching {
    var results: [URL] = []
    func search(term: String) async throws -> [URL] {
        results
    }
}

final class MockFaviconUpdating: FaviconUpdating {
    func updateFavicon(forDomain domain: String, with image: UIImage) {

    }
}

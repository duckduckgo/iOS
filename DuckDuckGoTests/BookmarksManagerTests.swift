//
//  BookmarksManagerTests.swift
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

class BookmarksManagerTests: XCTestCase {

    struct Constants {
        static let exampleTitle = "example"
        static let exampleUrl = URL(string: "https://example.com")!
        static let exampleLink = Link(title: exampleTitle, url: exampleUrl)
        static let otherTitle = "oter"
        static let otherUrl = URL(string: "https://other.com")!
        static let otherLink = Link(title: otherTitle, url: otherUrl)
    }
    
    lazy var mockStore: MockBookmarkStore = MockBookmarkStore()
    lazy var manager = BookmarksManager(dataStore: mockStore)

    func testWhenFavoriteMovedToBookmarkThenBookmarksAndFavoritesAreUpdated() {
        mockStore.favorites = [Constants.otherLink, Constants.exampleLink]
        manager.moveFavorite(at: 0, toBookmark: 0)
        
        XCTAssertEqual(1, mockStore.bookmarks?.count)
        XCTAssertEqual(1, mockStore.favorites?.count)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.bookmarks?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.bookmarks?[0].url)
        
        XCTAssertEqual(Constants.exampleTitle, mockStore.favorites?[0].title)
        XCTAssertEqual(Constants.exampleUrl, mockStore.favorites?[0].url)
    }

    func testWhenBookmarkMovedToFavoritesThenBookmarksAndFavoritesAreUpdated() {
        mockStore.bookmarks = [Constants.exampleLink, Constants.otherLink]
        manager.moveBookmark(at: 0, toFavorite: 0)

        XCTAssertEqual(1, mockStore.bookmarks?.count)
        XCTAssertEqual(1, mockStore.favorites?.count)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.bookmarks?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.bookmarks?[0].url)

        XCTAssertEqual(Constants.exampleTitle, mockStore.favorites?[0].title)
        XCTAssertEqual(Constants.exampleUrl, mockStore.favorites?[0].url)
    }
    
    func testWhenFavoriteMovedInFavoritesThenFavoritesAreUpdated() {
        
        mockStore.favorites = [Constants.exampleLink, Constants.otherLink]
        manager.moveFavorite(at: 0, to: 1)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.favorites?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.favorites?[0].url)
        
        mockStore.favorites = [Constants.exampleLink, Constants.otherLink]
        manager.moveFavorite(at: 1, to: 0)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.favorites?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.favorites?[0].url)
    }
    
    func testWhenBookmarkMovedInBookmarksThenBookmarksAreUpdated() {
        
        mockStore.bookmarks = [Constants.exampleLink, Constants.otherLink]
        manager.moveBookmark(at: 0, to: 1)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.bookmarks?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.bookmarks?[0].url)

        mockStore.bookmarks = [Constants.exampleLink, Constants.otherLink]
        manager.moveBookmark(at: 1, to: 0)
        
        XCTAssertEqual(Constants.otherTitle, mockStore.bookmarks?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.bookmarks?[0].url)
    }
    
    func testWhenUpdateFavoriteThenBookmarkIsUpdatedInStore() {
        mockStore.favorites = [Constants.exampleLink]
        manager.updateFavorite(at: 0, with: Constants.otherLink)
        XCTAssertEqual(Constants.otherTitle, mockStore.favorites?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.favorites?[0].url)
    }

    func testWhenUpdateBookmarkThenBookmarkIsUpdatedInStore() {
        mockStore.bookmarks = [Constants.exampleLink]
        manager.updateBookmark(at: 0, with: Constants.otherLink)
        XCTAssertEqual(Constants.otherTitle, mockStore.bookmarks?[0].title)
        XCTAssertEqual(Constants.otherUrl, mockStore.bookmarks?[0].url)
    }
    
    func testWhenDeleteFavoriteThenCountIsCorrect() {
        mockStore.favorites = [Constants.exampleLink]
        manager.deleteFavorite(at: 0)
        XCTAssertEqual(0, manager.favoritesCount)
    }

    func testWhenDeleteBookmarkThenCountIsCorrect() {
        mockStore.bookmarks = [Constants.exampleLink]
        manager.deleteBookmark(at: 0)
        XCTAssertEqual(0, manager.bookmarksCount)
    }
    
    func testWhenFavoriteRetrievedByIndexThenFavoriteReturned() {
        mockStore.favorites = [Constants.exampleLink]
        XCTAssertEqual(Constants.exampleTitle, manager.favorite(atIndex: 0)?.title)
        XCTAssertEqual(Constants.exampleUrl, manager.favorite(atIndex: 0)?.url)
    }

    func testWhenBookmarkRetrievedByIndexThenBookmarkReturned() {
        mockStore.bookmarks = [Constants.exampleLink]
        XCTAssertEqual(Constants.exampleTitle, manager.bookmark(atIndex: 0)?.title)
        XCTAssertEqual(Constants.exampleUrl, manager.bookmark(atIndex: 0)?.url)
    }
    
    func testWhenFavoritesAvailableThenCountIsCorrect() {
        mockStore.favorites = [Constants.exampleLink]
        XCTAssertEqual(1, manager.favoritesCount)
    }
    
    func testWhenBookmarksAvailableThenCountIsCorrect() {
        mockStore.bookmarks = [Constants.exampleLink]
        XCTAssertEqual(1, manager.bookmarksCount)
    }
    
    func testWhenFavoriteSavedThenFavoriteAddedToStore() {
        manager.save(favorite: Constants.exampleLink)
        XCTAssertEqual(1, mockStore.addedFavorites.count)
        XCTAssertEqual(Constants.exampleTitle, mockStore.addedFavorites[0].title)
        XCTAssertEqual(Constants.exampleUrl, mockStore.addedFavorites[0].url)
    }

    func testWhenBookmarkSavedThenBookmarkAddedToStore() {
        manager.save(bookmark: Constants.exampleLink)
        XCTAssertEqual(1, mockStore.addedBookmarks.count)
        XCTAssertEqual(Constants.exampleTitle, mockStore.addedBookmarks[0].title)
        XCTAssertEqual(Constants.exampleUrl, mockStore.addedBookmarks[0].url)
    }
    
    func testWhenNewThenFavoritesCountIsZero() {
        XCTAssertEqual(0, manager.favoritesCount)
    }

    func testWhenNewThenBookmarksCountIsZero() {
        XCTAssertEqual(0, manager.bookmarksCount)
    }
    
}

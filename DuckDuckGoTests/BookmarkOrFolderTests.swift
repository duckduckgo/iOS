//
//  BookmarkOrFolderTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

class BookmarkOrFolderTests: XCTestCase {

    func test_WhenBookmarkHasUrl_ThenIsValidBookmark() throws {
        let bookmarkOrFolder = BookmarkOrFolder(name: Constants.bookmarkTitle, type: .bookmark, urlString: Constants.bookmarkURLString, children: nil)
        XCTAssertFalse(bookmarkOrFolder.isInvalidBookmark)
    }

    func test_WhenBookmarkHasNoUrl_ThenIsInvalidBookmark() throws {
        let bookmarkOrFolder = BookmarkOrFolder(name: Constants.bookmarkTitle, type: .bookmark, urlString: nil, children: nil)
        XCTAssertTrue(bookmarkOrFolder.isInvalidBookmark)
    }

    func test_WhenFavoriteHasUrl_ThenIsValidBookmark() throws {
        let bookmarkOrFolder = BookmarkOrFolder(name: Constants.bookmarkTitle, type: .favorite, urlString: Constants.bookmarkURLString, children: nil)
        XCTAssertFalse(bookmarkOrFolder.isInvalidBookmark)
    }

    func test_WhenFavoriteHasNoUrl_ThenIsInvalidBookmark() throws {
        let bookmarkOrFolder = BookmarkOrFolder(name: Constants.bookmarkTitle, type: .favorite, urlString: nil, children: nil)
        XCTAssertTrue(bookmarkOrFolder.isInvalidBookmark)
    }

    func test_WhenFolder_ThenIsValidBookmark() throws {
        let bookmarkOrFolder = BookmarkOrFolder(name: Constants.bookmarkTitle, type: .folder, urlString: nil, children: nil)
        XCTAssertFalse(bookmarkOrFolder.isInvalidBookmark)
    }
}

private extension BookmarkOrFolderTests {
    enum Constants {
        static let bookmarkTitle = "my bookmark"
        static let bookmarkURLString = "https://duckduckgo.com"
    }
}

//
//  FireproofFaviconUpdaterTests.swift
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

import Foundation
import XCTest
@testable import DuckDuckGo
import Persistence
import Core
import Bookmarks

class FireproofFaviconUpdaterTests: XCTestCase, TabNotifying, FaviconProviding {

    var db: CoreDataDatabase!

    var didUpdateFaviconCalled = false
    var replaceFaviconCalled = false

    var loadFaviconDomain: String?
    var loadFaviconURL: URL?
    var loadFaviconCache: Favicons.CacheType?

    var image: UIImage?

    override func setUpWithError() throws {
        try super.setUpWithError()

        let model = CoreDataDatabase.loadModel(from: Bookmarks.bundle, named: "BookmarksModel")!

        db = CoreDataDatabase(name: "Test", containerLocation: tempDBDir(), model: model)
        db.loadStore()

        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        BookmarkUtils.prepareFoldersStructure(in: context)
        try context.save()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try db.tearDown(deleteStores: true)
    }

    func testWhenBookmarkDoesNotExist_ThenImageNotReplacement() {
        let updater = FireproofFaviconUpdater(bookmarksDatabase: db, tab: self, favicons: self)
        updater.faviconUserScript(FaviconUserScript(), didRequestUpdateFaviconForHost: "example.com", withUrl: nil)

        XCTAssertEqual(loadFaviconDomain, "example.com")
        XCTAssertEqual(loadFaviconURL, nil)
        XCTAssertEqual(loadFaviconCache, .tabs)

        XCTAssertTrue(didUpdateFaviconCalled)
        XCTAssertFalse(replaceFaviconCalled)
    }

    func testWhenBookmarkExistsButNoImage_ThenImageNotReplacement() throws {
        try createBookmark()

        let updater = FireproofFaviconUpdater(bookmarksDatabase: db, tab: self, favicons: self)
        updater.faviconUserScript(FaviconUserScript(), didRequestUpdateFaviconForHost: "example.com", withUrl: nil)

        XCTAssertEqual(loadFaviconDomain, "example.com")
        XCTAssertEqual(loadFaviconURL, nil)
        XCTAssertEqual(loadFaviconCache, .tabs)

        XCTAssertTrue(didUpdateFaviconCalled)
        XCTAssertFalse(replaceFaviconCalled)
    }

    func testWhenBookmarkExistsButAnddImageExists_ThenImageIsReplaced() throws {
        try createBookmark()

        image = UIImage()
        let url = URL(string: "https://example.com/favicon.ico")!

        let updater = FireproofFaviconUpdater(bookmarksDatabase: db, tab: self, favicons: self)
        updater.faviconUserScript(FaviconUserScript(), didRequestUpdateFaviconForHost: "example.com", withUrl: url)

        XCTAssertEqual(loadFaviconDomain, "example.com")
        XCTAssertEqual(loadFaviconURL, url)
        XCTAssertEqual(loadFaviconCache, .tabs)

        XCTAssertTrue(didUpdateFaviconCalled)
        XCTAssertTrue(replaceFaviconCalled)
    }

    func testWhenBookmarkExistsWithWWWPrefixButAnddImageExists_ThenImageIsReplaced() throws {
        try createBookmark()

        image = UIImage()
        let url = URL(string: "https://example.com/favicon.ico")!

        let updater = FireproofFaviconUpdater(bookmarksDatabase: db, tab: self, favicons: self)
        updater.faviconUserScript(FaviconUserScript(), didRequestUpdateFaviconForHost: "www.example.com", withUrl: url)

        XCTAssertEqual(loadFaviconDomain, "www.example.com")
        XCTAssertEqual(loadFaviconURL, url)
        XCTAssertEqual(loadFaviconCache, .tabs)

        XCTAssertTrue(didUpdateFaviconCalled)
        XCTAssertTrue(replaceFaviconCalled)
    }

    func didUpdateFavicon() {
        didUpdateFaviconCalled = true
    }

    func loadFavicon(forDomain domain: String, fromURL url: URL?, intoCache cacheType: Favicons.CacheType, completion: ((UIImage?) -> Void)?) {
        loadFaviconDomain = domain
        loadFaviconURL = url
        loadFaviconCache = cacheType
        completion?(image)
    }

    func replaceFireproofFavicon(forDomain domain: String?, withImage: UIImage) {
        replaceFaviconCalled = true
    }

    func createBookmark() throws {
        let context = db.makeContext(concurrencyType: .mainQueueConcurrencyType)
        guard let root = BookmarkUtils.fetchRootFolder(context) else {
            fatalError("failed to fetch root folder")
        }
        _ = BookmarkEntity.makeBookmark(title: "Test", url: "https://www.example.com", parent: root, context: context)
        try context.save()
    }

}

func tempDBDir() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
}

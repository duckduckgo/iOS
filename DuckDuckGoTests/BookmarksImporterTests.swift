//
//  BookmarksImporterTests.swift
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
import SwiftSoup
@testable import Core

class BookmarksImporterTests: XCTestCase {

    private var storage: MockBookmarksCoreDataStore!
    private var importer: BookmarksImporter!
    private var htmlLoader: HtmlTestDataLoader!

    override func setUpWithError() throws {
        try super.setUpWithError()

        htmlLoader = HtmlTestDataLoader()
        storage = MockBookmarksCoreDataStore()
        _ = BookmarksCoreDataStorage.rootFolderManagedObject(storage.viewContext)
        _ = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(storage.viewContext)

        storage.saveContext()
        storage.loadStoreAndCaches { _ in }

        importer = BookmarksImporter(coreDataStore: storage)
    }

    override func tearDownWithError() throws {
        htmlLoader = nil
        storage = nil
        importer = nil

        try super.tearDownWithError()
    }

    func test_WhenDocumentIsOfSafariFormat_ThenReturnTrue() throws {
        let document: Document = try SwiftSoup.parse(htmlLoader.fromHtmlFile("MockFiles/bookmarks_safari.html"))
        XCTAssertTrue(importer.isDocumentInSafariFormat(document))
    }

    func test_WhenParseChromeHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_chrome.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 9)
    }

    func test_WhenParseSafariHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_safari.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 10)
    }

    func test_WhenParseSafariHtml_ThenReadingListExcluded() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_safari.html"))

        let result = importer.importedBookmarks.filter { $0.name == "Reading List" }
        XCTAssertEqual(result.count, 0)
    }

    func test_WhenParseFirefoxHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_firefox.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 10)
    }

    func test_WhenParseBraveHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_brave.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 1)
    }

    func test_WhenParseDDGAndroidHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_ddg_android.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 2)
    }

    func test_WhenParseDDGMacOSHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_ddg_macos.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 9)
    }

    func test_WhenParseNetscapeHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_netscape_nested.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 5)
    }

    func test_WhenParseFirefoxFlatHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_firefox_flat.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 23)
    }

    func test_WhenParseFirefoxNestedHtml_ThenImportSuccess() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_firefox_nested.html"))
        XCTAssertEqual(importer.importedBookmarks.count, 8)
    }

    func test_WhenParseInvalidHtml_ThenImportFail() async throws {
        // Note: wanted to use XCTAssertThrowsError but it doesn't support concurrency yet
        do {
            try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_invalid.html"))
            XCTFail("Expected parsing of HTML to fail, but succeeded")
        } catch {
            XCTAssertEqual(error as? BookmarksImportError, .invalidHtmlNoDLTag)
        }
    }

    func test_WhenCreateBookmark_ThenBookmarkCreated() {
        let importedBookmark = BookmarkOrFolder(name: "AFolder", type: .folder,
                urlString: Constants.bookmarkURLString, children: nil)

        let createdBookmark = importer.createBookmarkOrFolder(name: "A bookmark",
                                                              type: .bookmark,
                                                              urlString: Constants.bookmarkURLString,
                                                              bookmarkOrFolder: importedBookmark)
        XCTAssertNotNil(createdBookmark)
        XCTAssertEqual(createdBookmark.type, .bookmark)
    }

    func test_WhenSaveBookmarks_ThenDataSaved() async throws {
        try await importer.parseHtml(htmlLoader.fromHtmlFile("MockFiles/bookmarks_safari.html"))
        try await importer.saveBookmarks(importer.importedBookmarks)

        // Note: exhaustive hierarchy is tested in BookmarksExporterTests.testExportHtml
        XCTAssertEqual(storage.topLevelBookmarksItems.count, 10)
    }

    func test_WhenParseHtmlAndSave_ThenDataSaved() async {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_chrome.html"))
        switch result {
        case .success(let importedBookmarks):
            XCTAssertEqual(importedBookmarks.count, 9)
        case .failure(let bookmarksImportError):
            XCTFail("Failed to parse and save HTML \(bookmarksImportError.localizedDescription)")
        }
    }
}

private extension BookmarksImporterTests {
    enum Constants {
        static let bookmarkTitle = "my bookmark"
        static let bookmarkURLString = "https://duckduckgo.com"
        static let bookmarkURL = URL(string: "https://duckduckgo.com")!
    }
}

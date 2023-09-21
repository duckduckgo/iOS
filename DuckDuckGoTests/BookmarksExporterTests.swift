//
//  BookmarksExporterTests.swift
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
@testable import Core

@MainActor
class BookmarksExporterTests: XCTestCase {

    private var storage = MockBookmarksDatabase.make()
    private var htmlLoader: HtmlTestDataLoader!
    private var importer: BookmarksImporter!
    private var exporter: BookmarksExporter!

    override func setUpWithError() throws {
        try super.setUpWithError()

        htmlLoader = HtmlTestDataLoader()

        importer = BookmarksImporter(coreDataStore: storage, favoritesDisplayMode: .displayNative(.mobile))
        exporter = BookmarksExporter(coreDataStore: storage, favoritesDisplayMode: .displayNative(.mobile))
    }

    override func tearDownWithError() throws {
        importer = nil
        exporter = nil
        htmlLoader = nil
        
        try storage.tearDown(deleteStores: true)
        
        try super.tearDownWithError()
    }
    
    func test_WhenImportChrome_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_chrome.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Bookmarks Bar"))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(buildCommonContent())
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    func test_WhenImportSafari_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_safari.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Favourites"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Apple",
                                                               url: "https://www.apple.com/uk"))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Bookmarks Menu"))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(buildCommonContent())
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    func test_WhenImportFirefox_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_firefox.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Mozilla Firefox"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Get Help",
                                                               url: "https://support.mozilla.org/en-US/products/firefox"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Customize Firefox",
                                                               url: "https://support.mozilla.org/en-US/kb/customize-firefox-controls-buttons-and-toolbars?utm_source=firefox-browser&utm_medium=default-bookmarks&utm_campaign=customize"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Get Involved",
                                                               url: "https://www.mozilla.org/en-US/contribute/"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "About Us",
                                                               url: "https://www.mozilla.org/en-US/about/"))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(buildCommonContent())
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Bookmarks Toolbar"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Getting Started",
                                                               url: "https://www.mozilla.org/en-US/firefox/central/"))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    func test_WhenImportBrave_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_brave.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "Bookmarks bar"))
            content.append(buildCommonContent(level: 3))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    func test_WhenImportDDGAndroid_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_ddg_android.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "DuckDuckGo Bookmarks"))
            content.append(buildCommonContent(level: 3))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(BookmarksExporter.Template.openFolder(level: 2, named: "DuckDuckGo Favorites"))
            content.append(BookmarksExporter.Template.bookmark(level: 3,
                                                               title: "Apple (United Kingdom)",
                                                               url: "https://www.apple.com/uk/",
                                                               isFavorite: true))
            content.append(BookmarksExporter.Template.closeFolder(level: 2))
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    func test_WhenImportDDGMacOS_ThenExportSuccess() async throws {
        let result = await importer.parseAndSave(html: htmlLoader.fromHtmlFile("MockFiles/bookmarks_ddg_macos.html"))
        switch result {
        case .success:
            guard let exportedHtml = try? exporter.exportBookmarksToContent() else {
                return XCTFail("Could not export HTML")
            }

            var content = [BookmarksExporter.Template.header]
            content.append(buildCommonContent())
            content.append(BookmarksExporter.Template.bookmark(level: 2,
                                                               title: "Apple (United Kingdom)",
                                                               url: "https://www.apple.com/uk/",
                                                               isFavorite: true))
            content.append(BookmarksExporter.Template.footer)

            XCTAssertEqual(exportedHtml, content.joined())
        case .failure:
            XCTFail("Could not import HTML")
        }
    }

    // swiftlint:disable:next function_body_length
    func buildCommonContent(level: Int = 2) -> String {
        return [
            BookmarksExporter.Template.openFolder(level: level, named: "FolderA-Level1"),
            BookmarksExporter.Template.openFolder(level: level + 1, named: "FolderA-Level2"),
            BookmarksExporter.Template.openFolder(level: level + 2, named: "FolderA-Level3"),
            BookmarksExporter.Template.bookmark(level: level + 3,
                                                title: "News, sport and opinion from the Guardian\'s global edition | The Guardian",
                                                url: "https://www.theguardian.com/international"),
            BookmarksExporter.Template.closeFolder(level: level + 2),
            BookmarksExporter.Template.bookmark(level: level + 2,
                                                title: "Digg - What the Internet is talking about right now",
                                                url: "https://digg.com/"),
            BookmarksExporter.Template.closeFolder(level: level + 1),
            BookmarksExporter.Template.bookmark(level: level + 1,
                                                title: "Wikipedia",
                                                url: "https://www.wikipedia.org/"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.openFolder(level: level, named: "FolderB-Level1"),
            BookmarksExporter.Template.openFolder(level: level + 1, named: "FolderB-Level2"),
            BookmarksExporter.Template.openFolder(level: level + 2, named: "FolderB-Level3-a"),
            BookmarksExporter.Template.bookmark(level: level + 3,
                    title: "Bloomberg.com",
                    url: "https://www.bloomberg.com/europe"),
            BookmarksExporter.Template.closeFolder(level: level + 2),
            BookmarksExporter.Template.openFolder(level: level + 2, named: "FolderB-Level3-b"),
            BookmarksExporter.Template.bookmark(level: level + 3,
                    title: "TechCrunch – Startup and Technology News",
                    url: "https://techcrunch.com/"),
            BookmarksExporter.Template.closeFolder(level: level + 2),
            BookmarksExporter.Template.bookmark(level: level + 2,
                    title: "The Verge",
                    url: "https://www.theverge.com/"),
            BookmarksExporter.Template.closeFolder(level: level + 1),
            BookmarksExporter.Template.bookmark(level: level + 1,
                    title: "Techmeme",
                    url: "https://techmeme.com/"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.openFolder(level: level, named: "EmptyFolder"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.openFolder(level: level, named: "DuplicateFolderName"),
            BookmarksExporter.Template.bookmark(level: level + 1,
                    title: "Breaking News | Irish &amp; International Headlines | The Irish Times",
                    url: "https://www.irishtimes.com/"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.openFolder(level: level, named: "DuplicateFolderName"),
            BookmarksExporter.Template.bookmark(level: level + 1,
                    title: "The Wall Street Journal - Breaking News, Business, Financial &amp; Economic News, World News and Video",
                    url: "https://www.wsj.com/?mod=wsjheader_logo"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.bookmark(level: level,
                    title: "DuckDuckGo — Privacy, simplified.",
                    url: "https://duckduckgo.com/"),
            BookmarksExporter.Template.openFolder(level: level, named: "DupeFolderNameContents"),
            BookmarksExporter.Template.bookmark(level: level + 1,
                    title: "MacRumors: Apple News and Rumors",
                    url: "https://www.macrumors.com/"),
            BookmarksExporter.Template.closeFolder(level: level),
            BookmarksExporter.Template.openFolder(level: level, named: "DupeFolderNameContents"),
            BookmarksExporter.Template.bookmark(level: level + 1,
                    title: "MacRumors: Apple News and Rumors",
                    url: "https://www.macrumors.com/"),
            BookmarksExporter.Template.closeFolder(level: level)
        ].joined()
    }
}

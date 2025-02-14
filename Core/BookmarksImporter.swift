//
//  BookmarksImporter.swift
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

import Bookmarks
import Common
import Foundation
import Persistence
import SwiftSoup
import os.log
import BrowserServicesKit

public enum BookmarksImportError: Error {
    case invalidHtmlNoDLTag
    case invalidHtmlNoBodyTag
    case safariTransformFailure
    case saveFailure
    case unknown
}

final public class BookmarksImporter {

    public enum Notifications {
        public static let importDidBegin = Notification.Name("com.duckduckgo.app.BookmarksImportDidBegin")
        public static let importDidEnd = Notification.Name("com.duckduckgo.app.BookmarksImportDidEnd")
    }

    private(set) var importedBookmarks: [BookmarkOrFolder] = []
    private(set) var coreDataStorage: BookmarkCoreDataImporter
    private let htmlContent: String

    @MainActor
    public init(coreDataStore: CoreDataDatabase, favoritesDisplayMode: FavoritesDisplayMode, htmlContent: String) {
        coreDataStorage = BookmarkCoreDataImporter(database: coreDataStore, favoritesDisplayMode: favoritesDisplayMode)
        self.htmlContent = htmlContent
    }

    @MainActor
    public func parseAndSave() async -> Result<BookmarksImportSummary, BookmarksImportError> {
        NotificationCenter.default.post(name: Notifications.importDidBegin, object: nil)

        do {
            try await parseHtml(htmlContent)
            let summary = try await saveBookmarks(importedBookmarks)
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            return .success(summary)
        } catch BookmarksImportError.invalidHtmlNoDLTag {
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            Pixel.fire(pixel: .bookmarkImportFailureParsingDL)
            return .failure(.invalidHtmlNoDLTag)
        } catch BookmarksImportError.invalidHtmlNoBodyTag {
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            Pixel.fire(pixel: .bookmarkImportFailureParsingBody)
            return .failure(.invalidHtmlNoBodyTag)
        } catch BookmarksImportError.safariTransformFailure {
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            Pixel.fire(pixel: .bookmarkImportFailureTransformingSafari)
            return .failure(.safariTransformFailure)
        } catch BookmarksImportError.saveFailure {
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            Pixel.fire(pixel: .bookmarkImportFailureSaving)
            return .failure(.saveFailure)
        } catch {
            NotificationCenter.default.post(name: Notifications.importDidEnd, object: nil)
            Pixel.fire(pixel: .bookmarkImportFailureUnknown)
            return .failure(.unknown)
        }
    }

    public static func totalValidBookmarks(in htmlContent: String) -> Int {
        do {
            let normalizedHtml = try normalizeBookmarkHtml(htmlContent)
            var count = 0
            try countBookmarks(in: normalizedHtml, count: &count)
            return count
        } catch {
            return 0
        }
    }

    func parseHtml(_ htmlContent: String) async throws {
        // remove irrelevant DD tags used in older firefox and netscape bookmark files
        let normalizedHtml = try Self.normalizeBookmarkHtml(htmlContent)

        try parse(documentElement: normalizedHtml, importedBookmark: nil)
    }

    private static func normalizeBookmarkHtml(_ htmlContent: String) throws -> Element {
        let normalizedHtml = htmlContent.replacingOccurrences(of: "<DD>", with: "", options: .caseInsensitive)

        let document: Document = try SwiftSoup.parse(normalizedHtml)

        let root = try document.select("body").first() ?? document

        // Get all direct children
        let children = try root.children()
            .filter { try !$0.select("DT").isEmpty() }

        // If multiple root elements, wrap them in DL
        let rootElement: Element
        if children.count > 1 {
            let newDL = try Element(Tag.valueOf("DL"), "")
            try children.forEach { child in
                try newDL.appendChild(child)
            }
            rootElement = newDL
        } else {
            rootElement = root
        }

        return rootElement
    }

    private static func countBookmarks(in documentElement: Element, count: inout Int) throws {
        guard let firstDL = try documentElement.select("DL").first() else {
            throw BookmarksImportError.invalidHtmlNoDLTag
        }

        try firstDL.children()
            .filter({ try $0.select("DT").hasText() })
            .forEach({ element in
                let folder = try? element.select("H3").first()

                if folder != nil {
                    // Apple includes folders in the bookmarks count when exporting from Safari
                    count += 1
                    // Recursively count contents of folder
                    try? countBookmarks(in: element, count: &count)
                } else {
                    let linkItem = try element.select("A")
                    if !linkItem.isEmpty() {
                        count += 1
                    }
                }
            })
    }

    private func parse(documentElement: Element, importedBookmark: BookmarkOrFolder?, inFavorite: Bool = false) throws {
        guard let firstDL = try documentElement.select("DL").first() else {
            throw BookmarksImportError.invalidHtmlNoDLTag
        }
        try firstDL.children()
                .filter({ try $0.select("DT").hasText() })
                .forEach({ element in
                    let folder = try? element.select("H3").first()

                    if folder != nil {
                        guard let folderName = try folder?.text() else {
                            return
                        }

                        //  Handling for DDG favorites imported from Android
                        if folderName == Constants.FavoritesFolder || folderName == Constants.BookmarksFolder {
                            let newBookmarkOrFolder = createBookmarkOrFolder(name: folderName,
                                                                             type: .folder,
                                                                             urlString: nil,
                                                                             bookmarkOrFolder: importedBookmark)
                            try parse(documentElement: element,
                                      importedBookmark: newBookmarkOrFolder,
                                      inFavorite: folderName == Constants.FavoritesFolder)
                        } else {
                            let newBookmarkOrFolder = createBookmarkOrFolder(name: folderName,
                                                                             type: .folder,
                                                                             urlString: nil,
                                                                             bookmarkOrFolder: importedBookmark)
                            try parse(documentElement: element, importedBookmark: newBookmarkOrFolder)
                        }
                    } else {
                        let linkItem = try element.select("a")

                        if !linkItem.isEmpty() {
                            // Handling for DDG favorites imported from MacOS / iOS
                            var isDDGFavoriteAttr = false
                            if let attribute = try? linkItem.attr(Constants.favoriteAttribute), attribute == Constants.isFavorite {
                                isDDGFavoriteAttr = true
                            }

                            if let link = try? linkItem.attr(Constants.href), let title = try? linkItem.text() {
                                _ = createBookmarkOrFolder(name: title,
                                                           type: isDDGFavoriteAttr || inFavorite ? .favorite : .bookmark,
                                                           urlString: link,
                                                           bookmarkOrFolder: importedBookmark)
                            }
                        }
                    }
                })
    }

    func createBookmarkOrFolder(name: String,
                                type: BookmarkOrFolder.BookmarkType,
                                urlString: String?,
                                bookmarkOrFolder: BookmarkOrFolder?) -> BookmarkOrFolder {
        let newBookmarkOrFolder = BookmarkOrFolder(name: name, type: type, urlString: urlString, children: nil)
        if let bookmarkOrFolder = bookmarkOrFolder {
            if bookmarkOrFolder.children == nil {
                bookmarkOrFolder.children = []
            }
            bookmarkOrFolder.children?.append(newBookmarkOrFolder)
        } else {
            importedBookmarks.append(newBookmarkOrFolder)
        }

        return newBookmarkOrFolder
    }

    func saveBookmarks(_ bookmarks: [BookmarkOrFolder]) async throws -> BookmarksImportSummary {
        do {
            return try await coreDataStorage.importBookmarks(bookmarks)
        } catch {
            Logger.bookmarks.error("Failed to save imported bookmarks to core data: \(error.localizedDescription, privacy: .public)")
            throw BookmarksImportError.saveFailure
        }
    }

    private enum Constants {
        static let FavoritesFolder = "DuckDuckGo Favorites"
        static let BookmarksFolder = "DuckDuckGo Bookmarks"
        static let bookmarkURLString = "https://duckduckgo.com"
        static let bookmarkURL = URL(string: "https://duckduckgo.com")!
        static let favoriteAttribute = "duckduckgo:favorite"
        static let isFavorite = "true"
        static let idAttribute = "id"
        static let readingListId = "com.apple.ReadingList"

        static let href = "href"
    }
}

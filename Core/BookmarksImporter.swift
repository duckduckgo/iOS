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

import Foundation
import SwiftSoup
import os.log

public enum BookmarksImportError: Error {
    case invalidHtml
    case saveFailure
    case unknown
}

final public class BookmarksImporter {

    private(set) var importedBookmarks: [BookmarkOrFolder] = []
    private(set) var coreDataStorage: BookmarksCoreDataStorage

    public init(coreDataStore: BookmarksCoreDataStorage = BookmarksCoreDataStorage.shared) {
        coreDataStorage = coreDataStore
    }

    func isDocumentInSafariFormat(_ document: Document) -> Bool {
        // have to handle Safari html bookmarks differently as it doesn't wrap bookmarks in DL tags
        if let firstDL = try? document.select("DL").first(), firstDL.parents().size() > 2 {
            return true
        }

        return false
    }

    public func parseAndSave(html: String) async -> Result<[BookmarkOrFolder], BookmarksImportError> {
        do {
            try await parseHtml(html)
            try await saveBookmarks(importedBookmarks)
            return .success(importedBookmarks)
        } catch BookmarksImportError.invalidHtml {
            return .failure(.invalidHtml)
        } catch BookmarksImportError.saveFailure {
            return .failure(.saveFailure)
        } catch {
            return .failure(.unknown)
        }
    }

    func parseHtml(_ htmlContent: String) async throws {
        let document: Document = try SwiftSoup.parse(htmlContent)

        do {
            if isDocumentInSafariFormat(document) {
                guard let newDocument = try transformSafariDocument(document: document) else {
                    os_log("Safari format could not be handled", type: .debug)
                    throw BookmarksImportError.invalidHtml
                }
                try parse(documentElement: newDocument, importedBookmark: nil)
            } else {
                try parse(documentElement: document, importedBookmark: nil)
            }
        } catch {
            throw BookmarksImportError.invalidHtml
        }
    }

    /// transform Safari document into a standard bookmark html format
    func transformSafariDocument(document: Document) throws -> Document? {
        guard let body = try document.select("body").first() else {
            throw BookmarksImportError.invalidHtml
        }

        let newDocument: Document = Document("")

        // create new DL tag
        let dlElement = try newDocument.appendElement("DL")

        // get all childNodes of document body, filtering out Safari Reading list
        let bodyChildren = body.getChildNodes().filter { isSafariReadingList(node: $0) == false }

        // insert DT elements into the new DL element
        try dlElement.insertChildren(0, bodyChildren)

        return newDocument
    }

    func isSafariReadingList(node: Node) -> Bool {
        if let element = node as? Element {
            for childElement in element.children() {
                if let folder = try? childElement.select("H3").first(),
                    let attribute = try? folder.attr(Constants.idAttribute),
                    attribute == Constants.readingListId {
                    return true
                }
            }
        }
        return false
    }

    func parse(documentElement: Element, importedBookmark: BookmarkOrFolder?, inFavorite: Bool = false) throws {
        guard let firstDL = try documentElement.select("DL").first() else {
            throw BookmarksImportError.invalidHtml
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

    func saveBookmarks(_ bookmarks: [BookmarkOrFolder]) async throws {
        do {
            try await coreDataStorage.importBookmarks(importedBookmarks)
        } catch {
            os_log("Failed to save imported bookmarks to core data %s", type: .debug, error.localizedDescription)
            throw BookmarksImportError.saveFailure
        }
    }

    enum Constants {
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

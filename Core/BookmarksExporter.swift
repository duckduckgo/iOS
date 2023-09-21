//
//  BookmarksExporter.swift
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
import Bookmarks
import Persistence

public enum BookmarksExporterError: Error {
    case brokenDatabaseStructure
}

@MainActor
public struct BookmarksExporter {

    private(set) var coreDataStorage: CoreDataDatabase
    private let favoritesDisplayMode: FavoritesDisplayMode

    public init(coreDataStore: CoreDataDatabase, favoritesDisplayMode: FavoritesDisplayMode) {
        coreDataStorage = coreDataStore
        self.favoritesDisplayMode = favoritesDisplayMode
    }

    public func exportBookmarksTo(url: URL) throws {
        try exportBookmarksToContent().write(to: url, atomically: true, encoding: .utf8)
    }

    func exportBookmarksToContent() throws -> String {
        var content = [Template.header]
        
        let context = coreDataStorage.makeContext(concurrencyType: .mainQueueConcurrencyType)
        guard let rootFolder = BookmarkUtils.fetchRootFolder(context) else {
            throw BookmarksExporterError.brokenDatabaseStructure
        }

        let orphanedBookmarks = BookmarkUtils.fetchOrphanedEntities(context)
        let topLevelBookmarksAndFavorites = rootFolder.childrenArray + orphanedBookmarks
        content.append(contentsOf: export(topLevelBookmarksAndFavorites, level: 2))
        content.append(Template.footer)
        return content.joined()
    }

    func export(_ entities: [BookmarkEntity], level: Int) -> [String] {
        var content = [String]()
        for entity in entities {
            if entity.isFolder {
                content.append(Template.openFolder(level: level, named: entity.title!))
                content.append(contentsOf: export(entity.childrenArray, level: level + 1))
                content.append(Template.closeFolder(level: level))
            } else {
                content.append(Template.bookmark(level: level,
                                                 title: entity.title!.escapedForHTML,
                                                 url: entity.url!,
                                                 isFavorite: entity.isFavorite(on: favoritesDisplayMode.displayedFolder)))
            }
        }
        return content
    }
}

// MARK: Exported Bookmarks Template

extension BookmarksExporter {

    struct Template {

        static var header =
        """
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
            <HTML xmlns:duckduckgo="https://duckduckgo.com/bookmarks">
            <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
            <Title>Bookmarks</Title>
            <H1>Bookmarks</H1>
            <DL><p>

        """

        static let footer =
        """
        </DL><p>
        </HTML>
        """

        static func bookmark(level: Int, title: String, url: String, isFavorite: Bool = false) -> String {
            """
            \(String.indent(by: level))<DT><A HREF="\(url)"\(isFavorite ? " duckduckgo:favorite=\"true\"" : "")>\(title)</A>

            """
        }

        static func openFolder(level: Int, named name: String) -> String {
            """
            \(String.indent(by: level))<DT><H3 FOLDED>\(name)</H3>
            \(String.indent(by: level))<DL><p>

            """
        }

        // This "open paragraph" to close the folder is part of the format 🙄
        static func closeFolder(level: Int) -> String {
            """
            \(String(repeating: "\t", count: level))</DL><p>

            """
        }
    }
}

private extension String {

    var escapedForHTML: String {
        self.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    static func indent(by level: Int) -> String {
        return String(repeating: "\t", count: level)
    }
}

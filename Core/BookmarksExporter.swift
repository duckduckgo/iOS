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

public struct BookmarksExporter {

    private(set) var coreDataStorage: BookmarksCoreDataStorage

    public init(coreDataStore: BookmarksCoreDataStorage = BookmarksCoreDataStorage.shared) {
        coreDataStorage = coreDataStore
    }

    public func exportBookmarksTo(url: URL) throws {
        try exportBookmarksToContent().write(to: url, atomically: true, encoding: .utf8)
    }

    func exportBookmarksToContent() throws -> String {
        var content = [Template.header]
        let topLevelBookmarksAndFavorites = coreDataStorage.favorites + coreDataStorage.topLevelBookmarksItems
        content.append(contentsOf: export(topLevelBookmarksAndFavorites, level: 2))
        content.append(Template.footer)
        return content.joined()
    }

    func export(_ entities: [BookmarkItemManagedObject], level: Int) -> [String] {
        var content = [String]()
        for entity in entities {
            if let bookmark = entity as? Bookmark {
                content.append(Template.bookmark(level: level,
                                                 title: bookmark.displayTitle!.escapedForHTML,
                                                 url: bookmark.url!,
                                                 isFavorite: bookmark.isFavorite))
            }

            if let folder = entity as? BookmarkFolder {
                content.append(Template.openFolder(level: level, named: folder.title!))
                if let arrayChildren: [BookmarkItemManagedObject] = folder.children?.array as? [BookmarkItemManagedObject] {
                    content.append(contentsOf: export(arrayChildren, level: level + 1))
                }
                        
                content.append(Template.closeFolder(level: level))
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

        static func bookmark(level: Int, title: String, url: URL, isFavorite: Bool = false) -> String {
            """
            \(String.indent(by: level))<DT><A HREF="\(url.absoluteString)"\(isFavorite ? " duckduckgo:favorite=\"true\"" : "")>\(title)</A>

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

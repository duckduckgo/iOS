//
//  BookmarkOrFolder.swift
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

public class BookmarkOrFolder {
    let name: String

    enum BookmarkType: String {
        case bookmark
        case favorite
        case folder
    }

    let type: BookmarkType

    let urlString: String?

    var children: [BookmarkOrFolder]?

    var url: URL? {
        if let url = self.urlString {
            return URL(string: url)
        }

        return nil
    }

    // There's no guarantee that imported bookmarks will have a URL, this is used to filter them out during import
    var isInvalidBookmark: Bool {
        switch type {
        case .bookmark, .favorite:
            return urlString == nil
        default:
            return false
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case urlString = "url"
        case children
    }

    init(name: String, type: BookmarkType, urlString: String?, children: [BookmarkOrFolder]?) {
        self.name = name
        self.type = type
        self.urlString = urlString
        self.children = children
    }
}

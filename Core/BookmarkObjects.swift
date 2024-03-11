//
//  BookmarkObjects.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import CoreData

public protocol BookmarkItem {
    var objectID: NSManagedObjectID { get }
    var title: String? { get set }
    var isFavorite: Bool { get set }
    var parentFolder: BookmarkFolder? { get set }
}

private struct Constants {
    static let ddgSuffix = " at DuckDuckGo"
}

public protocol Bookmark: BookmarkItem {
    var url: URL? { get set }

    var displayTitle: String? { get }
}

public extension Bookmark {

    var displayTitle: String? {
        let host = url?.host?.droppingWwwPrefix() ?? url?.absoluteString

        var displayTitle = (title?.isEmpty ?? true) ? host : title

        if let url = url, url.isDuckDuckGo,
            let title = displayTitle, title.hasSuffix(Constants.ddgSuffix) {
            displayTitle = String(title.dropLast(Constants.ddgSuffix.count))
        }

        return displayTitle
    }
}

public protocol BookmarkFolder: BookmarkItem {
    var children: NSOrderedSet? { get set }
}

public extension BookmarkFolder {

    var numberOfChildrenDeep: Int {
        guard let children = children else { return 0 }
        return children.reduce(children.count) { $0 + (($1 as? BookmarkFolder)?.numberOfChildrenDeep ?? 0) }
    }
}

extension BookmarkItemManagedObject: BookmarkItem {
    public var parentFolder: BookmarkFolder? {
        get {
            parent
        }
        set {
            parent = newValue as? BookmarkFolderManagedObject
        }
    }
}

extension BookmarkManagedObject: Bookmark { }

extension BookmarkFolderManagedObject: BookmarkFolder { }

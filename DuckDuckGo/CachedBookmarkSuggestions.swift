//
//  CachedBookmarkSuggestions.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import Bookmarks
import Suggestions
import Persistence
import Core

final class CachedBookmarks {

    let context: NSManagedObjectContext
    lazy var all: [BookmarkSuggestion] = {
        let fetchRequest = CoreDataBookmarksSearchStore.shallowBookmarksFetchRequest(context: context)
        let result = try? self.context.fetch(fetchRequest) as? [[String: Any]]

        return result?.compactMap { BookmarkSuggestion($0) } ?? []
    }()

    init(_ bookmarksDatabase: CoreDataDatabase) {
        context = bookmarksDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType, name: "Autocomplete Bookmarks Cache")
    }

}

struct BookmarkSuggestion: Suggestions.Bookmark {

    var url: String
    var title: String
    var isFavorite: Bool

    init?(_ properties: [String: Any]) {
        guard let title = properties[#keyPath(BookmarkEntity.title)] as? String,
              let url = properties[#keyPath(BookmarkEntity.url)] as? String,
              let favoritesFolderCount = properties[#keyPath(BookmarkEntity.favoriteFolders)] as? Int else {
                  return nil
              }

        self.title = title
        self.url = url
        self.isFavorite = favoritesFolderCount > 0
    }

}

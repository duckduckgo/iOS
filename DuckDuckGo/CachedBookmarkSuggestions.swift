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

final class CachedBookmarks {

    let context: NSManagedObjectContext
    lazy var all: [BookmarkSuggestion] = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkEntity")
        fetchRequest.predicate = NSPredicate(
            format: "%K = NO AND %K == NO",
            #keyPath(BookmarkEntity.isFolder),
            #keyPath(BookmarkEntity.isPendingDeletion)
        )
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [#keyPath(BookmarkEntity.title),
                                          #keyPath(BookmarkEntity.url)]
        fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(BookmarkEntity.favoriteFolders)]
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
              let url = properties[#keyPath(BookmarkEntity.url)] as? String else {
                  return nil
              }

        self.title = title
        self.url = url
        self.isFavorite = (properties[#keyPath(BookmarkEntity.favoriteFolders)] as? Set<NSManagedObject>)?.isEmpty != true
    }

}

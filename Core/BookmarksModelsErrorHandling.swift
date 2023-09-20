//
//  BookmarksModelsErrorHandling.swift
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
import Common
import DDGSync
import Persistence
import CoreData

public class BookmarksModelsErrorHandling: EventMapping<BookmarksModelError> {

    // swiftlint:disable:next cyclomatic_complexity
    init(syncService: DDGSyncing? = nil) {
        super.init { event, error, _, _ in
            var domainEvent: Pixel.Event?
            var params = [String: String]()
            switch event {
                
            case .bookmarkFolderExpected:
                domainEvent = .bookmarkFolderExpected
            case .bookmarksListIndexNotMatchingBookmark:
                domainEvent = .bookmarksListIndexNotMatchingBookmark
            case .bookmarksListMissingFolder:
                domainEvent = .bookmarksListMissingFolder
            case .editorNewParentMissing:
                domainEvent = .editorNewParentMissing
            case .favoritesListIndexNotMatchingBookmark:
                domainEvent = .favoritesListIndexNotMatchingBookmark
            case .fetchingRootItemFailed(let model):
                domainEvent = .fetchingRootItemFailed(model)
            case .indexOutOfRange(let model):
                domainEvent = .indexOutOfRange(model)
            case .saveFailed(let model):
                domainEvent = .saveFailed(model)
                
                if let error = error as? NSError {
                    let processedErrors = CoreDataErrorsParser.parse(error: error)
                    params = processedErrors.errorPixelParameters
                }
                
            case .missingParent(let object):
                domainEvent = .missingParent(object)
            case .orphanedBookmarksPresent:
                if let syncService, syncService.authState == .inactive {
                    domainEvent = .orphanedBookmarksPresent
                }
            }

            if let domainEvent {
                if let error = error {
                    Pixel.fire(pixel: domainEvent, error: error, withAdditionalParameters: params)
                } else {
                    Pixel.fire(pixel: domainEvent)
                }
            }
        }
    }
    
    override init(mapping: @escaping EventMapping<BookmarksModelError>.Mapping) {
        fatalError("Use init()")
    }
}

public extension BookmarkEditorViewModel {
    
    convenience init(editingEntityID: NSManagedObjectID,
                     bookmarksDatabase: CoreDataDatabase,
                     favoritesDisplayMode: FavoritesDisplayMode,
                     syncService: DDGSyncing?) {
        self.init(editingEntityID: editingEntityID,
                  bookmarksDatabase: bookmarksDatabase,
                  favoritesDisplayMode: favoritesDisplayMode,
                  errorEvents: BookmarksModelsErrorHandling(syncService: syncService))
        
    }
    
    convenience init(creatingFolderWithParentID parentFolderID: NSManagedObjectID?,
                     bookmarksDatabase: CoreDataDatabase,
                     favoritesDisplayMode: FavoritesDisplayMode,
                     syncService: DDGSyncing?) {
        self.init(creatingFolderWithParentID: parentFolderID,
                  bookmarksDatabase: bookmarksDatabase,
                  favoritesDisplayMode: favoritesDisplayMode,
                  errorEvents: BookmarksModelsErrorHandling(syncService: syncService))
    }
}

public extension BookmarkListViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase,
                     parentID: NSManagedObjectID?,
                     favoritesDisplayMode: FavoritesDisplayMode,
                     syncService: DDGSyncing?) {
        self.init(bookmarksDatabase: bookmarksDatabase,
                  parentID: parentID,
                  favoritesDisplayMode: favoritesDisplayMode,
                  errorEvents: BookmarksModelsErrorHandling(syncService: syncService))
    }
}

public extension FavoritesListViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase, favoritesDisplayMode: FavoritesDisplayMode) {
        self.init(bookmarksDatabase: bookmarksDatabase, errorEvents: BookmarksModelsErrorHandling(), favoritesDisplayMode: favoritesDisplayMode)
    }
}

public extension MenuBookmarksViewModel {
    
    convenience init(bookmarksDatabase: CoreDataDatabase, syncService: DDGSyncing?) {
        self.init(bookmarksDatabase: bookmarksDatabase, errorEvents: BookmarksModelsErrorHandling(syncService: syncService))
    }
}

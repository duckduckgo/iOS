//
//  BookmarksManager.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Core
import WidgetKit
import CoreData

class BookmarksManager {
    
    public struct Notifications {
        public static let bookmarksDidChange = Notification.Name("com.duckduckgo.app.BookmarksDidChange")
    }

    private(set) var dataStore: BookmarkStore
    private(set) var coreDataStorage: BookmarksCoreDataStorage
    

    init(dataStore: BookmarkStore = BookmarkUserDefaults(), coreDataStore: BookmarksCoreDataStorage = BookmarksCoreDataStorage.shared) {
        self.dataStore = dataStore
        self.coreDataStorage = coreDataStore
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: BookmarksCoreDataStorage.Notifications.dataDidChange, object: nil)
    }
    
    @objc func dataDidChange(notification: Notification) {
        NotificationCenter.default.post(name: BookmarksManager.Notifications.bookmarksDidChange, object: nil)
    }

    var topLevelBookmarkItemsCount: Int {
        return coreDataStorage.topLevelBookmarksItems.count
    }
    
    var topLevelBookmarkItems: [BookmarkItem] {
        return coreDataStorage.topLevelBookmarksItems
    }
    
    var topLevelBookmarksFolder: BookmarkFolder? {
        return coreDataStorage.topLevelBookmarksFolder
    }
    
    var favorites: [Bookmark] {
        return coreDataStorage.favorites
    }
        
    var favoritesCount: Int {
        return favorites.count
    }
    
    func favorite(atIndex index: Int) -> Bookmark? {
        if favorites.count <= index {
            return nil
        }
        return favorites[index]
    }
    
    func contains(url: URL, completion: @escaping (Bool) -> Void) {
        coreDataStorage.contains(url: url, completion: completion)
    }
    
    func containsBookmark(url: URL, completion: @escaping (Bool) -> Void) {
        coreDataStorage.containsBookmark(url: url, completion: completion)
    }
    
    func containsFavorite(url: URL, completion: @escaping (Bool) -> Void) {
        coreDataStorage.containsFavorite(url: url, completion: completion)
    }
    
    func bookmark(forURL url: URL, completion: @escaping (Bookmark?) -> Void) {
        coreDataStorage.bookmark(forURL: url, completion: completion)
    }
    
    func favorite(forURL url: URL, completion: @escaping (Bookmark?) -> Void) {
        coreDataStorage.favorite(forURL: url, completion: completion)
    }
    
    func saveNewFolder(withTitle title: String, parentID: NSManagedObjectID) {
        coreDataStorage.saveNewFolder(withTitle: title, parentID: parentID)
        Pixel.fire(pixel: .bookmarksFolderCreated)
    }
    
    func saveNewFavorite(withTitle title: String, url: URL) {
        coreDataStorage.saveNewFavorite(withTitle: title, url: url)
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .bookmarks, fromCache: .tabs)
        reloadWidgets()
    }
    
    func saveNewBookmark(withTitle title: String, url: URL, parentID: NSManagedObjectID?) {
        coreDataStorage.saveNewBookmark(withTitle: title, url: url, parentID: parentID)
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .bookmarks, fromCache: .tabs)
        if parentID != nil {
            Pixel.fire(pixel: .bookmarkCreatedInSubfolder)
        } else {
            Pixel.fire(pixel: .bookmarkCreatedAtTopLevel)
        }
    }
    
    func update(folderID: NSManagedObjectID, newTitle: String, newParentID: NSManagedObjectID) {
        coreDataStorage.update(folderID: folderID, newTitle: newTitle, newParentID: newParentID)
    }
    
    func update(favorite: Bookmark, newTitle: String, newURL: URL) {
        coreDataStorage.update(favoriteID: favorite.objectID, newTitle: newTitle, newURL: newURL)
        updateFaviconIfNeeded(favorite, newURL)
        reloadWidgets()
    }
    

    func update(bookmark: Bookmark, newTitle: String, newURL: URL, newParentID: NSManagedObjectID) {
        coreDataStorage.update(bookmarkID: bookmark.objectID, newTitle: newTitle, newURL: newURL, newParentID: newParentID)
        updateFaviconIfNeeded(bookmark, newURL)
        if newParentID == topLevelBookmarksFolder?.objectID {
            Pixel.fire(pixel: .bookmarkEditedAtTopLevel)
        } else {
            Pixel.fire(pixel: .bookmarkEditedInSubfolder)
        }
    }
    
    func updateIndex(of bookmarkItemID: NSManagedObjectID, newIndex: Int) {
        coreDataStorage.updateIndex(of: bookmarkItemID, newIndex: newIndex)
        reloadWidgets()
    }
    
    func convertFavoriteToBookmark(_ favoriteID: NSManagedObjectID, newIndex: Int) {
        coreDataStorage.convertFavoriteToBookmark(favoriteID, newIndex: newIndex)
        reloadWidgets()
    }
    
    func convertBookmarkToFavorite(_ bookmarkID: NSManagedObjectID, newIndex: Int) {
        coreDataStorage.convertBookmarkToFavorite(bookmarkID, newIndex: newIndex)
        reloadWidgets() // TODO this reload kind of isn't gonna work, really we should do it once we know the update has actually happened
        //I think we have quite a few of these places where we shouldn't really do stuff until we know it's done.
        //honestly all of these methods should have optional completions
    }
    
    func delete(_ bookmarkItem: BookmarkItem) {
        coreDataStorage.delete(bookmarkItem.objectID)
        if let bookmark = bookmarkItem as? Bookmark {
            removeFavicon(forBookmark: bookmark)
            if bookmark.isFavorite {
                reloadWidgets()
            }
        }
    }
    
    private func removeFavicon(forBookmark bookmark: Bookmark?) {
        guard let domain = bookmark?.url?.host else { return }
        
        coreDataStorage.allBookmarksAndFavoritesShallow() { bookmarks in
            let matchesDomain: ((Bookmark) -> Bool) = { $0.url?.host == domain }
            if !bookmarks.contains(where: matchesDomain) {
                print("culprit?")
                Favicons.shared.removeBookmarkFavicon(forDomain: domain)
            }
        }
    }
    
    private func updateFaviconIfNeeded(_ old: Bookmark, _ newURL: URL) {
        guard old.url?.host != newURL.host else { return }
        removeFavicon(forBookmark: old)
        Favicons.shared.loadFavicon(forDomain: newURL.host, intoCache: .bookmarks)
    }

    func reloadWidgets() {
        if #available(iOS 14, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}

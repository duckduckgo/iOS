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

class BookmarksManager {

    private var dataStore: BookmarkStore

    init(dataStore: BookmarkStore = BookmarkUserDefaults()) {
        self.dataStore = dataStore
    }

    var bookmarksCount: Int {
        return dataStore.bookmarks.count
    }
    
    var favoritesCount: Int {
        return dataStore.favorites.count
    }

    func bookmark(atIndex index: Int) -> Link? {
        return link(at: index, in: dataStore.bookmarks)
    }

    func favorite(atIndex index: Int) -> Link? {
        return link(at: index, in: dataStore.favorites)
    }
    
    private func link(at index: Int, in links: [Link]?) -> Link? {
        guard let links = links else { return nil }
        guard links.count > index else { return nil }
        return links[index]
    }

    func save(bookmark: Link) {
        dataStore.addBookmark(bookmark)
        Favicons.shared.loadFavicon(forDomain: bookmark.url.host, intoCache: .bookmarks, fromCache: .tabs)
    }

    func save(favorite: Link) {
        dataStore.addFavorite(favorite)
        Favicons.shared.loadFavicon(forDomain: favorite.url.host, intoCache: .bookmarks, fromCache: .tabs)
        reloadWidgets()
    }

    func moveFavorite(at favoriteIndex: Int, toBookmark bookmarkIndex: Int) {
        let link = dataStore.favorites[favoriteIndex]
        var favorites = dataStore.favorites
        var bookmarks = dataStore.bookmarks

        if bookmarks.count < bookmarkIndex {
            bookmarks.append(link)
        } else {
            bookmarks.insert(link, at: bookmarkIndex)
        }
        favorites.remove(at: favoriteIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
        reloadWidgets()
    }

    func moveFavorite(at fromIndex: Int, to toIndex: Int) {
        var favorites = dataStore.favorites
        let link = favorites.remove(at: fromIndex)
        favorites.insert(link, at: toIndex)
        dataStore.favorites = favorites
        reloadWidgets()
    }
    
    func moveBookmark(at bookmarkIndex: Int, toFavorite favoriteIndex: Int) {
        let link = dataStore.bookmarks[bookmarkIndex]
        var bookmarks = dataStore.bookmarks
        var favorites = dataStore.favorites

        if favorites.count < favoriteIndex {
            favorites.append(link)
        } else {
            favorites.insert(link, at: favoriteIndex)
        }
        bookmarks.remove(at: bookmarkIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
        reloadWidgets()
    }
    
    func moveBookmark(at fromIndex: Int, to toIndex: Int) {
        var bookmarks = dataStore.bookmarks
        let link = bookmarks.remove(at: fromIndex)
        bookmarks.insert(link, at: toIndex)
        dataStore.bookmarks = bookmarks
    }

    func deleteBookmark(at index: Int) {
        let link = bookmark(atIndex: index)
        var bookmarks = dataStore.bookmarks
        bookmarks.remove(at: index)
        dataStore.bookmarks = bookmarks
        removeFavicon(forLink: link)
    }

    func deleteFavorite(at index: Int) {
        let link = favorite(atIndex: index)
        var favorites = dataStore.favorites
        favorites.remove(at: index)
        dataStore.favorites = favorites
        removeFavicon(forLink: link)
        reloadWidgets()
    }

    func removeFavicon(forLink link: Link?) {
        guard let domain = link?.url.host else { return }
        let favorites = dataStore.favorites
        let bookmarks = dataStore.bookmarks
        DispatchQueue.global(qos: .background).async {
            let matchesDomain: ((Link) -> Bool) = { $0.url.host == domain }
            if !favorites.contains(where: matchesDomain) && !bookmarks.contains(where: matchesDomain) {
                Favicons.shared.removeBookmarkFavicon(forDomain: domain)
            }
        }
    }

    func updateFavorite(at index: Int, with link: Link) {
        var favorites = dataStore.favorites
        let old = favorites.remove(at: index)
        favorites.insert(link, at: index)
        dataStore.favorites = favorites
        updateFaviconIfNeeded(old, link)
        reloadWidgets()
    }

    func updateBookmark(at index: Int, with link: Link) {
        var bookmarks = dataStore.bookmarks
        let old = bookmarks.remove(at: index)
        bookmarks.insert(link, at: index)
        dataStore.bookmarks = bookmarks
        updateFaviconIfNeeded(old, link)
    }

    private func updateFaviconIfNeeded(_ old: Link, _ new: Link) {
        guard old.url.host != new.url.host else { return }
        removeFavicon(forLink: old)
        Favicons.shared.loadFavicon(forDomain: new.url.host, intoCache: .bookmarks)
    }
    
    private func indexOfBookmark(url: URL) -> Int? {
        let bookmarks = dataStore.bookmarks
        return indexOf(url, in: bookmarks)
    }

    func contains(url: URL) -> Bool {
        return containsBookmark(url: url) || containsFavorite(url: url)
    }

    func containsFavorite(url: URL) -> Bool {
        return indexOfFavorite(url: url) != nil
    }

    func containsBookmark(url: URL) -> Bool {
        return indexOfBookmark(url: url) != nil
    }

    private func indexOfFavorite(url: URL) -> Int? {
        let favorites = dataStore.favorites
        return indexOf(url, in: favorites)
    }
    
    private func indexOf(_ url: URL, in links: [Link]) -> Int? {
        var index = 0
        for link in links {
            if link.url == url {
                return index
            }
            index += 1
        }
        return nil
    }
    
    func migrateFavoritesToBookmarks() {
        while favoritesCount > 0 {
            moveFavorite(at: 0, toBookmark: 0)
        }
    }

    func reloadWidgets() {
        if #available(iOS 14, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}

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

class BookmarksManager {

    private var dataStore: BookmarkStore

    init(dataStore: BookmarkStore = BookmarkUserDefaults()) {
        self.dataStore = dataStore
    }

    var bookmarksCount: Int {
        return dataStore.bookmarks?.count ?? 0
    }
    
    var favoritesCount: Int {
        return dataStore.favorites?.count ?? 0
    }

    func bookmark(atIndex index: Int) -> Link {
        return dataStore.bookmarks![index]
    }

    func favorite(atIndex index: Int) -> Link {
        return dataStore.favorites![index]
    }

    func save(bookmark: Link) {
        dataStore.addBookmark(bookmark)
    }

    func save(favorite: Link) {
        dataStore.addFavorite(favorite)
    }

    func moveFavorite(at favoriteIndex: Int, toBookmark bookmarkIndex: Int) {
        guard let link = dataStore.favorites?[favoriteIndex] else { return }
        guard var favorites = dataStore.favorites else { return }
        var bookmarks = dataStore.bookmarks ?? []

        bookmarks.insert(link, at: bookmarkIndex)
        favorites.remove(at: favoriteIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
    }

    func moveFavorite(at fromIndex: Int, to toIndex: Int) {
        guard var favorites = dataStore.favorites else { return }
        let link = favorites.remove(at: fromIndex)
        favorites.insert(link, at: toIndex)
        dataStore.favorites = favorites
    }
    
    func moveBookmark(at bookmarkIndex: Int, toFavorite favoriteIndex: Int) {
        guard let link = dataStore.bookmarks?[bookmarkIndex] else { return }
        guard var bookmarks = dataStore.bookmarks else { return }
        var favorites = dataStore.favorites ?? []

        favorites.insert(link, at: favoriteIndex)
        bookmarks.remove(at: bookmarkIndex)
        
        dataStore.bookmarks = bookmarks
        dataStore.favorites = favorites
    }
    
    func moveBookmark(at fromIndex: Int, to toIndex: Int) {
        guard var bookmarks = dataStore.bookmarks else { return }
        let link = bookmarks.remove(at: fromIndex)
        bookmarks.insert(link, at: toIndex)
        dataStore.bookmarks = bookmarks
    }

    func deleteBookmark(at index: Int) {
        guard var bookmarks = dataStore.bookmarks else { return }
        bookmarks.remove(at: index)
        dataStore.bookmarks = bookmarks
    }

    func deleteFavorite(at index: Int) {
        guard var favorites = dataStore.favorites else { return }
        favorites.remove(at: index)
        dataStore.favorites = favorites
    }

    func updateFavorite(at index: Int, with link: Link) {
        guard var favorites = dataStore.favorites else { return }
        _ = favorites.remove(at: index)
        favorites.insert(link, at: index)
        dataStore.favorites = favorites
    }

    func updateBookmark(at index: Int, with link: Link) {
        guard var bookmarks = dataStore.bookmarks else { return }
        _ = bookmarks.remove(at: index)
        bookmarks.insert(link, at: index)
        dataStore.bookmarks = bookmarks
    }

    func clear() {
        dataStore.bookmarks = [Link]()
    }

    private func indexOfBookmark(url: URL) -> Int? {
        guard let bookmarks = dataStore.bookmarks else { return nil }
        return indexOf(url, in: bookmarks)
    }
    
    func contains(url: URL) -> Bool {
        return nil != indexOfFavorite(url: url) || nil != indexOfBookmark(url: url)
    }

    private func indexOfFavorite(url: URL) -> Int? {
        guard let favorites = dataStore.favorites else { return nil }
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
    
}

//
//  FavoritesPreviewDataSource.swift
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

import Combine
import Bookmarks
import Foundation

final class FavoritesPreviewModel: FavoritesViewModel {
    init(favorites: [Favorite] = randomFavorites) {
        super.init(favoriteDataSource: FavoritesPreviewDataSource(favorites: favorites), faviconLoader: EmptyFaviconLoading())
    }

    static var randomFavorites: [Favorite] {
        (0...20).map {
            Favorite(
                id: UUID().uuidString,
                title: "Favorite \($0)",
                domain: "favorite\($0).domain.com")
        }
    }
}

final class FavoritesPreviewDataSource: NewTabPageFavoriteDataSource {
    var externalUpdates: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher()

    var favorites: [Favorite]

    init(favorites: [Favorite]) {
        self.favorites = favorites
    }

    func moveFavorite(_ favorite: Favorite, fromIndex: Int, toIndex: Int) {
        favorites.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
    }
    
    func bookmarkEntity(for favorite: Favorite) -> Bookmarks.BookmarkEntity? {
        nil
    }
    
    func favorite(at index: Int) throws -> Favorite? {
        favorites[index]
    }
    
    func removeFavorite(_ favorite: Favorite) {
        // no-op
    }
}

struct EmptyFaviconLoading: FavoritesFaviconLoading {
    func existingFavicon(for favorite: Favorite, size: CGFloat) -> Favicon? {
        nil
    }

    func fakeFavicon(for favorite: Favorite, size: CGFloat) -> Favicon {
        .empty
    }

    func loadFavicon(for favorite: Favorite, size: CGFloat) async -> Favicon? {
        nil
    }
}

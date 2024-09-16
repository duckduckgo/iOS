//
//  FavoritesPreviewModel.swift
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

import Bookmarks
import Foundation

final class FavoritesPreviewModel: FavoritesModel, FavoritesEmptyStateModel {

    @Published var isShowingTooltip: Bool = false
    var isCollapsed: Bool = true
    
    @Published var allFavorites: [Favorite]

    var isEmpty: Bool { allFavorites.isEmpty }
    var faviconLoader: FavoritesFaviconLoading? { nil }

    init(allFavorites: [Favorite]) {
        self.allFavorites = allFavorites
    }

    convenience init() {
        let favorites = (0...20).map {
            Favorite(
                id: UUID().uuidString,
                title: "Favorite \($0)",
                domain: "favorite\($0).domain.com")
        }

        self.init(allFavorites: favorites)
    }

    func prefixedFavorites(for columnsCount: Int) -> FavoritesSlice {
        let maxCollapsedItemsCount = columnsCount * 2
        let favorites = isCollapsed ? Array(allFavorites.prefix(maxCollapsedItemsCount)) : allFavorites
        let isCollapsible = allFavorites.count > maxCollapsedItemsCount

        return .init(items: favorites, isCollapsible: isCollapsible)
    }

    func toggleCollapse() {
        isCollapsed.toggle()
    }

    func faviconMissing() {

    }

    func favoriteSelected(_ favorite: Favorite) {

    }

    func deleteFavorite(_ favorite: Favorite) {

    }

    func editFavorite(_ favorite: Favorite) {

    }

    func moveFavorites(from indexSet: IndexSet, to index: Int) {
        allFavorites.move(fromOffsets: indexSet, toOffset: index)
    }

    func loadFavicon(for favorite: Favorite, size: CGFloat) async {
        
    }

    func placeholderTapped() {

    }

    func toggleTooltip() {
    
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

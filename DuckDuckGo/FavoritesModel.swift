//
//  FavoritesModel.swift
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

protocol FavoritesModel: AnyObject, ObservableObject {
    var allFavorites: [Favorite] { get }
    var faviconLoader: FavoritesFaviconLoading? { get }

    var isEmpty: Bool { get }
    var isCollapsed: Bool { get }

    func prefixedFavorites(for columnsCount: Int) -> FavoritesSlice

    func faviconMissing()

    // MARK: - Interactions

    func toggleCollapse()

    func favoriteSelected(_ favorite: Favorite)
    func editFavorite(_ favorite: Favorite)
    func deleteFavorite(_ favorite: Favorite)
}

struct FavoritesSlice {
    let items: [Favorite]
    let isCollapsible: Bool
}

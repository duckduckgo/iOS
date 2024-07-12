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

import Foundation

final class FavoritesPreviewModel: FavoritesModel {
    @Published var allFavorites: [Favorite]

    var isEmpty: Bool { allFavorites.isEmpty }

    init(allFavorites: [Favorite]) {
        self.allFavorites = allFavorites
    }

    convenience init() {
        let favorites = (0...10).map {
            Favorite(
                id: UUID().uuidString,
                title: "Favorite \($0)",
                domain: "favorite\($0).domain.com")
        }

        self.init(allFavorites: favorites)
    }

    func faviconMissing() {

    }
}

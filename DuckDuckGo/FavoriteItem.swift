//
//  FavoriteItem.swift
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
import UniformTypeIdentifiers

enum FavoriteItem {
    case favorite(Favorite)
    case addFavorite
    case placeholder(_ id: String)
}

extension FavoriteItem: Identifiable {
    var id: String {
        switch self {
        case .favorite(let favorite):
            return favorite.id
        case .addFavorite:
            return "addFavorite"
        case .placeholder(let id):
            return id
        }
    }
}

extension FavoriteItem: Reorderable {
    var trait: ReorderableTrait {
        switch self {
        case .favorite(let favorite):
            let itemProvider = NSItemProvider(object: (favorite.urlObject?.absoluteString ?? "") as NSString)
            let metadata = MoveMetadata(itemProvider: itemProvider, type: .plainText)
            return .movable(metadata)
        case .addFavorite, .placeholder:
            return .stationary
        }
    }
}

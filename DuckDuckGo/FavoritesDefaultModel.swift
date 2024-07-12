//
//  FavoritesDefaultModel.swift
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
import Bookmarks
import SwiftUI

final class FavoritesDefaultModel: FavoritesModel {

    @Published private(set) var allFavorites: [Favorite]

    private let interactionModel: FavoritesListInteracting
    private var didReportMissingFavicon = false

    var onFaviconMissing: () -> Void = {}

    var isEmpty: Bool {
        allFavorites.isEmpty
    }

    init(interactionModel: FavoritesListInteracting) {
        self.interactionModel = interactionModel
        do {
            self.allFavorites = try interactionModel.favorites.map(Favorite.init)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func faviconMissing() {
        onFaviconMissing()
    }
}

enum FavoriteMappingError: Error {
    case missingUUID
}

private extension Favorite {
    init(_ bookmarkEntry: BookmarkEntity) throws {
        guard let uuid = bookmarkEntry.uuid else {
            throw FavoriteMappingError.missingUUID
        }

        self.id = uuid
        self.title = bookmarkEntry.displayTitle
        self.domain = bookmarkEntry.host
    }
}

private extension BookmarkEntity {

    var displayTitle: String {
        if let title = title?.trimmingWhitespace() {
            return title
        }

        if let host = urlObject?.host?.droppingWwwPrefix() {
            return host
        }

        assertionFailure("Unable to create display title")
        return ""
    }

    var host: String {
        return urlObject?.host ?? ""
    }

}

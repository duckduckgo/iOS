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
import Combine
import SwiftUI
import Core
import WidgetKit

final class FavoritesDefaultModel: FavoritesModel {

    @Published private(set) var allFavorites: [Favorite]
    @Published private(set) var isCollapsed: Bool = true

    private let interactionModel: FavoritesListInteracting
    private var didReportMissingFavicon = false
    private var cancellables = Set<AnyCancellable>()

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

        interactionModel.externalUpdates.sink { [weak self] _ in
            try? self?.updateData()
        }.store(in: &cancellables)
    }

    func toggleCollapse() {
        isCollapsed.toggle()
    }

    func prefixedFavorites(for columnsCount: Int) -> FavoritesSlice {
        let maxCollapsedItemsCount = columnsCount * 2
        let favorites = isCollapsed ? Array(allFavorites.prefix(maxCollapsedItemsCount)) : allFavorites
        let isCollapsible = allFavorites.count > maxCollapsedItemsCount

        return .init(items: favorites, isCollapsible: isCollapsible)
    }

    // MARK: - External actions

    var onFaviconMissing: () -> Void = {}
    func faviconMissing() {
        onFaviconMissing()
    }

    var onFavoriteURLSelected: ((URL) -> Void)?
    func favoriteSelected(_ favorite: Favorite) {
        guard let url = favorite.urlObject else { return }

        Pixel.fire(pixel: .favoriteLaunchedNTP)
        DailyPixel.fire(pixel: .favoriteLaunchedNTPDaily)
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .fireproof, fromCache: .tabs)

        onFavoriteURLSelected?(url)
    }

    var onFavoriteDeleted: ((BookmarkEntity) -> Void)?
    func deleteFavorite(_ favorite: Favorite) {
        guard let entity = lookupEntity(for: favorite) else { return }

        Pixel.fire(pixel: .homeScreenDeleteFavorite)
        
        interactionModel.removeFavorite(entity)

        WidgetCenter.shared.reloadAllTimelines()
        try? updateData()

        onFavoriteDeleted?(entity)
    }

    var onFavoriteEdit: ((BookmarkEntity) -> Void)?
    func editFavorite(_ favorite: Favorite) {
        guard let entity = lookupEntity(for: favorite) else { return }

        Pixel.fire(pixel: .homeScreenEditFavorite)

        onFavoriteEdit?(entity)
    }

    private func lookupEntity(for favorite: Favorite) -> BookmarkEntity? {
        interactionModel.favorites.first {
            $0.uuid == favorite.id
        }
    }

    private func updateData() throws {
        self.allFavorites = try interactionModel.favorites.map(Favorite.init)
    }
}

enum FavoriteMappingError: Error {
    case missingUUID
}

private extension Favorite {
    init(_ bookmark: BookmarkEntity) throws {
        guard let uuid = bookmark.uuid else {
            throw FavoriteMappingError.missingUUID
        }

        self.id = uuid
        self.title = bookmark.displayTitle
        self.domain = bookmark.host
        self.urlObject = bookmark.urlObject
    }
}

private extension BookmarkEntity {

    var displayTitle: String {
        if let title = title?.trimmingWhitespace(), !title.isEmpty {
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

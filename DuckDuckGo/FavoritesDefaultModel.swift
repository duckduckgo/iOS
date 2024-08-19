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

final class FavoritesDefaultModel: FavoritesModel, FavoritesEmptyStateModel {

    @Published private(set) var allFavorites: [Favorite] = []
    @Published private(set) var isCollapsed: Bool = true
    @Published private(set) var isShowingTooltip: Bool = false

    private(set) lazy var faviconLoader: FavoritesFaviconLoading? = {
        FavoritesFaviconLoader(onFaviconMissing: { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.faviconMissing()
            }
        })
    }()

    private var cancellables = Set<AnyCancellable>()

    private let interactionModel: FavoritesListInteracting
    private let pixelFiring: PixelFiring.Type
    private let dailyPixelFiring: DailyPixelFiring.Type

    var isEmpty: Bool {
        allFavorites.isEmpty
    }

    init(interactionModel: FavoritesListInteracting,
         pixelFiring: PixelFiring.Type = Pixel.self,
         dailyPixelFiring: DailyPixelFiring.Type = DailyPixel.self) {
        self.interactionModel = interactionModel
        self.pixelFiring = pixelFiring
        self.dailyPixelFiring = dailyPixelFiring

        interactionModel.externalUpdates.sink { [weak self] _ in
            try? self?.updateData()
        }.store(in: &cancellables)

        do {
            try updateData()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func toggleCollapse() {
        isCollapsed.toggle()
        
        if isCollapsed {
            pixelFiring.fire(.newTabPageFavoritesSeeLess, withAdditionalParameters: [:])
        } else {
            pixelFiring.fire(.newTabPageFavoritesSeeMore, withAdditionalParameters: [:])
        }
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

        pixelFiring.fire(.favoriteLaunchedNTP, withAdditionalParameters: [:])
        dailyPixelFiring.fireDaily(.favoriteLaunchedNTPDaily)
        Favicons.shared.loadFavicon(forDomain: url.host, intoCache: .fireproof, fromCache: .tabs)

        onFavoriteURLSelected?(url)
    }

    var onFavoriteDeleted: ((BookmarkEntity) -> Void)?
    func deleteFavorite(_ favorite: Favorite) {
        guard let entity = lookupEntity(for: favorite) else { return }

        pixelFiring.fire(.homeScreenDeleteFavorite, withAdditionalParameters: [:])

        interactionModel.removeFavorite(entity)

        WidgetCenter.shared.reloadAllTimelines()
        try? updateData()

        onFavoriteDeleted?(entity)
    }

    var onFavoriteEdit: ((BookmarkEntity) -> Void)?
    func editFavorite(_ favorite: Favorite) {
        guard let entity = lookupEntity(for: favorite) else { return }

        pixelFiring.fire(.homeScreenEditFavorite, withAdditionalParameters: [:])

        onFavoriteEdit?(entity)
    }

    func moveFavorites(from indexSet: IndexSet, to index: Int) {
        guard indexSet.count == 1,
              let fromIndex = indexSet.first else { return }

        let favorite = allFavorites[fromIndex]
        guard let entity = lookupEntity(for: favorite) else { return }

        // adjust for different target index handling
        let toIndex = index > fromIndex ? index - 1 : index
        interactionModel.moveFavorite(entity, fromIndex: fromIndex, toIndex: toIndex)
        allFavorites.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: index)
    }

    // MARK: - Empty state model

    func placeholderTapped() {
        pixelFiring.fire(.newTabPageFavoritesPlaceholderTapped, withAdditionalParameters: [:])
    }

    func toggleTooltip() {
        isShowingTooltip.toggle()
        if isShowingTooltip {
            pixelFiring.fire(.newTabPageFavoritesInfoTooltip, withAdditionalParameters: [:])
        }
    }

    // MARK: -

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

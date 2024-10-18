//
//  FavoritesListInteractingAdapter.swift
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
import Combine
import Bookmarks

final class FavoritesListInteractingAdapter: NewTabPageFavoriteDataSource {

    let favoritesListInteracting: FavoritesListInteracting
    let appSettings: AppSettings

    private var cancellables: Set<AnyCancellable> = []

    private var displayModeSubject = PassthroughSubject<Void, Never>()

    init(favoritesListInteracting: FavoritesListInteracting, appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.favoritesListInteracting = favoritesListInteracting
        self.appSettings = appSettings
        self.externalUpdates = favoritesListInteracting.externalUpdates.merge(with: displayModeSubject).eraseToAnyPublisher()

        NotificationCenter.default.publisher(for: AppUserDefaults.Notifications.favoritesDisplayModeChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                favoritesListInteracting.favoritesDisplayMode = self.appSettings.favoritesDisplayMode
                displayModeSubject.send()
            }
            .store(in: &cancellables)
    }

    let externalUpdates: AnyPublisher<Void, Never>

    var favorites: [Favorite] {
        (try? favoritesListInteracting.favorites.map(Favorite.init)) ?? []
    }

    func moveFavorite(_ favorite: Favorite, fromIndex: Int, toIndex: Int) {
        guard let entity = bookmarkEntity(for: favorite) else { return }

        // adjust for different target index handling
        let toIndex = toIndex > fromIndex ? toIndex - 1 : toIndex
        favoritesListInteracting.moveFavorite(entity, fromIndex: fromIndex, toIndex: toIndex)
    }
    
    func bookmarkEntity(for favorite: Favorite) -> BookmarkEntity? {
        favoritesListInteracting.favorites.first {
            $0.uuid == favorite.id
        }
    }
    
    func favorite(at index: Int) throws -> Favorite? {
        try favoritesListInteracting.favorite(at: index).map(Favorite.init)
    }
    
    func removeFavorite(_ favorite: Favorite) {
        guard let entity = bookmarkEntity(for: favorite) else { return }

        favoritesListInteracting.removeFavorite(entity)
    }
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

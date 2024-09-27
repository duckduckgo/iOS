//
//  AddFavoriteViewModel.swift
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
import UIKit
import Bookmarks
import Combine
import Core
import Persistence
import CoreData

protocol FaviconUpdating {
    @MainActor
    func updateFavicon(forDomain domain: String, with image: UIImage)
}

class AddFavoriteViewModel: ObservableObject {
    @Published var results: [FavoriteSearchResult] = []
    @Published var searchTerm: String = ""
    @Published var wasSearchCompleted: Bool = false

    private var cancellables = Set<AnyCancellable>()

    private var searchTask: Task<Void, Error>?
    private let websiteSearch: any WebsiteSearching
    private let favoritesCreating: MenuBookmarksInteracting
    private let booksmarksSearch: BookmarksStringSearch
    private let faviconLoading: FavoritesFaviconLoading
    private let faviconUpdating: FaviconUpdating
    private let pixelFiring: PixelFiring.Type

    var onAddCustomWebsite: ((_ text: String) -> Void)?
    var onFavoriteAdded: ((_ favorite: BookmarkEntity) -> Void)?

    init(websiteSearching: WebsiteSearching = DDGAutocompleteWebsiteSearch(),
         favoritesCreating: MenuBookmarksInteracting,
         booksmarksSearch: BookmarksStringSearch,
         faviconLoading: FavoritesFaviconLoading,
         faviconUpdating: FaviconUpdating = Favicons.shared,
         pixelFiring: PixelFiring.Type = Pixel.self) {
        self.websiteSearch = websiteSearching
        self.favoritesCreating = favoritesCreating
        self.booksmarksSearch = booksmarksSearch
        self.faviconLoading = faviconLoading
        self.faviconUpdating = faviconUpdating
        self.pixelFiring = pixelFiring

        $searchTerm
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.runSearch()
            }
            .store(in: &cancellables)
    }

    func clear() {
        searchTask?.cancel()
        searchTask = nil
        searchTerm = ""
        clearResults()
    }

    func addFavorite(for result: FavoriteSearchResult) async {

        guard result.isActionable else {
            return
        }

        // We have the same bookmark either without www or with different scheme.
        // Mark this one as a favorite.
        if case let .partialBookmark(matchedURL) = result.favoriteMatch {
            await createOrToggleFavorite(title: result.name, url: matchedURL)
            return
        }

        let name: String
        let url: URL

        // Decorate results and use metadata to create a new bookmark.
        // Use icon from metadata as favicon.
        let decoratedResult = await FavoriteSearchResultDecorator().decorate(results: [result])
        if let decoratedResult = decoratedResult.first {
            name = decoratedResult.name
            url = decoratedResult.url

            if let host = url.host, let icon = decoratedResult.icon {
                await faviconUpdating.updateFavicon(forDomain: host, with: icon)
            }
        } else {
            name = result.name
            url = result.url
        }

        await createOrToggleFavorite(title: name, url: url)
    }

    @MainActor
    func createOrToggleFavorite(title: String, url: URL) {
        favoritesCreating.createOrToggleFavorite(title: title, url: url)
        if let favorite = favoritesCreating.favorite(for: url) {
            pixelFiring.fire(.newTabPageFavoriteAddedAutocomplete, withAdditionalParameters: [:])
            onFavoriteAdded?(favorite)
        }
    }

    func addCustomWebsite() {
        pixelFiring.fire(.addFavoriteAddCustomWebsite, withAdditionalParameters: [:])
        let customWebsiteInput = searchTerm.trimmingWhitespace()
        guard !customWebsiteInput.isEmpty,
              let url = URL(string: customWebsiteInput) else {
            return
        }

        onAddCustomWebsite?(url.absoluteString)
    }

    @MainActor
    private func setSearchCompleted(_ isCompleted: Bool) {
        wasSearchCompleted = isCompleted
    }

    private func clearResults() {
        results = []
    }

    private func runSearch() {
        guard !searchTerm.isEmpty else {
            Task { await setSearchCompleted(false) }
            clearResults()
            return
        }

        searchTask?.cancel()
        searchTask = Task {

            do {
                let urls = try await websiteSearch.search(term: searchTerm)

                try Task.checkCancellation()
                let results = await mapIntoSearchResults(urls)

                try Task.checkCancellation()
                await publishResults(results)
            } catch {
                await publishResults([])
            }

            await setSearchCompleted(true)
        }
    }

    private func mapIntoSearchResults(_ urls: [URL]) async -> [FavoriteSearchResult] {
        let urlMatcher = AddFavoriteURLMatcher(bookmarksSearch: booksmarksSearch)
        
        return await withTaskGroup(of: FavoriteSearchResult.self, returning: [FavoriteSearchResult].self) { group in
            for url in urls {
                group.addTask {
                    let favoriteMatch = await urlMatcher.favoriteMatch(for: url)
                    let name = url.nakedString ?? url.absoluteString
                    var image: UIImage?

                    if let host = url.host {
                        image = await self.faviconLoading.loadFavicon(for: host, size: 64)?.image
                    }

                    return FavoriteSearchResult(id: url.absoluteString, name: name, url: url, favoriteMatch: favoriteMatch, icon: image)
                }
            }

            return await group.reduce(into: [FavoriteSearchResult]()) { partialResult, result in
                partialResult.append(result)
            }
        }
    }

    @MainActor
    private func publishResults(_ results: [FavoriteSearchResult]) {
        self.results = results
    }

    private func convertToURL(_ searchTerm: String) -> URL? {
        let sanitizedTerm = searchTerm.trimmingWhitespace()
        guard !sanitizedTerm.isEmpty,
              var url = URL(string: sanitizedTerm) else { return nil }

        if url.scheme == nil,
           url.navigationalScheme == nil,
           let urlWithScheme = URL(string: "https://\(sanitizedTerm)") {
            url = urlWithScheme
        }

        return url
    }
}

struct FavoriteSearchResult: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL
    let favoriteMatch: AddFavoriteURLMatch?
    let icon: UIImage?

    init(id: String, name: String, url: URL, favoriteMatch: AddFavoriteURLMatch? = nil, icon: UIImage? = nil) {
        self.id = id
        self.name = name
        self.url = url
        self.icon = icon
        self.favoriteMatch = favoriteMatch
    }
}

extension FavoriteSearchResult {

    var isActionable: Bool {
        switch favoriteMatch {
        case .none, .exactBookmark, .partialBookmark:
            return true
        case .exactFavorite, .partialFavorite:
            return false
        }
    }

    var displayURL: String {
        url.absoluteString
    }
}

extension AddFavoriteViewModel {
    static var preview: AddFavoriteViewModel {
        .init(
            favoritesCreating: NullMenuBookmarksInteracting(),
            booksmarksSearch: PreviewBookmarksSearch(),
            faviconLoading: EmptyFaviconLoading()
        )
    }
}

extension Favicons: FaviconUpdating {
    @MainActor
    func updateFavicon(forDomain domain: String, with image: UIImage) {
        loadFavicon(forDomain: domain, intoCache: .fireproof, completion: { existingImage in
            if existingImage == nil {
                self.replaceFireproofFavicon(forDomain: domain, withImage: image)
            }
        })
    }
}

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

class AddFavoriteViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var results: [FavoriteSearchResult] = []
    @Published var searchTerm: String = ""

    private var cancellables = Set<AnyCancellable>()

    private var searchTask: Task<Void, Error>?
    private let websiteSearch: any WebsiteSearching
    private let favoritesCreating: MenuBookmarksInteracting

    init(websiteSearching: WebsiteSearching = DDGAutocompleteWebsiteSearch(), favoritesCreating: MenuBookmarksInteracting) {
        self.websiteSearch = websiteSearching
        self.favoritesCreating = favoritesCreating

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

    func addFavorite(for result: FavoriteSearchResult) -> Bool {
        guard favoritesCreating.bookmark(for: result.url) == nil else { return false }

        favoritesCreating.createOrToggleFavorite(title: result.name, url: result.url)

        // TODO: Cache favicon

        return true
    }

    private func clearResults() {
        errorMessage = nil
        results = []
    }

    private func runSearch() {
        guard !searchTerm.isEmpty else {
            clearResults()
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            do {
                let urls = try await websiteSearch.search(term: searchTerm)
                let results: [FavoriteSearchResult]
                if urls.isEmpty, let manualEntry = await createManualEntry(searchTerm: searchTerm) {
                    results = [manualEntry]
                } else {
                    results = urls.map(FavoriteSearchResult.init(url:))
                }

                await publishResults(results)

                try Task.checkCancellation()

                let decorator = FavoriteSearchResultDecorator()
                let decoratedResults = await decorator.decorate(results: results)

                try Task.checkCancellation()

                await publishResults(decoratedResults)
            } catch {
                await publishResults([])
            }
        }
    }

    private func createManualEntry(searchTerm: String) async -> FavoriteSearchResult? {
        guard let url = convertToURL(searchTerm) else { return nil }
        
        return FavoriteSearchResult(url: url)
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
    let icon: UIImage?

    init(id: String, name: String, url: URL, icon: UIImage? = nil) {
        self.id = id
        self.name = name
        self.url = url
        self.icon = icon
    }
}

extension FavoriteSearchResult {
    init(url: URL) {
        self.id = url.absoluteString
        self.name = url.absoluteString
        self.url = url
        self.icon = nil
    }

    var isValid: Bool {
        return url.isValid
    }

    var displayURL: String {
        url.absoluteString
    }
}

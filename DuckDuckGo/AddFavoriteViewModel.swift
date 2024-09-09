//
//  FavoriteSearchViewModel.swift
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

class AddFavoriteViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var results: [WebPageSearchResultValue] = []
    @Published var manualEntry: WebPageSearchResultValue?
    @Published var isManualEntryValid: Bool = false
    @Published var searchTerm: String = ""

    static var ddg: AddFavoriteViewModel { AddFavoriteViewModel(websiteSearch: DDGAutocompleteWebsiteSearch()) }

    private var cancellables = Set<AnyCancellable>()

    private var searchTask: Task<Void, Error>?
    private var manualEntryTask: Task<Void, Error>?
    private let websiteSearch: any WebsiteSearch

    init(websiteSearch: WebsiteSearch) {
        self.websiteSearch = websiteSearch

        $searchTerm
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.runSearch()
            }
            .store(in: &cancellables)
    }

    func clear() {
        manualEntryTask?.cancel()
        manualEntryTask = nil
        searchTask?.cancel()
        searchTask = nil
        searchTerm = ""
        clearResults()
    }

    private func clearResults() {
        errorMessage = nil
        results = []
        manualEntry = nil
        isManualEntryValid = false
    }

    private func runSearch() {
        guard !searchTerm.isEmpty else {
            clearResults()
            return
        }

        searchTask?.cancel()
        searchTask = Task {
            do {
                let results = try await websiteSearch.search(term: searchTerm)
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

        manualEntryTask?.cancel()
        manualEntryTask = Task {
            if let url = convertToURL(searchTerm) {
                let entry = WebPageSearchResultValue(id: url.absoluteString, name: url.absoluteString, displayUrl: url.absoluteString, url: url)
                await publishManualEntry(entry)

                try Task.checkCancellation()
                let decorator = FavoriteSearchResultDecorator()
                let decoratedResults = await decorator.decorate(results: [entry])

                try Task.checkCancellation()
                await publishManualEntry(decoratedResults.first)
            } else {
                manualEntry = nil
                isManualEntryValid = false
            }
        }
    }

    @MainActor
    private func publishManualEntry(_ entry: WebPageSearchResultValue?) {
        manualEntry = entry
        isManualEntryValid = entry?.url.isValid ?? false
    }

    @MainActor
    private func publishResults(_ results: [WebPageSearchResultValue]) {
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

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

class FavoriteSearchViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var results: [WebPageSearchResultValue] = []
    @Published var manualEntry: WebPageSearchResultValue?
    @Published var isManualEntryValid: Bool = false
    @Published var searchTerm: String = ""

    static var fake: FavoriteSearchViewModel { FavoriteSearchViewModel(websiteSearch: MockWebsiteSearch()) }
    static var bing: FavoriteSearchViewModel { FavoriteSearchViewModel(websiteSearch: BingWebsiteSearch()) }
    static var ddg: FavoriteSearchViewModel { FavoriteSearchViewModel(websiteSearch: DDGAutocompleteWebsiteSearch())}

    private var cancellables = Set<AnyCancellable>()

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

        Task {
            do {
                let results = try await websiteSearch.search(term: searchTerm)
                await publishResults(results)
            } catch let error as BingError {
                await publishResults([], error: error)
            } catch {
                await publishResults([])
            }
        }

        if let url = convertToURL(searchTerm) {
            manualEntry = WebPageSearchResultValue(id: url.absoluteString, name: url.absoluteString, displayUrl: url.absoluteString, url: url)
            isManualEntryValid = url.isValid
        } else {
            manualEntry = nil
            isManualEntryValid = false
        }
    }

    @MainActor
    private func publishResults(_ results: [WebPageSearchResultValue], error: BingError? = nil) {
        self.results = results
        self.errorMessage = error?.message
    }

    private func convertToURL(_ searchTerm: String) -> URL? {
        guard !searchTerm.isEmpty,
              var url = URL(string: searchTerm.trimmingWhitespace()) else { return nil }

        if url.isValid || url.isCustomURLScheme() {
            return url
        } else if url.scheme == nil {
            return URL(string: "https://\(url.absoluteString)")
        }

        return nil
    }
}

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
    @Published var searchTerm: String = ""

    static private(set) var fakeShared = FavoriteSearchViewModel(websiteSearch: MockWebsiteSearch())

    private var cancellables = Set<AnyCancellable>()

    private let websiteSearch: any WebsiteSearch

    init(websiteSearch: WebsiteSearch) {
        self.websiteSearch = websiteSearch

        $searchTerm
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.runSearch()
            }
            .store(in: &cancellables)
    }

    func clear() {
        errorMessage = nil
        searchTerm = ""
        results = []
    }

    private func runSearch() {
        guard !searchTerm.isEmpty else {
            results = []
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
    }

    @MainActor
    private func publishResults(_ results: [WebPageSearchResultValue], error: BingError? = nil) {
        self.results = results
        self.errorMessage = error?.message
    }
}

//
//  AddFavoriteURLMatcher.swift
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
import Common
import Core

enum AddFavoriteURLMatch: Hashable {
    case exactFavorite
    case exactBookmark
    case partialFavorite(matchedURL: URL)
    case partialBookmark(matchedURL: URL)
}

protocol AddFavoriteURLMatching {
    @MainActor
    func favoriteMatch(for url: URL) -> AddFavoriteURLMatch?
}

struct AddFavoriteURLMatcher: AddFavoriteURLMatching {
    let bookmarksSearch: BookmarksStringSearch

    @MainActor
    func favoriteMatch(for url: URL) -> AddFavoriteURLMatch? {
        let searchTerm = url.nakedString ?? url.absoluteString

        let results = bookmarksSearch.search(query: searchTerm)
        guard !results.isEmpty else {
            return nil
        }

        if let match = results.first(where: { $0.url.absoluteString == url.absoluteString }) {
            return match.isFavorite ? .exactFavorite : .exactBookmark
        }

        if let match = results.first(where: { $0.url.absoluteString.contains(searchTerm) }) {
            return match.isFavorite ? .partialFavorite(matchedURL: match.url) : .partialBookmark(matchedURL: match.url)
        }

        return nil
    }
}

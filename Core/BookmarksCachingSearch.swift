//
//  BookmarksCachingSearch.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

public protocol BookmarksSearchStore {
    var hasData: Bool { get }
    func bookmarksAndFavorites(completion: @escaping ([Bookmark]) -> Void)
}

extension BookmarksCoreDataStorage: BookmarksSearchStore {
    public var hasData: Bool {
        !topLevelBookmarksItems.isEmpty || !favorites.isEmpty
    }
    
    public func bookmarksAndFavorites(completion: @escaping ([Bookmark]) -> Void) {
        allBookmarksAndFavoritesFlat(completion: completion)
    }
}

public class BookmarksCachingSearch {
    
    private class ScoredBookmark {
        let bookmark: Bookmark
        var score: Int
        
        init(bookmark: Bookmark, score: Int = 0) {
            self.bookmark = bookmark
            self.score = score
        }
    }
    
    private let bookmarksStore: BookmarksSearchStore

    public init(bookmarksStore: BookmarksSearchStore = BookmarksCoreDataStorage.shared) {
        self.bookmarksStore = bookmarksStore
        loadCache()
    }

    public var hasData: Bool {
        return bookmarksStore.hasData
    }
    
    private var cachedBookmarksAndFavorites: [Bookmark]?
    private let cacheLoadedCondition = RunLoop.ResumeCondition()
    
    private func loadCache() {
        bookmarksStore.bookmarksAndFavorites { bookmarks in
            self.cachedBookmarksAndFavorites = bookmarks
            self.cacheLoadedCondition.resolve()
        }
    }
    
    private var bookmarksAndFavorites: [Bookmark] {
        RunLoop.current.run(until: cacheLoadedCondition)
        return cachedBookmarksAndFavorites ?? []
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func score(query: String, results: [ScoredBookmark]) {
        let tokens = query.split(separator: " ").filter { !$0.isEmpty }.map { String($0).lowercased() }
        
        for entry in results {
            guard let title = entry.bookmark.displayTitle?.lowercased() else { continue }
            
            // Exact matches - full query
            if title.starts(with: query) { // High score for exact match from the begining of the title
                entry.score += 200
            } else if title.contains(" \(query)") { // Exact match from the begining of the word within string.
                entry.score += 100
            }
            
            let domain = entry.bookmark.url?.host?.dropPrefix(prefix: "www.") ?? ""
            
            // Tokenized matches
            
            if tokens.count > 1 {
                var matchesAllTokens = true
                for token in tokens {
                    // Match only from the begining of the word to avoid unintuitive matches.
                    if !title.starts(with: token) && !title.contains(" \(token)") && !domain.starts(with: token) {
                        matchesAllTokens = false
                        break
                    }
                }
                
                if matchesAllTokens {
                    // Score tokenized matches
                    entry.score += 10
                    
                    // Boost score if first token matches:
                    if let firstToken = tokens.first { // domain - high score boost
                        if domain.starts(with: firstToken) {
                            entry.score += 300
                        } else if title.starts(with: firstToken) { // begining of the title - moderate score boost
                            entry.score += 50
                        }
                    }
                }
            } else {
                // High score for matching domain in the URL
                if let firstToken = tokens.first, domain.starts(with: firstToken) {
                    entry.score += 300
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

    public func search(query: String, sortByRelevance: Bool = true, completion: @escaping ([Bookmark]) -> Void) {
        guard hasData else {
            completion([])
            return
        }
        
        let bookmarks = bookmarksAndFavorites
        let results: [ScoredBookmark] = bookmarks.map {
            let score = $0.isFavorite ? 0 : -1
            return ScoredBookmark(bookmark: $0, score: score)
        }
                    
        let trimmed = query.trimWhitespace()
        self.score(query: trimmed, results: results)
        
        var finalResult = results.filter { $0.score > 0 }
        if sortByRelevance {
            finalResult = finalResult.sorted { $0.score > $1.score }
        }
        
        DispatchQueue.main.async {
            completion(finalResult.map { $0.bookmark })
        }
    }
}

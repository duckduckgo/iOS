//
//  BookmarksSearch.swift
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

import Core

class BookmarksSearch {
    
    private class ScoredLink {
        let link: Link
        var score: Int
        
        init(link: Link, score: Int = 0) {
            self.link = link
            self.score = score
        }
    }
    
    private let bookmarksStore: BookmarkStore
    
    init(bookmarksStore: BookmarkStore = BookmarkUserDefaults()) {
        self.bookmarksStore = bookmarksStore
    }
    
    var hasData: Bool {
        return !bookmarksStore.bookmarks.isEmpty || !bookmarksStore.favorites.isEmpty
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func score(query: String, results: [ScoredLink]) {
        let tokens = query.split(separator: " ").filter { !$0.isEmpty }.map { String($0).lowercased() }
        
        for entry in results {
            guard let title = entry.link.displayTitle?.lowercased() else { continue }
            
            // Exact matches - full query
            if title.starts(with: query) { // High score for exact match from the begining of the title
                entry.score += 200
            } else if title.contains(" \(query)") { // Exact match from the begining of the word within string.
                entry.score += 100
            }
            
            let domain = entry.link.url.host?.dropPrefix(prefix: "www.") ?? ""
            
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
    
    func search(query: String, sortByRelevance: Bool = true) -> [Link] {
        guard hasData else {
            return []
        }
        
        let results = bookmarksStore.favorites.map { ScoredLink(link: $0)} + bookmarksStore.bookmarks.map { ScoredLink(link: $0, score: -1) }
        
        let trimmed = query.trimWhitespace()
        score(query: trimmed, results: results)
        
        var finalResult = results.filter { $0.score > 0 }
        if sortByRelevance {
            finalResult = finalResult.sorted { $0.score > $1.score }
        }
        
        return finalResult.map { $0.link }
    }
}

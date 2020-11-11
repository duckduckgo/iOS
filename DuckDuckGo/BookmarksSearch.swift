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
    
    // Single letter queries should only match first character of each word from the title
    private func scoreSingleLetter(query: String, results: [ScoredLink]) {
        for entry in results {
            guard let title = entry.link.displayTitle?.lowercased() else { continue }
            
            if title.starts(with: query) {
                entry.score += 50
            } else if title.contains(" \(query)") {
                entry.score += 10
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func score(query: String, results: [ScoredLink]) {
        let tokens = query.split(separator: " ").filter { !$0.isEmpty }.map { String($0) }
        
        for entry in results {
            guard let title = entry.link.displayTitle?.lowercased() else { continue }
            
            let url: String
            if var components = URLComponents(url: entry.link.url, resolvingAgainstBaseURL: true) {
                components.query = nil
                if let baseUrl = components.url {
                    url = baseUrl.absoluteString.lowercased()
                } else {
                    url = entry.link.url.absoluteString.lowercased()
                }
            } else {
                url = entry.link.url.absoluteString.lowercased()
            }
            
            if title.starts(with: query) { // High score for exact match from the begining of the title
                entry.score += 200
            } else if title.contains(" \(query)") { // Exact match from the begining of the word within string.
                entry.score += 150
            } else if title.contains(query) { // Slightly lower score for 'contains' exact match.
                entry.score += 100
            }
            
            if tokens.count > 1 {
                var matchesAllTokens = true
                for token in tokens {
                    if !title.contains(token) && !url.contains(token) {
                        matchesAllTokens = false
                        break
                    }
                }
                
                if matchesAllTokens {
                    // Score tokenized matches
                    entry.score += 10
                    
                    // Boost score if first token matches begining of the title
                    if let firstToken = tokens.first, title.starts(with: firstToken) {
                        entry.score += 50
                    }
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    
    func search(query: String) -> [Link] {
        let results = bookmarksStore.favorites.map { ScoredLink(link: $0)} + bookmarksStore.bookmarks.map { ScoredLink(link: $0, score: -1) }
        
        let trimmed = query.trimWhitespace()
        if trimmed.count == 1 {
            scoreSingleLetter(query: trimmed, results: results)
        } else {
            score(query: query, results: results)
        }
        
        return results.filter { $0.score > 0 }.sorted { $0.score > $1.score } .map { $0.link }
    }
}

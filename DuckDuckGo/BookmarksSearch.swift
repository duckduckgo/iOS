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
    
    private class ScoredBookmark {
        let bookmark: Bookmark
        var score: Int
        
        init(bookmark: Bookmark, score: Int = 0) {
            self.bookmark = bookmark
            self.score = score
        }
    }
    
    private let bookmarksStore: BookmarkStore
    
    //TODO inject properly, don't like this duplication at all
    //honestly why is this not using bookmarksmanager?
    private let bookmarksCoreDataStorage: BookmarksCoreDataStorage
    
    init(bookmarksStore: BookmarkStore = BookmarkUserDefaults()) {
        self.bookmarksStore = bookmarksStore
        self.bookmarksCoreDataStorage = BookmarksCoreDataStorage()
    }
    
    var hasData: Bool {
        return !bookmarksCoreDataStorage.topLevelBookmarksItems.isEmpty || !bookmarksCoreDataStorage.favorites.isEmpty
        //return !bookmarksStore.bookmarks.isEmpty || !bookmarksStore.favorites.isEmpty
    }
    
    /*
     bookmarks start with -1 (favs 0)
     breakdown search query into lowercase words
     lowercase title
        if starts with query, +200 points
        if contains " query" (strategic use of space to ensure full word match?) , + 100 points
     
     url.host with www. dropped
        if query only has one word, and domain starts with that word, +300 points
        
        If query more than one word, for each word
            check if title starts with the word or containts it (" query"), or if domain starts with it.
        if all have some kind of match, score +10
        if domain starts with first query word, +300
        if title starts with first query word, +50
     
     I assume this original is diacritic sensative
     
     case insensitivity keywords.name CONTAINS[cd] %@
     also BEGINSWITH, instead of contains is a thing
     
     I think we're just gonna have to do this with several core data calls, and then aggrigate them, otherwise we can't score them appropriately
     I suppose the alternatiev is grab everything, and score as is. Hmm, may as well try that first, it'll be easier.
     
     also need to remember to exlude folders (just search BookmarkManagedObject)
     */
    
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
    
    func search(query: String, sortByRelevance: Bool = true, completion: @escaping ([Bookmark]) -> Void) {
        guard hasData else {
            completion([])
            return
        }
        
        bookmarksCoreDataStorage.allBookmarksAndFavoritesShallow() { bookmarks in
            let results: [ScoredBookmark] = bookmarks.map {
                let score = $0.isFavorite ? 0 : -1
                return ScoredBookmark(bookmark: $0, score: score)
            }
            
            //let results = bookmarksStore.favorites.map { ScoredLink(link: $0)} + bookmarksStore.bookmarks.map { ScoredLink(link: $0, score: -1) }
            
            let trimmed = query.trimWhitespace()
            self.score(query: trimmed, results: results)
            
            var finalResult = results.filter { $0.score > 0 }
            if sortByRelevance {
                finalResult = finalResult.sorted { $0.score > $1.score }
            }
            
            completion(finalResult.map { $0.bookmark })
        }
    }
}

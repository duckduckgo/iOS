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
    
    class ScoredLink {
        let link: Link
        var score: Int
        
        init(link: Link, score: Int = 0) {
            self.link = link
            self.score = score
        }
    }
    
    let data: [Link]
    
    init(bookmarksManager: BookmarksManager = BookmarksManager()) {
        let bud = BookmarkUserDefaults()
        data = bud.favorites + bud.bookmarks
    }
    
    func scoreSingleLetter(query: String, data: [ScoredLink]) {
        
        for entry in data {
            guard let title = entry.link.title?.lowercased() else { continue }
            
            if title.starts(with: query) || title.contains(" \(query)") {
                entry.score += 50
            }

        }
    }
    
    func score(query: String, data: [ScoredLink]) {
        let tokens = query.split(separator: " ").filter { !$0.isEmpty }.map { String($0) }
        
        for entry in data {
            guard let title = entry.link.title?.lowercased() else { continue }
            let url = entry.link.url.absoluteString.lowercased()
            
            if title.contains(query) {
                entry.score += 50
            }
            
            if url.contains(query) {
                entry.score += 50
            }
            
            // Look if all tokens match
            var matchesAll = true
            for token in tokens {
                if !title.contains(token) && !url.contains(token) {
                    matchesAll = false
                    break
                }
            }
            
            if matchesAll {
                entry.score += 10
            }
        }
    }
    
    func search(query: String) -> [Link] {
        
        let bud = BookmarkUserDefaults()
        
        let data = bud.favorites.map { ScoredLink(link: $0)} + bud.bookmarks.map { ScoredLink(link: $0, score: -1) }
        
        let trimmed = query.trimWhitespace()
        if trimmed.count == 1 {
            scoreSingleLetter(query: trimmed, data: data)
        } else {
            score(query: query, data: data)
        }
        
        return data.filter { $0.score > 0 }.map { $0.link }
    }
    
    func basicSearch(text: String) -> [Link] {
        let text = text.lowercased()
        let tokens = text.split(separator: " ").filter { !$0.isEmpty }.map { String($0) }

        return data.filter { link -> Bool in
            guard let title = link.title?.lowercased() else { return false }
            let url = link.url.absoluteString.lowercased()
            // Look for direct match
            if title.contains(text) || url.contains(text) {
                return true
            }
            
            // Look if all tokens match
            var matchesAll = true
            for token in tokens {
                if !title.contains(token) && !url.contains(token) {
                    matchesAll = false
                    break
                }
            }
            
            return matchesAll
        }
        
    }
}

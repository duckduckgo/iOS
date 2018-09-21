//
//  GradeCache.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

public class GradeCache {
    
    public static let shared = GradeCache()
    
    private var cachedScores = [String: Grade.Scores]()
    
    private init() { }
    
    /**
     Adds a score to the cache. Only replaces a preexisting score if
     the new score is higher
     - returns: true if the cache was updated, otherwise false
     */
    func add(url: URL, scores: Grade.Scores) -> Bool {
        return compareAndSet(url: url, scores: scores)
    }
    
    private func compareAndSet(url: URL, scores current: Grade.Scores) -> Bool {
        let key = cacheKey(forUrl: url)
        if let previous = cachedScores[key], previous.site.score > current.site.score {
            return false
        }
        cachedScores[key] = current
        return true
    }
    
    func get(url: URL) -> Grade.Scores? {
        let key = cacheKey(forUrl: url)
        return cachedScores[key]
    }
    
    func reset() {
        cachedScores =  [String: Grade.Scores]()
    }
    
    private func cacheKey(forUrl url: URL) -> String {
        guard let domain = url.host else {
            return url.absoluteString
        }
        let scheme = url.scheme ?? URL.URLProtocol.http.rawValue
        return "\(scheme)_\(domain)"
    }
    
}

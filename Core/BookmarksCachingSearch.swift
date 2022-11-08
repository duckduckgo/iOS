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
import Bookmarks
import Persistence
import CoreData

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

    public struct ScoredBookmark {
        public let title: String
        public let url: URL?
        var score: Int
        
        init?(bookmark: [String: Any]) {
            guard let title = bookmark[#keyPath(BookmarkEntity.title)] as? String,
                  let urlString = bookmark[#keyPath(BookmarkEntity.url)] as? String,
                  let url = URL(string: urlString) else {
                return nil
            }
            
            self.title = title
            self.url = url
            
            if (bookmark[#keyPath(BookmarkEntity.isFavorite)] as? NSNumber)?.boolValue ?? false {
                score = 0
            } else {
                score = -1
            }
        }
        
    }
    
    private let bookmarksStore: CoreDataDatabase

    public init(bookmarksStore: CoreDataDatabase = BookmarksDatabase.shared) {
        self.bookmarksStore = bookmarksStore
        loadCache()
        registerForNotifications()
    }

    public var hasData: Bool {
        return cachedBookmarksAndFavorites.count > 0
    }
    
    private var cachedBookmarksAndFavorites = [ScoredBookmark]()
    private var cacheLoadedCondition = RunLoop.ResumeCondition()
    
    private func loadCache() {
        let context = bookmarksStore.makeContext(concurrencyType: .privateQueueConcurrencyType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkEntity")
        fetchRequest.predicate = NSPredicate(format: "%K = false", #keyPath(BookmarkEntity.isFolder))
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [#keyPath(BookmarkEntity.title),
                                          #keyPath(BookmarkEntity.url),
                                          #keyPath(BookmarkEntity.isFavorite)]
        
        context.perform {
            let result = try? context.fetch(fetchRequest) as? [Dictionary<String, Any>]

            DispatchQueue.main.async {
                self.cachedBookmarksAndFavorites = result?.compactMap(ScoredBookmark.init) ?? []
                if !self.cacheLoadedCondition.isResolved {
                    self.cacheLoadedCondition.resolve()
                }
            }
        }
    }
    
    private var bookmarksAndFavorites: [ScoredBookmark] {
        RunLoop.current.run(until: cacheLoadedCondition)
        return cachedBookmarksAndFavorites
    }
// Todo: To remove
	public var bookmarksCount: Int {
		let bookmarksAndFavorites = bookmarksAndFavorites
//		let bookmarksOnly = bookmarksAndFavorites.filter { !$0.isFavorite }
		return bookmarksAndFavorites.count
	}

	public var favoritesCount: Int {
		let bookmarksAndFavorites = bookmarksAndFavorites
//		let favoritesOnly = bookmarksAndFavorites.filter { $0.isFavorite }
		return bookmarksAndFavorites.count
	}

    public func containsDomain(_ domain: String) -> Bool {
        return bookmarksAndFavorites.contains { $0.url?.host == domain }
    }
// ---------

    private func registerForNotifications() {
        registerForCoreDataStorageNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(importDidBegin),
                                               name: BookmarksImporter.Notifications.importDidBegin,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(importDidEnd),
                                               name: BookmarksImporter.Notifications.importDidEnd,
                                               object: nil)
    }

    public func registerForCoreDataStorageNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dataDidChange),
                                               name: BookmarksCoreDataStorage.Notifications.dataDidChange,
                                               object: nil)
    }

    public func refreshCache() {
        // setting cacheLoadedCondition back to initialized state
        cacheLoadedCondition = RunLoop.ResumeCondition()
        loadCache()
    }

    @objc func dataDidChange(notification: Notification) {
        refreshCache()
    }

    @objc func importDidBegin(notification: Notification) {
        // preemptively deregisterForNotifications so that bookmarksCachingSearch is not saturated with notification events
        // and constantly rebuilding while bookmarks are being imported (bookmark files could be very large)
        NotificationCenter.default.removeObserver(self,
                                                  name: BookmarksCoreDataStorage.Notifications.dataDidChange,
                                                  object: nil)
    }

    @objc func importDidEnd(notification: Notification) {
        // force refresh of cached data and re-enable notification observer
        refreshCache()
        registerForCoreDataStorageNotifications()
    }

    // swiftlint:disable cyclomatic_complexity
    private func score(query: String, input: [ScoredBookmark]) -> [ScoredBookmark] {
        let tokens = query.split(separator: " ").filter { !$0.isEmpty }.map { String($0).lowercased() }
        
        var input = input
        var result = [ScoredBookmark]()
        
        for index in 0..<input.count {
            let entry = input[index]
            let title = entry.title.lowercased()
            
            // Exact matches - full query
            if title.starts(with: query) { // High score for exact match from the beginning of the title
                input[index].score += 200
            } else if title.contains(" \(query)") { // Exact match from the beginning of the word within string.
                input[index].score += 100
            }
            
            let domain = entry.url?.host?.droppingWwwPrefix() ?? ""
            
            // Tokenized matches
            
            if tokens.count > 1 {
                var matchesAllTokens = true
                for token in tokens {
                    // Match only from the beginning of the word to avoid unintuitive matches.
                    if !title.starts(with: token) && !title.contains(" \(token)") && !domain.starts(with: token) {
                        matchesAllTokens = false
                        break
                    }
                }
                
                if matchesAllTokens {
                    // Score tokenized matches
                    input[index].score += 10
                    
                    // Boost score if first token matches:
                    if let firstToken = tokens.first { // domain - high score boost
                        if domain.starts(with: firstToken) {
                            input[index].score += 300
                        } else if title.starts(with: firstToken) { // beginning of the title - moderate score boost
                            input[index].score += 50
                        }
                    }
                }
            } else {
                // High score for matching domain in the URL
                if let firstToken = tokens.first, domain.starts(with: firstToken) {
                    input[index].score += 300
                }
            }
            if input[index].score > 0 {
                result.append(input[index])
            }
        }
        return result
    }
    // swiftlint:enable cyclomatic_complexity

    public func search(query: String,
                       sortByRelevance: Bool = true,
                       completion: @escaping ([ScoredBookmark]) -> Void) {
        guard hasData else {
            completion([])
            return
        }
        
        let bookmarks = bookmarksAndFavorites
                    
        let trimmed = query.trimmingWhitespace()
        var finalResult = self.score(query: trimmed, input: bookmarks)
        if sortByRelevance {
            finalResult = finalResult.sorted { $0.score > $1.score }
        }
        
        DispatchQueue.main.async {
            completion(finalResult)
        }
    }
}

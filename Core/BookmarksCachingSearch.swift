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
import Combine

public protocol BookmarksStringSearch {
    var hasData: Bool { get }
    func search(query: String) -> [BookmarksStringSearchResult]
}

public protocol BookmarksStringSearchResult {
    var objectID: NSManagedObjectID { get }
    var title: String { get }
    var url: URL { get }
    var isFavorite: Bool { get }
    func togglingFavorite() -> BookmarksStringSearchResult
}

public protocol BookmarksSearchStore {
    
    var dataDidChange: AnyPublisher<Void, Never> { get }
    
    func bookmarksAndFavorites(completion: @escaping ([BookmarksCachingSearch.ScoredBookmark]) -> Void)
}

public class CoreDataBookmarksSearchStore: BookmarksSearchStore {
    
    private let bookmarksStore: CoreDataDatabase
    
    private let subject = PassthroughSubject<Void, Never>()
    public var dataDidChange: AnyPublisher<Void, Never>
    
    public init(bookmarksStore: CoreDataDatabase) {
        self.bookmarksStore = bookmarksStore
        self.dataDidChange = self.subject.eraseToAnyPublisher()
        
        registerForCoreDataStorageNotifications()
    }
    
    public func bookmarksAndFavorites(completion: @escaping ([BookmarksCachingSearch.ScoredBookmark]) -> Void) {
        
        let context = bookmarksStore.makeContext(concurrencyType: .privateQueueConcurrencyType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookmarkEntity")
        fetchRequest.predicate = NSPredicate(
            format: "%K = false AND %K == NO",
            #keyPath(BookmarkEntity.isFolder),
            #keyPath(BookmarkEntity.isPendingDeletion)
        )
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [#keyPath(BookmarkEntity.title),
                                          #keyPath(BookmarkEntity.url),
                                          #keyPath(BookmarkEntity.objectID)]
        fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(BookmarkEntity.favoriteFolders)]
        
        context.perform {
            let result = try? context.fetch(fetchRequest) as? [Dictionary<String, Any>]
            
            let bookmarksAndFavorites = result?.compactMap(BookmarksCachingSearch.ScoredBookmark.init) ?? []

            DispatchQueue.main.async {
                completion(bookmarksAndFavorites)
            }
        }
    }
    
    private func registerForCoreDataStorageNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataDidSave),
                                               name: NSManagedObjectContext.didSaveObjectsNotification,
                                               object: nil)
    }
    
    @objc func coreDataDidSave(notification: Notification) {
        guard let externalContext = notification.object as? NSManagedObjectContext,
              externalContext.persistentStoreCoordinator == bookmarksStore.coordinator else { return }
        subject.send()
    }
}

public class BookmarksCachingSearch: BookmarksStringSearch {

    public struct ScoredBookmark: BookmarksStringSearchResult {
        public let objectID: NSManagedObjectID
        public let title: String
        public let url: URL
        public let isFavorite: Bool
        var score: Int
        
        init(objectID: NSManagedObjectID, title: String, url: URL, isFavorite: Bool) {
            self.objectID = objectID
            self.title = title
            self.url = url
            self.isFavorite = isFavorite
            
            if isFavorite {
                score = 0
            } else {
                score = -1
            }
        }
        
        init?(bookmark: [String: Any]) {
            guard let title = bookmark[#keyPath(BookmarkEntity.title)] as? String,
                  let urlString = bookmark[#keyPath(BookmarkEntity.url)] as? String,
                  let url = URL(string: urlString),
                  let objectID = bookmark[#keyPath(BookmarkEntity.objectID)] as? NSManagedObjectID else {
                return nil
            }
            
            self.init(objectID: objectID,
                      title: title,
                      url: url,
                      isFavorite: (bookmark[#keyPath(BookmarkEntity.favoriteFolders)] as? Set<NSManagedObject>)?.isEmpty != true)
        }

        public func togglingFavorite() -> BookmarksStringSearchResult {
            return Self.init(objectID: objectID, title: title, url: url, isFavorite: !isFavorite)
        }
    }
    
    private let bookmarksStore: BookmarksSearchStore
    private var cancellable: AnyCancellable?

    public init(bookmarksStore: BookmarksSearchStore) {
        self.bookmarksStore = bookmarksStore
        self.cancellable = bookmarksStore.dataDidChange.sink { [weak self] _ in
            self?.refreshCache()
        }
        
        loadCache()
    }

    public var hasData: Bool {
        return cachedBookmarksAndFavorites.count > 0
    }
    
    private var cachedBookmarksAndFavorites = [ScoredBookmark]()
    private var cacheLoadedCondition = RunLoop.ResumeCondition()
    
    private func loadCache() {
        bookmarksStore.bookmarksAndFavorites { result in
            self.cachedBookmarksAndFavorites = result
            if !self.cacheLoadedCondition.isResolved {
                self.cacheLoadedCondition.resolve()
            }
        }
    }
    
    private var bookmarksAndFavorites: [ScoredBookmark] {
        RunLoop.current.run(until: cacheLoadedCondition)
        return cachedBookmarksAndFavorites
    }

    public func refreshCache() {
        // setting cacheLoadedCondition back to initialized state
        cacheLoadedCondition = RunLoop.ResumeCondition()
        loadCache()
    }

    // swiftlint:disable cyclomatic_complexity
    private func score(query: String, input: [ScoredBookmark]) -> [ScoredBookmark] {
        let query = query.lowercased()
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
            
            let domain = entry.url.host?.droppingWwwPrefix() ?? ""
            
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

    public func search(query: String) -> [BookmarksStringSearchResult] {
        guard hasData else {
            return []
        }
        
        let bookmarks = bookmarksAndFavorites
                    
        let trimmed = query.trimmingWhitespace()
        var finalResult = self.score(query: trimmed, input: bookmarks)
        finalResult = finalResult.sorted { $0.score > $1.score }

        return finalResult
    }
}

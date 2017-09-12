//
//  Migration.swift
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
import CoreData
import Core

class Migration {

    struct Constants {
        static let oldBookmarksKey = "bookmarks"
        static let migrationOccurredKey = "com.duckduckgo.migration.occurred"
    }

    private let bookmarks: BookmarksManager
    private var container: PersistenceContainer
    private var userDefaults: UserDefaults
    
    init(container: PersistenceContainer = PersistenceContainer(name: "Stories")!,
         userDefaults: UserDefaults = UserDefaults.standard,
         bookmarks: BookmarksManager = BookmarksManager()) {
        self.container = container
        self.userDefaults = userDefaults
        self.bookmarks = bookmarks
    }
    
    func start(queue: DispatchQueue = DispatchQueue.global(qos: .background), completion: @escaping (_ occured: Bool, _ stories: Int, _ bookmarks: Int) -> ()) {

        if userDefaults.bool(forKey: Constants.migrationOccurredKey) {
            completion(false, 0, 0)
            return
        }

        queue.async {
            let bookmarksMigrated = self.migrateBookmarks(into: self.bookmarks)
            let storiesMigrated = self.migrateStories(into: self.bookmarks)
            self.userDefaults.set(true, forKey: Constants.migrationOccurredKey)
            completion(true, storiesMigrated, bookmarksMigrated)
        }
        
    }
    
    private func migrateBookmarks(into bookmarks: BookmarksManager) -> Int {
        
        guard let oldBookmarks = userDefaults.array(forKey: Constants.oldBookmarksKey) else {
            return 0
        }
        
        var bookmarkCount = 0
        for bookmarkDict in oldBookmarks {
            
            guard let bookmark = bookmarkDict as? [ String: String? ] else { continue }
            guard let title = bookmark["title"] else { continue }
            guard let urlString = bookmark["url"] else { continue }
            guard let url = URL(string: urlString!) else { continue }
            
            bookmarks.save(bookmark: Link(title: title, url: url, favicon: nil))
            bookmarkCount += 1
        }
        
        userDefaults.removeObject(forKey: Constants.oldBookmarksKey)
        return bookmarkCount
    }
    
    private func migrateStories(into bookmarks: BookmarksManager) -> Int {
        let savedStories = container.savedStories()
        
        var storyCount = 0
        for story in savedStories {
            
            guard let urlString = story.urlString else { continue }
            guard let url = URL(string: urlString) else { continue }
            
            bookmarks.save(bookmark: Link(title: story.title, url: url, favicon: nil))
            storyCount += 1
        }
        
        container.clear()
        return storyCount;
    }
    
}

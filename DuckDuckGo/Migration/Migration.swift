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
    private let container: DDGPersistenceContainer
    private let userDefaults: UserDefaults

    init(container: DDGPersistenceContainer = DDGPersistenceContainer(name: "Stories")!,
         userDefaults: UserDefaults = UserDefaults.standard,
         bookmarks: BookmarksManager = BookmarksManager()) {
        self.container = container
        self.userDefaults = userDefaults
        self.bookmarks = bookmarks
    }

    func start(queue: DispatchQueue = DispatchQueue.global(qos: .background), completion: @escaping (_ occured: Bool, _ stories: Int, _ bookmarks: Int) -> Void) {

        if userDefaults.bool(forKey: Constants.migrationOccurredKey) {
            completion(false, 0, 0)
            return
        }

        queue.async {
            var bookmarksMigrated = 0
            var storiesMigrated = 0
            self.container.managedObjectContext.performAndWait {
                bookmarksMigrated = self.migrateBookmarks(into: self.bookmarks)
                storiesMigrated = self.migrateStories(into: self.bookmarks)
                self.userDefaults.set(true, forKey: Constants.migrationOccurredKey)
            }

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

            bookmarks.save(bookmark: Link(title: title, url: url))
            bookmarkCount += 1
        }

        userDefaults.removeObject(forKey: Constants.oldBookmarksKey)
        return bookmarkCount
    }

    private func migrateStories(into bookmarks: BookmarksManager) -> Int {

        var storyCount = 0
        for story in savedStories() {

            guard let urlString = story.urlString else { continue }
            guard let url = URL(string: urlString) else { continue }

            bookmarks.save(bookmark: Link(title: story.title, url: url))
            storyCount += 1
        }

        clear()
        return storyCount
    }

    func createStory(in feed: DDGStoryFeed) -> DDGStory {
        guard let story = NSEntityDescription.insertNewObject(forEntityName: "Story", into: container.managedObjectContext) as? DDGStory else {
            fatalError("Failed to insert object as DDGStory")
        }

        story.feed = feed
        feed.addToStories(story)

        return story
    }

    func createFeed() -> DDGStoryFeed {
        guard let feed = NSEntityDescription.insertNewObject(forEntityName: "Feed", into: container.managedObjectContext) as? DDGStoryFeed else {
            fatalError("Failed to insert object as DDGStoryFeed")
        }
        return feed
    }

    func savedStories() -> [DDGStory] {
        do {
            let request: NSFetchRequest<DDGStory> = DDGStory.fetchRequest()
            request.predicate = NSPredicate(format: "saved > 0")

            return try container.managedObjectContext.fetch(request)
        } catch {
            debugPrint("Failed to fetch stories", error.localizedDescription)
        }
        return []
    }

    func allStories() -> [DDGStory] {
        do {
            return try container.managedObjectContext.fetch(DDGStory.fetchRequest())
        } catch {
            debugPrint("Failed to fetch stories", error.localizedDescription)
        }
        return []
    }

    func clear() {

        for story in allStories() {
            container.managedObjectContext.delete(story)
        }

        _ = container.save()
    }

}

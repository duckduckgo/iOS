//
//  MigrationTests.swift
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

import XCTest
@testable import DuckDuckGo
@testable import Core

class MigrationTests: XCTestCase {

    var container: DDGPersistenceContainer!
    var userDefaults: UserDefaults!
    var bookmarksManager: BookmarksManager!
    var migration: Migration!

    override func setUp() {
        container = DDGPersistenceContainer(name: "test_stories")
        userDefaults = UserDefaults(suiteName: "test")
        userDefaults.removeSuite(named: "test")
        userDefaults.removePersistentDomain(forName: "test")
        userDefaults.synchronize()

        bookmarksManager = BookmarksManager(dataStore: BookmarkUserDefaults(userDefaults: userDefaults))
        bookmarksManager.clear()

        migration = Migration(container: container, userDefaults: userDefaults, bookmarks: bookmarksManager)
    }

    override func tearDown() {
        migration.clear()
        bookmarksManager.clear()
        clearOldBookmarks()
        userDefaults.removeSuite(named: "test")
        userDefaults.removePersistentDomain(forName: "test")
        userDefaults.synchronize()
    }

    func testWhenMigrationHasOccuredCompletionReturnsFalse() {

        let initialMigration = XCTestExpectation(description: "testWhenMigrationHasOccuredCompletionReturnsFalse")
        migration.start { occurred, _, _ in
            XCTAssertTrue(occurred)
            initialMigration.fulfill()
        }
        wait(for: [initialMigration], timeout: 1)

        let subsequentMigration = XCTestExpectation(description: "testWhenMigrationHasOccuredCompletionReturnsFalse")
        migration.start { occurred, _, _ in
            XCTAssertFalse(occurred)
            subsequentMigration.fulfill()
        }
        wait(for: [subsequentMigration], timeout: 1)
    }

    func testMigrateBothTypes() {

        userDefaults.setValue([[ "title": "example1.com", "url": "http://www.example1.com" ],
                           [ "title": "example2.com", "url": "http://www.example2.com" ]], forKeyPath: Migration.Constants.oldBookmarksKey)
        userDefaults.synchronize()

        let feed = initialise(feed: migration.createFeed())
        _ = createStory(in: feed)
        _ = createStory(in: feed)
        XCTAssert(container.save())

        let expectation = XCTestExpectation(description: "testMigrateBothTypes")
        migration.start { occurred, storiesMigrated, bookmarksMigrated in

            XCTAssertTrue(occurred)
            XCTAssertEqual(2, storiesMigrated)
            XCTAssertEqual(2, bookmarksMigrated)

            XCTAssertEqual(4, self.bookmarksManager.count)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testOldBookmarksDeletedAfterMigration() {
        testSingleFavouriteSearchesMigratedToBookmarks()
        XCTAssertNil(UserDefaults.standard.array(forKey: Migration.Constants.oldBookmarksKey))
    }

    func testSeveralFavouriteSearchesMigratedToBookmarks() {

        userDefaults.setValue([[ "title": "example1.com", "url": "http://www.example1.com" ],
                           [ "title": "example2.com", "url": "http://www.example2.com" ],
                           [ "title": "example3.com", "url": "http://www.example3.com" ]], forKeyPath: Migration.Constants.oldBookmarksKey)
        userDefaults.synchronize()

        let expectation = XCTestExpectation(description: "testSeveralFavouriteSearchesMigratedToBookmarks")
        migration.start { occurred, storiesMigrated, bookmarksMigrated in
            XCTAssertTrue(occurred)
            XCTAssertEqual(0, storiesMigrated)
            XCTAssertEqual(3, bookmarksMigrated)

            XCTAssertEqual(3, self.bookmarksManager.count)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSingleFavouriteSearchesMigratedToBookmarks() {

        userDefaults.setValue([[ "title": "example.com", "url": "http://www.example.com" ]], forKeyPath: Migration.Constants.oldBookmarksKey)
        userDefaults.synchronize()

        let expectation = XCTestExpectation(description: "testSingleFavouriteSearchesMigratedToBookmarks")
        migration.start { occurred, storiesMigrated, bookmarksMigrated in
            XCTAssertTrue(occurred)
            XCTAssertEqual(0, storiesMigrated)
            XCTAssertEqual(1, bookmarksMigrated)

            XCTAssertEqual(1, self.bookmarksManager.count)

            let link = self.self.bookmarksManager.bookmark(atIndex: 0)
            XCTAssertEqual("example.com", link.title)
            XCTAssertEqual("http://www.example.com", link.url.absoluteString)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFavouriteStoriesDeletedAfterMigration() {
        testOnlyFavouriteStoryMigratedToBookmarks()
        XCTAssertEqual(0, migration.allStories().count)
    }

    func testSeveralFavouriteStoriesMigratedToBookmarks() {

        let feed = initialise(feed: migration.createFeed())
        createStory(in: feed).saved = false
        createStory(in: feed).saved = true
        createStory(in: feed).saved = false
        createStory(in: feed).saved = true
        XCTAssert(container.save())

        let expectation = XCTestExpectation(description: "testSeveralFavouriteStoriesMigratedToBookmarks")
        migration.start { occurred, storiesMigrated, _ in

            XCTAssertTrue(occurred)
            XCTAssertEqual(2, storiesMigrated)
            XCTAssertEqual(2, self.self.bookmarksManager.count)
            expectation.fulfill()

        }

        wait(for: [expectation], timeout: 1)
    }

    func testOnlyFavouriteStoryMigratedToBookmarks() {

        let feed = initialise(feed: migration.createFeed())
        createStory(in: feed).saved = false
        createStory(in: feed).saved = true
        XCTAssert(container.save())

        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        migration.start { occurred, storiesMigrated, _ in

            XCTAssertTrue(occurred)
            XCTAssertEqual(1, storiesMigrated)
            XCTAssertEqual(1, self.bookmarksManager.count)
            expectation.fulfill()

        }

        wait(for: [expectation], timeout: 1)
    }

    func testSingleFavouriteStoriesMigratedToBookmarks() {

        let feed = initialise(feed: migration.createFeed())
        let story = retain(story: createStory(in: feed))
        XCTAssert(container.save())

        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        migration.start { occurred, storiesMigrated, _ in
            XCTAssertTrue(occurred)
            XCTAssertEqual(1, storiesMigrated)

            XCTAssertEqual(1, self.bookmarksManager.count)

            let link = self.bookmarksManager.bookmark(atIndex: 0)
            XCTAssertEqual(story.title, link.title)
            XCTAssertEqual(story.urlString, link.url.absoluteString)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testWhenNoMigrationRequiredCompletionIsCalled() {

        let expectation = XCTestExpectation(description: "testWhenNoMigrationRequiredCompletionIsCalled")
        migration.start { occurred, storiesMigrated, bookmarksMigrated in

            print("testWhenNoMigrationRequiredCompletionIsCalled:completion", occurred, storiesMigrated, bookmarksMigrated)

            XCTAssertTrue(occurred)
            XCTAssertEqual(0, storiesMigrated)
            expectation.fulfill()

        }

        wait(for: [expectation], timeout: 1)
    }

    private func initialise(feed: DDGStoryFeed) -> DDGStoryFeed {
        feed.id = "fake id"
        feed.enabledByDefault = true
        feed.imageDownloaded = false
        return feed
    }

    private func createStory(in feed: DDGStoryFeed) -> DDGStory {
        let story = migration.createStory(in: feed)
        story.title = "A title"
        story.urlString = "http://example.com"
        story.saved = true
        story.htmlDownloaded = false
        story.imageDownloaded = false
        return story
    }

    // Stories created in the db are reset when deleted, so copy the bits we want to assert to a value holder
    private func retain(story: DDGStory) -> Story {
        return Story(title: story.title, urlString: story.urlString)
    }

    private func clearOldBookmarks() {
        userDefaults.removeObject(forKey: Migration.Constants.oldBookmarksKey)
        userDefaults.synchronize()
    }

    struct Story {

        var title: String?
        var urlString: String?

    }

}

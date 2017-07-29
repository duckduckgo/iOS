//
//  MigrationTests.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 27/07/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest
@testable import DuckDuckGo

class MigrationTests: XCTestCase {

    var container: PersistenceContainer!
    
    override func setUp() {
        container = PersistenceContainer(name: UUID.init().uuidString)
    }
    
    override func tearDown() {
        
        container.clear()
        BookmarksManager().clear()
        clearOldBookmarks()
        
    }
    
    func testMigrateBothTypes() {
        
        let defaults = UserDefaults.standard
        defaults.setValue([[ "title": "example1.com", "url": "http://www.example1.com" ],
                           [ "title": "example2.com", "url": "http://www.example2.com" ]], forKeyPath: Migration.oldBookmarksKey)
        defaults.synchronize()

        let feed = initialise(feed: container.createFeed())
        let _ = retain(story: createStory(in: feed))
        let _ = retain(story: createStory(in: feed))
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testMigrateBothTypes")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            XCTAssertEqual(2, storiesMigrated)
            XCTAssertEqual(2, bookmarksMigrated)
            
            let bookmarksManager = BookmarksManager()
            XCTAssertEqual(4, bookmarksManager.count)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testOldBookmarksDeletedAfterMigration() {
        testSingleFavouriteSearchesMigratedToBookmarks()
        XCTAssertNil(UserDefaults.standard.array(forKey: Migration.oldBookmarksKey))
    }
    
    func testSeveralFavouriteSearchesMigratedToBookmarks() {
        
        let defaults = UserDefaults.standard
        defaults.setValue([[ "title": "example1.com", "url": "http://www.example1.com" ],
                           [ "title": "example2.com", "url": "http://www.example2.com" ],
                           [ "title": "example3.com", "url": "http://www.example3.com" ]], forKeyPath: Migration.oldBookmarksKey)
        defaults.synchronize()
        
        let expectation = XCTestExpectation(description: "testSeveralFavouriteSearchesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            XCTAssertEqual(0, storiesMigrated)
            XCTAssertEqual(3, bookmarksMigrated)
            
            let bookmarksManager = BookmarksManager()
            XCTAssertEqual(3, bookmarksManager.count)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)            
    }

    func testSingleFavouriteSearchesMigratedToBookmarks() {
        
        let defaults = UserDefaults.standard
        defaults.setValue([[ "title": "example.com", "url": "http://www.example.com" ]], forKeyPath: Migration.oldBookmarksKey)
        defaults.synchronize()
        
        let expectation = XCTestExpectation(description: "testSingleFavouriteSearchesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            XCTAssertEqual(0, storiesMigrated)
            XCTAssertEqual(1, bookmarksMigrated)
            
            let bookmarksManager = BookmarksManager()
            XCTAssertEqual(1, bookmarksManager.count)
            
            let link = bookmarksManager.bookmark(atIndex: 0)
            XCTAssertEqual("example.com", link.title)
            XCTAssertEqual("http://www.example.com", link.url.absoluteString)
            XCTAssertNil(link.favicon)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFavouriteStoriesDeletedAfterMigration() {
        testOnlyFavouriteStoryMigratedToBookmarks()
        XCTAssertEqual(0, container.allStories().count)
    }
    
    func testSeveralFavouriteStoriesMigratedToBookmarks() {
        
        let feed = initialise(feed: container.createFeed())
        createStory(in: feed).saved = NSNumber(booleanLiteral: false)
        createStory(in: feed).saved = NSNumber(booleanLiteral: true)
        createStory(in: feed).saved = NSNumber(booleanLiteral: false)
        createStory(in: feed).saved = NSNumber(booleanLiteral: true)
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testSeveralFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            
            XCTAssertEqual(2, storiesMigrated)
            XCTAssertEqual(2, BookmarksManager().count)
            expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: 1)
    }

    func testOnlyFavouriteStoryMigratedToBookmarks() {
        
        let feed = initialise(feed: container.createFeed())
        createStory(in: feed).saved = NSNumber(booleanLiteral: false)
        createStory(in: feed).saved = NSNumber(booleanLiteral: true)
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            
            XCTAssertEqual(1, storiesMigrated)
            XCTAssertEqual(1, BookmarksManager().count)
            expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    func testSingleFavouriteStoriesMigratedToBookmarks() {
        
        let feed = initialise(feed: container.createFeed())
        let story = retain(story: createStory(in: feed))
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated, bookmarksMigrated in
            XCTAssertEqual(1, storiesMigrated)

            let bookmarksManager = BookmarksManager()
            XCTAssertEqual(1, bookmarksManager.count)
            
            let link = bookmarksManager.bookmark(atIndex: 0)
            XCTAssertEqual(story.title, link.title)
            XCTAssertEqual(story.urlString, link.url.absoluteString)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testWhenNoMigrationRequiredCompletionIsCalled() {
        
        let expectation = XCTestExpectation(description: "testWhenNoMigrationRequiredCompletionIsCalled")
        Migration().start { storiesMigrated, bookmarksMigrated in
            
            XCTAssertEqual(0, storiesMigrated)
            expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    private func initialise(feed: DDGStoryFeed) -> DDGStoryFeed {
        feed.id = "fake id"
        feed.enabledByDefault = NSNumber(booleanLiteral: true)
        feed.imageDownloaded = NSNumber(booleanLiteral: false)
        return feed
    }
    
    private func createStory(in feed: DDGStoryFeed) -> DDGStory {
        let story = container.createStory(in: feed)
        story.title = "A title"
        story.urlString = "http://example.com"
        story.saved = NSNumber(booleanLiteral: true)
        story.htmlDownloaded = NSNumber(booleanLiteral: false)
        story.imageDownloaded = NSNumber(booleanLiteral: false)
        return story
    }

    // Stories created in the db are reset when deleted, so copy the bits we want to assert to a value holder
    private func retain(story: DDGStory) -> Story {
        return Story(title: story.title, urlString: story.urlString)
    }
    
    private func clearOldBookmarks() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Migration.oldBookmarksKey)
        defaults.synchronize()
    }
    
    struct Story {
        
        var title: String?
        var urlString: String?
        
    }
    
}

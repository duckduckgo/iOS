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
    }
    
    // testFavouriteSearchesDeletedAfterMigration
    // testFavouriteSearchesMigratedToBookmarks
    
    func testFavouriteStoriesDeletedAfterMigration() {
        testOnlyFavouriteStoryMigratedToBookmarks()
        XCTAssertEqual(0, container.allStories().count)
    }
    
    func testOnlyFavouriteStoryMigratedToBookmarks() {
        
        let feed = initialise(feed: container.createFeed())
        createStory(in: feed).saved = NSNumber(booleanLiteral: false)
        createStory(in: feed).saved = NSNumber(booleanLiteral: true)
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start { storiesMigrated in
            
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
        Migration(container: container).start { storiesMigrated in
            XCTAssertEqual(1, storiesMigrated)

            let bookmarksManager = BookmarksManager()
            XCTAssertEqual(1, bookmarksManager.count)
            
            let link = bookmarksManager.bookmark(atIndex: 0)
            XCTAssertEqual(story.title, link.title)
            XCTAssertEqual(story.articleURLString, link.url.absoluteString)
            XCTAssertEqual(story.imageURLString, link.favicon?.absoluteString)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testWhenNoMigrationRequiredCompletionIsCalled() {
        
        let expectation = XCTestExpectation(description: "testWhenNoMigrationRequiredCompletionIsCalled")
        Migration().start { storiesMigrated in
            
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
        story.articleURLString = "http://example.com"
        story.imageURLString = "http://example.com/favicon.ico"
        story.saved = NSNumber(booleanLiteral: true)
        story.htmlDownloaded = NSNumber(booleanLiteral: false)
        story.imageDownloaded = NSNumber(booleanLiteral: false)
        return story
    }

    // Stories created in the db are reset when deleted, so copy the bits we want to assert to a value holder
    private func retain(story: DDGStory) -> Story {
        return Story(title: story.title, articleURLString: story.articleURLString, imageURLString: story.imageURLString)
    }
    
    struct Story {
        
        var title: String?
        var articleURLString: String?
        var imageURLString: String?
        
    }
    
}

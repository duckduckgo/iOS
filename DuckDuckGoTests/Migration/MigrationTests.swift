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
    // testFavouriteStoriesDeletedAfterMigration
    
    func testFavouriteStoriesMigratedToBookmarks() {
        
        let feed = initialise(feed: container.createFeed())
        let story = container.createStory(in: feed)
        story.title = "A title"
        story.articleURLString = "http://example.com"
        story.imageURLString = "http://example.com/favicon.ico"
        story.saved = NSNumber(booleanLiteral: true)
        story.htmlDownloaded = NSNumber(booleanLiteral: false)
        story.imageDownloaded = NSNumber(booleanLiteral: false)
        XCTAssert(container.save())
        
        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start {
            
            XCTAssertEqual(1, BookmarksManager().count)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testWhenNoMigrationRequiredCompletionIsCalled() {
        
        let expectation = XCTestExpectation(description: "testWhenNoMigrationRequiredCompletionIsCalled")
        Migration().start {
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
    
}

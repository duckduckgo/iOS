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

    // testFavouriteSearchesDeletedAfterMigration
    // testFavouriteSearchesMigratedToBookmarks
    // testFavouriteStoriesDeletedAfterMigration
    
    func testFavouriteStoriesMigratedToBookmarks() {
        
        // add a story
        let container = PersistenceContainer(name: "testFavouriteStoriesMigratedToBookmarks")
        let story = container.createStory()
//        story.title = "A title"
//        story.urlString = "http://example.com"
//        story.imageURLString = "http://example.com/favicon.ico"
//        story.saved = NSNumber(booleanLiteral: true)
//        XCTAssert(container.save())
        
        // run migration
        let expectation = XCTestExpectation(description: "testFavouriteStoriesMigratedToBookmarks")
        Migration(container: container).start {
            
            // check bookmarks
            XCTAssertEqual(1, BookmarksManager().count)
            
            expectation.fulfill()
        }
        
        // Have a timeout for this test
        wait(for: [expectation], timeout: 1)
        
    }
    
    func testWhenNoMigrationRequiredCompletionIsCalled() {
        
        let expectation = XCTestExpectation(description: "testWhenNoMigrationRequiredCompletionIsCalled")
        Migration().start {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
}

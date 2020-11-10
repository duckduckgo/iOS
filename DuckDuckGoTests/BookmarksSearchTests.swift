//
//  BookmarksSearchTests.swift
//  UnitTests
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

import XCTest

@testable import Core
@testable import DuckDuckGo

class BookmarksSearchTests: XCTestCase {

    let url = URL(string: "http://duckduckgo.com")!
    let simpleStore = MockBookmarkStore()
    
    enum Entry: String {
        case b1 = "test bookmark 1"
        case b2 = "test bookmark 2"
        case b12 = "test bookmark 12"
        case f1 = "test fav 1"
        case f2 = "test fav 2"
        case f12 = "test fav 12"
    }
    
    override func setUp() {
        simpleStore.bookmarks = [Link(title: Entry.b1.rawValue, url: url),
                                 Link(title: Entry.b2.rawValue, url: url),
                                 Link(title: Entry.b12.rawValue, url: url)]
        
        simpleStore.favorites = [Link(title: Entry.f1.rawValue, url: url),
                                 Link(title: Entry.f2.rawValue, url: url),
                                 Link(title: Entry.f12.rawValue, url: url)]
    }

    func testWhenSearchingSingleLetterThenOnlyFirstLettersFromWordsAreMatched() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        XCTAssertEqual(engine.search(query: "t").count, 6)
        XCTAssertEqual(engine.search(query: "b").count, 3)
        XCTAssertEqual(engine.search(query: "1").count, 4)
        XCTAssertEqual(engine.search(query: "e").count, 0)
    }
    
    func testWhenSearchingFullStringThenExactMatchesAreFirst() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "fav 1")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, Entry.f1.rawValue)
        XCTAssertEqual(result[1].title, Entry.f12.rawValue)
    }
    
    func testWhenSearchingThenFavoritesAreFirst() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "1")
        
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].title, Entry.f1.rawValue)
        XCTAssertEqual(result[1].title, Entry.f12.rawValue)
        XCTAssertEqual(result[2].title, Entry.b1.rawValue)
        XCTAssertEqual(result[3].title, Entry.b12.rawValue)
    }

    func testWhenSearchingMultipleWordsThenAllMustBeFound() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "te bo")
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].title, Entry.b1.rawValue)
        XCTAssertEqual(result[1].title, Entry.b2.rawValue)
        XCTAssertEqual(result[2].title, Entry.b12.rawValue)
    }
    
    func testWhenSearchingThenNotFindingAnythingIsAlsoValid() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "testing")
        
        XCTAssertEqual(result.count, 0)
    }

}

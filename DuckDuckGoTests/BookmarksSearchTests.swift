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
    
    let urlStore = MockBookmarkStore()
    
    enum Entry: String {
        case b1 = "bookmark test 1"
        case b2 = "test bookmark 2"
        case b12 = "bookmark test 12"
        case b12a = "test bookmark 12 a"
        case f1 = "fav test 1"
        case f2 = "test fav 2"
        case f12 = "fav test 12"
        case f12a = "test fav 12 a"
        
        case urlExample1 = "Test E 1"
        case urlExample2 = "Test E 2"
        case urlNasa = "Test N 1 Duck"
        case urlDDG = "Test D 1"
    }
    
    override func setUp() {
        simpleStore.bookmarks = [Link(title: Entry.b1.rawValue, url: url),
                                 Link(title: Entry.b2.rawValue, url: url),
                                 Link(title: Entry.b12.rawValue, url: url),
                                 Link(title: Entry.b12a.rawValue, url: url)]
        
        simpleStore.favorites = [Link(title: Entry.f1.rawValue, url: url),
                                 Link(title: Entry.f2.rawValue, url: url),
                                 Link(title: Entry.f12.rawValue, url: url),
                                 Link(title: Entry.f12a.rawValue, url: url)]
        
        urlStore.favorites = [Link(title: Entry.urlExample1.rawValue, url: URL(string: "https://example.com")!),
                              Link(title: Entry.urlExample2.rawValue, url: URL(string: "https://example.com")!),
                              Link(title: Entry.urlNasa.rawValue, url: URL(string: "https://www.nasa.gov")!),
                              Link(title: Entry.urlDDG.rawValue, url: url)]
    }

    func testWhenSearchingThenOnlyBeginingsOfWordsAreMatched() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        XCTAssertEqual(engine.search(query: "t").count, 8)
        XCTAssertEqual(engine.search(query: "b").count, 4)
        XCTAssertEqual(engine.search(query: "1").count, 6)
        XCTAssertEqual(engine.search(query: "a").count, 2)
        XCTAssertEqual(engine.search(query: "k").count, 0)
        XCTAssertEqual(engine.search(query: "e").count, 0)
    }
    
    func testWhenSearchingThenBeginingOfTitlesArePromoted() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let resultSingleLetter = engine.search(query: "t")
        XCTAssertEqual(resultSingleLetter[0].title, Entry.f2.rawValue)
        XCTAssertEqual(resultSingleLetter[1].title, Entry.f12a.rawValue)
        
        XCTAssertEqual(resultSingleLetter[2].title, Entry.b2.rawValue)
        XCTAssertEqual(resultSingleLetter[3].title, Entry.b12a.rawValue)
        
        XCTAssertEqual(resultSingleLetter[4].title, Entry.f1.rawValue)
        XCTAssertEqual(resultSingleLetter[5].title, Entry.f12.rawValue)
        
        XCTAssertEqual(resultSingleLetter[6].title, Entry.b1.rawValue)
        XCTAssertEqual(resultSingleLetter[7].title, Entry.b12.rawValue)
        
        let resultWord = engine.search(query: "tes")
        
        XCTAssertEqual(resultWord[0].title, Entry.f2.rawValue)
        XCTAssertEqual(resultWord[1].title, Entry.f12a.rawValue)
        
        XCTAssertEqual(resultWord[2].title, Entry.b2.rawValue)
        XCTAssertEqual(resultWord[3].title, Entry.b12a.rawValue)
        
        XCTAssertEqual(resultWord[4].title, Entry.f1.rawValue)
        XCTAssertEqual(resultWord[5].title, Entry.f12.rawValue)
        
        XCTAssertEqual(resultWord[6].title, Entry.b1.rawValue)
        XCTAssertEqual(resultWord[7].title, Entry.b12.rawValue)
        
        let resultFullWord = engine.search(query: "bookmark")
        XCTAssertEqual(resultFullWord[0].title, Entry.b1.rawValue)
        XCTAssertEqual(resultFullWord[1].title, Entry.b12.rawValue)
        XCTAssertEqual(resultFullWord[2].title, Entry.b2.rawValue)
        XCTAssertEqual(resultFullWord[3].title, Entry.b12a.rawValue)
        
        let resultSentence = engine.search(query: "tes fav")
        XCTAssertEqual(resultSentence[0].title, Entry.f2.rawValue)
        XCTAssertEqual(resultSentence[1].title, Entry.f12a.rawValue)
        XCTAssertEqual(resultSentence[2].title, Entry.f1.rawValue)
        XCTAssertEqual(resultSentence[3].title, Entry.f12.rawValue)
    }
    
    func testWhenSearchingFullStringThenExactMatchesAreFirst() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "fav 1")
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].title, Entry.f12a.rawValue)
        XCTAssertEqual(result[1].title, Entry.f1.rawValue)
        XCTAssertEqual(result[2].title, Entry.f12.rawValue)
    }
    
    func testWhenSearchingThenFavoritesAreFirst() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "1")
        
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0].title, Entry.f1.rawValue)
        XCTAssertEqual(result[1].title, Entry.f12.rawValue)
        XCTAssertEqual(result[2].title, Entry.f12a.rawValue)
        XCTAssertEqual(result[3].title, Entry.b1.rawValue)
        XCTAssertEqual(result[4].title, Entry.b12.rawValue)
        XCTAssertEqual(result[5].title, Entry.b12a.rawValue)
    }

    func testWhenSearchingMultipleWordsThenAllMustBeFound() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "te bo")
        
        XCTAssertEqual(result.count, 4)
        // Prioritize if first word match the begining of the title
        XCTAssertEqual(result[0].title, Entry.b2.rawValue)
        XCTAssertEqual(result[1].title, Entry.b12a.rawValue)
        XCTAssertEqual(result[2].title, Entry.b1.rawValue)
        XCTAssertEqual(result[3].title, Entry.b12.rawValue)
    }
    
    func testWhenSearchingThenNotFindingAnythingIsAlsoValid() throws {
        
        let engine = BookmarksSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "testing")
        
        XCTAssertEqual(result.count, 0)
    }
    
    func testWhenMatchingURLThenDomainMatchesArePromoted() throws {
        
        let engine = BookmarksSearch(bookmarksStore: urlStore)
        
        let result = engine.search(query: "exam")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].title, Entry.urlExample1.rawValue)
        XCTAssertEqual(result[1].title, Entry.urlExample2.rawValue)
        
        let result2 = engine.search(query: "exam 2")
        
        XCTAssertEqual(result2.count, 1)
        XCTAssertEqual(result2[0].title, Entry.urlExample2.rawValue)
        
        let result3 = engine.search(query: "test")
        
        XCTAssertEqual(result3.count, 4)
        
        let result4 = engine.search(query: "duck")
        
        XCTAssertEqual(result4.count, 2)
        XCTAssertEqual(result4[0].title, Entry.urlDDG.rawValue)
        XCTAssertEqual(result4[1].title, Entry.urlNasa.rawValue)
        
    }

}

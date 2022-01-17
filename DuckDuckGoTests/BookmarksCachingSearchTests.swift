//
//  BookmarksCachingSearchTests.swift
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
import CoreData

@testable import Core
@testable import DuckDuckGo

class MockBookmarkSearchStore: BookmarksSearchStore {
    var hasData: Bool {
        return true
    }
    
    func bookmarksAndFavorites(completion: @escaping ([Bookmark]) -> Void) {
        completion(bookmarks + favorites)
    }
    
    var bookmarks = [Bookmark]()
    var favorites = [Bookmark]()
}

class MockBookmark: Bookmark {
    
    var title: String?
    var url: URL?
    var isFavorite: Bool
    
    init(title: String, url: URL, isFavorite: Bool) {
        self.title = title
        self.url = url
        self.isFavorite = isFavorite
    }
    
    var objectID: NSManagedObjectID {
        fatalError()
    }
    
    var parentFolder: BookmarkFolder?
}

class BookmarksCachingSearchTests: XCTestCase {

    let url = URL(string: "http://duckduckgo.com")!
    let simpleStore = MockBookmarkSearchStore()
    
    let urlStore = MockBookmarkSearchStore()
    
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
        simpleStore.bookmarks = [MockBookmark(title: Entry.b1.rawValue, url: url, isFavorite: false),
                                 MockBookmark(title: Entry.b2.rawValue, url: url, isFavorite: false),
                                 MockBookmark(title: Entry.b12.rawValue, url: url, isFavorite: false),
                                 MockBookmark(title: Entry.b12a.rawValue, url: url, isFavorite: false)]
        
        simpleStore.favorites = [MockBookmark(title: Entry.f1.rawValue, url: url, isFavorite: true),
                                 MockBookmark(title: Entry.f2.rawValue, url: url, isFavorite: true),
                                 MockBookmark(title: Entry.f12.rawValue, url: url, isFavorite: true),
                                 MockBookmark(title: Entry.f12a.rawValue, url: url, isFavorite: true)]
        
        urlStore.favorites = [
            MockBookmark(title: Entry.urlExample1.rawValue, url: URL(string: "https://example.com")!, isFavorite: true),
            MockBookmark(title: Entry.urlExample2.rawValue, url: URL(string: "https://example.com")!, isFavorite: true),
            MockBookmark(title: Entry.urlNasa.rawValue, url: URL(string: "https://www.nasa.gov")!, isFavorite: true),
            MockBookmark(title: Entry.urlDDG.rawValue, url: url, isFavorite: true)]
    }

    func testWhenSearchingThenOnlyBeginingsOfWordsAreMatched() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        let expectations = [
            expectation(description: "test for correct number of search results"),
            expectation(description: "test for correct number of search results"),
            expectation(description: "test for correct number of search results"),
            expectation(description: "test for correct number of search results"),
            expectation(description: "test for correct number of search results"),
            expectation(description: "test for correct number of search results")]
        
        engine.search(query: "t") { bookmarks in
            XCTAssertEqual(bookmarks.count, 8)
            expectations[0].fulfill()
        }
        engine.search(query: "b") { bookmarks in
            XCTAssertEqual(bookmarks.count, 4)
            expectations[1].fulfill()
        }
        engine.search(query: "1") { bookmarks in
            XCTAssertEqual(bookmarks.count, 6)
            expectations[2].fulfill()
        }
        engine.search(query: "a") { bookmarks in
            XCTAssertEqual(bookmarks.count, 2)
            expectations[3].fulfill()
        }
        engine.search(query: "k") { bookmarks in
            XCTAssertEqual(bookmarks.count, 0)
            expectations[4].fulfill()
        }
        engine.search(query: "e") { bookmarks in
            XCTAssertEqual(bookmarks.count, 0)
            expectations[5].fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenSearchingThenBeginingOfTitlesArePromoted() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let expectation1 = expectation(description: "t")
        engine.search(query: "t") { resultSingleLetter in
            XCTAssertEqual(resultSingleLetter[0].title, Entry.f2.rawValue)
            XCTAssertEqual(resultSingleLetter[1].title, Entry.f12a.rawValue)
            
            XCTAssertEqual(resultSingleLetter[2].title, Entry.b2.rawValue)
            XCTAssertEqual(resultSingleLetter[3].title, Entry.b12a.rawValue)
            
            XCTAssertEqual(resultSingleLetter[4].title, Entry.f1.rawValue)
            XCTAssertEqual(resultSingleLetter[5].title, Entry.f12.rawValue)
            
            XCTAssertEqual(resultSingleLetter[6].title, Entry.b1.rawValue)
            XCTAssertEqual(resultSingleLetter[7].title, Entry.b12.rawValue)
            
            expectation1.fulfill()
        }
                
        let expectation2 = expectation(description: "tes")
        engine.search(query: "tes") { resultWord in
        
            XCTAssertEqual(resultWord[0].title, Entry.f2.rawValue)
            XCTAssertEqual(resultWord[1].title, Entry.f12a.rawValue)
            
            XCTAssertEqual(resultWord[2].title, Entry.b2.rawValue)
            XCTAssertEqual(resultWord[3].title, Entry.b12a.rawValue)
            
            XCTAssertEqual(resultWord[4].title, Entry.f1.rawValue)
            XCTAssertEqual(resultWord[5].title, Entry.f12.rawValue)
            
            XCTAssertEqual(resultWord[6].title, Entry.b1.rawValue)
            XCTAssertEqual(resultWord[7].title, Entry.b12.rawValue)
            
            expectation2.fulfill()
        }
            
        let expectation3 = expectation(description: "bookmark")
        engine.search(query: "bookmark") { resultFullWord in
        
            XCTAssertEqual(resultFullWord[0].title, Entry.b1.rawValue)
            XCTAssertEqual(resultFullWord[1].title, Entry.b12.rawValue)
            XCTAssertEqual(resultFullWord[2].title, Entry.b2.rawValue)
            XCTAssertEqual(resultFullWord[3].title, Entry.b12a.rawValue)
            
            expectation3.fulfill()
        }
        
        let expectation4 = expectation(description: "tes fav")
        engine.search(query: "tes fav") { resultSentence in
        
            XCTAssertEqual(resultSentence[0].title, Entry.f2.rawValue)
            XCTAssertEqual(resultSentence[1].title, Entry.f12a.rawValue)
            XCTAssertEqual(resultSentence[2].title, Entry.f1.rawValue)
            XCTAssertEqual(resultSentence[3].title, Entry.f12.rawValue)
            
            expectation4.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenSearchingFullStringThenExactMatchesAreFirst() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let expectation1 = expectation(description: "fav 1")
        engine.search(query: "fav 1") { result in
        
            XCTAssertEqual(result.count, 3)
            XCTAssertEqual(result[0].title, Entry.f12a.rawValue)
            XCTAssertEqual(result[1].title, Entry.f1.rawValue)
            XCTAssertEqual(result[2].title, Entry.f12.rawValue)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenSearchingThenFavoritesAreFirst() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let expectation1 = expectation(description: "1")
        engine.search(query: "1") { result in
            XCTAssertEqual(result.count, 6)
            XCTAssertEqual(result[0].title, Entry.f1.rawValue)
            XCTAssertEqual(result[1].title, Entry.f12.rawValue)
            XCTAssertEqual(result[2].title, Entry.f12a.rawValue)
            XCTAssertEqual(result[3].title, Entry.b1.rawValue)
            XCTAssertEqual(result[4].title, Entry.b12.rawValue)
            XCTAssertEqual(result[5].title, Entry.b12a.rawValue)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }

    func testWhenSearchingMultipleWordsThenAllMustBeFound() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let expectation1 = expectation(description: "te bo")
        engine.search(query: "te bo") { result in
            XCTAssertEqual(result.count, 4)
            // Prioritize if first word match the begining of the title
            XCTAssertEqual(result[0].title, Entry.b2.rawValue)
            XCTAssertEqual(result[1].title, Entry.b12a.rawValue)
            XCTAssertEqual(result[2].title, Entry.b1.rawValue)
            XCTAssertEqual(result[3].title, Entry.b12.rawValue)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenSearchingThenNotFindingAnythingIsAlsoValid() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let expectation1 = expectation(description: "testing")
        engine.search(query: "testing") { result in
            XCTAssertEqual(result.count, 0)
            
            expectation1.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testWhenMatchingURLThenDomainMatchesArePromoted() throws {
        
        let engine = BookmarksCachingSearch(bookmarksStore: urlStore)
        
        let expectation1 = expectation(description: "exam")
        engine.search(query: "exam") { result in
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].title, Entry.urlExample1.rawValue)
            XCTAssertEqual(result[1].title, Entry.urlExample2.rawValue)
            
            expectation1.fulfill()
        }
                
        let expectation2 = expectation(description: "exam 2")
        engine.search(query: "exam 2") { result2 in
        
            XCTAssertEqual(result2.count, 1)
            XCTAssertEqual(result2[0].title, Entry.urlExample2.rawValue)
            
            expectation2.fulfill()
        }
            
        let expectation3 = expectation(description: "test")
        engine.search(query: "test") { result3 in
        
            XCTAssertEqual(result3.count, 4)
            
            expectation3.fulfill()
        }
        
        let expectation4 = expectation(description: "duck")
        engine.search(query: "duck") { result4 in
        
            XCTAssertEqual(result4.count, 2)
            XCTAssertEqual(result4[0].title, Entry.urlDDG.rawValue)
            XCTAssertEqual(result4[1].title, Entry.urlNasa.rawValue)
            
            expectation4.fulfill()
        }
        
        waitForExpectations(timeout: 5) 
    }
}

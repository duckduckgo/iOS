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

import Bookmarks
import Combine
import CoreData
import XCTest

@testable import Core

public class MockBookmarksSearchStore: BookmarksSearchStore {
    
    let subject = PassthroughSubject<Void, Never>()
    public var dataDidChange: AnyPublisher<Void, Never>

    var dataSet = [BookmarksCachingSearch.ScoredBookmark]()
    
    init() {
        dataDidChange = subject.eraseToAnyPublisher()
    }
    
    public func bookmarksAndFavorites(completion: @escaping ([BookmarksCachingSearch.ScoredBookmark]) -> Void) {
        completion(dataSet)
    }
}

class BookmarksCachingSearchTests: XCTestCase {
    
    let url = URL(string: "http://duckduckgo.com")!
    
    let simpleStore = MockBookmarksSearchStore()
    let urlStore = MockBookmarksSearchStore()
    let quotedTitleStore = MockBookmarksSearchStore()

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

        case quotedTitle1 = "\"Cats and Dogs\""
        case quotedTitle2 = "«Рукописи не горят»: первый замысел"
    }
    
    private var mockObjectID: NSManagedObjectID!
    private var inMemoryStore: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        
        inMemoryStore = CoreData.createInMemoryPersistentContainer(modelName: "BookmarksModel",
                                                                  bundle: Bookmarks.bundle)
        BookmarkUtils.prepareFoldersStructure(in: inMemoryStore.viewContext)
        mockObjectID = BookmarkUtils.fetchRootFolder(inMemoryStore.viewContext)?.objectID
        XCTAssertNotNil(mockObjectID)
    
        simpleStore.dataSet = [
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.b1.rawValue, url: url, isFavorite: false),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.b2.rawValue, url: url, isFavorite: false),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.b12.rawValue, url: url, isFavorite: false),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.b12a.rawValue, url: url, isFavorite: false),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.f1.rawValue, url: url, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.f2.rawValue, url: url, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.f12.rawValue, url: url, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.f12a.rawValue, url: url, isFavorite: true),
        ]

        urlStore.dataSet = [
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.urlExample1.rawValue, url: URL(string: "https://example.com")!, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.urlExample2.rawValue, url: URL(string: "https://example.com")!, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.urlNasa.rawValue, url: URL(string: "https://www.nasa.gov")!, isFavorite: true),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.urlDDG.rawValue, url: url, isFavorite: true),
        ]

        quotedTitleStore.dataSet = [
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.quotedTitle1.rawValue, url: url, isFavorite: false),
            BookmarksCachingSearch.ScoredBookmark(objectID: mockObjectID, title: Entry.quotedTitle2.rawValue, url: url, isFavorite: false),
        ]

    }
    
    override func tearDown() {
        mockObjectID = nil
        inMemoryStore = nil
        
        super.tearDown()
    }

    func testWhenSearchingForCharactersThenCharactersAtTheStartAreMatched() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: quotedTitleStore)
        var bookmarks = engine.search(query: "\"")
        XCTAssertEqual(bookmarks.count, 1)

        bookmarks = engine.search(query: "«")
        XCTAssertEqual(bookmarks.count, 1)
    }

    func testWhenSearchingForWordsAtStartWithQuotesThenWordsAreMatched() async throws {

        let engine = BookmarksCachingSearch(bookmarksStore: quotedTitleStore)
        var bookmarks = engine.search(query: "Cats")
        XCTAssertEqual(bookmarks.count, 1)

        bookmarks = engine.search(query: "Р")
        XCTAssertEqual(bookmarks.count, 1)

        bookmarks = engine.search(query: "Ру")
        XCTAssertEqual(bookmarks.count, 1)

        bookmarks = engine.search(query: "Рук")
        XCTAssertEqual(bookmarks.count, 1)

        bookmarks = engine.search(query: "Nope")
        XCTAssertEqual(bookmarks.count, 0)
    }

    func testWhenSearchingThenOnlyBeginingsOfWordsAreMatched() async throws {

        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        var bookmarks = engine.search(query: "t")
        XCTAssertEqual(bookmarks.count, 8)
        
        bookmarks = engine.search(query: "b")
        XCTAssertEqual(bookmarks.count, 4)
        
        bookmarks = engine.search(query: "1")
        XCTAssertEqual(bookmarks.count, 6)
        
        bookmarks = engine.search(query: "a")
        XCTAssertEqual(bookmarks.count, 2)
        
        bookmarks = engine.search(query: "k")
        XCTAssertEqual(bookmarks.count, 0)
        
        bookmarks = engine.search(query: "e")
        XCTAssertEqual(bookmarks.count, 0)
    }
    
    func testWhenSearchingThenBeginingOfTitlesArePromoted() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
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
    
    func testWhenSearchingFullStringThenExactMatchesAreFirst() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "fav 1")
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].title, Entry.f12a.rawValue)
        XCTAssertEqual(result[1].title, Entry.f1.rawValue)
        XCTAssertEqual(result[2].title, Entry.f12.rawValue)
    }
    
    func testWhenSearchingThenFavoritesAreFirst() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "1")
        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result[0].title, Entry.f1.rawValue)
        XCTAssertEqual(result[1].title, Entry.f12.rawValue)
        XCTAssertEqual(result[2].title, Entry.f12a.rawValue)
        XCTAssertEqual(result[3].title, Entry.b1.rawValue)
        XCTAssertEqual(result[4].title, Entry.b12.rawValue)
        XCTAssertEqual(result[5].title, Entry.b12a.rawValue)
    }

    func testWhenSearchingMultipleWordsThenAllMustBeFound() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "te bo")
        XCTAssertEqual(result.count, 4)
        // Prioritize if first word match the beginning of the title
        XCTAssertEqual(result[0].title, Entry.b2.rawValue)
        XCTAssertEqual(result[1].title, Entry.b12a.rawValue)
        XCTAssertEqual(result[2].title, Entry.b1.rawValue)
        XCTAssertEqual(result[3].title, Entry.b12.rawValue)
    }
    
    func testWhenSearchingThenNotFindingAnythingIsAlsoValid() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: simpleStore)
        
        let result = engine.search(query: "testing")
        XCTAssertEqual(result.count, 0)
    }
    
    func testWhenMatchingURLThenDomainMatchesArePromoted() async throws {
        let engine = BookmarksCachingSearch(bookmarksStore: urlStore)
        
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

private extension BookmarksCachingSearchTests {
    enum Constants {
        static let bookmarkTitle = "my bookmark"
        static let bookmarkURL = URL(string: "https://www.apple.com")!
    }
}

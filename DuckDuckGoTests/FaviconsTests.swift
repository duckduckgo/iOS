//
//  FaviconsTests.swift
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
import Kingfisher
import CoreData
import Bookmarks

class FaviconsTests: XCTestCase {

    private var favicons: Favicons!
    
    private var mockObjectID: NSManagedObjectID!
    private var inMemoryStore: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        
        inMemoryStore = CoreData.createInMemoryPersistentContainer(modelName: "BookmarksModel",
                                                                  bundle: Bookmarks.bundle)
        BookmarkUtils.prepareFoldersStructure(in: inMemoryStore.viewContext)
        mockObjectID = BookmarkUtils.fetchRootFolder(inMemoryStore.viewContext)?.objectID
        XCTAssertNotNil(mockObjectID)

        favicons = Favicons(sourcesProvider: DefaultFaviconSourcesProvider(),
                            downloader: NotFoundCachingDownloader())

        Favicons.Constants.tabsCache.clearDiskCache()
        Favicons.Constants.tabsCache.clearMemoryCache()
        Favicons.Constants.fireproofCache.clearDiskCache()
        Favicons.Constants.fireproofCache.clearMemoryCache()
        
        _ = DefaultUserAgentManager.shared
    }

    override func tearDownWithError() throws {
        favicons = nil
        mockObjectID = nil
        inMemoryStore = nil

        try super.tearDownWithError()
    }
    
    func testWhenGeneratingKingfisherOptionsThenOptionsAreConfiguredCorrectly() {
        
        let options = favicons.kfOptions(forDomain: Constants.exampleDomain, usingCache: .tabs)

        switch options?[0] {
        case .downloader(let downloader):
            XCTAssertTrue(downloader === favicons.downloader)

        default:
            XCTFail("Unexpected option")
        }
        
        switch options?[1] {
        case .requestModifier(let modifier):
            XCTAssertTrue(modifier as AnyObject === Favicons.Constants.requestModifier)
            
        default:
            XCTFail("Unexpected option")
        }

        switch options?[2] {
        case .targetCache(let cache):
            XCTAssertTrue(cache === Favicons.Constants.caches[.tabs])
            
        default:
            XCTFail("Unexpected option")
        }

        // release builds will set an explicit 7 day, test builds use a smaller expiry
        switch options?[3] {
        case .diskCacheExpiration: break

        default:
            XCTFail("Unexpected option")
        }
        
        switch options?[4] {
        case .alternativeSources(let sources):
            XCTAssertEqual(2, sources.count)
            XCTAssertEqual(sources[0].url, URL(string: "https://example.com/favicon.ico"))
            XCTAssertEqual(sources[1].url, URL(string: "http://example.com/favicon.ico"))

        default:
            XCTFail("Unexpected option")
        }
        
    }
    
    func testWhenGeneratingKingfisherResourceThenCorrectKeyAndURLAreGenerated() {
        
        let resource = favicons.defaultResource(forDomain: Constants.exampleDomain)
        XCTAssertEqual(resource?.cacheKey, "\(Favicons.Constants.salt)\(Constants.exampleDomain)".sha256())
        XCTAssertEqual(resource?.downloadURL, URL(string: "https://example.com/apple-touch-icon.png"))
        
    }

    func testWhenDomainIsBookmarkThenIsFaviconCached() {
        let expectation = self.expectation(description: "isFaviconCachedForBookmarks")

        guard let image = UIImage(named: "Logo"),
              let resource = favicons.defaultResource(forDomain: Constants.exampleDomain) else {
            XCTFail("Failed to load data needed for test")
            return
        }

        Favicons.Constants.fireproofCache.store(image, forKey: resource.cacheKey) { _ in
            XCTAssertTrue(Favicons.Constants.fireproofCache.isCached(forKey: resource.cacheKey))
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }

	func testWhenProvidedImageThenSizeIsValid() {
		guard let image = UIImage(named: "Logo") else {
			XCTFail("Failed to load image needed for test")
			return
		}

		XCTAssertTrue(favicons.isValidImage(image, forMaxSize: CGSize(width: 128.0, height: 128.0)))
		XCTAssertFalse(favicons.isValidImage(image, forMaxSize: CGSize(width: 64.0, height: 64.0)))
	}

	func testWhenProvidedImageThenImageIsResized() {
		guard let image = UIImage(named: "Logo") else {
			XCTFail("Failed to load image needed for test")
			return
		}

		let size = CGSize(width: 64, height: 64)
		XCTAssertTrue(image.size != size)

		let resizedImage = favicons.resizedImage(image, toSize: size)
		XCTAssertTrue(resizedImage.size == size)
	}

}

struct MockSourcesProvider: FaviconSourcesProvider {
    
    let mainSource: URL
    let additionalSources: [URL]
        
    func mainSource(forDomain: String) -> URL? {
        return mainSource
    }
    
    func additionalSources(forDomain: String) -> [URL] {
        return additionalSources
    }
}

private extension FaviconsTests {
    enum Constants {
        static let exampleDomain = "example.com"
        static let bookmarkURLString = "https://duckduckgo.com"
    }
}

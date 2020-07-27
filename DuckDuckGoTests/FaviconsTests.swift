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

class FaviconsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        UserDefaults.clearStandard()
        
        Favicons.Constants.tabsCache.clearDiskCache()
        Favicons.Constants.tabsCache.clearMemoryCache()
        Favicons.Constants.bookmarksCache.clearDiskCache()
        Favicons.Constants.bookmarksCache.clearMemoryCache()
    }
    
    func testWhenFreshInstallThenNeedsMigration() {
        XCTAssertTrue(Favicons.shared.needsMigration)
        let migrationExpectation = expectation(description: "migrateIfNeeded")
        Favicons.shared.migrateIfNeeded {
            migrationExpectation.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertFalse(Favicons.shared.needsMigration)
    }
    
    func testWhenGeneratingKingfisherOptionsThenOptionsAreConfiguredCorrectly() {
        
        let options = Favicons.shared.kfOptions(forDomain: "example.com", usingCache: .tabs)
          
        switch options?[0] {
        case .downloader(let downloader):
            XCTAssertTrue(downloader === Favicons.Constants.downloader)

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
        
        let resource = Favicons.shared.defaultResource(forDomain: "example.com")
        XCTAssertEqual(resource?.cacheKey, "\(Favicons.Constants.salt)example.com".sha256())
        XCTAssertEqual(resource?.downloadURL, URL(string: "https://example.com/apple-touch-icon.png"))
        
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

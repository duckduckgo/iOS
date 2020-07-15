//
//  NotFoundCachingDownloaderTests.swift
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

class NotFoundCachingDownloaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.clearStandard()
    }
    
    func testWhenURLSavedNotStoredInPlainText() {
        let downloader = NotFoundCachingDownloader()
        downloader.cacheNotFound("example.com")

        guard let domains: [String: TimeInterval] = UserDefaults.standard.object(forKey: UserDefaultsWrapper<Any>.Key.notFoundCache.rawValue)
            as? [String: TimeInterval] else {
                XCTFail("Failed to load not found cache")
                return
        }
        
        XCTAssertEqual(1, domains.count)
        domains.forEach {
            XCTAssertEqual($0.key, "\(Favicons.Constants.salt)example.com".sha256())
        }
        
    }
    
    func testWhenExpiredEntriesAreRemovedThenDomainsShouldDownload() {

        let downloader = NotFoundCachingDownloader()
        downloader.cacheNotFound("example.com")
        
        let moreThanAWeekFromNow = Date().addingTimeInterval(60 * 60 * 24 * 8)
        downloader.removeExpired(referenceDate: moreThanAWeekFromNow)
        
        XCTAssertTrue(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!))

    }
    
    func testWhenDomainMarkedAsDomainExpiresThenShouldDownload() {
        let downloader = NotFoundCachingDownloader()
        downloader.cacheNotFound("example.com")
        
        let moreThanAWeekFromNow = Date().addingTimeInterval(60 * 60 * 24 * 8)
        XCTAssertTrue(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!, referenceDate: moreThanAWeekFromNow))
    }

    func testWhenMarkingDomainAsNotFoundThenShouldNotDownload() {
        let downloader = NotFoundCachingDownloader()
        downloader.cacheNotFound("example.com")
        XCTAssertFalse(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!))
    }

    func testWhenDomainNotMarkedAsNotFoundThenShouldNotDownload() {
        let downloader = NotFoundCachingDownloader()
        XCTAssertTrue(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!))
    }

}

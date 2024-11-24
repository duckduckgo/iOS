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
@testable import DuckDuckGo

class NotFoundCachingDownloaderTests: XCTestCase {

    private var downloader: NotFoundCachingDownloader!

    override func setUp() {
        super.setUp()
        
        setupUserDefault(with: #file)
        downloader = NotFoundCachingDownloader(sourcesProvider: DefaultFaviconSourcesProvider())
    }

    override func tearDown() {
        downloader = nil

        super.tearDown()
    }

    // If this test fails... ask yourself why have you changed the salt?
    //  If it was intentional, then please update this test.
    func testSaltValueHasNotChanged() {
        XCTAssertEqual("DDGSalt:", FaviconHasher.salt)
    }

    func testWhenURLSavedNotStoredInPlainText() {
        downloader.noFaviconsFound(forDomain: "example.com")

        guard let domains: [String: TimeInterval] = UserDefaults.app.object(forKey: UserDefaultsWrapper<Any>.Key.notFoundCache.rawValue)
            as? [String: TimeInterval] else {
                XCTFail("Failed to load not found cache")
                return
        }
        
        XCTAssertEqual(1, domains.count)
        domains.forEach {
            XCTAssertEqual($0.key, "\(FaviconHasher.salt)example.com".sha256())
        }
        
    }
        
    func testWhenDomainMarkedAsDomainExpiresThenShouldDownload() {
        downloader.noFaviconsFound(forDomain: "example.com")
        
        let moreThanAWeekFromNow = Date().addingTimeInterval(60 * 60 * 24 * 8)
        XCTAssertTrue(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!, referenceDate: moreThanAWeekFromNow))
        
        guard let domains: [String: TimeInterval] = UserDefaults.app.object(forKey: UserDefaultsWrapper<Any>.Key.notFoundCache.rawValue)
            as? [String: TimeInterval] else {
                XCTFail("Failed to load not found cache")
                return
        }

        XCTAssertTrue(domains.isEmpty)
    }

    func testWhenMarkingDomainAsNotFoundThenShouldNotDownload() {
        downloader.noFaviconsFound(forDomain: "example.com")
        XCTAssertFalse(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!))
    }

    func testWhenDomainNotMarkedAsNotFoundThenShouldNotDownload() {
        XCTAssertTrue(downloader.shouldDownload(URL(string: "https://example.com/path/to/image.png")!))
    }

}

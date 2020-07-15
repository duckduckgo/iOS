//
//  FaviconSourcesProviderTests.swift
//  Core
//
//  Created by Chris Brind on 15/07/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class FaviconSourcesProviderTests: XCTestCase {
    
    func testWhenAdditionalSourcesRequestedThenFaviconsReturned() {
        let sources = DefaultFaviconSourcesProvider().additionalSources(forDomain: "www.example.com")
        XCTAssertEqual(2, sources.count)
        XCTAssertEqual("https://www.example.com/favicon.ico", sources[0])
        XCTAssertEqual("http://www.example.com/favicon.ico", sources[1])
    }
    
    func testWhenMainSourceRequestedThenAppleTouchIconReturned() {
        XCTAssertEqual("https://www.example.com/apple-touch-icon.png", DefaultFaviconSourcesProvider().mainSource(forDomain: "www.example.com"))
    }

}

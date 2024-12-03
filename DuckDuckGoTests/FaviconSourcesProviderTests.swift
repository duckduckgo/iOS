//
//  FaviconSourcesProviderTests.swift
//  Core
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

class FaviconSourcesProviderTests: XCTestCase {
    
    func testWhenAdditionalSourcesRequestedThenFaviconsReturned() {
        let sources = DefaultFaviconSourcesProvider().additionalSources(forDomain: "www.example.com")
        XCTAssertEqual(2, sources.count)
        XCTAssertEqual("https://www.example.com/favicon.ico", sources[0].absoluteString)
        XCTAssertEqual("http://www.example.com/favicon.ico", sources[1].absoluteString)
    }
    
    func testWhenMainSourceRequestedThenAppleTouchIconReturned() {
        XCTAssertEqual("https://www.example.com/apple-touch-icon.png",
                       DefaultFaviconSourcesProvider().mainSource(forDomain: "www.example.com")?.absoluteString)
    }

}

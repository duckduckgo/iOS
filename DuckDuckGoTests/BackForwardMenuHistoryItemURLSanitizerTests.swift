//
//  BackForwardMenuHistoryItemURLSanitizerTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import Foundation
import XCTest

@testable import DuckDuckGo

class BackForwardMenuHistoryItemURLSanitizerTests: XCTestCase {

    func testURLWithoutWWW() {
        let base = URL(string: "duck.com")!
        let expected = "duck.com"
        let result = BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(base)
        XCTAssertEqual(expected, result, "URL should be the same")
    }
    
    func testURLWithWWW() {
        let base = URL(string: "www.duck.com")!
        let expected = "duck.com"
        let result = BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(base)
        XCTAssertEqual(expected, result, "URL should be the same")
    }

    func testURLWithHTTPSAndWWW() {
        let base = URL(string: "https://www.duck.com")!
        let expected = "duck.com"
        let result = BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(base)
        XCTAssertEqual(expected, result, "URL should be the same")
    }
    
    func testURLWithHTTPSAndWWWAndEndingSlash() {
        let base = URL(string: "https://www.duck.com/")!
        let expected = "duck.com"
        let result = BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(base)
        XCTAssertEqual(expected, result, "URL should be the same")
    }
    
    func testURLWithExceedingNameSize() {
        let base = URL(string: "https://duckduckgo.com/?q=potato+and+potato&t=h_&ia=web")!
        let expected = "duckduckgo.com/?q=potato+..."
        let result = BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(base)
        XCTAssertEqual(expected, result, "URL should be the same")
    }
}

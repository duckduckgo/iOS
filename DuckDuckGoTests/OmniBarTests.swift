//
//  OmniBarTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class OmniBarTests: XCTestCase {
    
    func testDeemphasisePathDoesNotCrash() {
        
        _ = OmniBar.demphasisePath(forUrl: URL(string: "example.com")!)
        _ = OmniBar.demphasisePath(forUrl: URL(string: "a/b")!)

        testWith(prefix: "http:///") // crashes but we don't allow it anyway
        testWith(prefix: "http://localhost")
        testWith(prefix: "http://localhost/")
        testWith(prefix: "http://example.com")
        testWith(prefix: "http://example.com/")
        testWith(prefix: "http://example.com/path")
        testWith(prefix: "http://example.com/path/")
        testWith(prefix: "http://user:password@example.com/path/")
        
        testWith(prefix: "http://localhost:8080")
        testWith(prefix: "http://localhost:8080/")
        testWith(prefix: "http://example.com:8080")
        testWith(prefix: "http://example.com:8080/")
        testWith(prefix: "http://example.com:8080/path")
        testWith(prefix: "http://example.com:8080/path/")
        testWith(prefix: "http://user:password@example.com:8080/path/")

    }

    private func testWith(prefix: String) {
        
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: prefix)!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)#")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)#/fragment")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)?")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)?x=1")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)?x=1&")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)?x=1&y=1")!))
        XCTAssertNotNil(OmniBar.demphasisePath(forUrl: URL(string: "\(prefix)?x=1&y=1,2")!))
        
    }
    
}

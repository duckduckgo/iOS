//
//  HashExtensionTest.swift
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
@testable import Core

class HashExtensionTest: XCTestCase {
    
    func testWhenSha1DataIsCalledThenHashIsCorrect() {
        let result = "Hello World!".data(using: .utf8)?.sha1
        let expectedResult = "2ef7bde608ce5404e97d5f042f95f89f1c232871"
        XCTAssertEqual(expectedResult, result)
    }
    
    func testWhenSha1StringIsCalledThenHashIsCorrect() {
        let result = "Hello World!".sha1
        let expectedResult = "2ef7bde608ce5404e97d5f042f95f89f1c232871"
        XCTAssertEqual(expectedResult, result)
    }
    
    func testWhenSha256DataIsCalledThenHashIsCorrect() {
        let result = "Hello World!".data(using: .utf8)?.sha256
        let expectedResult = "7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069"
        XCTAssertEqual(expectedResult, result)
    }
}

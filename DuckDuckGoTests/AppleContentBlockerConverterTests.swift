//
//  AppleContentBlockerConverterTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import SwiftyJSON
@testable import Core

class AppleContentBlockerConverterTests: XCTestCase {
    
    private var testee = AppleContentBlockerConverter()

    func testWhenNoTrackersThenParserCreatesEmptyArray() {
        let result = try! testee.toJsonData(trackers: noTrackers())
        let json = try! JSON(data: result)
        XCTAssertNotNil(json.array)
        XCTAssertEqual(json.array!.count, 0)
    }
    
    func testWhenTrackersValidThenParserCreatesJsonArrayOfCorrectSize() {
        let result = try! testee.toJsonData(trackers: validTrackers())
        let json = try! JSON(data: result)
        XCTAssertNotNil(json.array)
        XCTAssertEqual(json.array!.count, 2)
    }
    
    func testWhenTrackersValidThenParserCreatesCorrectJsonData() {
        let result = try! testee.toJsonData(trackers: validTrackers())
        let resultString = String(data: result, encoding: .utf8)!
        let expectedString = "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"load-type\":[\"third-party\"],\"url-filter\":\"\\\\\\/\\\\\\/([A-Za-z0-9\\\\-]*.)facebook.gb(\\\\\\/.*)?\"}},{\"action\":{\"type\":\"block\"},\"trigger\":{\"load-type\":[\"third-party\"],\"url-filter\":\"\\\\\\/\\\\\\/([A-Za-z0-9\\\\-]*.)reddit.co.uk(\\\\\\/.*)?\"}}]"
        XCTAssertEqual(resultString, expectedString)
    }
    
    private func noTrackers() -> [Tracker] {
        return [Tracker]()
    }

    private func validTrackers() -> [Tracker] {
        return [
            Tracker(url: "facebook.gb", parentDomain: "facebook.com"),
            Tracker(url: "reddit.co.uk", parentDomain: "reddit.com")
        ]
    }
}

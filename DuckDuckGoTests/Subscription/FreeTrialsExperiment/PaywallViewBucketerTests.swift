//
//  PaywallViewBucketerTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class PaywallViewBucketerTests: XCTestCase {

    func testBucketForVariousValues() {
        // Given
        let bucketer = PaywallViewBucketer()

        // When & Then
        XCTAssertEqual(bucketer.bucket(for: 1), "1", "Given 1 view, Then it should map to '1'")
        XCTAssertEqual(bucketer.bucket(for: 5), "5", "Given 5 views, Then it should map to '5'")
        XCTAssertEqual(bucketer.bucket(for: 7), "6-10", "Given 7 views, Then it should map to '6-10'")
        XCTAssertEqual(bucketer.bucket(for: 15), "11-50", "Given 15 views, Then it should map to '11-50'")
        XCTAssertEqual(bucketer.bucket(for: 51), "51+", "Given 51 views, Then it should map to '51+'")
        XCTAssertEqual(bucketer.bucket(for: 100), "51+", "Given 100 views, Then it should map to '51+'")
    }

    /// Tests that values outside the defined ranges return "Unknown".
    func testBucketForOutOfRangeValues() {
        // Given
        let bucketer = PaywallViewBucketer()

        // When & Then
        XCTAssertEqual(bucketer.bucket(for: 0), "Unknown", "Given 0 views (out of range), Then it should map to 'Unknown'")
        XCTAssertEqual(bucketer.bucket(for: -10), "Unknown", "Given -10 views (negative value), Then it should map to 'Unknown'")
    }

    /// Tests edge cases at the boundary of each bucket range.
    func testBucketForEdgeCases() {
        // Given
        let bucketer = PaywallViewBucketer()

        // When & Then
        XCTAssertEqual(bucketer.bucket(for: 10), "6-10", "Given 10 views (upper boundary of '6-10'), Then it should map to '6-10'")
        XCTAssertEqual(bucketer.bucket(for: 50), "11-50", "Given 50 views (upper boundary of '11-50'), Then it should map to '11-50'")
    }
}

//
//  HomePageDisplayDailyPixelBucketTests.swift
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

final class HomePageDisplayDailyPixelBucketTests: XCTestCase {
    func testBucketValues() {
        let ranges = [
            0...0: "0",
            1...1: "1",
            2...3: "2-3",
            4...5: "4-5",
            6...10: "6-10",
            11...15: "11-15",
            16...25: "16-25"
        ]

        for range in ranges {
            for count in range.key {
                let bucket = HomePageDisplayDailyPixelBucket(favoritesCount: count)

                XCTAssertEqual(bucket.value, range.value)
            }
        }

        let bucket = HomePageDisplayDailyPixelBucket(favoritesCount: 60)

        XCTAssertEqual(bucket.value, ">25")
    }
}

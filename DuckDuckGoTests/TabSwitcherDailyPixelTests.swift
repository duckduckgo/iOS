//
//  TabSwitcherDailyPixelTests.swift
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
import Core
@testable import DuckDuckGo

final class TabSwitcherDailyPixelTests: XCTestCase {
    func testPopulatesParameters() {
        let tabs = [Tab(), Tab(), Tab()]
        let pixel = TabSwitcherOpenDailyPixel()

        let parameters = pixel.parameters(with: tabs)

        XCTAssertNotNil(parameters[ParameterName.tabCount])
        XCTAssertNotNil(parameters[ParameterName.newTabCount])
    }

    func testIncludesProperCountsForParameters() {
        let tabs = [Tab(), Tab(), .mock()]
        let pixel = TabSwitcherOpenDailyPixel()

        let parameters = pixel.parameters(with: tabs)

        XCTAssertEqual(parameters[ParameterName.tabCount], "2-5")
        XCTAssertEqual(parameters[ParameterName.newTabCount], "1-5")
    }

    func testBucketsAggregation() {
        let bucketValues = [
            1...1: "1",
            2...5: "2-5",
            6...10: "6-10",
            11...20: "11-20",
            21...40: "21-40",
            41...60: "41-60",
            61...80: "61-80",
            81...100: "81-100",
            101...125: "101-125",
            126...150: "126-150",
            151...250: "151-250",
            251...500: "251-500",
            501...504: "501+"]

        for bucket in bucketValues {
            for value in bucket.key {
                let tabs = Array(repeating: Tab.mock(), count: value)

                let countParameter = TabSwitcherOpenDailyPixel().parameters(with: tabs)[ParameterName.tabCount]

                XCTAssertEqual(countParameter, bucket.value)
            }
        }
    }

    func testNewTabBucketsAggregation() {
        let bucketValues = [
            0...0: "0",
            1...5: "1-5",
            6...10: "6-10",
            11...50: "11-50",
            51...60: "51+"]

        for bucket in bucketValues {
            for value in bucket.key {
                let tabs = Array(repeating: Tab(), count: value)

                let countParameter = TabSwitcherOpenDailyPixel().parameters(with: tabs)[ParameterName.newTabCount]

                XCTAssertEqual(countParameter, bucket.value)
            }
        }
    }
}

private extension Tab {
    static func mock() -> Tab {
        Tab(link: Link(title: nil, url: URL("https://example.com")!))
    }
}

private enum ParameterName {
    static let newTabCount = "new_tab_count"
    static let tabCount = "tab_count"
}

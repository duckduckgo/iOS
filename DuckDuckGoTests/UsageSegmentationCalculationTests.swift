//
//  UsageSegmentationCalculationTests.swift
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

import Foundation
import XCTest
@testable import Core

final class UsageSegmentationCalculationTests: XCTestCase {

    func testPerformance() throws {
        // Use this to suppress warning about code below not being run
        if ProcessInfo().arguments.contains("testing") {
            throw XCTSkip("Only used for performance testing and optimisation")
        }

        var atbs = [Atb]()
        for week in 100 ..< 800 {
            for day in 1...7 {
                atbs.append(Atb(version: "v\(week)-\(day)", updateVersion: nil))
            }
        }

        let installAtb = Atb(version: "v100-1", updateVersion: nil)
        let calculator = UsageSegmentationCalculator(installAtb: installAtb)

        XCTAssertEqual(atbs.count, 4900)

        measure {
            for atb in atbs {
                _ = calculator.processAtb(atb, forActivityType: .appUse)
            }
        }

    }

    func testCalculations() throws {
        let data = JsonTestDataLoader().fromJsonFile("mobile_segments_test_cases.json")
        XCTAssertNotNil(data)

        let cases = try JSONDecoder().decode([UsageSegmentationTestCase].self, from: data)

        // Ensure we've read the file correctly and is the expected test cases.
        XCTAssertEqual(cases.count, 92)
        XCTAssertEqual(cases.reduce(0, { partialResult, testCase in
            return partialResult + testCase.results.count
        }), 378)

        for index in 0 ..< cases.count {
            assertTestCase(cases[index], caseIndex: index)
        }
    }

    private func assertTestCase(_ testCase: UsageSegmentationTestCase, caseIndex: Int) {

        guard testCase.client.usage.count == testCase.results.count else {
            XCTFail("Mismatching usage and results")
            return
        }

        let installAtb = Atb(version: testCase.client.atb, updateVersion: nil)
        let calculator = UsageSegmentationCalculator(installAtb: installAtb)
        for index in 0 ..< testCase.client.usage.count {
            let usage = testCase.client.usage[index]
            let expectedResult = testCase.results[index]

            let atb = Atb(version: usage, updateVersion: nil)
            let actualResult = calculator.processAtb(atb, forActivityType: UsageActivityType(rawValue: testCase.client.activity_type)!)

            if let uri = expectedResult.pixel_uri,
               let components = URLComponents(string: uri),
               let queryItems = components.queryItems {
                assertActualResultMatchesQueryItems(queryItems, actualResult: actualResult, caseIndex: caseIndex, usageIndex: index)
            } else if actualResult != nil {
                XCTFail("case index \(caseIndex).\(index) returned unexpected result")
            }
        }
    }

    private func assertActualResultMatchesQueryItems(_ queryItems: [URLQueryItem], actualResult: [String: String]?, caseIndex: Int, usageIndex: Int) {
        guard let actualResult else {
            XCTFail("Actual result is nil")
            return
        }

        guard !queryItems.isEmpty else {
            XCTFail("Expected test parameters missing")
            return
        }

        for item in queryItems {
            // These get added by the pixel framework and we're using a mock, so skip them for the test
            guard item.name != "test",
                  item.name != "appVersion" else { continue }

            XCTAssertEqual(actualResult[item.name], item.value, "\(caseIndex)-\(usageIndex) \(item.name)")
        }
    }

    // For pragmatism sake just mimic the json directly.
    // swiftlint:disable identifier_name nesting
    struct UsageSegmentationTestCase: Decodable {

        struct Client: Decodable {
            let atb: String
            let activity_type: String
            let usage: [String]
        }

        struct Result: Decodable {
            let set_atb: String
            let pixel_uri: String?
        }

        let client: Client
        let results: [Result]

    }
    // swiftlint:enable identifier_name nesting

}

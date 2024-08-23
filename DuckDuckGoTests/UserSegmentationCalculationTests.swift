//
//  UserSegmentationCalculationTests.swift
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

class UsageSegmentationCalculationTests: XCTestCase {

    var atbs: [Atb] = []

    override func tearDown() {
        super.tearDown()
        PixelFiringMock.tearDown()
    }

    func testCalculations() throws {
        let data = JsonTestDataLoader().fromJsonFile("mobile_segments_test_cases.json")
        XCTAssertNotNil(data)

        let cases = try JSONDecoder().decode([UsageSegmentationTestCase].self, from: data)
        for index in 0 ..< cases.count {
            assertTestCase(cases[index], caseIndex: index)
        }
    }

    private func assertTestCase(_ testCase: UsageSegmentationTestCase, caseIndex: Int) {

        guard testCase.client.usage.count == testCase.results.count else {
            XCTFail("Mismatching usage and results")
            return
        }

        // Reset the storage
        atbs = []

        let sut = UsageSegmentation(pixelFiring: PixelFiringMock.self, storage: self)

        let installAtb = Atb(version: testCase.client.atb, updateVersion: nil)
        for index in 0 ..< testCase.client.usage.count {
            // Each usage *could* fire a pixel, so clear the last one
            PixelFiringMock.tearDown()

            let usage = testCase.client.usage[index]
            let result = testCase.results[index]

            let atb = Atb(version: usage, updateVersion: nil)
            sut.processATB(atb, withInstallAtb: installAtb, andActivityType: UsageActivityType(rawValue: testCase.client.activity_type)!)

            XCTAssertEqual(atb.version, result.set_atb)

            if let uri = result.pixel_uri,
               let components = URLComponents(string: uri),
               let queryItems = components.queryItems {
                assertLastDailyPixelHasExpectedParameters(queryItems, caseIndex: caseIndex, usageIndex: index)
            } else if PixelFiringMock.lastDailyPixelInfo != nil {
                XCTFail("case index \(caseIndex) - result \(index) unexpected pixel fired for client \(testCase.client)")
            }
        }
    }

    private func assertLastDailyPixelHasExpectedParameters(_ queryItems: [URLQueryItem], caseIndex: Int, usageIndex: Int) {
        guard let params = PixelFiringMock.lastDailyPixelInfo?.params else {
            XCTFail("Fired pixel parameters missing")
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

            XCTAssertEqual(params[item.name], item.value, "\(caseIndex)-\(usageIndex) \(item.name)")
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

extension UsageSegmentationCalculationTests: UsageSegmentationStoring {

}

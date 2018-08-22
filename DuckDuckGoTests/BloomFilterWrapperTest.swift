//
//  BloomFilterWrapperTest.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class BloomFilterWrapperTest: XCTestCase {
    
    struct Constants {
        static let filterElementCount = 1000
        static let additionalTestDataElementCount = 1000
        static let targetErrorRate = 0.001
        static let acceptableErrorRate = Constants.targetErrorRate * 5
    }
    
    func testWhenBloomFilterEmptyThenContainsIsFalse() {
        let testee = BloomFilterWrapper(totalItems: Int32(Constants.filterElementCount), errorRate: Constants.targetErrorRate)!
        XCTAssertFalse(testee.contains("abc"))
    }
    
    func testWhenBloomFilterContainsElementThenContainsIsTrue() {
        let testee = BloomFilterWrapper(totalItems: Int32(Constants.filterElementCount), errorRate: Constants.targetErrorRate)!
        testee.add("abc")
        XCTAssertTrue(testee.contains("abc"))
    }
    
    func testWhenBloomFilterContainsItemsThenLookupResultsAreWithinRange() {
        let bloomData = createRandomStrings(count: Constants.filterElementCount)
        let testData = bloomData + createRandomStrings(count: Constants.additionalTestDataElementCount)
        
        let testee = BloomFilterWrapper(totalItems: Int32(bloomData.count), errorRate: Constants.targetErrorRate)!
        bloomData.forEach { testee.add($0) }
        
        var falsePositives = 0, truePositives = 0, falseNegatives = 0, trueNegatives = 0
        for element in testData {
            let result = testee.contains(element)
            if bloomData.contains(element) && !result { falseNegatives += 1 }
            if !bloomData.contains(element) && result { falsePositives += 1 }
            if !bloomData.contains(element) && !result { trueNegatives += 1 }
            if bloomData.contains(element) && result { truePositives += 1 }
        }
        
        let errorRate = Double(falsePositives) / Double(testData.count)
        XCTAssertEqual(0, falseNegatives)
        XCTAssertEqual(bloomData.count, truePositives)
        XCTAssertTrue(trueNegatives <= testData.count - bloomData.count)
        XCTAssertTrue(errorRate <= Constants.acceptableErrorRate)
    }
    
    private func createRandomStrings(count: Int) -> [String] {
        var list = [String]()
        for _ in 0..<count {
            list.append(UUID.init().uuidString)
        }
        return list
    }
}

//
//  BloomFilterWrapperTest.swift
//  DuckDuckGo
//
//  Created by duckduckgo on 21/08/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest
@testable import Core

class BloomFilterWrapperTest: XCTestCase {
    
    struct Constants {
        static let filterElementCount = 5000
        static let additionalTestDataElementCount = 5000
        static let targetErrorRate = 0.001
        static let acceptableErrorRate = Constants.targetErrorRate * 2
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

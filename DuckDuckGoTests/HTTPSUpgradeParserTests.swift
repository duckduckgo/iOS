//
//  HTTPSUpgradeParserTests.swift
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

import XCTest
@testable import Core

class HTTPSUpgradeParserTests: XCTestCase {
    
    func testWhenExcludedDomainsJSONIsUnexpectedThenTypeMismatchErrorThrown() {
        let data = JsonTestDataLoader().unexpected()
        XCTAssertThrowsError(try HTTPSUpgradeParser.convertExcludedDomainsData(data)) { error in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenExcludedDomainsJSONIsInvalidThenInvalidJsonErrorThrown() {
        let data = JsonTestDataLoader().invalid()
        XCTAssertThrowsError(try HTTPSUpgradeParser.convertExcludedDomainsData(data)) { error in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenExcludedDomainsJSONIsValidThenDomainsReturned() {
        let data = JsonTestDataLoader().fromJsonFile("MockFiles/https_excluded_domains.json")
        let result = try? HTTPSUpgradeParser.convertExcludedDomainsData(data)
        XCTAssertEqual(Set<String>(["www.example.com", "example.com", "test.com", "anothertest.com"]), Set<String>(result!))
    }
    
    func testWhenBloomFilterSpecificationJSONIsUnexpectedThenTypeMismatchErrorThrown() {
        let data = JsonTestDataLoader().unexpected()
        XCTAssertThrowsError(try HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data), "") { error in
            XCTAssertEqual(error.localizedDescription, JsonError.typeMismatch.localizedDescription)
        }
    }
    
    func testWhenBloomFilterSpecificationJSONIsInvalidThenInvalidJsonErrorThrown() {
        let data = JsonTestDataLoader().invalid()
        XCTAssertThrowsError(try HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data)) { error in
            XCTAssertEqual(error.localizedDescription, JsonError.invalidJson.localizedDescription)
        }
    }
    
    func testWhenBloomFilterSpecificationIsValidThenSpecificationReturned() {
        let data = JsonTestDataLoader().fromJsonFile("MockFiles/https_bloom_spec.json")
        let result = try? HTTPSUpgradeParser.convertBloomFilterSpecification(fromJSONData: data)
        XCTAssertNotNil(result)
        XCTAssertEqual(1250000, result?.bitCount)
        XCTAssertEqual(0.00001, result?.errorRate)
        XCTAssertEqual(10000000, result?.totalEntries)
        XCTAssertEqual("4d3941604", result?.sha256)
    }
}

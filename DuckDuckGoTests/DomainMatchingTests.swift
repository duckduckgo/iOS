//
//  DomainMatchingTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
@testable import TrackerRadarKit
@testable import Core
import Foundation
import os.log

struct RefTests: Decodable {
    
    struct Test: Decodable {
        
        let name: String
        let siteURL: String
        let requestURL: String
        let requestType: String
        let expectAction: String?
        let exceptPlatforms: [String]?
        
    }
    
    struct DomainTests: Decodable {
        
        let name: String
        let desc: String
        let tests: [Test]
        
    }
    
    let domainTests: DomainTests
}

class DomainMatchingTests: XCTestCase {
    private var data = JsonTestDataLoader()

    func testDomainMatchingRules() throws {
        let trackerJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_radar_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/domain_matching_tests.json")

        let trackerData = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)
        
        let refTests = try JSONDecoder().decode(RefTests.self, from: testJSON)
        let tests = refTests.domainTests.tests

        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: ["duckduckgo.com"],
                andTemporaryUnprotectedDomains: [])

        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                print("!!SKIPPING TEST: %s", test.name)
                continue
            }
            print("TEST: %s", test.name)
            let requestURL = URL(string: test.requestURL)
            let siteURL = URL(string: test.siteURL)
            let requestType = ContentBlockerRulesBuilder.resourceMapping[test.requestType]
            let rule = rules.matchURL(url: requestURL!, topLevel: siteURL!, resourceType: requestType!)
            let result = rule?.action
            if test.expectAction == "block" {
                XCTAssertEqual(result, .block())
            } else {
                XCTAssertTrue(result == nil || result == .ignorePreviousRules())
            }
        }
    }
}

extension Array where Element == ContentBlockerRule {
    func matchURL(url: URL, topLevel: URL, resourceType: ContentBlockerRule.Trigger.ResourceType) -> ContentBlockerRule? {
        var result: ContentBlockerRule?
        for rule in self where rule.matches(resourceUrl: url, onPageWithUrl: topLevel, ofType: resourceType) {
            result = rule
        }
        
        return result
    }
}

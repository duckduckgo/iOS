//
//  DomainMatchingReportTests.swift
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
import BrowserServicesKit
import Common

class DomainMatchingReportTests: XCTestCase {
    private var data = JsonTestDataLoader()

    func testRegularDomainMatchingRules() throws {
        let trackerJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_radar_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/domain_matching_tests.json")

        let trackerData = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)
        
        let refTests = try JSONDecoder().decode(RefTests.self, from: testJSON)
        let tests = refTests.domainTests.tests
        
        let resolver = TrackerResolver(tds: trackerData, unprotectedSites: [], tempList: [], tld: TLD())

        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                os_log("!!SKIPPING TEST: %s", test.name)
                continue
            }
            os_log("TEST: %s", test.name)
            
            let tracker = resolver.trackerFromUrl(test.requestURL,
                                                  pageUrlString: test.siteURL,
                                                  resourceType: test.requestType,
                                                  potentiallyBlocked: true)
            
            if test.expectAction == "block" {
                XCTAssertNotNil(tracker)
                XCTAssert(tracker?.isBlocked ?? false)
            } else if test.expectAction == "ignore" {
                XCTAssertFalse(tracker?.isBlocked ?? false)
            } else {
                XCTAssert(tracker?.isBlocked ?? true)
            }
        }
    }
}

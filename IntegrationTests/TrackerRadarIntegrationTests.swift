//
//  TrackerRadarIntegrationTests.swift
//  AtbIntegrationTests
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class TrackerRadarIntegrationTests: XCTestCase {

    func test() throws {

        let url = AppUrls(statisticsStore: MockStatisticsStore()).trackerDataSet
        let data = try Data(contentsOf: url)
        let trackerData = try JSONDecoder().decode(TrackerData.self, from: data)
        let dataManager = TrackerDataManager(trackerData: trackerData)

        dataManager.assertIsMajorTracker(domain: "google.com")
        dataManager.assertIsMajorTracker(domain: "facebook.com")
        dataManager.assertEntityAndDomainLookups()
        dataManager.assertEntitiesHaveNames()

    }

}

extension TrackerDataManager {

    func assertIsMajorTracker(domain: String, file: StaticString = #file, line: UInt = #line) {
        let entity = findEntity(forHost: domain)
        XCTAssertNotNil(entity, "no entity found for domain \(domain)", file: file, line: line)
        XCTAssertGreaterThan(entity?.prevalence ?? 0, SiteRating.Constants.majorNetworkPrevalence, file: file, line: line)
    }

    func assertEntityAndDomainLookups(file: StaticString = #file, line: UInt = #line) {
        trackerData.domains.forEach { domain, entityName in
            let entityFromHost = findEntity(forHost: domain)
            let entityFromName = findEntity(byName: entityName)
            XCTAssertNotNil(entityFromHost, file: file, line: line)
            XCTAssertNotNil(entityFromName, file: file, line: line)
            XCTAssertEqual(entityFromHost, entityFromName, file: file, line: line)
        }
    }

    func assertEntitiesHaveNames(file: StaticString = #file, line: UInt = #line) {
        trackerData.entities.keys.forEach { entityName in
            XCTAssertNotNil(entityName, file: file, line: line)
            XCTAssertNotEqual("", entityName, file: file, line: line)
        }
    }

}

//
//  AtbServerTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import BrowserServicesKit

class AtbServerTests: XCTestCase {
    
    var loader: StatisticsLoader!
    var store: MockStatisticsStore!
    
    static var defaultSessionConfig = URLSessionConfiguration.default
    var original: Method!
    var new: Method!
    
    override func setUp() {
        super.setUp()

        store = MockStatisticsStore()
        loader = StatisticsLoader(statisticsStore: store)
        
    }
     
    func testExtiCall() {

        let waitForCompletion = expectation(description: "wait for completion")
        loader.load {
            waitForCompletion.fulfill()
        }
        
        wait(for: [waitForCompletion], timeout: 5.0)
        
        XCTAssertNotNil(store.atb)
    }
    
    func testApphRetentionAtb() {

        store.atb = "v117-2"
        store.appRetentionAtb = "v117-2"

        let waitForCompletion = expectation(description: "wait for completion")
        loader.refreshAppRetentionAtb {
            waitForCompletion.fulfill()
        }
        
        wait(for: [waitForCompletion], timeout: 5.0)

        XCTAssertNotNil(store.appRetentionAtb)
        XCTAssertNotEqual(store.atb, store.appRetentionAtb)
    }
    
    func testSearchRetentionAtb() {
        
        store.atb = "v117-2"
        store.searchRetentionAtb = "v117-2"
        
        let waitForCompletion = expectation(description: "wait for completion")
        loader.refreshSearchRetentionAtb {
            waitForCompletion.fulfill()
        }
        
        wait(for: [waitForCompletion], timeout: 5.0)
        
        XCTAssertNotNil(store.searchRetentionAtb)
        XCTAssertNotEqual(store.atb, store.searchRetentionAtb)
    }

    func testWhenAtbIsOldThenCohortIsGeneralizedForAppRetention() {

        store.atb = "v117-2"
        store.appRetentionAtb = "v117-2"

        let waitForCompletion = expectation(description: "wait for completion")
        loader.refreshAppRetentionAtb {
            waitForCompletion.fulfill()
        }

        wait(for: [waitForCompletion], timeout: 5.0)

        XCTAssertNotNil(store.appRetentionAtb)
        XCTAssertEqual(store.atb, "v117-1")
    }

    func testWhenAtbIsOldThenCohortIsGeneralizedForSearchRetention() {

        store.atb = "v117-2"
        store.searchRetentionAtb = "v117-2"

        let waitForCompletion = expectation(description: "wait for completion")
        loader.refreshSearchRetentionAtb {
            waitForCompletion.fulfill()
        }

        wait(for: [waitForCompletion], timeout: 5.0)

        XCTAssertNotNil(store.searchRetentionAtb)
        XCTAssertEqual(store.atb, "v117-1")
    }

}

class MockStatisticsStore: StatisticsStore {
    
    var hasInstallStatistics: Bool = false
    
    var installDate: Date?
    
    var atb: String?
    
    var appRetentionAtb: String?
    
    var searchRetentionAtb: String?

    var variant: String?
}

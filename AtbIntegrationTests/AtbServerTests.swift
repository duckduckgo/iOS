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
import Alamofire
@testable import Core

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
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExtiCall() {
        
        let waitForCompletion = expectation(description: "wait for completion")
        loader.refreshRetentionAtb {
            waitForCompletion.fulfill()
        }
        
        wait(for: [waitForCompletion], timeout: 5.0)
        
        XCTAssertNotNil(store.atb)
    }
    
}

class MockStatisticsStore: StatisticsStore {
    
    var hasInstallStatistics: Bool = false
    
    var atb: String?
    
    var retentionAtb: String?
    
    var variant: String?
    
    var atbWithVariant: String?
    
}

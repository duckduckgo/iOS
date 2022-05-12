//
//  EmbeddedTrackerDataTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import TrackerRadarKit
import BrowserServicesKit
import WebKit
@testable import Core
@testable import DuckDuckGo

class EmbeddedTrackerDataTests: XCTestCase {
    
    func testWhenEmbeddedDataIsUpdatedThenUpdateSHAAndEtag() throws {
        
        let hash = try Data(contentsOf: AppTrackerDataSetProvider.embeddedUrl).sha256
    print(hash)
        XCTAssertEqual(hash, AppTrackerDataSetProvider.Constants.embeddedDataSHA, "Error: please update SHA and ETag when changing embedded TDS")
    }
    
    func testWhenEmbeddedDataIsPresentThenWeCanUseItToLookupTrackers() {
        let manager = TrackerDataManager(etag: nil,
                                         data: nil,
                                         embeddedDataProvider: AppTrackerDataSetProvider())
        
        XCTAssertEqual(manager.trackerData.findEntity(forHost: "www.google.com")?.displayName, "Google")
    }
    
    func testWhenEmbeddedDataIsCompiledThenThereIsNoError() throws {
        
        let embeddedData = try Data(contentsOf: AppTrackerDataSetProvider.embeddedUrl)
        let tds = try JSONDecoder().decode(TrackerData.self, from: embeddedData)
        let builder = ContentBlockerRulesBuilder(trackerData: tds)
        
        let rules = builder.buildRules(withExceptions: [],
                                       andTemporaryUnprotectedDomains: [],
                                       andTrackerAllowlist: [])
        
        let data = try JSONEncoder().encode(rules)
        let ruleList = String(data: data, encoding: .utf8)!
        
        let identifier = UUID().uuidString
        
        let compiled = expectation(description: "Rules compiled")
        
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: identifier,
                                                                encodedContentRuleList: ruleList) { result, error in
            XCTAssertNotNil(result)
            XCTAssertNil(error)
            compiled.fulfill()
        }
        
        wait(for: [compiled], timeout: 30.0)
        
        let removed = expectation(description: "Rules removed")
        
        WKContentRuleListStore.default().removeContentRuleList(forIdentifier: identifier) { _ in
            removed.fulfill()
        }
        
        wait(for: [removed], timeout: 5.0)
    }
}

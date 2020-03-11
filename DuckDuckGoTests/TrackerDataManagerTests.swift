//
//  TrackerDataManagerTests.swift
//  Core
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class TrackerDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .trackerDataSet))
    }
    
    func testWhenReloadCalledInitiallyThenDataSetIsEmbedded() {
        XCTAssertEqual(TrackerDataManager.shared.reload(etag: nil), .embedded)
    }

    func testFindTrackerByUrl() {
        let tracker = TrackerDataManager.shared.findTracker(forUrl: "http://googletagmanager.com")
        XCTAssertNotNil(tracker)
        XCTAssertEqual("Google", tracker?.owner?.displayName)
    }
    
    func testFindEntityByName() {
        let entity = TrackerDataManager.shared.findEntity(byName: "Google LLC")
        XCTAssertNotNil(entity)
        XCTAssertEqual("Google", entity?.displayName)
    }
    
    func testFindEntityForHost() {
        let entity = TrackerDataManager.shared.findEntity(forHost: "www.google.com")
        XCTAssertNotNil(entity)
        XCTAssertEqual("Google", entity?.displayName)
    }
    
    // swiftlint:disable function_body_length
    func testWhenDownloadedDataAvailableThenReloadUsesIt() {

        let update = """
        {
          "trackers": {
            "notreal.io": {
              "domain": "notreal.io",
              "default": "block",
              "owner": {
                "name": "CleverDATA LLC",
                "displayName": "CleverDATA",
                "privacyPolicy": "https://hermann.ai/privacy-en",
                "url": "http://hermann.ai"
              },
              "source": [
                "DDG"
              ],
              "prevalence": 0.002,
              "fingerprinting": 0,
              "cookies": 0.002,
              "performance": {
                "time": 1,
                "size": 1,
                "cpu": 1,
                "cache": 3
              },
              "categories": [
                "Ad Motivated Tracking",
                "Advertising",
                "Analytics",
                "Third-Party Analytics Marketing"
              ]
            }
          },
          "entities": {
            "Not Real": {
              "domains": [
                "notreal.io"
              ],
              "displayName": "Not Real",
              "prevalence": 0.666
            }
          },
          "domains": {
            "notreal.io": "Not Real"
          }
        }
        """

        XCTAssertTrue(FileStore().persist(update.data(using: .utf8), forConfiguration: .trackerDataSet))
        XCTAssertEqual(TrackerDataManager.shared.etag, nil)
        XCTAssertEqual(TrackerDataManager.shared.reload(etag: "new etag"), .downloaded)
        XCTAssertEqual(TrackerDataManager.shared.etag, "new etag")
        XCTAssertNil(TrackerDataManager.shared.findEntity(byName: "Google LLC"))
        XCTAssertNotNil(TrackerDataManager.shared.findEntity(byName: "Not Real"))

    }
    // swiftlint:enable function_body_length
}

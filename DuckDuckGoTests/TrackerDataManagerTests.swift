//
//  TrackerDataManagerTests.swift
//  Core
//
//  Created by Chris Brind on 26/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import XCTest
@testable import Core

class TrackerDataManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: FileStore().persistenceLocation(forConfiguration: .trackerDataSet))
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
        TrackerDataManager.shared.reload()
        XCTAssertNil(TrackerDataManager.shared.findEntity(byName: "Google LLC"))
        XCTAssertNotNil(TrackerDataManager.shared.findEntity(byName: "Not Real"))

    }
    // swiftlint:enable function_body_length
}

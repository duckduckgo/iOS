//
//  ContentBlockerRulesManagerTests.swift
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
@testable import Core
import TrackerRadarKit

// swiftlint:disable file_length

class ContentBlockerRulesManagerTests: XCTestCase {
    
    static let validRules = """
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
    
    static let invalidRules = """
    {
      "trackers": {
        "notreal.io": {
          "domain": "this is broken",
          "default": "block",
          "owner": {
            "name": "CleverDATA LLC",
            "displayName": "CleverDATA",
            "privacyPolicy": "https://hermann.ai/privacy-en",
            "url": "test test"
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
          ],
          "rules": [
            {
              "rule": "something",
              "exceptions": {
                "domains": [
                  "example.com",
                   "Broken Ltd."
                ]
              }
            }
          ]
        }
      },
      "entities": {
        "Not Real": {
          "domains": [
            "example.com",
            "Broken Ltd.",
            "example.com"
          ],
          "properties": [
            "broken Ltd.",
            "example.net"
          ],
          "displayName": "Not Real",
          "prevalence": 0.666
        }
      },
      "domains": {
        "exampleö.com": "Example",
        "Broken Ltd.": "Not Real",
        "TEsT~~.com": "Example",
        "😉.com": "T"
      }
    }
    """
    
    let validTempSites = ["example.com"]
    
    let invalidTempSites = ["This is not valid.. ."]
    
    static var fakeEmbeddedDataSet: TrackerDataManager.DataSet!
    
    override class func setUp() {
        super.setUp()
        
        fakeEmbeddedDataSet = makeDataSet(tds: validRules, etag: "\"\(UUID().uuidString)\"")
    }
    
    static func makeDataSet(tds: String) -> TrackerDataManager.DataSet {
        return makeDataSet(tds: tds, etag: makeEtag())
    }
    
    static func makeDataSet(tds: String, etag: String) -> TrackerDataManager.DataSet {
        let data = tds.data(using: .utf8)!
        let decoded = try? JSONDecoder().decode(TrackerData.self, from: data)
        return (decoded!, etag)
    }
    
    static func makeEtag() -> String {
        return "\"\(UUID().uuidString)\""
    }
    
}

class ContentBlockerRulesManagerLoadingTests: ContentBlockerRulesManagerTests {
    
    func test_ValidTDS_NoTempList_NoUnprotectedSites() {
        
        let mockSource = MockContentBlockerRulesSource(trackerData: (Self.fakeEmbeddedDataSet.tds, Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.trackerData?.etag)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.trackerData?.etag ?? "") + "\"\"")
    }
    
    func test_InvalidTDS_NoTempList_NoUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.invalidRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.embeddedTrackerData.etag)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + "\"\"")
    }
    
    func test_ValidTDS_ValidTempList_NoUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertNotNil(cbrm.currentRules?.etag)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.trackerData?.etag)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.trackerData?.etag ?? "") + mockSource.tempListEtag)
        
    }
    
    func test_InvalidTDS_ValidTempList_NoUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.invalidRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertNotNil(cbrm.currentRules?.etag)
        
        XCTAssertNotNil(cbrm.etagForFailedTDSCompilation)
        XCTAssertEqual(cbrm.etagForFailedTDSCompilation, mockSource.trackerData?.etag)
        
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.embeddedTrackerData.etag)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + mockSource.tempListEtag)
    }
    
    func test_ValidTDS_InvalidTempList_NoUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = invalidTempSites
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertNotNil(cbrm.currentRules?.etag)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.embeddedTrackerData.etag)
        
        // TDS is also marked as invalid to simplify flow
        XCTAssertNotNil(cbrm.etagForFailedTDSCompilation)
        XCTAssertEqual(cbrm.etagForFailedTDSCompilation, mockSource.trackerData?.etag)
        
        XCTAssertNotNil(cbrm.etagForFailedTempListCompilation)
        XCTAssertEqual(cbrm.etagForFailedTempListCompilation, mockSource.tempListEtag)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + "\"\"")
    }
    
    func test_ValidTDS_ValidTempList_ValidUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        mockSource.unprotectedSites = ["example.com"]
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertNotNil(cbrm.currentRules?.etag)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.trackerData?.etag)
        
        XCTAssertNil(cbrm.etagForFailedTDSCompilation)
        XCTAssertNil(cbrm.etagForFailedTempListCompilation)
        XCTAssertNil(cbrm.hashForFailedUnprotectedSitesCompilation)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue,
                       (mockSource.trackerData?.etag ?? "\"\"") + mockSource.tempListEtag + mockSource.unprotectedSitesHash)
    }
    
    func test_ValidTDS_ValidTempList_BrokenUnprotectedSites() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        mockSource.unprotectedSites = ["broken site Ltd. . 😉.com"]
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let exp = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                              object: cbrm,
                              handler: nil)

        wait(for: [exp], timeout: 15.0)
        
        XCTAssertNotNil(cbrm.currentRules)
        XCTAssertNotNil(cbrm.currentRules?.etag)
        XCTAssertEqual(cbrm.currentRules?.etag, mockSource.embeddedTrackerData.etag)
        
        // TDS is also marked as invalid to simplify flow
        XCTAssertNotNil(cbrm.etagForFailedTDSCompilation)
        XCTAssertEqual(cbrm.etagForFailedTDSCompilation, mockSource.trackerData?.etag)
        
        XCTAssertNotNil(cbrm.etagForFailedTempListCompilation)
        XCTAssertEqual(cbrm.etagForFailedTempListCompilation, mockSource.tempListEtag)
        
        XCTAssertNotNil(cbrm.hashForFailedUnprotectedSitesCompilation)
        XCTAssertEqual(cbrm.hashForFailedUnprotectedSitesCompilation, mockSource.unprotectedSitesHash)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + "\"\"")
    }
}

class ContentBlockerRulesManagerUpdatingTests: ContentBlockerRulesManagerTests {
    
    func test_InvalidTDS_BeingFixed() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.invalidRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let initialLoading = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                         object: cbrm,
                                         handler: nil)
        
        wait(for: [initialLoading], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + mockSource.tempListEtag)
        
        mockSource.trackerData = Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag())
        
        let identifier = cbrm.currentRules?.identifier
        
        cbrm.recompile()
        let updating = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                   object: cbrm,
                                   handler: nil)
        
        wait(for: [updating], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue,
                       (mockSource.trackerData?.etag ?? "\"\"") + mockSource.tempListEtag)
        
        if let oldId = identifier, let newId = cbrm.currentRules?.identifier {
            let diff = oldId.compare(with: newId)
            
            XCTAssert(diff.contains(.tdsEtag))
            XCTAssertFalse(diff.contains(.tempListEtag))
            XCTAssertFalse(diff.contains(.unprotectedSites))
        } else {
            XCTFail("Missing identifiers")
        }
    }
    
    func test_InvalidTempList_BeingFixed() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = invalidTempSites
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let initialLoading = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                         object: cbrm,
                                         handler: nil)
        
        wait(for: [initialLoading], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + "\"\"")
        
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        
        let identifier = cbrm.currentRules?.identifier
        
        cbrm.recompile()
        let updating = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                   object: cbrm,
                                   handler: nil)
        
        wait(for: [updating], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue,
                       (mockSource.trackerData?.etag ?? "\"\"") + mockSource.tempListEtag)
        
        if let oldId = identifier, let newId = cbrm.currentRules?.identifier {
            let diff = oldId.compare(with: newId)
            
            XCTAssert(diff.contains(.tdsEtag))
            XCTAssert(diff.contains(.tempListEtag))
            XCTAssertFalse(diff.contains(.unprotectedSites))
        } else {
            XCTFail("Missing identifiers")
        }
    }
    
    func test_InvalidUnprotectedSites_BeingFixed() {

        let mockSource = MockContentBlockerRulesSource(trackerData: Self.makeDataSet(tds: Self.validRules, etag: Self.makeEtag()),
                                                       embeddedTrackerData: Self.fakeEmbeddedDataSet)
        mockSource.tempListEtag = Self.makeEtag()
        mockSource.tempList = validTempSites
        mockSource.unprotectedSites = ["broken site Ltd. . 😉.com"]
        
        XCTAssertNotEqual(mockSource.trackerData?.etag, mockSource.embeddedTrackerData.etag)
        
        let cbrm = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)
        
        let initialLoading = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                         object: cbrm,
                                         handler: nil)
        
        wait(for: [initialLoading], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue, (mockSource.embeddedTrackerData.etag) + "\"\"")
        
        mockSource.unprotectedSites = ["example.com"]
        
        let identifier = cbrm.currentRules?.identifier
        
        cbrm.recompile()
        let updating = expectation(forNotification: ContentBlockerProtectionChangedNotification.name,
                                   object: cbrm,
                                   handler: nil)
        
        wait(for: [updating], timeout: 15.0)
        
        XCTAssertEqual(cbrm.currentRules?.identifier.stringValue,
                       (mockSource.trackerData?.etag ?? "\"\"") + mockSource.tempListEtag + mockSource.unprotectedSitesHash)
        
        if let oldId = identifier, let newId = cbrm.currentRules?.identifier {
            let diff = oldId.compare(with: newId)
            
            XCTAssert(diff.contains(.tdsEtag))
            XCTAssert(diff.contains(.tempListEtag))
            XCTAssert(diff.contains(.unprotectedSites))
        } else {
            XCTFail("Missing identifiers")
        }
    }
}

class MockContentBlockerRulesSource: ContentBlockerRulesSource {
    
    var trackerData: TrackerDataManager.DataSet?
    var embeddedTrackerData: TrackerDataManager.DataSet

    var tempListEtag: String = ""
    var tempList: [String] = []
    var unprotectedSites: [String] = []
    
    init(trackerData: TrackerDataManager.DataSet?, embeddedTrackerData: TrackerDataManager.DataSet) {
        self.trackerData = trackerData
        self.embeddedTrackerData = embeddedTrackerData
    }
    
    var unprotectedSitesHash: String {
        return ContentBlockerRulesIdentifier.hash(domains: unprotectedSites)
    }
    
}
// swiftlint:enable file_length

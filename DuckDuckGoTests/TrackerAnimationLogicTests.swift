//
//  TrackerAnimationLogicTests.swift
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

import Foundation
import XCTest
import TrackerRadarKit
import BrowserServicesKit
import ContentBlocking
import PrivacyDashboard
@testable import Core
@testable import DuckDuckGo

class TrackerAnimationLogicTests: XCTestCase {

    static let pageURL = URL(string: "https://example.com")!
    
    func testAnimationLogicToAnimateTrackersIfAnyBlocked() {
        let trackerInfo = makeBlockedTrackerInfo(pageURL: Self.pageURL)
        XCTAssertTrue(TrackerAnimationLogic.shouldAnimateTrackers(for: trackerInfo))
    }
    
    func testAnimationLogicNotToAnimateTrackersIfNoneBlocked() {
        let trackerInfo = makeNonBlockedTrackerInfo(pageURL: Self.pageURL)
        XCTAssertFalse(TrackerAnimationLogic.shouldAnimateTrackers(for: trackerInfo))
    }
    
    private func makeBlockedTrackerInfo(pageURL: URL) -> TrackerInfo {
        var trackerInfo = TrackerInfo()
        
        let entity = Entity(displayName: "E", domains: [], prevalence: 1.0)
        let trackers = [DetectedRequest(url: "a",
                                        eTLDplus1: nil,
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .ownedByFirstParty),
                                        pageUrl: pageURL.absoluteString),
                        DetectedRequest(url: "b",
                                        eTLDplus1: nil,
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .otherThirdPartyRequest),
                                        pageUrl: pageURL.absoluteString),
                        DetectedRequest(url: "c",
                                        eTLDplus1: nil,
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .blocked,
                                        pageUrl: pageURL.absoluteString)]
        
        for tracker in trackers {
            trackerInfo.addDetectedTracker(tracker, onPageWithURL: pageURL)
        }
        
        return trackerInfo
    }
    
    private func makeNonBlockedTrackerInfo(pageURL: URL) -> TrackerInfo {
        var trackerInfo = TrackerInfo()
        
        let entity = Entity(displayName: "E", domains: [], prevalence: 1.0)
        let trackers = [DetectedRequest(url: "a",
                                        eTLDplus1: nil,
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .ownedByFirstParty),
                                        pageUrl: pageURL.absoluteString),
                        DetectedRequest(url: "b",
                                        eTLDplus1: nil,
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .otherThirdPartyRequest),
                                        pageUrl: pageURL.absoluteString)]
        
        for tracker in trackers {
            trackerInfo.addDetectedTracker(tracker, onPageWithURL: pageURL)
        }
        
        return trackerInfo
    }
}

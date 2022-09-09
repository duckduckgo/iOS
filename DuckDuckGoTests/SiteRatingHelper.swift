//
//  SiteRatingHelper.swift
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
@testable import Core
@testable import DuckDuckGo

class SiteRatingHelper {
    
    var pageURL: URL
    var prevalence: Double
    
    init(pageURL: URL, prevalence: Double = 1) {
        self.pageURL = pageURL
        self.prevalence = prevalence
    }
    
    func makeBlockedTrackersSiteRating() -> SiteRating {
        let entityMapping = MockEntityMapping(entity: "network", prevalence: 100)
        let siteRating = SiteRating(url: pageURL, entityMapping: entityMapping)
        
        let entity = Entity(displayName: "E", domains: [], prevalence: prevalence)
        let trackers = [DetectedRequest(url: "a",
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .blocked,
                                        pageUrl: pageURL.absoluteString),
                        DetectedRequest(url: "b",
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .blocked,
                                        pageUrl: pageURL.absoluteString)]
        
        for tracker in trackers {
            siteRating.trackerDetected(tracker)
        }
        
        return siteRating
    }
    
    func makeNonBlockedTrackersSiteRating() -> SiteRating {
        let entityMapping = MockEntityMapping(entity: "network", prevalence: 100)
        let siteRating = SiteRating(url: pageURL, entityMapping: entityMapping)
        
        let entity = Entity(displayName: "E", domains: [], prevalence: prevalence)
        let trackers = [DetectedRequest(url: "a",
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .ownedByFirstParty),
                                        pageUrl: pageURL.absoluteString),
                        DetectedRequest(url: "b",
                                        knownTracker: nil,
                                        entity: entity,
                                        state: .allowed(reason: .otherThirdPartyRequest),
                                        pageUrl: pageURL.absoluteString)]
        
        for tracker in trackers {
            siteRating.trackerDetected(tracker)
        }
        
        return siteRating
    }
    
}

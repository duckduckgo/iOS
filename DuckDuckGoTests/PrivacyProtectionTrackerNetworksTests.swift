//
//  PrivacyProtectionTrackerNetworksTests.swift
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

import Foundation

import Foundation
import XCTest
@testable import DuckDuckGo
@testable import Core

class PrivacyProtectionTrackerNetworksTests: XCTestCase {

    func testWhenNetworkNotKnownSingleSectionWithSingleRowOfSameDomainBuilt() {
        let mockContentBlocker = MockContentBlockerConfigurationStore()
        mockContentBlocker.addToWhitelist(domain: "edition.cnn.com")
        
        let siteRating = SiteRating(url: URL(string: "https://edition.cnn.com")!)
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker1.com", networkName: nil, category: nil, blocked: false))
        
        let sections = SiteRatingTrackerNetworkSectionBuilder(siteRating: siteRating, contentBlocker: mockContentBlocker, majorNetworksOnly: false).build()
        
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("tracker1.com", sections[0].name)
        XCTAssertEqual(1, sections[0].rows.count)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
    }
    
    func testWhenDomainWhitelistedSectionsBuiltForNetworksDetected() {
        let mockContentBlocker = MockContentBlockerConfigurationStore()
        mockContentBlocker.addToWhitelist(domain: "edition.cnn.com")
        
        let siteRating = SiteRating(url: URL(string: "https://edition.cnn.com")!)
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker1.com", networkName: "Network 1", category: nil, blocked: false))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: nil, blocked: false))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker3.com", networkName: "Network 2", category: nil, blocked: false))
        
        let sections = SiteRatingTrackerNetworkSectionBuilder(siteRating: siteRating, contentBlocker: mockContentBlocker, majorNetworksOnly: false).build()
        
        XCTAssertEqual(2, sections.count)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual(1, sections[1].rows.count)
    }
    
    func testWhenDomainNotWhitelistedSectionsBuiltForNetworksBlocked() {
        let mockContentBlocker = MockContentBlockerConfigurationStore()
        
        let siteRating = SiteRating(url: URL(string: "https://edition.cnn.com")!)
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker1.com", networkName: "Network 1", category: nil, blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: nil, blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker3.com", networkName: "Network 2", category: nil, blocked: false))
        
        let sections = SiteRatingTrackerNetworkSectionBuilder(siteRating: siteRating, contentBlocker: mockContentBlocker, majorNetworksOnly: false).build()
        
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(2, sections[0].rows.count)
    }

    func testWhenMajorNetworkDetectedSectionBuiltWithRowPerUniqueMajorTracker() {
        let mockContentBlocker = MockContentBlockerConfigurationStore()
        
        let siteRating = SiteRating(url: URL(string: "https://edition.cnn.com")!, majorTrackerNetworkStore: MockMajorTrackerNetworkStore())
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker1.com", networkName: "Major", category: "Category 1", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Major", category: "Category 2", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Major", category: "Category 3", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker3.com", networkName: "Minor", category: "Category 4", blocked: true))

        let sections = SiteRatingTrackerNetworkSectionBuilder(siteRating: siteRating, contentBlocker: mockContentBlocker, majorNetworksOnly: true).build()
        
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Major", sections[0].name)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
    }

    func testWhenNetworkDetectedSectionBuiltWithRowPerUniqueTracker() {

        let mockContentBlocker = MockContentBlockerConfigurationStore()
        
        let siteRating = SiteRating(url: URL(string: "https://edition.cnn.com")!)
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker1.com", networkName: "Network 1", category: "Category 1", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: "Category 2", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: "Category 2", blocked: true))
        siteRating.trackerDetected(DetectedTracker(url: "http://tracker2.com", networkName: "Network 1", category: "Category 2", blocked: true))

        let sections = SiteRatingTrackerNetworkSectionBuilder(siteRating: siteRating, contentBlocker: mockContentBlocker, majorNetworksOnly: false).build()
        
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual("Network 1", sections[0].name)
        XCTAssertEqual(2, sections[0].rows.count)
        XCTAssertEqual("tracker1.com", sections[0].rows[0].name)
        XCTAssertEqual("Category 1", sections[0].rows[0].value)
        XCTAssertEqual("tracker2.com", sections[0].rows[1].name)
        XCTAssertEqual("Category 2", sections[0].rows[1].value)
    }
    
}

fileprivate class MockMajorTrackerNetworkStore: MajorTrackerNetworkStore {
    
    let majorTrackerNetwork = MajorTrackerNetwork(name: "Major", domain: "major.com", perentageOfPages: 20)
    
    func network(forName name: String) -> MajorTrackerNetwork? {
        if "Major" == name { return majorTrackerNetwork }
        return nil
    }
    
    func network(forDomain domain: String) -> MajorTrackerNetwork? {
        if "major.com" == domain { return majorTrackerNetwork }
        return nil
    }

}

//
//  PrivacyIconLogicTests.swift
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
import PrivacyDashboard
@testable import Core
@testable import DuckDuckGo

class PrivacyIconLogicTests: XCTestCase {
    
    static let pageURL = URL(string: "https://example.com")!
    static let insecurePageURL = URL(string: "http://example.com")!
    static let ddgSearchURL = URL(string: "https://duckduckgo.com/?q=catfood&t=h_&ia=web")!
    static let ddgMainURL = URL(string: "https://duckduckgo.com")!
    static let ddgSupportURL = URL(string: "https://duckduckgo.com/email/settings/support")!
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testPrivacyIconIsShieldForPageURL() {
        let url = PrivacyIconLogicTests.insecurePageURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsDaxForSearchURL() {
        let url = PrivacyIconLogicTests.ddgSearchURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertTrue(AppUrls().isDuckDuckGoSearch(url: url))
        XCTAssertEqual(icon, .daxLogo)
    }
    
    func testPrivacyIconIsShieldForMainURL() {
        let url = PrivacyIconLogicTests.ddgMainURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsShieldForSupportURL() {
        let url = PrivacyIconLogicTests.ddgSupportURL
        let icon = PrivacyIconLogic.privacyIcon(for: url)
        
        XCTAssertEqual(icon, .shield)
    }
    
    func testPrivacyIconIsShieldWithDotForHTTP() {
        let url = PrivacyIconLogicTests.insecurePageURL
        let entity = Entity(displayName: "E", domains: [], prevalence: TrackerInfo.Constants.majorNetworkPrevalence - 1.0)
        let protectionStatus = ProtectionStatus(unprotectedTemporary: false, enabledFeatures: [], allowlisted: false, denylisted: false)
        let privacyInfo = PrivacyInfo(url: url, parentEntity: entity, protectionStatus: protectionStatus)

        let icon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        
        XCTAssertTrue(url.isHttp)
        XCTAssertFalse(privacyInfo.https)
        XCTAssertFalse(privacyInfo.isMajorTrackerNetwork)
        XCTAssertEqual(icon, .shieldWithDot)
    }
    
    func testPrivacyIconIsShieldWithDotForMajorTrackerNetwork() {
        let url = PrivacyIconLogicTests.pageURL
        let entity = Entity(displayName: "E", domains: [], prevalence: TrackerInfo.Constants.majorNetworkPrevalence + 1.0)
        let protectionStatus = ProtectionStatus(unprotectedTemporary: false, enabledFeatures: [], allowlisted: false, denylisted: false)
        let privacyInfo = PrivacyInfo(url: url, parentEntity: entity, protectionStatus: protectionStatus)
        
        let icon = PrivacyIconLogic.privacyIcon(for: privacyInfo)
        
        XCTAssertTrue(url.isHttps)
        XCTAssertTrue(privacyInfo.https)
        XCTAssertTrue(privacyInfo.isMajorTrackerNetwork)
        XCTAssertEqual(icon, .shieldWithDot)
    }

}

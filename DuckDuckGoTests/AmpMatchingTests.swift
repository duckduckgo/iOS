//
//  AmpMatchingTests.swift
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
@testable import TrackerRadarKit
@testable import Core
import Foundation
import BrowserServicesKit
import os.log

struct AmpRefTests: Decodable {
    struct AmpFormatTests: Decodable {
        let name: String
        let desc: String
        let tests: [AmpFormatTest]
    }
    
    struct AmpFormatTest: Decodable {
        let name: String
        let ampURL: String
        let expectURL: String
        let exceptPlatforms: [String]?
    }
    
    struct AmpKeywordTests: Decodable {
        let name: String
        let desc: String
        let tests: [AmpKeywordTest]
    }
    
    struct AmpKeywordTest: Decodable {
        let name: String
        let ampURL: String
        let expectAmpDetected: Bool
        let exceptPlatforms: [String]?
    }
    
    let ampFormats: AmpFormatTests
    let ampKeywords: AmpKeywordTests
}

class AmpMatchingTests: XCTestCase {
    
    private var data = JsonTestDataLoader()
    
    private var appConfig: PrivacyConfiguration!
    private var ampTestSuite: AmpRefTests!
    
    override func setUpWithError() throws {
        let configJSON = data.fromJsonFile("privacy-reference-tests/amp-protections/config_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/amp-protections/tests.json")
        
        ampTestSuite = try JSONDecoder().decode(AmpRefTests.self, from: testJSON)
        
        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = []
        
        // swiftlint:disable:next force_cast
        let configDict = try JSONSerialization.jsonObject(with: configJSON, options: []) as! [String: Any]
        let configData = PrivacyConfigurationData(json: configDict)
        appConfig = AppPrivacyConfiguration(data: configData, identifier: "", localProtection: localProtection)
    }

    func testAmpFormats() throws {
        let tests = ampTestSuite.ampFormats.tests
        
        let linkCleaner = LinkCleaner()
        
        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                os_log("!!SKIPPING TEST: %s", test.name)
                continue
            }
            
            os_log("TEST: %s", test.name)
            
            let ampUrl = URL(string: test.ampURL)
            let resultUrl = linkCleaner.extractCanonicalFromAmpLink(initiator: nil, destination: ampUrl, config: appConfig)
            
            // Empty exptectedUrl should be treated as nil
            let expectedUrl = !test.expectURL.isEmpty ? test.expectURL : nil
            XCTAssertEqual(resultUrl?.absoluteString, expectedUrl, "\(resultUrl!.absoluteString) not equal to expected: \(expectedUrl ?? "nil")")
        }
    }
    
    func testAmpKeywords() throws {
        let tests = ampTestSuite.ampKeywords.tests
        
        let linkCleaner = LinkCleaner()
        let ampExtractor = AMPCanonicalExtractor(linkCleaner: linkCleaner)
        
        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                os_log("!!SKIPPING TEST: %s", test.name)
                continue
            }
            
            os_log("TEST: %s", test.name)
            
            let ampUrl = URL(string: test.ampURL)
            let result = ampExtractor.urlContainsAmpKeyword(ampUrl, config: appConfig)
            XCTAssertEqual(result, test.expectAmpDetected, "\(test.ampURL) not correctly identified. Expected: \(test.expectAmpDetected.description)")
        }
    }

}

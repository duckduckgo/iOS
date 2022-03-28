//
//  URLParameterTests.swift
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
import BrowserServicesKit
import Foundation
import os.log

struct URLParamRefTests: Decodable {
    struct URLParamTests: Decodable {
        let name: String
        let desc: String
        let tests: [URLParamTest]
    }
    
    struct URLParamTest: Decodable {
        let name: String
        let testURL: String
        let expectURL: String
        let initiatorURL: String?
        let exceptPlatforms: [String]?
    }
    
    let trackingParameters: URLParamTests
}

class URLParameterTests: XCTestCase {
    
    private var data = JsonTestDataLoader()
    
    private var appConfig: PrivacyConfiguration!
    private var urlParamTestSuite: URLParamRefTests!
    
    override func setUpWithError() throws {
        let configJSON = data.fromJsonFile("privacy-reference-tests/url-parameters/config_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/url-parameters/tests.json")
        
        urlParamTestSuite = try JSONDecoder().decode(URLParamRefTests.self, from: testJSON)
        
        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = []
        
        // swiftlint:disable:next force_cast
        let configDict = try JSONSerialization.jsonObject(with: configJSON, options: []) as! [String: Any]
        let configData = PrivacyConfigurationData(json: configDict)
        appConfig = AppPrivacyConfiguration(data: configData, identifier: "", localProtection: localProtection)
    }

    func testURLParamStripping() throws {
        let tests = urlParamTestSuite.trackingParameters.tests
        
        let linkCleaner = LinkCleaner()
        
        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                os_log("!!SKIPPING TEST: %s", test.name)
                continue
            }
            
            os_log("TEST: %s", test.name)
            
            let testUrl = URL(string: test.testURL)
            let initiator = test.initiatorURL != nil ? URL(string: test.initiatorURL!) : nil
            var resultUrl = linkCleaner.cleanTrackingParameters(initiator: initiator, url: testUrl, config: appConfig)
            
            if resultUrl == nil {
                // Tests expect unchanged URLs to match testURL
                resultUrl = testUrl
            }
            
            XCTAssertEqual(resultUrl?.absoluteString, test.expectURL,
                           "\(resultUrl?.absoluteString ?? "(nil)") not equal to expected: \(test.expectURL)")
        }
    }

}

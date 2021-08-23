//
//  ContentBlockerReferenceTests.swift
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
import os.log
import WebKit
import BrowserServicesKit
import TrackerRadarKit
@testable import Core
@testable import DuckDuckGo


class ContentBlockerReferenceTests: XCTestCase {

    let schemeHandler = TestSchemeHandler()
    let userScriptDelegateMock = MockUserScriptDelegate()
    let navigationDelegateMock = MockNavigationDelegate()

    var webView: WKWebView?

    override func setUp() {
        super.setUp()
    }

    func setupWebViewForUserScripTests(trackerData: TrackerData,
                                       exceptions: [String],
                                       tempUnprotected: [String],
                                       userScriptDelegate: ContentBlockerUserScriptDelegate,
                                       schemeHandler: TestSchemeHandler,
                                       completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: exceptions,
                                                     tempUnprotected: tempUnprotected) { rules in
            guard let rules = rules else {
                XCTFail("Rules were not compiled properly")
                return
            }

            let configuration = WKWebViewConfiguration()
            configuration.setURLSchemeHandler(schemeHandler, forURLScheme: schemeHandler.scheme)

            let webView = WKWebView(frame: .init(origin: .zero, size: .init(width: 500, height: 1000)),
                                 configuration: configuration)
            webView.navigationDelegate = self.navigationDelegateMock

            let mockUserScriptConfig = MockUserScriptConfigSource()
            mockUserScriptConfig.trackerData = trackerData

            let userScript = ContentBlockerRulesUserScript(configurationSource: mockUserScriptConfig)
            userScript.delegate = userScriptDelegate

            for messageName in userScript.messageNames {
                configuration.userContentController.add(userScript, name: messageName)
            }

            configuration.userContentController.addUserScript(WKUserScript(source: userScript.source,
                                                                           injectionTime: .atDocumentStart,
                                                                           forMainFrameOnly: false))
            configuration.userContentController.add(rules)

            completion(webView)
        }
    }

    private var data = JsonTestDataLoader()

    func wiptestDomainMatching() throws {
        let trackerJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_radar_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/domain_matching_tests.json")

        let trackerData = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)

        let refTests = try JSONDecoder().decode(RefTests.self, from: testJSON)
        let tests = refTests.domainTests.tests

        setupWebViewForUserScripTests(trackerData: trackerData,
                                      exceptions: ["duckduckgo.com"],
                                      tempUnprotected: [],
                                      userScriptDelegate: userScriptDelegateMock,
                                      schemeHandler: schemeHandler) { webView in
            self.webView = webView


        }

        for test in tests {
            let skip = test.exceptPlatforms?.contains("ios-browser")
            if skip == true {
                os_log("!!SKIPPING TEST: %s", test.name)
                continue
            }

            os_log("TEST: %s", test.name)


            let requestURL = URL(string: test.requestURL)
            let siteURL = URL(string: test.siteURL)

            if test.expectAction == "block" {
//                XCTAssertEqual(result, .block())
            } else {
//                XCTAssertTrue(result == nil || result == .ignorePreviousRules())
            }
        }
    }
    
}

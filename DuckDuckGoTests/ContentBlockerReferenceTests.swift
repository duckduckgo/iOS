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
    let userScriptDelegateMock = MockRulesUserScriptDelegate()
    let navigationDelegateMock = MockNavigationDelegate()

    var webView: WKWebView!
    var tds: TrackerData!
    var tests = [RefTests.Test]()

    override func setUp() {
        super.setUp()
    }

    func setupWebViewForUserScripTests(trackerData: TrackerData,
                                       userScriptDelegate: ContentBlockerRulesUserScriptDelegate,
                                       schemeHandler: TestSchemeHandler,
                                       completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: [],
                                                     tempUnprotected: []) { rules in
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

    func testDomainMatching() throws {

        let data = JsonTestDataLoader()
        let trackerJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_radar_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/domain_matching_tests.json")

        tds = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)

        let refTests = try JSONDecoder().decode(RefTests.self, from: testJSON)
        tests = refTests.domainTests.tests

        let testsExecuted = expectation(description: "tests executed")
        testsExecuted.expectedFulfillmentCount = tests.count

        setupWebViewForUserScripTests(trackerData: tds,
                                      userScriptDelegate: userScriptDelegateMock,
                                      schemeHandler: schemeHandler) { webView in
            self.webView = webView

            self.popTestAndExecute(onTestExecuted: testsExecuted)
        }

        waitForExpectations(timeout: 60, handler: nil)
    }

    private func popTestAndExecute(onTestExecuted: XCTestExpectation) {

        guard let test = tests.popLast() else {
            return
        }

        let skip = test.exceptPlatforms?.contains("ios-browser")
        if skip == true {
            os_log("!!SKIPPING TEST: %s", test.name)
            onTestExecuted.fulfill()
            DispatchQueue.main.async {
                self.popTestAndExecute(onTestExecuted: onTestExecuted)
            }
        }

        os_log("TEST: %s", test.name)

        let siteURL = URL(string: test.siteURL.replacingOccurrences(of: "https://", with: "test://"))!
        let requestURL = URL(string: test.requestURL.replacingOccurrences(of: "https://", with: "test://"))!

        let resource: MockWebsite.EmbeddedResource
        if test.requestType == "image" {
            resource = MockWebsite.EmbeddedResource(type: .image,
                                                    url: requestURL.appendingPathComponent("1.png"))
        } else if test.requestType == "script" {
            resource = MockWebsite.EmbeddedResource(type: .script,
                                                    url: requestURL.appendingPathComponent("1.js"))
        } else {
            XCTFail("Unknown request type: \(test.requestType) in test \(test.name)")
            return
        }

        let mockWebsite = MockWebsite(resources: [resource])

        schemeHandler.reset()
        schemeHandler.requestHandlers[siteURL] = { _ in
            return mockWebsite.htmlRepresentation.data(using: .utf8)!
        }

        userScriptDelegateMock.reset()

        os_log("Loading %s ...", siteURL.absoluteString)
        let request = URLRequest(url: siteURL)
        webView.load(request)

        navigationDelegateMock.onDidFinishNavigation = {
            os_log("Website loaded")
            if test.expectAction == "block" {
                // Only website request
                XCTAssertEqual(self.schemeHandler.handledRequests.count, 1)
                // Only resource request
                XCTAssertEqual(self.userScriptDelegateMock.detectedTrackers.count, 1)

                if let tracker = self.userScriptDelegateMock.detectedTrackers.first {
                    XCTAssert(tracker.blocked)
                } else {
                    XCTFail("Expected to detect tracker for test \(test.name)")
                }
            } else if test.expectAction == "ignore" {
                // Website request & resource request
                XCTAssertEqual(self.schemeHandler.handledRequests.count, 2)

                if let pageEntity = self.tds.findEntity(forHost: siteURL.host!),
                   let trackerOwner = self.tds.findTracker(forUrl: requestURL.absoluteString)?.owner,
                   pageEntity.displayName == trackerOwner.name {

                    // Nothing to detect - tracker and website have the same entity
                } else {
                    XCTAssertEqual(self.userScriptDelegateMock.detectedTrackers.count, 1)

                    if let tracker = self.userScriptDelegateMock.detectedTrackers.first {
                        XCTAssertFalse(tracker.blocked)
                    } else {
                        XCTFail("Expected to detect tracker for test \(test.name)")
                    }
                }

            } else {
                // Website request & resource request
                XCTAssertEqual(self.schemeHandler.handledRequests.count, 2)
                XCTAssertEqual(self.userScriptDelegateMock.detectedTrackers.count, 0)
            }

            onTestExecuted.fulfill()
            DispatchQueue.main.async {
                self.popTestAndExecute(onTestExecuted: onTestExecuted)
            }
        }
    }
    
}

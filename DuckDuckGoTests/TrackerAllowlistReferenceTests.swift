//
//  TrackerAllowlistReferenceTests.swift
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

struct AllowlistTests: Decodable {

    struct Test: Decodable {

        let description: String
        let site: String
        let request: String
        let isAllowlisted: Bool

    }

    let domainTests: [Test]
}

class TrackerAllowlistReferenceTests: XCTestCase {

    let schemeHandler = TestSchemeHandler()
    let userScriptDelegateMock = MockRulesUserScriptDelegate()
    let navigationDelegateMock = MockNavigationDelegate()

    var webView: WKWebView!
    var tds: TrackerData!
    var tests = [AllowlistTests.Test]()
    var mockWebsite: MockWebsite!

    override func setUp() {
        super.setUp()
    }

    func setupWebView(trackerData: TrackerData,
                      userScriptDelegate: ContentBlockerRulesUserScriptDelegate,
                      trackerAllowlist: PrivacyConfigurationData.TrackerAllowlistData,
                      schemeHandler: TestSchemeHandler,
                      completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        let exceptions = DefaultContentBlockerRulesSource.transform(allowList: trackerAllowlist)

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: [],
                                                     tempUnprotected: [],
                                                     trackerExceptions: exceptions) { rules in
            guard let rules = rules else {
                XCTFail("Rules were not compiled properly")
                return
            }

            let configuration = WKWebViewConfiguration()
            configuration.setURLSchemeHandler(schemeHandler, forURLScheme: schemeHandler.scheme)

            let webView = WKWebView(frame: .init(origin: .zero, size: .init(width: 500, height: 1000)),
                                 configuration: configuration)
            webView.navigationDelegate = self.navigationDelegateMock

            let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                      tempUnprotected: [],
                                                                      trackerAllowlist: trackerAllowlist,
                                                                      contentBlockingEnabled: true,
                                                                      exceptions: [])

            let mockUserScriptConfig = MockUserScriptConfigSource(privacyConfig: privacyConfig)
            mockUserScriptConfig.trackerData = trackerData

            let userScript = CustomContentBlockerRulesUserScript(configurationSource: mockUserScriptConfig)
            userScript.delegate = userScriptDelegate

            // UserScripts contain TrackerAllowlist rules in form of regular expressions - we need to ensure test scheme is matched instead of http/https
            userScript.onSourceInjection = { inputScript -> String in
                return inputScript.replacingOccurrences(of: "http", with: "test")
            }

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

    func testDomainAllowlist() throws {

        let data = JsonTestDataLoader()
        let trackerJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_allowlist_tds_reference.json")
        let testJSON = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_allowlist_matching_tests.json")

        let allowlistReference = data.fromJsonFile("privacy-reference-tests/tracker-radar-tests/TR-domain-matching/tracker_allowlist_reference.json")

        tds = try JSONDecoder().decode(TrackerData.self, from: trackerJSON)

        let allowlistJson = try? JSONSerialization.jsonObject(with: allowlistReference, options: []) as? [String: Any]

        let allowlist = PrivacyConfigurationData.TrackerAllowlist(json: ["state": "enabled", "settings": ["allowlistedTrackers": allowlistJson]])!

        let refTests = try JSONDecoder().decode(Array<AllowlistTests.Test>.self, from: testJSON)
        tests = refTests

        let testsExecuted = expectation(description: "tests executed")
        testsExecuted.expectedFulfillmentCount = tests.count

        setupWebView(trackerData: tds,
                     userScriptDelegate: userScriptDelegateMock,
                     trackerAllowlist: allowlist.entries,
                     schemeHandler: schemeHandler) { webView in
            self.webView = webView

            self.popTestAndExecute(onTestExecuted: testsExecuted)
        }

        waitForExpectations(timeout: 560, handler: nil)
    }

    private func normalizeScheme(urlString: String) -> String {
        return urlString.replacingOccurrences(of: "https://", with: "test://").replacingOccurrences(of: "http://", with: "test://")
    }

    // swiftlint:disable function_body_length
    private func popTestAndExecute(onTestExecuted: XCTestExpectation) {

        guard let test = tests.popLast() else {
            return
        }

        os_log("TEST: %s", test.description)

        let siteURL = URL(string: normalizeScheme(urlString: test.site))!
        let requestURL = URL(string: normalizeScheme(urlString: test.request))!

        let resource = MockWebsite.EmbeddedResource(type: .script,
                                                    url: requestURL)

        mockWebsite = MockWebsite(resources: [resource])

        schemeHandler.reset()
        schemeHandler.requestHandlers[siteURL] = { _ in
            return self.mockWebsite.htmlRepresentation.data(using: .utf8)!
        }

        userScriptDelegateMock.reset()

        os_log("Loading %s ...", siteURL.absoluteString)
        let request = URLRequest(url: siteURL)

        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache,
                                                          WKWebsiteDataTypeMemoryCache],
                                                modifiedSince: Date(timeIntervalSince1970: 0),
                                                completionHandler: {
            self.webView.load(request)
        })

        navigationDelegateMock.onDidFinishNavigation = {
            os_log("Website loaded")
            if !test.isAllowlisted {
                // Only website request
                XCTAssertEqual(self.schemeHandler.handledRequests.count, 1)
                // Only resource request
                XCTAssertEqual(self.userScriptDelegateMock.detectedTrackers.count, 1)

                if let tracker = self.userScriptDelegateMock.detectedTrackers.first {
                    XCTAssert(tracker.blocked)
                } else {
                    XCTFail("Expected to detect tracker for test \(test.description)")
                }
            } else {
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
                        XCTFail("Expected to detect tracker for test \(test.description)")
                    }
                }
            }

            onTestExecuted.fulfill()
            DispatchQueue.main.async {
                self.popTestAndExecute(onTestExecuted: onTestExecuted)
            }
        }
    }
    // swiftlint:enable function_body_length

}

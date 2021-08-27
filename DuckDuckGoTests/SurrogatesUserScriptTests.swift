//
//  SurrogatesUserScriptTests.swift
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
import WebKit
import BrowserServicesKit
import TrackerRadarKit
@testable import Core
@testable import DuckDuckGo

class SurrogatesUserScriptsTests: XCTestCase {

    static let exampleRules = """
{
  "trackers": {
    "tracker.com": {
      "domain": "tracker.com",
      "default": "block",
      "rules": [
        {
          "rule": "tracker\\\\.com\\\\/scripts\\\\/script\\\\.js",
          "surrogate": "script.js"
        }
      ],
      "owner": {
        "name": "Fake Tracking Inc",
        "displayName": "FT Inc",
        "privacyPolicy": "https://tracker.com/privacy",
        "url": "http://tracker.com"
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
    "Fake Tracking Inc": {
      "domains": [
        "tracker.com"
      ],
      "displayName": "Fake Tracking Inc",
      "prevalence": 0.1
    }
  },
  "domains": {
    "tracker.com": "Fake Tracking Inc"
  }
}
"""

    static let exampleSurrogates = """
        tracker.com/script.js application/javascript
        (() => {
            'use strict';
            var surrogatesScriptTest = function() {
                function ping() {
                    return "success"
                }
                return {
                    ping: ping
                }
            }()
            window.surrT = surrogatesScriptTest
        })();
        """

    let schemeHandler = TestSchemeHandler()
    let userScriptDelegateMock = MockSurrogatesUserScriptDelegate()
    let navigationDelegateMock = MockNavigationDelegate()

    var webView: WKWebView?

    let nonTrackerURL = URL(string: "test://nontracker.com/1.png")!
    let trackerURL = URL(string: "test://tracker.com/1.png")!
    let surrogateScriptURL = URL(string: "test://tracker.com/scripts/script.js")!
    let nonSurrogateScriptURL = URL(string: "test://tracker.com/other/script.js")!

    var website: MockWebsite!

    override func setUp() {
        super.setUp()

        website = MockWebsite(resources: [.init(type: .image, url: nonTrackerURL),
                                          .init(type: .image, url: trackerURL),
                                          .init(type: .script, url: surrogateScriptURL),
                                          .init(type: .script, url: nonSurrogateScriptURL)])
    }

    func setupWebViewForUserScripTests(trackerData: TrackerData,
                                       encodedTrackerData: String,
                                       privacyConfig: PrivacyConfiguration,
                                       userScriptDelegate: SurrogatesUserScriptDelegate,
                                       schemeHandler: TestSchemeHandler,
                                       completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        var tempUnprotected = privacyConfig.tempUnprotectedDomains.filter { !$0.trimWhitespace().isEmpty }
        tempUnprotected.append(contentsOf: privacyConfig.exceptionsList(forFeature: .contentBlocking))

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: privacyConfig.locallyUnprotectedDomains,
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

            let mockUserScriptConfig = MockSurrogatesUserScriptConfigSource(privacyConfig: privacyConfig)
            mockUserScriptConfig.encodedTrackerData = encodedTrackerData
            mockUserScriptConfig.surrogates = Self.exampleSurrogates

            let userScript = SurrogatesUserScript(configurationSource: mockUserScriptConfig)
            userScript.delegate = userScriptDelegate

            for messageName in userScript.messageNames {
                configuration.userContentController.add(userScript, name: messageName)
            }

            let debugMessagingSource = DebugUserScript.loadJS("debug-messaging-disabled", from: Bundle.core)
            configuration.userContentController.addUserScript(WKUserScript(source: debugMessagingSource,
                                                                           injectionTime: .atDocumentStart,
                                                                           forMainFrameOnly: false))
            configuration.userContentController.addUserScript(WKUserScript(source: userScript.source,
                                                                           injectionTime: .atDocumentStart,
                                                                           forMainFrameOnly: false))
            configuration.userContentController.add(rules)

            completion(webView)
        }
    }

    func testBasicSurrogateInjection() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")
        let websiteURL = URL(string: "test://example.com")!

        let trackerDataSource = Self.exampleRules.data(using: .utf8)!
        let trackerData = (try? JSONDecoder().decode(TrackerData.self, from: trackerDataSource))!

        let encodedData = try? JSONEncoder().encode(trackerData)
        let encodedTrackerData = String(data: encodedData!, encoding: .utf8)!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 1)
            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.first?.url, self.surrogateScriptURL.absoluteString)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { result, err in
                XCTAssertNil(err)
                if let result = result as? String {
                    XCTAssertEqual(result, "success")
                    surrogateValidated.fulfill()
                }
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        setupWebViewForUserScripTests(trackerData: trackerData,
                                      encodedTrackerData: encodedTrackerData,
                                      privacyConfig: privacyConfig,
                                      userScriptDelegate: userScriptDelegateMock,
                                      schemeHandler: schemeHandler) { webView in
            // Keep webview in memory till test finishes
            self.webView = webView

            // Test non-fist party trackers
            self.schemeHandler.requestHandlers[websiteURL] = { _ in
                return self.website.htmlRepresentation.data(using: .utf8)!
            }

            let request = URLRequest(url: websiteURL)
            webView.load(request)
        }

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 90)
    }
}

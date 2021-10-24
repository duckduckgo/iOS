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

// swiftlint:disable file_length
// swiftlint:disable type_body_length
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

    private func setupWebViewForUserScripTests(trackerData: TrackerData,
                                               encodedTrackerData: String,
                                               privacyConfig: PrivacyConfiguration,
                                               completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        var tempUnprotected = privacyConfig.tempUnprotectedDomains.filter { !$0.trimWhitespace().isEmpty }
        tempUnprotected.append(contentsOf: privacyConfig.exceptionsList(forFeature: .contentBlocking))

        let exceptions = DefaultContentBlockerRulesSource.transform(allowList: privacyConfig.trackerAllowlist)

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: privacyConfig.userUnprotectedDomains,
                                                     tempUnprotected: tempUnprotected,
                                                     trackerExceptions: exceptions) { rules in
            guard let rules = rules else {
                XCTFail("Rules were not compiled properly")
                return
            }

            let configuration = WKWebViewConfiguration()
            configuration.setURLSchemeHandler(self.schemeHandler, forURLScheme: self.schemeHandler.scheme)

            let webView = WKWebView(frame: .init(origin: .zero, size: .init(width: 500, height: 1000)),
                                 configuration: configuration)
            webView.navigationDelegate = self.navigationDelegateMock

            let mockUserScriptConfig = MockSurrogatesUserScriptConfigSource(privacyConfig: privacyConfig)
            mockUserScriptConfig.encodedTrackerData = encodedTrackerData
            mockUserScriptConfig.surrogates = Self.exampleSurrogates

            let userScript = CustomSurrogatesUserScript(configurationSource: mockUserScriptConfig)
            userScript.delegate = self.userScriptDelegateMock

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

    private func performTestFor(privacyConfig: PrivacyConfiguration,
                                websiteURL: URL) {

        let trackerDataSource = Self.exampleRules.data(using: .utf8)!
        let trackerData = (try? JSONDecoder().decode(TrackerData.self, from: trackerDataSource))!

        let encodedData = try? JSONEncoder().encode(trackerData)
        let encodedTrackerData = String(data: encodedData!, encoding: .utf8)!

        setupWebViewForUserScripTests(trackerData: trackerData,
                                      encodedTrackerData: encodedTrackerData,
                                      privacyConfig: privacyConfig) { webView in
            // Keep webview in memory till test finishes
            self.webView = webView

            self.schemeHandler.requestHandlers[websiteURL] = { _ in
                return self.website.htmlRepresentation.data(using: .utf8)!
            }

            let request = URLRequest(url: websiteURL)
            WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache,
                                                              WKWebsiteDataTypeMemoryCache],
                                                    modifiedSince: Date(timeIntervalSince1970: 0),
                                                    completionHandler: {
                webView.load(request)
            })
        }
    }

    func testWhenThereIsSurrogateRuleThenSurrogateIsInjected() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])
        let websiteURL = URL(string: "test://example.com")!

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

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

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsLocallyUnprotectedThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: ["example.com"],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsSubdomainOfLocallyUnprotectedThenSurrogatesAreInjected() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: ["example.com"],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteURL = URL(string: "test://sub.example.com")!

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

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

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsTempUnprotectedThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: ["example.com"],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsSubdomainOfTempUnprotectedThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://sub.example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: ["example.com"],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsInExceptionListThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://example.com")!

        let allowlist = ["tracker.com": [PrivacyConfigurationData.TrackerAllowlist.Entry(rule: "tracker.com/", domains: ["example.com"])]]

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: allowlist,
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsNotInExceptionListThenSurrogatesAreInjected() {

        let websiteURL = URL(string: "test://example.com")!

        let allowlist = ["tracker.com": [PrivacyConfigurationData.TrackerAllowlist.Entry(rule: "tracker.com/", domains: ["test.com"])]]

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: allowlist,
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 1)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenTrackerIsInAllowListThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: ["example.com"])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenSiteIsSubdomainOfExceptionListThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://sub.example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: ["example.com"])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.nonSurrogateScriptURL, self.surrogateScriptURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }

    func testWhenContentBlockingFeatureIsDisabledThenSurrogatesAreNotInjected() {

        let websiteURL = URL(string: "test://sub.example.com")!

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  trackerAllowlist: [:],
                                                                  contentBlockingEnabled: false,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let surrogateValidated = self.expectation(description: "Validated surrogate injection")

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            XCTAssertEqual(self.userScriptDelegateMock.detectedSurrogates.count, 0)

            self.webView?.evaluateJavaScript("window.surrT.ping()", completionHandler: { _, err in
                XCTAssertNotNil(err)
                surrogateValidated.fulfill()
            })

            // Note: do not check the requests - they will be blocked as test setup adds content blocking rules
            // despite feature flag being set to false - so we validate only how Surrogates script handles that.
        }

        performTestFor(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded, surrogateValidated], timeout: 15)
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length

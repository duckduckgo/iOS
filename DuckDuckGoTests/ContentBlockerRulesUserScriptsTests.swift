//
//  ContentBlockerRulesUserScriptsTests.swift
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
class ContentBlockerRulesUserScriptsTests: XCTestCase {

    static let exampleRules = """
{
  "trackers": {
    "tracker.com": {
      "domain": "tracker.com",
      "default": "block",
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

    let schemeHandler = TestSchemeHandler()
    let userScriptDelegateMock = MockRulesUserScriptDelegate()
    let navigationDelegateMock = MockNavigationDelegate()

    var webView: WKWebView?

    let nonTrackerURL = URL(string: "test://nontracker.com/1.png")!
    let trackerURL = URL(string: "test://tracker.com/1.png")!
    let subTrackerURL = URL(string: "test://sub.tracker.com/1.png")!

    var website: MockWebsite!

    override func setUp() {
        super.setUp()

        website = MockWebsite(resources: [.init(type: .image, url: nonTrackerURL),
                                          .init(type: .image, url: trackerURL),
                                          .init(type: .image, url: subTrackerURL)])
    }
    
    private func setupWebViewForUserScripTests(trackerData: TrackerData,
                                               privacyConfig: PrivacyConfiguration,
                                               userScriptDelegate: ContentBlockerRulesUserScriptDelegate,
                                               schemeHandler: TestSchemeHandler,
                                               completion: @escaping (WKWebView) -> Void) {

        let mockSource = MockContentBlockerRulesSource(trackerData: nil,
                                                       embeddedTrackerData: (trackerData, UUID().uuidString) )
        _ = ContentBlockerRulesManager.test_prepareRegularInstance(source: mockSource, skipInitialSetup: false)

        var tempUnprotected = privacyConfig.tempUnprotectedDomains.filter { !$0.trimWhitespace().isEmpty }
        tempUnprotected.append(contentsOf: privacyConfig.exceptionsList(forFeature: .contentBlocking))

        WebKitTestHelper.prepareContentBlockingRules(trackerData: trackerData,
                                                     exceptions: privacyConfig.userUnprotectedDomains,
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

            let mockUserScriptConfig = MockUserScriptConfigSource(privacyConfig: privacyConfig)
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

    private func performTest(privacyConfig: PrivacyConfiguration,
                             websiteURL: URL) {

        let trackerDataSource = Self.exampleRules.data(using: .utf8)!
        let trackerData = (try? JSONDecoder().decode(TrackerData.self, from: trackerDataSource))!

        setupWebViewForUserScripTests(trackerData: trackerData,
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
    }

    func testWhenThereIsTrackerThenItIsReportedAndBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertEqual(expectedTrackers, blockedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsFirstPartyTrackerThenItIsNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://tracker.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            // Shall we detect first party trackers?
            // let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            // let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            // XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnLocallyUnprotectedSiteThenItIsReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: ["example.com"],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnLocallyUnprotectedSiteSubdomainThenItIsReportedAndBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: ["example.com"],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://sub.example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertEqual(expectedTrackers, blockedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnSiteSimmilarToLocallyUnprotectedSiteThenItIsReportedAndBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: ["example.com"],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://someexample.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertEqual(expectedTrackers, blockedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnTempUnprotectedSiteThenItIsReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: ["example.com"],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnTempUnprotectedSiteSubdomainThenItIsReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: ["example.com"],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://sub.example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnSiteSimmilarToTempUnprotectedSiteThenItIsReportedAndBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: ["example.com"],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://someexample.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertEqual(expectedTrackers, blockedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnSiteFromExceptionListThenItIsReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: ["example.com"])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenThereIsTrackerOnSubdomainOfSiteFromExceptionListThenItIsReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: true,
                                                                  exceptions: ["example.com"])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://sub.example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            let expectedRequests: Set<URL> = [websiteURL, self.nonTrackerURL, self.trackerURL, self.subTrackerURL]
            XCTAssertEqual(Set(self.schemeHandler.handledRequests), expectedRequests)
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }

    func testWhenContentBlockingFeatureIsDisabledThenTrackersAreReportedButNotBlocked() {

        let privacyConfig = WebKitTestHelper.preparePrivacyConfig(locallyUnprotected: [],
                                                                  tempUnprotected: [],
                                                                  contentBlockingEnabled: false,
                                                                  exceptions: [])

        let websiteLoaded = self.expectation(description: "Website Loaded")
        let websiteURL = URL(string: "test://example.com")!

        navigationDelegateMock.onDidFinishNavigation = {
            websiteLoaded.fulfill()

            let expectedTrackers: Set<String> = ["sub.tracker.com", "tracker.com"]
            let blockedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.filter { $0.blocked }.map { $0.domain })
            XCTAssertTrue(blockedTrackers.isEmpty)

            let detectedTrackers = Set(self.userScriptDelegateMock.detectedTrackers.map { $0.domain })
            XCTAssertEqual(expectedTrackers, detectedTrackers)

            // Note: do not check the requests - they will be blocked as test setup adds content blocking rules
            // despite feature flag being set to false - so we validate only how Surrogates script handles that.
        }

        performTest(privacyConfig: privacyConfig, websiteURL: websiteURL)

        self.wait(for: [websiteLoaded], timeout: 30)
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length

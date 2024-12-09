//
//  MaliciousSiteProtectionNavigationHandlerTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Testing
import WebKit
import SpecialErrorPages
import MaliciousSiteProtection
@testable import DuckDuckGo

@Suite("Special Error Pages - Malicious Site Protection Navigation Handler Unit Tests", .serialized)
struct MaliciousSiteProtectionNavigationHandlerTests {
    private var sut: MaliciousSiteProtectionNavigationHandler!
    private var mockMaliciousSiteProtectionManager: MockMaliciousSiteProtectionManager!
    private var webView: MockWebView!

    @MainActor
    init() {
        webView = MockWebView()
        mockMaliciousSiteProtectionManager = MockMaliciousSiteProtectionManager()
        sut = MaliciousSiteProtectionNavigationHandler(maliciousSiteProtectionManager: mockMaliciousSiteProtectionManager)
    }

    @MainActor
    @Test(
        "URLs that should not be handled do not create a Malicious Detection Task",
        arguments: [
            "about:blank",
            "https://duckduckgo.com?q=swift-testing",
            "duck://player"
        ]
    )
    func unhandledURLTypes(path: String) async throws {
        // GIVEN
        let url = try #require(URL(string: path))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))

        // WHEN
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)

        // THEN
        #expect(sut.maliciousSiteDetectionTasks[url] == nil)
    }

    @MainActor
    @Test("Non Bypassed Malicious Site creates a Malicious Detection Task", arguments: [ThreatKind.phishing, .malware])
    func whenBypassedMaliciousSiteThreatKindIsNotSetThenReturnNavigationHandled(threat: ThreatKind) throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        mockMaliciousSiteProtectionManager.threatKind = threat
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))

        // WHEN
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)

        // THEN
        #expect(sut.maliciousSiteDetectionTasks[url] != nil)
    }

    @MainActor
    @Test("Bypassed Malicious Site does not create a Malicious Detection Task", arguments: [ThreatKind.phishing, .malware])
    func whenBypassedMaliciousSiteThreatKindIsSetThenReturnNavigationNotHandled(threat: ThreatKind) throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        mockMaliciousSiteProtectionManager.threatKind = threat
        sut.visitSite(url: url, errorData: .maliciousSite(kind: threat, url: url))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))

        // WHEN
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)

        // THEN
        #expect(sut.maliciousSiteDetectionTasks[url] == nil)
    }

    @MainActor
    @Test("Retrieving Malicious Site Detection Task Nullifies it")
    func whenHandleDecidePolicyForNavigationResponse_AndTaskIsNotNil_ReturnTaskAndRemoveItFromTheDictionary() throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)
        let navigationResponse = MockNavigationResponse.with(url: url)
        #expect(sut.maliciousSiteDetectionTasks[url] != nil)

        // WHEN
        _ = try #require(sut.getMaliciousSiteDectionTask(for: navigationResponse, webView: webView))

        // THEN
        #expect(sut.maliciousSiteDetectionTasks[url] == nil)
    }

    @MainActor
    @Test("Do not handle navigation when Threat is nil")
    func whenThreatKindIsNilThenReturnNavigationNotHandled() async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url))
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)
        let navigationResponse = MockNavigationResponse.with(url: url)
        mockMaliciousSiteProtectionManager.threatKind = nil

        // WHEN
        let result = try #require(sut.getMaliciousSiteDectionTask(for: navigationResponse, webView: webView))

        // THEN
        #expect(await result.value == .navigationNotHandled)
    }

    @MainActor
    @Test(
        "Handle known threat in Main Frame",
        arguments: [
            ThreatKind.phishing,
                .malware
        ]
    )
    func whenThreatKindIsNotNil_AndNavigationIsMainFrame_ThenReturnNavigationHandledMainFrame(threat: ThreatKind) async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: true))
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)
        let navigationResponse = MockNavigationResponse.with(url: url)
        mockMaliciousSiteProtectionManager.threatKind = threat

        // WHEN
        let result = try #require(sut.getMaliciousSiteDectionTask(for: navigationResponse, webView: webView))

        // THEN
        #expect(await result.value == .navigationHandled(.mainFrame(MaliciousSiteDetectionNavigationResponse(navigationAction: navigationAction, errorData: .maliciousSite(kind: threat, url: url)))))
    }

    @MainActor
    @Test(
        "Handle known threat in IFrame",
        arguments: [
            ThreatKind.phishing,
                .malware
        ]
    )
    func whenThreatKindIsNotNil_AndNavigationIsIFrame_ThenReturnNavigationHandledIFrame(threat: ThreatKind) async throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let navigationAction = MockNavigationAction(request: URLRequest(url: url), targetFrame: MockFrameInfo(isMainFrame: false))
        sut.creatMaliciousSiteDetectionTask(for: navigationAction, webView: webView)
        let navigationResponse = MockNavigationResponse.with(url: url)
        mockMaliciousSiteProtectionManager.threatKind = threat

        // WHEN
        let result = try #require(sut.getMaliciousSiteDectionTask(for: navigationResponse, webView: webView))

        // THEN
        #expect(await result.value == .navigationHandled(.iFrame(maliciousURL: url, error: .maliciousSite(kind: threat, url: url))))
    }

    @MainActor
    @Test(
        "Visit Site sets Exemption URL and Threat Kind",
        arguments: [
            ThreatKind.phishing, .malware
        ]
    )
    func whenVisitSiteActionThenSetExemptionURLAndThreatKind(threat: ThreatKind) throws {
        // GIVEN
        let url = try #require(URL(string: "https://www.example.com"))
        let errorData = SpecialErrorData.maliciousSite(kind: threat, url: url)
        #expect(sut.maliciousURLExemptions.isEmpty)
        #expect(sut.bypassedMaliciousSiteThreatKind == nil)

        // WHEN
        sut.visitSite(url: url, errorData: errorData)

        // THEN
        #expect(sut.maliciousURLExemptions[url] == threat)
        #expect(sut.bypassedMaliciousSiteThreatKind == threat)
    }

    @Test("Leave Site Pixel", .disabled("Will be implmented in upcoming PR"))
    func whenLeaveSiteActionThenFirePixel() throws {

    }

    @Test("Advanced Site Info Pixel", .disabled("Will be implmented in upcoming PR"))
    func whenAdvancedSiteInfoActionThenFirePixel() throws {

    }

}

extension MockNavigationResponse {

    static func with(url: URL) -> MockNavigationResponse {
        let response = MockNavigationResponse()
        response.url = url
        response.mimeType = "text/html"
        return response
    }

}

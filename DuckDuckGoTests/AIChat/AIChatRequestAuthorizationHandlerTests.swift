//
//  MockAIChatDebugSettings.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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
import AIChat
@testable import DuckDuckGo

final class MockAIChatDebugSettings: AIChatDebugSettingsHandling {
    var messagePolicyHostname: String?
}

class AIChatRequestAuthorizationHandlerTests: XCTestCase {

    var handler: AIChatRequestAuthorizationHandler!
    var mockDebugSettings: MockAIChatDebugSettings!

    override func setUp() {
        super.setUp()
        mockDebugSettings = MockAIChatDebugSettings()
        handler = AIChatRequestAuthorizationHandler(debugSettings: mockDebugSettings)
    }

    override func tearDown() {
        handler = nil
        mockDebugSettings = nil
        super.tearDown()
    }

    // MARK: Valid URLS
    func testShouldAllowRequestWithDuckAIURL() {
        let url = URL(string: "https://duckduckgo.com/?ia=chat")!
        let request = URLRequest(url: url)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: nil)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertTrue(result, "Expected to allow request for DuckAI URL")
    }

    func testShouldAllowRequestWithDuckAIBang() {
        let url = URL(string: "https://duckduckgo.com/?q=!ai")!
        let request = URLRequest(url: url)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: nil)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertTrue(result, "Expected to allow request for DuckAI bang")
    }

    // MARK: - Main Frame
    func testShouldAllowRequestWithNonMainFrame() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: false)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertTrue(result, "Expected to allow request for non-main frame")
    }

    func testShouldNotAllowRequestWithNonDuckAIURLAndMainFrame() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: true)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertFalse(result, "Expected to not allow request for non-DuckAI URL and main frame")
    }

    // MARK: Debug settings
    func testShouldAllowRequestOnNonDuckDuckGoURLWhenDebugSettingsExists() {
        mockDebugSettings.messagePolicyHostname = "potato"
        let url = URL(string: "https://test.com")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: false)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertTrue(result, "Expected to allow request when debug settings is on even on non-DuckDuckGo URL")
    }

    func testShouldAllowRequestOnDuckDuckGoURLWhenDebugSettingsExists() {
        mockDebugSettings.messagePolicyHostname = "potato"
        let url = URL(string: "https://duck.ai")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: false)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertTrue(result, "Expected to allow request when debug settings is on")
    }

    func testShouldNotAllowRequestOnNonDuckDuckGoURLWhenDebugSettingsIsNil() {
        mockDebugSettings.messagePolicyHostname = nil
        let url = URL(string: "https://test.com")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: true)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertFalse(result, "Expected to deny request when debug settings doesnt exist on non-DuckDuckGo URL")
    }

    func testShouldNotAllowRequestOnNonDuckDuckGoURLWhenDebugSettingsIsEmpty() {
        mockDebugSettings.messagePolicyHostname = ""
        let url = URL(string: "https://test.com")!
        let request = URLRequest(url: url)
        let targetFrame = MockWKFrameInfo(isMainFrame: true)
        let navigationAction = MockWKNavigationAction(request: request, targetFrame: targetFrame)

        let result = handler.shouldAllowRequestWithNavigationAction(navigationAction)

        XCTAssertFalse(result, "Expected to deny request when debug settings doesnt exist on non-DuckDuckGo URL")
    }
}


final class MockWKNavigationAction: WKNavigationAction {
    private let mockRequest: URLRequest
    private let mockTargetFrame: WKFrameInfo?

    init(request: URLRequest, targetFrame: WKFrameInfo?) {
        self.mockRequest = request
        self.mockTargetFrame = targetFrame
        super.init()
    }

    override var request: URLRequest {
        return mockRequest
    }

    override var targetFrame: WKFrameInfo? {
        return mockTargetFrame
    }
}

final class MockWKFrameInfo: WKFrameInfo {
    private let mockIsMainFrame: Bool

    init(isMainFrame: Bool) {
        self.mockIsMainFrame = isMainFrame
        super.init()
    }

    override var isMainFrame: Bool {
        return mockIsMainFrame
    }
}

//
//  AIChatUserScriptHandlerTests.swift
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
@testable import DuckDuckGo
import UserScript
import WebKit

class AIChatUserScriptHandlerTests: XCTestCase {
    var aiChatUserScriptHandler: AIChatUserScriptHandler!
    var mockFeatureFlagger: MockFeatureFlagger!
    var mockPayloadHandler: MockAIChatPayloadHandling!

    override func setUp() {
        super.setUp()
        mockFeatureFlagger = MockFeatureFlagger(enabledFeatureFlags: [.aiChatDeepLink])
        mockPayloadHandler = MockAIChatPayloadHandling()
        aiChatUserScriptHandler = AIChatUserScriptHandler(featureFlagger: mockFeatureFlagger)
        aiChatUserScriptHandler.setPayloadHandler(mockPayloadHandler)
    }

    override func tearDown() {
        aiChatUserScriptHandler = nil
        mockFeatureFlagger = nil
        mockPayloadHandler = nil
        super.tearDown()
    }

    func testGetAIChatNativeConfigValues() {
        // Given
        // MockFeatureFlagger is already initialized with .aiChatDeepLink enabled

        // When
        let configValues = aiChatUserScriptHandler.getAIChatNativeConfigValues(params: [], message: MockUserScriptMessage(name: "test", body: [:]))  as? AIChatNativeConfigValues

        // Then
        XCTAssertNotNil(configValues)
        XCTAssertEqual(configValues?.isAIChatHandoffEnabled, true)
        XCTAssertEqual(configValues?.platform, "ios")
    }

    func testGetAIChatNativeHandoffData() {
        // Given
        let expectedPayload = ["key": "value"]
        mockPayloadHandler.payload = expectedPayload

        // When
        let handoffData = aiChatUserScriptHandler.getAIChatNativeHandoffData(params: [], message: MockUserScriptMessage(name: "test", body: [:])) as? AIChatNativeHandoffData

        // Then
        XCTAssertNotNil(handoffData)
        XCTAssertEqual(handoffData?.isAIChatHandoffEnabled, true)
        XCTAssertEqual(handoffData?.platform, "ios")
        XCTAssertEqual(handoffData?.aiChatPayload as? [String: String], expectedPayload)
    }

    func testOpenAIChat() async {
        // Given
        let expectation = self.expectation(description: "Notification should be posted")
        let payload = ["key": "value"]
        let message = MockUserScriptMessage(name: "test", body: payload)

        // When
        let result = await aiChatUserScriptHandler.openAIChat(params: payload, message: message)

        // Then
        XCTAssertNil(result)
        // Wait for the notification to be posted
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation])
    }
}

class MockAIChatPayloadHandling: AIChatPayloadHandling {
    typealias PayloadType = [String: Any]

    var payload: PayloadType?

    func setPayload(_ payload: PayloadType) {
        self.payload = payload
    }

    func consumePayload() -> PayloadType? {
        defer { payload = nil } // Reset the payload after consuming
        return payload
    }

    func reset() {
        payload = nil
    }
}

struct MockUserScriptMessage: UserScriptMessage {
    public var messageName: String
    public var messageBody: Any
    public var messageHost: String
    public var isMainFrame: Bool
    public var messageWebView: WKWebView?

    // Initializer for the mock
    public init(messageName: String, messageBody: Any, messageHost: String, isMainFrame: Bool, messageWebView: WKWebView?) {
        self.messageName = messageName
        self.messageBody = messageBody
        self.messageHost = messageHost
        self.isMainFrame = isMainFrame
        self.messageWebView = messageWebView
    }

    // Convenience initializer
    public init(name: String, body: Any) {
        self.messageName = name
        self.messageBody = body
        self.messageHost = "localhost" // Default value
        self.isMainFrame = true // Default value
        self.messageWebView = nil // Default value
    }
}

//
//  YoutublePlayerNavigationHandlerTests.swift
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

import XCTest
import WebKit
import ContentScopeScripts
import Combine
import BrowserServicesKit

@testable import DuckDuckGo

class DuckPlayerNavigationHandlerTests: XCTestCase {
    
    var webView: WKWebView!
    var mockWebView: MockWebView!
    var mockNavigationDelegate: MockWKNavigationDelegate!
    var mockAppSettings: AppSettingsMock!
    var mockPrivacyConfig: PrivacyConfigurationManagerMock!
    
    override func setUp() {
        super.setUp()
        webView = WKWebView()
        mockWebView = MockWebView()
        mockNavigationDelegate = MockWKNavigationDelegate()
        mockAppSettings = AppSettingsMock()
        mockPrivacyConfig = PrivacyConfigurationManagerMock()
        webView.navigationDelegate = mockNavigationDelegate
    }
    
    override func tearDown() {
        webView.navigationDelegate = nil
        mockWebView = nil
        mockNavigationDelegate = nil
        super.tearDown()
    }
    
    // Test for htmlTemplatePath existence
    func testHtmlTemplatePathExists() {
        let templatePath = DuckPlayerNavigationHandler.htmlTemplatePath
        let fileExists = FileManager.default.fileExists(atPath: templatePath)
        XCTAssertFalse(templatePath.isEmpty, "The template path should not be empty")
        XCTAssertTrue(fileExists, "The template file should exist at the specified path")
    }
    
    // Test for makeDuckPlayerRequest(from:)
    func testMakeDuckPlayerRequestFromOriginalRequest() {
        let originalRequest = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!)
        
        let duckPlayerRequest = DuckPlayerNavigationHandler.makeDuckPlayerRequest(from: originalRequest)
        
        XCTAssertEqual(duckPlayerRequest.url?.host, "www.youtube-nocookie.com")
        XCTAssertEqual(duckPlayerRequest.url?.path, "/embed/abc123")
        XCTAssertEqual(duckPlayerRequest.url?.query?.contains("t=10s"), true)
        XCTAssertEqual(duckPlayerRequest.value(forHTTPHeaderField: "Referer"), "http://localhost")
        XCTAssertEqual(duckPlayerRequest.httpMethod, "GET")
    }
    
    // Test for makeDuckPlayerRequest(for:timestamp:)
    func testMakeDuckPlayerRequestForVideoID() {
        let videoID = "abc123"
        let timestamp = "10s"
        
        let duckPlayerRequest = DuckPlayerNavigationHandler.makeDuckPlayerRequest(for: videoID, timestamp: timestamp)
        
        XCTAssertEqual(duckPlayerRequest.url?.host, "www.youtube-nocookie.com")
        XCTAssertEqual(duckPlayerRequest.url?.path, "/embed/abc123")
        XCTAssertEqual(duckPlayerRequest.url?.query?.contains("t=10s"), true)
        XCTAssertEqual(duckPlayerRequest.value(forHTTPHeaderField: "Referer"), "http://localhost")
        XCTAssertEqual(duckPlayerRequest.httpMethod, "GET")
    }
    
    // Test for makeHTMLFromTemplate
    func testMakeHTMLFromTemplate() {
        let expectedHtml = try? String(contentsOfFile: DuckPlayerNavigationHandler.htmlTemplatePath)
        let html = DuckPlayerNavigationHandler.makeHTMLFromTemplate()
        XCTAssertEqual(html, expectedHtml)
    }
    
    // MARK: handleURLChange tests
    @MainActor
    func testHandleURLChangeDuckPlayerEnabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: youtubeURL, webView: mockWebView)
        
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
        
    }
    
    @MainActor
    func testHandleURLChangeDuckPlayerDisabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: youtubeURL, webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request NOT to be loaded")
        
    }
    
    @MainActor
    func testHandleURLChangeDuckPlayerTemporarilyDisabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.isDuckPlayerTemporarilyDisabled = true
        
        handler.handleURLChange(url: youtubeURL, webView: mockWebView)
        
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "https")
            XCTAssertEqual(loadedRequest.url?.host, "m.youtube.com")
            XCTAssertEqual(loadedRequest.url?.path, "/watch")
            XCTAssertEqual(loadedRequest.url?.query?.contains("v=abc123"), true)
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    
    @MainActor
    func testHandleURLChangeNonYouTubeURL() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: nonYouTubeURL, webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request NOT to be loaded")
    }
    
    @MainActor
    func testHandleNavigationOpenInYoutubeLink() {
        let duckURL = URL(string: "duck://player/openInYoutube?v=12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckURL))
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleNavigation(navigationAction, webView: mockWebView)
        
        XCTAssertTrue(handler.isDuckPlayerTemporarilyDisabled, "Expected DuckPlayer to be temporarily disabled")
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "https")
            XCTAssertEqual(loadedRequest.url?.host, "m.youtube.com")
            XCTAssertEqual(loadedRequest.url?.path, "/watch")
            XCTAssertEqual(loadedRequest.url?.query?.contains("v=12345"), true)
        }
    }
    
    @MainActor
    func testHandleNavigationDuckPlayerEnabledAlreadyInDuckPlayer() {
        let duckPlayerURL = URL(string: "duck://player/CYTASDSD")!
        
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckPlayerURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings)
        player.settings.setMode(.enabled)
        
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        handler.handleNavigation(navigationAction, webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
    }
    
    
    @MainActor
    func testHandleNavigationDuckPlayerDisabled() {
        let duckPlayerURL = URL(string: "duck://player/CUIUIIUI")!
        
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckPlayerURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
                
        handler.handleNavigation(navigationAction, webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
    }
    
    @MainActor
    func testHandleDecidePolicyForVideoJustHandled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        // Call handleDecidePolicyFor twice with the same URL to simulate handling the same video twice
        handler.handleDecidePolicyFor(navigationAction, webView: mockWebView)
        
        // Wait for 0.8 seconds to simulate the time delay
        let expectation = self.expectation(description: "Wait for 0.8 seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            handler.handleDecidePolicyFor(navigationAction, webView: self.mockWebView)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        // Verify that the second call did not load a new request
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected no new request to be loaded since video was just handled")
    }
    
    @MainActor
    func testHandleDecidePolicyForTransformYoutubeURL() {
        
        let youtubeURL = URL(string: "https://m.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.enabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleDecidePolicyFor(navigationAction, webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
     
    }
    
    @MainActor
    func testHandleReloadForDuckPlayerVideoWithDuckPlayerDisabled() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        mockWebView.setCurrentURL(duckPlayerURL)
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
        
    }
    
    @MainActor
    func testHandleReloadForNonDuckPlayerVideoWithDuckPlayerEnabled() {
        let nonDuckPlayerURL = URL(string: "https://www.google.com")!
        
        // Simulate the current URL
        mockWebView.setCurrentURL(nonDuckPlayerURL)
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    @MainActor
    func testHandleReloadForNonDuckPlayerVideoWithDuckPlayerDisabled() {
        let nonDuckPlayerURL = URL(string: "https://www.google.com")!
        
        // Simulate the current URL
        mockWebView.setCurrentURL(nonDuckPlayerURL)
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }

}

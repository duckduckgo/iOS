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
    var playerSettings: MockDuckPlayerSettings!
    var player: MockDuckPlayer!
    
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
    
    
   // MARK: - Decide policyFor Tests
    
    @MainActor
    func testDecidePolicyForVideoWasAlreadyHandled() {
        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.lastHandledVideoID = "abc123"
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .cancel, "Expected navigation policy to be .cancel")

    }
    
    @MainActor
    func testDecidePolicyForVideosThatShouldLoadInYoutube() {
        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s&embeds_referring_euri=somevalue")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")

    }
    
    @MainActor
    func testDecidePolicyForVideosThatShouldLoadInDuckPlayer() {
        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .cancel, "Expected navigation policy to be .cancel")

    }
    
    @MainActor
    func testDecidePolicyForOtherURLThatShouldLoadNormally() {
        
        let youtubeURL = URL(string: "https://www.google.com/")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")

    }
    
    // MARK: - HandleJS Navigation Tests
    
    @MainActor
    func testJSNavigationForVideoWasAlreadyHandled() {
     
        let url: URL = URL(string: "https://www.example.com/")!
        webView.load(URLRequest(url: url))
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
       
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.lastHandledVideoID = "abc123"
        handler.handleJSNavigation(url: youtubeURL, webView: webView)
        
        XCTAssertEqual(webView.url?.absoluteString, url.absoluteString)
    }
    
    @MainActor
    func testJSNavigationForVideoThatShouldLoadInYoutube() {
        
        let url: URL = URL(string: "https://www.example.com/")!
        webView.load(URLRequest(url: url))
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s&embeds_referring_euri=somevalue")!
       
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
                
        handler.handleJSNavigation(url: youtubeURL, webView: webView)
        
        XCTAssertEqual(webView.url?.absoluteString, url.absoluteString)
    }
    
    @MainActor
    func testJSNavigationForVideoThatShouldLoadInDuckPlayer() {
        
        let url: URL = URL(string: "https://www.example.com/")!
        webView.load(URLRequest(url: url))
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
                
        handler.handleJSNavigation(url: youtubeURL, webView: webView)
        
        XCTAssertEqual(webView.url?.absoluteString, "duck://player/abc123?t=10s")
    }
    
    // MARK: Handle Navigation Tests
    
    @MainActor
    func testAgeRestrictedVideoShouldNotBeHandled() {
        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s&embeds_referring_euri=somevalue")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleNavigation(navigationAction, webView: webView)
        XCTAssertEqual(webView.url, nil)
        
    }
    
    @MainActor
    func testHandleNavigationLoadsDuckPlayer() {
        
        let link = URL(string: "duck://player/12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: link))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTAssertEqual(self.webView.url?.absoluteString, "https://www.youtube-nocookie.com/embed/12345")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    
    }
    
    @MainActor
    func testHandleReloadForDuckPlayerVideo() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        handler.handleReload(webView: mockWebView)
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    
    @MainActor
    func testAttach() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player)
        handler.handleAttach(webView: mockWebView)
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    

}

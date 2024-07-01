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

class MockWKNavigationDelegate: NSObject, WKNavigationDelegate {
    var didFinishNavigation: ((WKWebView, WKNavigation?) -> Void)?
    var didFailNavigation: ((WKWebView, WKNavigation?, Error) -> Void)?
    var decidePolicyForNavigationAction: ((WKWebView, WKNavigationAction, @escaping (WKNavigationActionPolicy) -> Void) -> Void)?
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishNavigation?(webView, navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didFailNavigation?(webView, navigation, error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decidePolicyForNavigationAction?(webView, navigationAction, decisionHandler) ?? decisionHandler(.allow)
    }
}

class MockWebView: WKWebView {
    var didStopLoadingCalled = false
    var lastLoadedRequest: URLRequest?
    var lastResponseHTML: String?
    var goToCalledWith: WKBackForwardListItem?
    var canGoBackMock = false
    var currentURL: URL?
    
    private var _url: URL?
    override var url: URL? {
        return currentURL
    }
    
    func setCurrentURL(_ url: URL) {
        self.currentURL = url
    }
    
    override func stopLoading() {
        didStopLoadingCalled = true
    }
    
    override func load(_ request: URLRequest) -> WKNavigation? {
        lastLoadedRequest = request
        return nil
    }
    
    override func reload() -> WKNavigation? {
        return nil
    }
}

class MockNavigationAction: WKNavigationAction {
    private let _request: URLRequest
    
    init(request: URLRequest) {
        self._request = request
    }
    
    override var request: URLRequest {
        return _request
    }
}

final class MockDuckPlayerSettings: DuckPlayerSettingsProtocol {
    
    private let duckPlayerSettingsSubject = PassthroughSubject<Void, Never>()
    var duckPlayerSettingsPublisher: AnyPublisher<Void, Never> {
        duckPlayerSettingsSubject.eraseToAnyPublisher()
    }
    
    var mode: DuckPlayerMode = .disabled
    var askModeOverlayHidden: Bool = false
    
    init(appSettings: AppSettings = AppSettingsMock(), privacyConfigManager: any BrowserServicesKit.PrivacyConfigurationManaging) {}
    func triggerNotification() {}
    
    func setMode(_ mode: DuckPlayerMode) {
        self.mode = mode
    }
    
    
}

final class MockDuckPlayer: DuckPlayerProtocol {
    var settings: any DuckPlayerSettingsProtocol
    
    init(settings: DuckPlayerSettingsProtocol) {
        self.settings = settings
    }
    
    func setUserValues(params: Any, message: WKScriptMessage) -> (any Encodable)? {
        nil
    }
    
    func getUserValues(params: Any, message: WKScriptMessage) -> (any Encodable)? {
        nil
    }
    
    func openVideoInDuckPlayer(url: URL, webView: WKWebView) {
        
    }
    
    func initialSetup(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
}

class YoutubePlayerNavigationHandlerTests: XCTestCase {
    
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
        let templatePath = YoutubePlayerNavigationHandler.htmlTemplatePath
        let fileExists = FileManager.default.fileExists(atPath: templatePath)
        XCTAssertFalse(templatePath.isEmpty, "The template path should not be empty")
        XCTAssertTrue(fileExists, "The template file should exist at the specified path")
    }
    
    // Test for makeDuckPlayerRequest(from:)
    func testMakeDuckPlayerRequestFromOriginalRequest() {
        let originalRequest = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!)
        
        let duckPlayerRequest = YoutubePlayerNavigationHandler.makeDuckPlayerRequest(from: originalRequest)
        
        XCTAssertEqual(duckPlayerRequest.url?.host, "www.youtube-nocookie.com")
        XCTAssertEqual(duckPlayerRequest.url?.path, "/embed/abc123")
        XCTAssertEqual(duckPlayerRequest.url?.query?.contains("t=10s"), true)
        XCTAssertEqual(duckPlayerRequest.value(forHTTPHeaderField: "Referer"), "http://localhost/")
        XCTAssertEqual(duckPlayerRequest.httpMethod, "GET")
    }
    
    // Test for makeDuckPlayerRequest(for:timestamp:)
    func testMakeDuckPlayerRequestForVideoID() {
        let videoID = "abc123"
        let timestamp = "10s"
        
        let duckPlayerRequest = YoutubePlayerNavigationHandler.makeDuckPlayerRequest(for: videoID, timestamp: timestamp)
        
        XCTAssertEqual(duckPlayerRequest.url?.host, "www.youtube-nocookie.com")
        XCTAssertEqual(duckPlayerRequest.url?.path, "/embed/abc123")
        XCTAssertEqual(duckPlayerRequest.url?.query?.contains("t=10s"), true)
        XCTAssertEqual(duckPlayerRequest.value(forHTTPHeaderField: "Referer"), "http://localhost/")
        XCTAssertEqual(duckPlayerRequest.httpMethod, "GET")
    }
    
    // Test for makeHTMLFromTemplate
    func testMakeHTMLFromTemplate() {
        let expectedHtml = try? String(contentsOfFile: YoutubePlayerNavigationHandler.htmlTemplatePath)
        let html = YoutubePlayerNavigationHandler.makeHTMLFromTemplate()
        XCTAssertEqual(html, expectedHtml)
    }
    
    // Test for handleURLChange
    @MainActor
    func testHandleURLChangeDuckPlayerEnabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: youtubeURL, webView: mockWebView)
        
        XCTAssertTrue(mockWebView.didStopLoadingCalled, "Expected stopLoading to be called")
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
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: youtubeURL, webView: mockWebView)
        
        XCTAssertFalse(mockWebView.didStopLoadingCalled, "Expected stopLoading Not to be called")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
        
    }
    
    @MainActor
    func testHandleURLChangeForNonYouTubeVideo() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)
        
        handler.handleURLChange(url: nonYouTubeURL, webView: mockWebView)
        
        XCTAssertFalse(mockWebView.didStopLoadingCalled, "Expected stopLoading not to be called")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    // Test for handleDecidePolicyFor
    @MainActor
    func testHandleDecidePolicyForWithDuckPlayerEnabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
                
    }
    
    @MainActor
    func testHandleDecidePolicyForWithDuckPlayerDisabled() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
                
    }
    
    @MainActor
    func testHandleDecidePolicyForNonYouTubeVideoWithDuckPlayerEnabled() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: nonYouTubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    @MainActor
    func testHandleDecidePolicyForNonYouTubeVideoWithDuckPlayerDisabled() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: nonYouTubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        let player = MockDuckPlayer(settings: playerSettings)
        let handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    @MainActor
    func testHandleReloadForDuckPlayerVideoWithDuckPlayerEnabled() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        mockWebView.setCurrentURL(duckPlayerURL)
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    
    @MainActor
    func testHandleReloadForDuckPlayerVideoWithDuckPlayerDisabled() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        mockWebView.setCurrentURL(duckPlayerURL)
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
        
    }

    @MainActor
    func testHandleReloadForNonDuckPlayerVideoWithDuckPlayerEnabled() {
        let nonDuckPlayerURL = URL(string: "https://www.google.com")!
        
        // Simulate the current URL
        mockWebView.setCurrentURL(nonDuckPlayerURL)
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.alwaysAsk)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    @MainActor
    func testHandleReloadForNonDuckPlayerVideoWithDuckPlayerDisabled() {
        let nonDuckPlayerURL = URL(string: "https://www.google.com")!
        
        // Simulate the current URL
        mockWebView.setCurrentURL(nonDuckPlayerURL)
        
        var playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.setMode(.disabled)
        var player = MockDuckPlayer(settings: playerSettings)
        var handler = YoutubePlayerNavigationHandler(duckPlayer: player)

        handler.handleReload(webView: mockWebView)
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
}

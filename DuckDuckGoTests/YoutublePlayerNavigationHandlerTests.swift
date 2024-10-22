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
import Core

@testable import DuckDuckGo

class DuckPlayerNavigationHandlerTests: XCTestCase {
    
    var webView: WKWebView!
    var mockWebView: MockWebView!
    var mockNavigationDelegate: MockWKNavigationDelegate!
    var mockAppSettings: AppSettingsMock!
    var mockPrivacyConfig: PrivacyConfigurationManagerMock!
    var playerSettings: MockDuckPlayerSettings!
    var player: MockDuckPlayer!
    var featureFlagger: FeatureFlagger!
    
    override func setUp() {
        super.setUp()
        webView = WKWebView()
        mockWebView = MockWebView()
        mockNavigationDelegate = MockWKNavigationDelegate()
        mockAppSettings = AppSettingsMock()
        mockPrivacyConfig = PrivacyConfigurationManagerMock()
        featureFlagger = MockDuckPlayerFeatureFlagger()
        webView.navigationDelegate = mockNavigationDelegate
        
    }
    
    override func tearDown() {
        webView.navigationDelegate = nil
        mockWebView = nil
        mockNavigationDelegate = nil
        PixelFiringMock.tearDown()
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
    
    
    // MARK: Handle Navigation Tests
    
    @MainActor
    func testAgeRestrictedVideoShouldNotBeHandled() {
        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s&embeds_referring_euri=somevalue")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.handleNavigation(navigationAction, webView: webView)
        XCTAssertEqual(webView.url, youtubeURL)
        
    }
    
    @MainActor
    func testHandleNavigationLoadsDuckPlayerWhenEnabled() {
        
        let link = URL(string: "duck://player/12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: link))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTAssertEqual(self.webView.url?.absoluteString, "https://www.youtube-nocookie.com/embed/12345")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    
    }
    
    @MainActor
    func testHandleNavigationLoadsDuckPlayerWhenAskMode() {
        
        let link = URL(string: "duck://player/12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: link))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .alwaysAsk
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTAssertEqual(self.webView.url?.absoluteString, "https://www.youtube-nocookie.com/embed/12345")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    
    }
    
    @MainActor
    func testHandleNavigationWithDuckPlayerDisabledRedirectsToYoutube() {
        
        let link = URL(string: "duck://player/12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: link))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .disabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Youtube URL request")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            guard let redirectedURL = self.webView.url,
                  let components = URLComponents(url: redirectedURL, resolvingAgainstBaseURL: false) else {
                XCTFail("URL is missing or could not be parsed.")
                expectation.fulfill()
                return
            }
            
            // Extract path and video ID from the redirected URL
            let isWatchPath = components.path == "/watch"
            let videoID = components.queryItems?.first(where: { $0.name == "v" })?.value
            
            XCTAssertTrue(isWatchPath, "Expected the path to be /watch.")
            XCTAssertEqual(videoID, "12345", "Expected the video ID to match.")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    @MainActor
    func testHandleNavigationLoadsOpenInYoutubeURL() {
        
        let link = URL(string: "duck://player/openInYoutube?v=12345")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: link))
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .alwaysAsk
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Youtube Redirect Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            XCTAssertEqual(self.webView.url?.absoluteString, "https://m.youtube.com/watch?v=12345&embeds_referring_euri=some_value")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    
    }
    
    
    // MARK: Handle URL Change tests
    @MainActor
    func testReturnsNotHandledWhenAlreadyDuckAddress() {
        let url = URL(string: "duck://player/12345")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .disabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)
                
        switch result {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .isAlreadyDuckAddress, "Expected .isAlreadyDuckAddress, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.isAlreadyDuckAddress), but got \(result).")
        }
    }
    
    @MainActor
    func testReturnsNotHandledWhenURLNotChanged() {
        let url = URL(string: "https://duckduckgo.com/?t=h_&q=search&ia=web")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Load the first URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)

        // Try to handle the same URL
        let result2 = handler.handleURLChange(webView: mockWebView)
                
        switch result2 {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .urlHasNotChanged, "Expected .urlHasNotChanged, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.urlHasNotChanged), but got \(result).")
        }
    }
        
    @MainActor
    func testReturnsNotHandledWhenDuckPlayerDisabled() {
        let url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .disabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)
                
        switch result {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .duckPlayerDisabled, "Expected .duckPlayerDisabled, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.duckPlayerDisabled), but got \(result).")
        }
    }
    
    @MainActor
    func testReturnsNotHandledWhenNoVideoDetailsPresent() {
        let url = URL(string: "https://www.vimeo.com/video=I9J120SZT14")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)
                
        switch result {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .videoIDNotPresent, "Expected .videoIDNotPresent, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.videoIDNotPresent), but got \(result).")
        }
    }
    
    @MainActor
    func testReturnsNotHandledWhenVideoAlreadyRendered() {
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        let url1 = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        _ = mockWebView.load(URLRequest(url: url1))
        let result1 = handler.handleURLChange(webView: mockWebView)
        
        // Load the Same video but slightly different URL (Redirecting to the m subdomain is quite common)
        let url2 = URL(string: "https://m.youtube.com/watch?v=I9J120SZT14")!
        _ = mockWebView.load(URLRequest(url: url2))
        let result2 = handler.handleURLChange(webView: mockWebView)
        
        switch result2 {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .videoAlreadyHandled, "Expected .videoAlreadyHandled, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.videoAlreadyHandled), but got \(result2).")
        }
    }
    
    @MainActor
    func testReturnsNotHandledWhenShouldBeDisabledForNextVideo() {
        let url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        playerSettings.allowFirstVideo = true
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)
                
        switch result {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .disabledForNextVideo, "Expected .disabledForNextVideo, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.disabledForNextVideo), but got \(result).")
        }
    }
    
    @MainActor
    func testReturnsNotHandledForYoutubePlayerLinks() {
        let url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14&&embeds_referring_euri=somevalue")!
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        playerSettings.allowFirstVideo = true
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        // Simulate webView loading the URL
        _ = mockWebView.load(URLRequest(url: url))
                
        let result = handler.handleURLChange(webView: mockWebView)
                
        switch result {
        case .notHandled(let reason):
            XCTAssertEqual(reason, .disabledForNextVideo, "Expected .disabledForNextVideo, but got \(reason).")
        default:
            XCTFail("Expected .notHandled(.disabledForNextVideo), but got \(result).")
        }
    }
    
    
    // MARK: Navigational Actions
    @MainActor
    func testHandleReloadForDuckPlayerVideo() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
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
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        handler.handleAttach(webView: mockWebView)
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    
    func testGetURLForYoutubeNoCookieWithDuckPlayerEnabled() {
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let  handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        var url = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
        var duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, "duck://player/abc123?t=10s")
        
        url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, url.absoluteString)
        
    }
    
    func testGetURLForYoutubeNoCookieWithDuckPlayerAskMode() {
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .alwaysAsk
        
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let  handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        var url = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
        var duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, "duck://player/abc123?t=10s")
        
        url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, url.absoluteString)
        
    }
    
    func testGetURLForYoutubeNoCookieWithDuckPlayerDisabled() {
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .disabled
        
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let  handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        var url = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
        var duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, url.absoluteString)
        
        url = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        duckURL = handler.getDuckURLFor(url).absoluteString
        XCTAssertEqual(duckURL, url.absoluteString)
        
    }
    
    func testShouldOpenInNewTabWhenEnabled() {
        let youtubeURL = URL(string: "duck://player/abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        
        mockAppSettings.duckPlayerOpenInNewTab = true
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
                
        handler.navigationType = .linkActivated
        playerSettings.mode = .enabled
                
        XCTAssertTrue(handler.shouldOpenInNewTab(navigationAction, webView: webView))
    }
    
    func testShouldNotOpenInNewTabWhenNotDuckPlayerURL() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=I9J120SZT14")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        
        mockAppSettings.duckPlayerOpenInNewTab = true
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.navigationType = .linkActivated
        playerSettings.mode = .enabled
        
        XCTAssertFalse(handler.shouldOpenInNewTab(navigationAction, webView: webView))
    }
    
    func testShouldNotOpenInNewTabWhenDisabled() {
        let youtubeURL = URL(string: "duck://player/abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        
        mockAppSettings.duckPlayerOpenInNewTab = false
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
                
        handler.navigationType = .linkActivated
        playerSettings.mode = .enabled
                
        XCTAssertFalse(handler.shouldOpenInNewTab(navigationAction, webView: webView))
    }
    
    
    func testHandleJSNavigationEventWhenEnabled() {
        let youtubeURL = URL(string: "duck://player/abc123")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        playerSettings.mode = .enabled
        mockAppSettings.duckPlayerOpenInNewTab = true
        
        handler.handleEvent(event: .JSTriggeredNavigation, url: youtubeURL, navigationAction: nil)
        
        XCTAssertTrue(handler.navigationType == .linkActivated)
    }
    
    func testHandleJSNavigationEventWhenDisabled() {
        let youtubeURL = URL(string: "duck://player/abc123")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        playerSettings.mode = .enabled
        mockAppSettings.duckPlayerOpenInNewTab = false
        
        handler.handleEvent(event: .JSTriggeredNavigation, url: youtubeURL, navigationAction: nil)
        
        XCTAssertFalse(handler.navigationType == .linkActivated)
    }
    
    func testHandleJSNavigationEventWhenDuckPlayerDisabled() {
        let youtubeURL = URL(string: "duck://player/abc123")!
        
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings)
        
        handler.navigationType = .linkActivated
        playerSettings.mode = .disabled
        mockAppSettings.duckPlayerOpenInNewTab = true
        
        handler.handleEvent(event: .JSTriggeredNavigation, url: youtubeURL, navigationAction: nil)
        
        XCTAssertFalse(handler.navigationType == .linkActivated)
    }
     
    
    // MARK: Pixel firing tests
    @MainActor
    func testPixelsAreFiredWhenEnabledAndReferrerIsSERP() {
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings, pixelFiring: PixelFiringMock.self)
        
        // Simulate Searching for a video in DuckDuckGo
        let link1 = URL(string: "https://www.duckduckgo.com/search?q=metallica+videos")!
        _ = mockWebView.load(URLRequest(url: link1))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Navigate to Duck Player
        let link2 = URL(string: "duck://player/I9J120SZT14")!
        _ = mockWebView.load(URLRequest(url: link2))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Now navigate to DuckPlayer
        let navigationAction = MockNavigationAction(request: URLRequest(url: link2))
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if PixelFiringMock.allPixelsFired.count != 2 {
                XCTFail("Pixel count should be two, but was \(PixelFiringMock.allPixelsFired.count)")
                return
            }
            
            // Validate the first pixel
            let firstPixel = PixelFiringMock.allPixelsFired[0]
            XCTAssertEqual(firstPixel.pixelName, Pixel.Event.duckPlayerDailyUniqueView.name)
            XCTAssertEqual(firstPixel.params, ["settings": "enabled"])
            XCTAssertNil(firstPixel.includedParams)

            // Validate the second pixel
            let secondPixel = PixelFiringMock.allPixelsFired[1]
            XCTAssertEqual(secondPixel.pixelName, Pixel.Event.duckPlayerViewFromSERP.name)
            XCTAssertEqual(secondPixel.params, [:])
            XCTAssertNil(secondPixel.includedParams)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    @MainActor
    func testPixelsAreFiredWhenEnabledAndReferrerIsOther() {
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings, pixelFiring: PixelFiringMock.self)
        
        // Simulate Searching for a video in DuckDuckGo
        let link1 = URL(string: "https://www.google.com/search?q=metallica+videos")!
        _ = mockWebView.load(URLRequest(url: link1))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Navigate to Duck Player
        let link2 = URL(string: "duck://player/I9J120SZT14")!
        _ = mockWebView.load(URLRequest(url: link2))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Now navigate to DuckPlayer
        let navigationAction = MockNavigationAction(request: URLRequest(url: link2))
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if PixelFiringMock.allPixelsFired.count != 2 {
                XCTFail("Pixel count should be two, but was \(PixelFiringMock.allPixelsFired.count)")
                return
            }
            
            // Validate the first pixel
            let firstPixel = PixelFiringMock.allPixelsFired[0]
            XCTAssertEqual(firstPixel.pixelName, Pixel.Event.duckPlayerDailyUniqueView.name)
            XCTAssertEqual(firstPixel.params, ["settings": "enabled"])
            XCTAssertNil(firstPixel.includedParams)

            // Validate the second pixel
            let secondPixel = PixelFiringMock.allPixelsFired[1]
            XCTAssertEqual(secondPixel.pixelName, Pixel.Event.duckPlayerViewFromOther.name)
            XCTAssertEqual(secondPixel.params, [:])
            XCTAssertNil(secondPixel.includedParams)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
    @MainActor
    func testPixelsAreFiredWhenEnabledAndAutomaticNavigation() {
        
        // Set up mock player settings and player
        let playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings, privacyConfigManager: mockPrivacyConfig)
        playerSettings.mode = .enabled
        let player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)
        let handler = DuckPlayerNavigationHandler(duckPlayer: player, featureFlagger: featureFlagger, appSettings: mockAppSettings, pixelFiring: PixelFiringMock.self)
        
        // Simulate A Youtube Page
        let link1 = URL(string: "https://www.youtube.com/watch?v=1234")!
        _ = mockWebView.load(URLRequest(url: link1))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Navigate to Duck Player
        let link2 = URL(string: "duck://player/I9J120SZT14")!
        _ = mockWebView.load(URLRequest(url: link2))
        _ = handler.handleURLChange(webView: mockWebView)
        
        // Now navigate to DuckPlayer
        let navigationAction = MockNavigationAction(request: URLRequest(url: link2))
        
        handler.handleNavigation(navigationAction, webView: webView)
                
        let expectation = self.expectation(description: "Simulated Request Expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            if PixelFiringMock.allPixelsFired.count != 2 {
                XCTFail("Pixel count should be two, but was \(PixelFiringMock.allPixelsFired.count)")
                return
            }
            
            // Validate the first pixel
            let firstPixel = PixelFiringMock.allPixelsFired[0]
            XCTAssertEqual(firstPixel.pixelName, Pixel.Event.duckPlayerDailyUniqueView.name)
            XCTAssertEqual(firstPixel.params, ["settings": "enabled"])
            XCTAssertNil(firstPixel.includedParams)

            // Validate the second pixel
            let secondPixel = PixelFiringMock.allPixelsFired[1]
            XCTAssertEqual(secondPixel.pixelName, Pixel.Event.duckPlayerViewFromYoutubeAutomatic.name)
            XCTAssertEqual(secondPixel.params, [:])
            XCTAssertNil(secondPixel.includedParams)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }
    
}

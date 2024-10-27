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
import Combine
import BrowserServicesKit
import Core

@testable import DuckDuckGo

class DuckPlayerNavigationHandlerTests: XCTestCase {

    var mockWebView: MockWebView!
    var mockAppSettings: AppSettingsMock!
    var mockPrivacyConfig: PrivacyConfigurationManagerMock!
    var playerSettings: MockDuckPlayerSettings!
    var player: MockDuckPlayer!
    var featureFlagger: MockDuckPlayerFeatureFlagger!
    var handler: DuckPlayerNavigationHandler!
    var tabNavigator: MockDuckPlayerTabNavigator!

    override func setUp() {
        super.setUp()
        mockWebView = MockWebView()
        mockAppSettings = AppSettingsMock()
        mockAppSettings.duckPlayerOpenInNewTab = false // Disable openInNewTab
        mockPrivacyConfig = PrivacyConfigurationManagerMock()
        playerSettings = MockDuckPlayerSettings(appSettings: mockAppSettings,
                                                privacyConfigManager: mockPrivacyConfig)
        featureFlagger = MockDuckPlayerFeatureFlagger()
        player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)

        // Create and assign the mock tab navigator
        tabNavigator = MockDuckPlayerTabNavigator()

        handler = DuckPlayerNavigationHandler(duckPlayer: player,
                                              featureFlagger: featureFlagger,
                                              appSettings: mockAppSettings,
                                              pixelFiring: PixelFiringMock.self)

        // Inject the mock tab navigator
        handler.tabNavigationHandler = tabNavigator

        PixelFiringMock.tearDown()
    }

    override func tearDown() {
        mockWebView = nil
        mockAppSettings = nil
        mockPrivacyConfig = nil
        playerSettings = nil
        player = nil
        featureFlagger = nil
        tabNavigator = nil
        handler = nil
        PixelFiringMock.tearDown()
        super.tearDown()
    }

    // MARK: - Test Cases

    @MainActor
    func testHandleNavigation_MultipleCalls_WithinHalfSecond_OnlyProcessesFirst() async {
        // Arrange
        let youtubeURL1 = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let youtubeURL2 = URL(string: "https://www.youtube.com/watch?v=def456")!
        let youtubeURL3 = URL(string: "https://www.youtube.com/watch?v=ghi789")!
        let navigationAction1 = MockNavigationAction(request: URLRequest(url: youtubeURL1))
        let navigationAction2 = MockNavigationAction(request: URLRequest(url: youtubeURL2))
        let navigationAction3 = MockNavigationAction(request: URLRequest(url: youtubeURL3))
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true
        mockWebView.loadedRequests = []
        mockWebView.loadCallCount = 0

        // Act
        handler.handleDuckNavigation(navigationAction1, webView: mockWebView)
        handler.handleDuckNavigation(navigationAction2, webView: mockWebView)
        handler.handleDuckNavigation(navigationAction3, webView: mockWebView)

        // Wait for a short time to allow any asynchronous processing
        await Task.sleep(UInt64(0.1 * Double(NSEC_PER_SEC)))

        // Assert
        XCTAssertEqual(mockWebView.loadCallCount, 1, "Expected only one request to be loaded")
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
        } else {
            XCTFail("DuckPlayer was not loaded")
        }
    }

    @MainActor
    func testHandleNavigation_DuckPlayerModeDisabled_AlwaysRedirectsToYouTube() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/123123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckPlayerURL))
        playerSettings.mode = .disabled  // DuckPlayer mode is disabled
        featureFlagger.isFeatureEnabled = true  // Feature is enabled

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
        await Task.yield()
        // It should redirect to YouTube
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.host, "m.youtube.com")
            XCTAssertEqual(loadedRequest.url?.path, "/watch")
            XCTAssertTrue(loadedRequest.url?.query?.contains("v=123123") ?? false)
        } else {
            XCTFail("YouTube was not loaded")
        }
    }
    
    @MainActor
    func testHandleNavigation_OpenInYouTubeURL_AlwaysRedirectsToYouTube() async {
        // Arrange
        let openInYouTubeURL = URL(string: "duck://player/openInYoutube?v=12311")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: openInYouTubeURL))
        playerSettings.mode = .enabled  // DuckPlayer mode is enabled
        featureFlagger.isFeatureEnabled = true  // Feature is enabled

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
        XCTAssertTrue(tabNavigator.isNewTab, "Expected a new tab to be opened")
        if let openedURL = tabNavigator.openedURL {
            XCTAssertEqual(openedURL.host, "m.youtube.com")
            XCTAssertEqual(openedURL.path, "/watch")
            XCTAssertTrue(openedURL.query?.contains("v=12311") ?? false)
        } else {
            XCTFail("No URL was opened in a new tab")
        }
    }

    @MainActor
    func testHandleNavigation_YouTubeURL_WithWatchInYouTubeParameter_RedirectsToYouTube() async {
        // Arrange
        let youtubeURL = URL(string: "https://m.youtube.com/watch?v=abc123&embeds_referring_euri=true")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
        // It should redirect to YouTube
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.host, "m.youtube.com")
            XCTAssertEqual(loadedRequest.url?.path, "/watch")
            XCTAssertTrue(loadedRequest.url?.query?.contains("v=abc123") ?? false)
        } else {
            XCTFail("YouTube was not loaded")
        }
    }

    @MainActor
    func testHandleNavigation_YouTubeURL_WithoutWatchInYouTubeParameter_RedirectsToDuckPlayer() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
        // It should redirect to DuckPlayer
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
        } else {
            XCTFail("DuckPlayer was not loaded")
        }
    }
    
    // MARK: - Tests for handleURLChange

    @MainActor
    func testHandleURLChange_MultipleCallsWithinOneSecond_ReturnsDuplicateNavigation() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        mockWebView.setCurrentURL(youtubeURL)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let result1 = handler.handleURLChange(webView: mockWebView)
        
        // Wait less than one second before calling again
        await Task.sleep(UInt64(0.5 * Double(NSEC_PER_SEC)))
        
        let result2 = handler.handleURLChange(webView: mockWebView)

        // Assert
        if case .handled = result1 {
            // Success
        } else {
            XCTFail("Expected first call to return .handled")
        }

        if case .notHandled(.duplicateNavigation) = result2 {
            // Success
        } else {
            XCTFail("Expected second call to return .duplicateNavigation")
        }
    }

    @MainActor
    func testHandleURLChange_DuckPlayerURL_ReturnsHandled() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/abc123")!
        mockWebView.setCurrentURL(duckPlayerURL)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let result = handler.handleURLChange(webView: mockWebView)

        if case .notHandled(.isNotYoutubeWatch) = result {
            // Success
        } else {
            XCTFail("Expected .unhandled for duck:// URLs")
        }
    }

    @MainActor
    func testHandleURLChange_NonYouTubeURL_ReturnsUnhandled() async {
        // Arrange
        let nonYouTubeURL = URL(string: "https://www.example.com")!
        mockWebView.setCurrentURL(nonYouTubeURL)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let result = handler.handleURLChange(webView: mockWebView)

        // Assert
        if case .notHandled(.invalidURL) = result {
            // Success
        } else {
            XCTFail("Expected .unhandled for non-YouTube URL")
        }
    }

    @MainActor
    func testHandleURLChange_YouTubeURL_DuckPlayerModeDisabled_ReturnsUnhandled() async {
        // Arrange
        let youtubeURL = URL(string: "https://m.youtube.com/watch?v=abc123")!
        mockWebView.setCurrentURL(youtubeURL)
        playerSettings.mode = .disabled  // DuckPlayer mode is disabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let result = handler.handleURLChange(webView: mockWebView)

        // Assert
        if case .notHandled(.duckPlayerDisabled) = result {
            // Success
        } else {
            XCTFail("Expected .unhandled when DuckPlayer mode is disabled")
        }
    }

    @MainActor
    func testHandleURLChange_YouTubeURL_FeatureFlagDisabled_ReturnsUnhandled() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        mockWebView.setCurrentURL(youtubeURL)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = false  // Feature is disabled

        // Act
        let result = handler.handleURLChange(webView: mockWebView)

        // Assert
        if case .notHandled(.featureOff) = result {
            // Success
        } else {
            XCTFail("Expected .unhandled when feature flag is disabled")
        }
    }
    
    @MainActor
    func testHandleDelegateNavigation_YouTubeURL_DuckPlayerEnabled_ReturnsTrue() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation to be cancelled as it's not mainframe navigation")
    }

    @MainActor
    func testHandleDelegateNavigation_NonYouTubeURL_ReturnsFalse() async {
        // Arrange
        let nonYouTubeURL = URL(string: "https://www.example.com")!
        let request = URLRequest(url: nonYouTubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled for non-YouTube URL")
    }

    @MainActor
    func testHandleDelegateNavigation_YouTubeURL_DuckPlayerDisabled_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .disabled  // DuckPlayer mode is disabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled when DuckPlayer is disabled")
    }

    @MainActor
    func testHandleDelegateNavigation_YouTubeURL_FeatureFlagDisabled_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = false  // Feature is disabled

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled when feature flag is disabled")
    }

    @MainActor
    func testHandleDelegateNavigation_DuckPlayerURL_ReturnsFalse() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/abc123")!
        let request = URLRequest(url: duckPlayerURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .enabled
        featureFlagger.isFeatureEnabled = true

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled for DuckPlayer URL")
    }
}

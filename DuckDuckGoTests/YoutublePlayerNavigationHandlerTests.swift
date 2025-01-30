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
    var mockInternalUserDecider: MockDuckPlayerInternalUserDecider!
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
                                                privacyConfigManager: mockPrivacyConfig,
                                                internalUserDecider: MockDuckPlayerInternalUserDecider())
        featureFlagger = MockDuckPlayerFeatureFlagger()
        player = MockDuckPlayer(settings: playerSettings, featureFlagger: featureFlagger)

        // Create and assign the mock tab navigator
        tabNavigator = MockDuckPlayerTabNavigator()

        handler = DuckPlayerNavigationHandler(duckPlayer: player,
                                              featureFlagger: featureFlagger,
                                              appSettings: mockAppSettings,
                                              pixelFiring: PixelFiringMock.self,
                                              dailyPixelFiring: PixelFiringMock.self)

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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]
        mockWebView.loadedRequests = []
        mockWebView.loadCallCount = 0

        // Act
        handler.handleDuckNavigation(navigationAction1, webView: mockWebView)
        handler.handleDuckNavigation(navigationAction2, webView: mockWebView)
        handler.handleDuckNavigation(navigationAction3, webView: mockWebView)

        // Wait for a short time to allow any asynchronous processing
        try? await Task.sleep(nanoseconds: 100_000_000)

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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]  // Feature is enabled

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]  // Feature is enabled
        
        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        // Assert
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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)

        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertTrue(loadedRequest.url?.query?.contains("referrer=other") ?? false)
        } else {
            XCTFail("DuckPlayer was not loaded")
        }
    }
    
    @MainActor
    func testHandleNavigation_ToDirectDuckURLInNewTab_OpenInNewTabWithParameters() async {
        // Arrange
        let youtubeURL = URL(string: "duck://player/abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        playerSettings.mode = .enabled
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)
        
        // Assert
        if let openedURL = tabNavigator.openedURL {
            XCTAssertEqual(openedURL.host, "player")
            XCTAssertEqual(openedURL.path, "/abc123")
            XCTAssertTrue(openedURL.query?.contains("referrer=other") ?? false)
        } else {
            XCTFail("No URL was opened in a new tab")
        }
    }
    
    @MainActor
    func testHandleNavigation_ToYouTubeWatchInAskMode_RedirectsToDuckPlayerWithParameters() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        playerSettings.mode = .alwaysAsk
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)
        
        // Assert
        if let openedURL = tabNavigator.openedURL {
            XCTAssertEqual(openedURL.host, "player")
            XCTAssertEqual(openedURL.path, "/abc123")
            XCTAssertTrue(openedURL.query?.contains("referrer=other") ?? false)
        } else {
            XCTFail("No URL was opened in a new tab")
        }
    }
    
    @MainActor
    func testHandleNavigation_WithReferrerInURL_UpdatesDuckPlayerReferrer() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&dp_referrer=serp")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        playerSettings.mode = .alwaysAsk
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)
        
        // Assert
        XCTAssertEqual(handler.referrer, .serp)
        
    }
    
    @MainActor
    func testHandleDelegateNavigation_DuckPlayerURL_CancelNavigationAndLoadsDuckPlayerWithParamsInTab() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/abc123")!
        let request = URLRequest(url: duckPlayerURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        handler.handleDuckNavigation(navigationAction, webView: mockWebView)
        
        // Assert
        if let openedURL = tabNavigator.openedURL {
            XCTAssertEqual(openedURL.host, "player")
            XCTAssertEqual(openedURL.path, "/abc123")
            XCTAssertTrue(openedURL.query?.contains("referrer=other") ?? false)
        } else {
            XCTFail("No URL was opened in a new tab")
        }
    }
    
    // MARK: - Tests for handleURLChange

    @MainActor
    func testHandleURLChange_MultipleCallsWithinOneSecond_ReturnsDuplicateNavigation() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        mockWebView.setCurrentURL(youtubeURL)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let result1 = handler.handleURLChange(webView: mockWebView)
        
        // Wait less than one second before calling again
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        let result2 = handler.handleURLChange(webView: mockWebView)

        // Assert
        if case .handled(.duckPlayerEnabled) = result1 {
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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

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
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

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
        featureFlagger.enabledFeatures = []  // Feature is disabled

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
    func testHandleURLChange_WithYoutubeEmbedURIParam_ReturnsHandled() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&&embeds_referring_euri=true")!
        mockWebView.setCurrentURL(youtubeURL)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let result = handler.handleURLChange(webView: mockWebView)
        
        // Assert
        if case .handled(.allowFirstVideo) = result {
            // Success
        } else {
            XCTFail("Expected first call to return .handled")
        }
    }

    
    @MainActor
    func testHandleDelegateNavigation_NotToMainFrame_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT to be cancelled as it's not mainframe navigation")
    }
    
    @MainActor
    func testHandleDelegateNavigation_With_DuckPlayerFeatureDisabled_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT be cancelled as DuckPlayer Feature is Disabled")
    }
    
    
    @MainActor
    func testHandleDelegateNavigation_With_DuckPlayerDisabled_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .disabled

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT to be cancelled as DuckPlayer is Disabled")
    }
    
    @MainActor
    func testHandleDelegateNavigation_ToYouTubeWith_DuckPlayerAlwaysAsk_ReturnsTrue() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .alwaysAsk
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertTrue(shouldCancel, "Expected navigation TO be cancelled as it should redirect to Youtube")
    }
    
    @MainActor
    func testHandleDelegateNavigation_WithBackForwardNavigation_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, navigationType: .backForward, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation to be cancelled as Nav is backForward")
    }
    
    @MainActor
    func testHandleDelegateNavigation_WithAllowFirstVideo_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        playerSettings.allowFirstVideo = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation to be cancelled as it's first video")
    }
    
    @MainActor
    func testHandleDelegateNavigation_WithValidURL_ReturnsTrue() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertTrue(shouldCancel, "Expected navigation to be cancelled as it's first video")
        
        if let url = mockWebView.lastLoadedRequest?.url {
            XCTAssertTrue(url.isDuckPlayer, "Expected final URL to be a Duck URL")
        } else {
            XCTFail("No URL was loaded. Expecting a Duck Player Video")
        }
        
    }
    

    @MainActor
    func testHandleDelegateNavigation_YouTubeURL_DuckPlayerDisabled_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let request = URLRequest(url: youtubeURL)
        let navigationAction = MockNavigationAction(request: request)
        playerSettings.mode = .disabled  // DuckPlayer mode is disabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

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
        featureFlagger.enabledFeatures = []  // Feature is disabled

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled when feature flag is disabled")
    }
    
    @MainActor
    func testHandleDelegateNavigation_DuckPlayerURL_DoesNotOpenInNewTabIfFeatureDisabled() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/abc123")!
        let request = URLRequest(url: duckPlayerURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer]  // Duckplayer feature is disabled

        // Act
        let shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation not to be cancelled for DuckPlayer URL")
        XCTAssertNil(tabNavigator.openedURL, "No new tabs should open")
    }
    

    // MARK: Reload Operations
    @MainActor
    func testHandleDelegateNavigation_DuckPlayerURLReloads_DoesNotOpenInANewTab() async {
        // Arrange
        let duckPlayerURL = URL(string: "duck://player/abc123")!
        playerSettings.mode = .enabled
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]
        mockWebView.setCurrentURL(duckPlayerURL)
        
        // Act
        handler.handleReload(webView: mockWebView)

        // Assert
        XCTAssertNil(tabNavigator.openedURL, "No new tabs should open")
    }
    
    @MainActor
    func testHandleDelegateNavigation_YoutubeWatchURLWithAlwaysAsk_DoesNotOpenInANewTab() async {
        // Arrange
        let duckPlayerURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        playerSettings.mode = .alwaysAsk
        playerSettings.openInNewTab = true
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]
        mockWebView.setCurrentURL(duckPlayerURL)
        
        // Act
        handler.handleReload(webView: mockWebView)

        // Assert
        XCTAssertNil(tabNavigator.openedURL, "No new tabs should open")
    }
    
    @MainActor
    func testHandleDelegateNavigation_YoutubeInternalNavigation_ReturnsFalse() async {
        // Arrange
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123#searching")!
        let request = URLRequest(url: youtubeURL)
        let mockFrameInfo = MockFrameInfo(isMainFrame: true)
        let navigationAction = MockNavigationAction(request: request, targetFrame: mockFrameInfo)
        playerSettings.mode = .enabled
        featureFlagger.enabledFeatures = [.duckPlayer, .duckPlayerOpenInNewTab]

        mockWebView.setCurrentURL(youtubeURL)
        
        // Act
        var shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT to be cancelled as it's Youtube Internal navigation")
        
        // Arrange
        playerSettings.mode = .disabled
        
        // Act
        shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT to be cancelled as it's Youtube Internal navigation")
        
        // Arrange
        featureFlagger.enabledFeatures = [.duckPlayer]
        
        // Act
        shouldCancel = handler.handleDelegateNavigation(navigationAction: navigationAction, webView: mockWebView)

        // Assert
        XCTAssertFalse(shouldCancel, "Expected navigation NOT to be cancelled as it's Youtube Internal navigation")
    }
    
}

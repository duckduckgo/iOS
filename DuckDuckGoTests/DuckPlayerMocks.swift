//
//  DuckPlayerMocks.swift
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

    
    var lastLoadedRequest: URLRequest?
    var loadedRequests: [URLRequest] = []
    var loadCallCount = 0
    
    var loadCompletionHandler: (() -> Void)?

    /// The current URL of the web view.
    private var _url: URL?
    override var url: URL? {
        return _url
    }

    /// Sets the current URL of the web view.
    func setCurrentURL(_ url: URL) {
        self._url = url
    }

    /// A simulated history stack to support navigation methods like `goBack()`.
    var historyStack: [URL] = []

    /// Indicates whether the `stopLoading()` method was called.
    var didStopLoadingCalled = false

    // MARK: - Overridden Methods

    override func load(_ request: URLRequest) -> WKNavigation? {
        lastLoadedRequest = request
        loadedRequests.append(request)
        loadCallCount += 1

        // Simulate asynchronous loading
        DispatchQueue.main.async {
            self.loadCompletionHandler?()
        }

        return nil
    }

    override func reload() -> WKNavigation? {
        // Simulate reload behavior if needed
        return nil
    }

    override func goBack() -> WKNavigation? {
        if historyStack.count > 1 {
            // Remove the current page
            historyStack.removeLast()
            // Set the URL to the previous page
            setCurrentURL(historyStack.last!)
        }
        return nil
    }

    override func stopLoading() {
        didStopLoadingCalled = true
    }

    // MARK: - Additional Helper Methods (if needed)

    /// Simulates navigating to a new URL.
    func navigate(to url: URL) {
        historyStack.append(url)
        setCurrentURL(url)
    }

    /// Resets the web view's state.
    func reset() {
        lastLoadedRequest = nil
        loadedRequests.removeAll()
        loadCallCount = 0
        didStopLoadingCalled = false
        historyStack.removeAll()
        _url = nil
        loadCompletionHandler = nil
    }
}

class MockNavigationAction: WKNavigationAction {
    private let _request: URLRequest
    private let _navigationType: WKNavigationType
    private let _targetFrame: WKFrameInfo?

    init(request: URLRequest, navigationType: WKNavigationType = .linkActivated, targetFrame: WKFrameInfo? = nil) {
        self._request = request
        self._navigationType = navigationType
        self._targetFrame = targetFrame
    }

    override var request: URLRequest {
        return _request
    }

    override var navigationType: WKNavigationType {
        return _navigationType
    }

    override var targetFrame: WKFrameInfo? {
        return _targetFrame
    }
}

class MockFrameInfo: WKFrameInfo {
    private let _isMainFrame: Bool

    init(isMainFrame: Bool) {
        self._isMainFrame = isMainFrame
    }

    override var isMainFrame: Bool {
        return _isMainFrame
    }
}

final class MockDuckPlayerSettings: DuckPlayerSettings {
    
    private let duckPlayerSettingsSubject = PassthroughSubject<Void, Never>()
    var duckPlayerSettingsPublisher: AnyPublisher<Void, Never> {
        duckPlayerSettingsSubject.eraseToAnyPublisher()
    }
    
    var mode: DuckPlayerMode = .disabled
    var askModeOverlayHidden: Bool = false
    var allowFirstVideo: Bool = false
    var openInNewTab: Bool = false
    var nativeUI: Bool = false
    var autoplay: Bool = false

    
    init(appSettings: any DuckDuckGo.AppSettings, privacyConfigManager: any BrowserServicesKit.PrivacyConfigurationManaging, internalUserDecider: any BrowserServicesKit.InternalUserDecider) {}
    
    func triggerNotification() {}
    
    func setMode(_ mode: DuckPlayerMode) {
        self.mode = mode
    }
    
    func setAskModeOverlayHidden(_ overlayHidden: Bool) {
        self.askModeOverlayHidden = overlayHidden
    }
    
}

final class MockDuckPlayer: DuckPlayerControlling {
    
    func telemetryEvent(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    
    var hostView: TabViewController?
    
    var youtubeNavigationRequest: PassthroughSubject<URL, Never>
    
    func openDuckPlayerSettings(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    func openDuckPlayerInfo(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    func setHostViewController(_ vc: TabViewController) {}
    func removeHostView() {}
    
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    func loadNativeDuckPlayerVideo(videoID: String) {
        return
    }
    
    var settings: any DuckPlayerSettings
    private var featureFlagger: FeatureFlagger
    
    init(settings: any DuckDuckGo.DuckPlayerSettings, featureFlagger: any BrowserServicesKit.FeatureFlagger) {
        self.settings = settings
        self.featureFlagger = featureFlagger
        self.youtubeNavigationRequest = PassthroughSubject<URL, Never>()
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

enum MockFeatureFlag: Hashable {
    case duckPlayer, duckPlayerOpenInNewTab
}

final class MockDuckPlayerFeatureFlagger: FeatureFlagger {
    var internalUserDecider: InternalUserDecider = DefaultInternalUserDecider(store: MockInternalUserStoring())
    var localOverrides: FeatureFlagLocalOverriding?

    var enabledFeatures: Set<MockFeatureFlag> = []

    func isFeatureOn(_ feature: MockFeatureFlag) -> Bool {
        return enabledFeatures.contains(feature)
    }

    func isFeatureOn<Flag: FeatureFlagDescribing>(for featureFlag: Flag, allowOverride: Bool) -> Bool {
        return !enabledFeatures.isEmpty
    }

    func getCohortIfEnabled(_ subfeature: any PrivacySubfeature) -> CohortID? {
        return nil
    }

    func resolveCohort<Flag>(for featureFlag: Flag, allowOverride: Bool) -> (any FeatureFlagCohortDescribing)? where Flag: FeatureFlagDescribing {
        return nil
    }

    var allActiveExperiments: Experiments = [:]
}

final class MockDuckPlayerStorage: DuckPlayerStorage {
    var userInteractedWithDuckPlayer: Bool = false
}

final class MockDuckPlayerTabNavigator: DuckPlayerTabNavigationHandling {
    var openedURL: URL?
    var closeTabCalled = false

    func openTab(for url: URL) {
        openedURL = url
    }

    func closeTab() {
        closeTabCalled = true
    }
}

final class MockDuckPlayerInternalUserDecider: InternalUserDecider {
    var mockIsInternalUser: Bool = false
    var mockIsInternalUserPublisher: AnyPublisher<Bool, Never> {
        Just(mockIsInternalUser).eraseToAnyPublisher()
    }

    var isInternalUser: Bool {
        return mockIsInternalUser
    }

    var isInternalUserPublisher: AnyPublisher<Bool, Never> {
        return mockIsInternalUserPublisher
    }

    @discardableResult
    func markUserAsInternalIfNeeded(forUrl url: URL?, response: HTTPURLResponse?) -> Bool {
        return mockIsInternalUser
    }
}

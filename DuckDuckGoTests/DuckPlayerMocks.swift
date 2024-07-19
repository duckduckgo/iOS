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
    
    func setOverlayHidden(_ overlayHidden: Bool) {
        self.askModeOverlayHidden = overlayHidden
    }
    
}

final class MockDuckPlayer: DuckPlayerProtocol {
    func initialSetupPlayer(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
    func initialSetupOverlay(params: Any, message: WKScriptMessage) async -> (any Encodable)? {
        nil
    }
    
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

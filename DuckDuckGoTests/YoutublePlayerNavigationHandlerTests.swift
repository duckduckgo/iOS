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


class YoutubePlayerNavigationHandlerTests: XCTestCase {
    
    var handler: YoutubePlayerNavigationHandler!
    var webView: WKWebView!
    var mockWebView: MockWebView!
    var mockNavigationDelegate: MockWKNavigationDelegate!
        
    override func setUp() {
        super.setUp()
        handler = YoutubePlayerNavigationHandler()
        webView = WKWebView()
        mockWebView = MockWebView()
        mockNavigationDelegate = MockWKNavigationDelegate()
        webView.navigationDelegate = mockNavigationDelegate
    }
    
    override func tearDown() {
        webView.navigationDelegate = nil
        webView = nil
        handler = nil
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
    func testHandleURLChange() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
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
    func testHandleURLChangeForNonYouTubeVideo() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        handler.handleURLChange(url: nonYouTubeURL, webView: mockWebView)
        
        XCTAssertFalse(mockWebView.didStopLoadingCalled, "Expected stopLoading not to be called")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    // Test for handleDecidePolicyFor
    @MainActor
    func testHandleDecidePolicyFor() {
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
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
    func testHandleDecidePolicyForNonYouTubeVideo() {
        let nonYouTubeURL = URL(string: "https://www.google.com")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: nonYouTubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleDecidePolicyFor(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .cancel, "Expected navigation policy to be .cancel")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    @MainActor
    func testHandleReloadForDuckPlayerVideo() {
        let duckPlayerURL = URL(string: "https://www.youtube-nocookie.com/embed/abc123?t=10s")!
                
        mockWebView.setCurrentURL(duckPlayerURL)
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
    func testHandleReloadForNonDuckPlayerVideo() {
        let nonDuckPlayerURL = URL(string: "https://www.google.com")!
        
        // Simulate the current URL
        mockWebView.setCurrentURL(nonDuckPlayerURL)
        handler.handleReload(webView: mockWebView)
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
}

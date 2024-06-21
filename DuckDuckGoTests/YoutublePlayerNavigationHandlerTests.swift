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
    
    override func stopLoading() {
        didStopLoadingCalled = true
    }
    
    override func load(_ request: URLRequest) -> WKNavigation? {
        lastLoadedRequest = request
        return nil
    }
    
    override func go(to item: WKBackForwardListItem) -> WKNavigation? {
        goToCalledWith = item
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
        // Given
        let originalRequest = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!)
        
        // When
        let duckPlayerRequest = YoutubePlayerNavigationHandler.makeDuckPlayerRequest(from: originalRequest)
        
        // Then
        XCTAssertEqual(duckPlayerRequest.url?.host, "www.youtube-nocookie.com")
        XCTAssertEqual(duckPlayerRequest.url?.path, "/embed/abc123")
        XCTAssertEqual(duckPlayerRequest.url?.query?.contains("t=10s"), true)
        XCTAssertEqual(duckPlayerRequest.value(forHTTPHeaderField: "Referer"), "http://localhost/")
        XCTAssertEqual(duckPlayerRequest.httpMethod, "GET")
    }

    // Test for makeDuckPlayerRequest(for:timestamp:)
    func testMakeDuckPlayerRequestForVideoID() {
        // Given
        let videoID = "abc123"
        let timestamp = "10s"
        
        // When
        let duckPlayerRequest = YoutubePlayerNavigationHandler.makeDuckPlayerRequest(for: videoID, timestamp: timestamp)
        
        // Then
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
    
    // Validate redirects are properly triggered
    func testHandleRedirect() {
                        
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        handler.handleRedirect(url: youtubeURL, webView: mockWebView)
        
        XCTAssertTrue(mockWebView.didStopLoadingCalled, "Expected stopLoading to be called")
        XCTAssertNotNil(mockWebView.lastLoadedRequest, "Expected a new request to be loaded")
        
        if let loadedRequest = mockWebView.lastLoadedRequest {
            XCTAssertEqual(loadedRequest.url?.scheme, "duck")
            XCTAssertEqual(loadedRequest.url?.host, "player")
            XCTAssertEqual(loadedRequest.url?.path, "/abc123")
            XCTAssertEqual(loadedRequest.url?.query?.contains("t=10s"), true)
        }
    }
    
    func testHandleRedirectForNonYouTubeVideo() {
                        
        let youtubeURL = URL(string: "https://www.google.com.com/watch?v=abc123&t=10s")!
        handler.handleRedirect(url: youtubeURL, webView: mockWebView)
        
        XCTAssertFalse(mockWebView.didStopLoadingCalled, "Expected stopLoading not to be called")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
        
    }
    
    func testHandleRedirectWithNavigationAction() {

        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleRedirect(navigationAction, completion: { policy in
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
    
    func testHandleRedirectWithNavigationActionForNonYouTubeVideo() {

        let youtubeURL = URL(string: "https://www.google.com.com/watch?v=abc123&t=10s")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: youtubeURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleRedirect(navigationAction, completion: { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }, webView: mockWebView)
                
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .cancel, "Expected navigation policy to be .cancel")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
    }
    
    // Test for handleNavigation for duck:// links
    func testHandleNavigationWithDuckPlayerURL() {
        // Given
        let handler = YoutubePlayerNavigationHandler()
        let mockWebView = MockWebView()
        let duckPlayerURL = URL(string: "duck://player/abc123&t=30")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckPlayerURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?

        handler.handleNavigation(navigationAction, webView: mockWebView) { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .allow, "Expected navigation policy to be .allow")
                
        if let responseHTML = mockWebView.lastResponseHTML {
            let expectedHtml = try? String(contentsOfFile: YoutubePlayerNavigationHandler.htmlTemplatePath)
            XCTAssertEqual(responseHTML, expectedHtml)
        }
    }
    
    // Test for handleNavigation for non duck:// links
    func testHandleNavigationWithNonDuckPlayerURL() {
        let handler = YoutubePlayerNavigationHandler()
        let mockWebView = MockWebView()
        let duckPlayerURL = URL(string: "https://www.youtube.com/watch?v=abc123")!
        let navigationAction = MockNavigationAction(request: URLRequest(url: duckPlayerURL))
        let expectation = self.expectation(description: "Completion handler called")
        
        var navigationPolicy: WKNavigationActionPolicy?
        
        handler.handleNavigation(navigationAction, webView: mockWebView) { policy in
            navigationPolicy = policy
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(navigationPolicy, .cancel, "Expected navigation policy to be .cancel")
        XCTAssertNil(mockWebView.lastLoadedRequest, "Expected a new request not to be loaded")
        XCTAssertNil(mockWebView.lastResponseHTML, "Expected the response HTML not to be loaded")
        
        if let responseHTML = mockWebView.lastResponseHTML {
            let expectedHtml = try? String(contentsOfFile: YoutubePlayerNavigationHandler.htmlTemplatePath)
            XCTAssertEqual(responseHTML, expectedHtml)
        }
    }

}

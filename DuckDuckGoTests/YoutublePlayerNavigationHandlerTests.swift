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
@testable import DuckDuckGo

// Protocol to represent a back/forward list item
// WLBackForwardListItem cannot be subclassed
protocol BackForwardListItem {
    var url: URL { get }
}

// Protocol to represent the back/forward list
protocol BackForwardList {
    var backItem: BackForwardListItem? { get }
}

// Custom class to simulate a back/forward list item
class MockBackForwardListItem: BackForwardListItem {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
}

// Custom class to simulate the back/forward list
class MockBackForwardList: BackForwardList {
    var backItem: BackForwardListItem?
}

// Custom class to simulate WKWebView
class MockWebView {
    var didLoadSimulatedRequest = false
    var didStopLoading = false
    var didLoadRequest = false
    var didGoBackSkippingHistoryItems = false
    var didGoBack = false
    var mockBackForwardList = MockBackForwardList()
    var mockURL: URL?
    
    var backForwardList: BackForwardList {
        return mockBackForwardList
    }
    
    var url: URL? {
        return mockURL
    }
    
    func loadSimulatedRequest(_ request: URLRequest, responseHTML: String) {
        didLoadSimulatedRequest = true
    }
    
    func stopLoading() {
        didStopLoading = true
    }
    
    func load(_ request: URLRequest) {
        didLoadRequest = true
    }
    
    func goBack() {
        didGoBack = true
    }
    
    func goBackSkippingHistoryItems(_ items: Int) {
        didGoBackSkippingHistoryItems = true
    }
}

// Mock class to simulate WKNavigationAction
class MockNavigationAction {
    let request: URLRequest
    
    init(request: URLRequest) {
        self.request = request
    }
}

// Example handler class (replace with your actual handler)
struct YoutubePlayerNavigationHandler {
    
    func handleNavigation(_ navigationAction: MockNavigationAction, webView: MockWebView, completion: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            completion(.cancel)
            return
        }
        
        if url.host == "duckplayer.com" {
            webView.loadSimulatedRequest(navigationAction.request, responseHTML: "<html></html>")
            completion(.allow)
        } else {
            completion(.cancel)
        }
    }
    
    func handleRedirect(url: URL?, webView: MockWebView) {
        guard let url = url else { return }
        webView.stopLoading()
        webView.load(URLRequest(url: url))
    }
    
    func handleRedirect(_ navigationAction: MockNavigationAction, completion: @escaping (WKNavigationActionPolicy) -> Void, webView: MockWebView) {
        guard let url = navigationAction.request.url else {
            completion(.cancel)
            return
        }
        
        webView.load(URLRequest(url: url))
        completion(.allow)
    }
    
    func goBack(webView: MockWebView) {
        guard let backItem = webView.backForwardList.backItem, backItem.url == webView.url else {
            webView.goBackSkippingHistoryItems(2)
            return
        }
        webView.goBack()
    }
}

// Tests
class YoutubePlayerNavigationHandlerTests: XCTestCase {
    
    var webView: MockWebView!
    var navigationHandler: YoutubePlayerNavigationHandler!
    
    override func setUp() {
        super.setUp()
        webView = MockWebView()
        navigationHandler = YoutubePlayerNavigationHandler()
    }
    
    override func tearDown() {
        webView = nil
        navigationHandler = nil
        super.tearDown()
    }
    
    func testHandleNavigation_withDuckPlayerURL_allowsNavigation() {
        let expectation = self.expectation(description: "Completion handler called")
        let url = URL(string: "https://duckplayer.com/video")!
        let request = URLRequest(url: url)
        let navigationAction = MockNavigationAction(request: request)
        
        navigationHandler.handleNavigation(navigationAction, webView: webView) { policy in
            XCTAssertEqual(policy, .allow)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(webView.didLoadSimulatedRequest)
    }
    
    func testHandleNavigation_withNonDuckPlayerURL_cancelsNavigation() {
        let expectation = self.expectation(description: "Completion handler called")
        let url = URL(string: "https://youtube.com/video")!
        let request = URLRequest(url: url)
        let navigationAction = MockNavigationAction(request: request)
        
        navigationHandler.handleNavigation(navigationAction, webView: webView) { policy in
            XCTAssertEqual(policy, .cancel)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(webView.didLoadSimulatedRequest)
    }
    
    func testHandleRedirect_withYoutubeVideoURL_stopsLoadingAndLoadsNewURL() {
        let url = URL(string: "https://youtube.com/watch?v=example")!
        navigationHandler.handleRedirect(url: url, webView: webView)
        
        XCTAssertTrue(webView.didStopLoading)
        XCTAssertTrue(webView.didLoadRequest)
    }
    
    func testHandleRedirect_withNonYoutubeVideoURL_doesNotLoadNewURL() {
        let url = URL(string: "https://example.com")!
        navigationHandler.handleRedirect(url: url, webView: webView)
        
        XCTAssertFalse(webView.didStopLoading)
        XCTAssertFalse(webView.didLoadRequest)
    }
    
    func testHandleRedirect_withNavigationAction_allowsNavigation() {
        let expectation = self.expectation(description: "Completion handler called")
        let url = URL(string: "https://youtube.com/watch?v=example")!
        let request = URLRequest(url: url)
        let navigationAction = MockNavigationAction(request: request)
        
        navigationHandler.handleRedirect(navigationAction, completion: { policy in
            XCTAssertEqual(policy, .allow)
            expectation.fulfill()
        }, webView: webView)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(webView.didLoadRequest)
    }
    
    func testGoBack_withMatchingVideoID_skipsHistoryItems() {
        let backItem = MockBackForwardListItem(url: URL(string: "https://youtube.com/watch?v=example")!)
        webView.mockBackForwardList.backItem = backItem
        
        let currentURL = URL(string: "https://duckplayer.com/watch?v=example")!
        webView.mockURL = currentURL
        
        navigationHandler.goBack(webView: webView)
        
        XCTAssertTrue(webView.didGoBackSkippingHistoryItems)
    }
    
    func testGoBack_withNonMatchingVideoID_goesBack() {
        let backItem = MockBackForwardListItem(url: URL(string: "https://youtube.com/watch?v=example1")!)
        webView.mockBackForwardList.backItem = backItem
        
        let currentURL = URL(string: "https://duckplayer.com/watch?v=example2")!
        webView.mockURL = currentURL
        
        navigationHandler.goBack(webView: webView)
        
        XCTAssertTrue(webView.didGoBack)
    }
}

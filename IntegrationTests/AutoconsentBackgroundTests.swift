//
//  AutoconsentBackgroundTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo
@testable import Core
@testable import BrowserServicesKit
import WebKit

final class AutoconsentBackgroundTests: XCTestCase {

    let autoconsentUserScript: AutoconsentUserScript = {
        let embeddedConfig =
        """
        {
            "features": {
                "autoconsent": {
                    "exceptions": [],
                    "settings": {
                        "disabledCMPs": [
                            "Sourcepoint-top"
                        ]
                    },
                    "state": "enabled",
                    "hash": "659eb19df598629f1eaecbe7fa2d7f00"
                }
            },
            "unprotectedTemporary": []
        }
        """.data(using: .utf8)!

        let mockEmbeddedData = MockEmbeddedDataProvider(data: embeddedConfig, etag: "embedded")

        let manager = PrivacyConfigurationManager(fetchedETag: nil,
                                                  fetchedData: nil,
                                                  embeddedDataProvider: mockEmbeddedData,
                                                  localProtection: MockDomainsProtectionStore(),
                                                  internalUserDecider: DefaultInternalUserDecider())
        return AutoconsentUserScript(config: manager.privacyConfig,
                                     preferences: MockAutoconsentPreferences(),
                                     ignoreNonHTTPURLs: false)
    }()

    @MainActor
    func testUserscriptIntegration() {
        let configuration = WKWebViewConfiguration()

        configuration.userContentController.addUserScript(autoconsentUserScript.makeWKUserScriptSync())
        
        for messageName in autoconsentUserScript.messageNames {
            let contentWorld: WKContentWorld = autoconsentUserScript.getContentWorld()
            configuration.userContentController.addScriptMessageHandler(autoconsentUserScript,
                                                                        contentWorld: contentWorld,
                                                                        name: messageName)
        }

        let webview = WKWebView(frame: .zero, configuration: configuration)
        let navigationDelegate = TestNavigationDelegate(e: expectation(description: "WebView Did finish navigation"))
        webview.navigationDelegate = navigationDelegate
        let url = Bundle(for: type(of: self)).url(forResource: "autoconsent-test-page", withExtension: "html")!
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        waitForExpectations(timeout: 10)

        let expectation = expectation(description: "Async call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            webview.evaluateJavaScript("results.results.includes('button_clicked')", in: nil, in: .page,
                                       completionHandler: { result in
                switch result {
                case .success(let value as Bool):
                    XCTAssertTrue(value, "Button should have been clicked once")
                case .success:
                    XCTFail("Failed to read test result")
                case .failure:
                    XCTFail("Failed to read test result")
                }
                expectation.fulfill()
            })
        }
        waitForExpectations(timeout: 10)
    }

    @MainActor
    func testCosmeticRule() {
        let configuration = WKWebViewConfiguration()

        configuration.userContentController.addUserScript(autoconsentUserScript.makeWKUserScriptSync())
        
        for messageName in autoconsentUserScript.messageNames {
            let contentWorld: WKContentWorld = autoconsentUserScript.getContentWorld()
            configuration.userContentController.addScriptMessageHandler(autoconsentUserScript,
                                                                        contentWorld: contentWorld,
                                                                        name: messageName)
        }

        let webview = WKWebView(frame: .zero, configuration: configuration)
        let navigationDelegate = TestNavigationDelegate(e: expectation(description: "WebView Did finish navigation"))
        webview.navigationDelegate = navigationDelegate
        let url = Bundle(for: type(of: self)).url(forResource: "autoconsent-test-page-banner", withExtension: "html")!
        webview.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        waitForExpectations(timeout: 10)

        let expectation = expectation(description: "Async call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            webview.evaluateJavaScript("window.getComputedStyle(banner).display === 'none'", in: nil, in: .page,
                                       completionHandler: { result in
                switch result {
                case .success(let value as Bool):
                    XCTAssertTrue(value, "Banner should have been hidden")
                case .success:
                    XCTFail("Failed to read test result")
                case .failure:
                    XCTFail("Failed to read test result")
                }
                expectation.fulfill()
            })
        }
        waitForExpectations(timeout: 10)
    }
}

final class TestNavigationDelegate: NSObject, WKNavigationDelegate {
    let e: XCTestExpectation

    init(e: XCTestExpectation) {
        self.e = e
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        e.fulfill()
    }
}

class MockEmbeddedDataProvider: EmbeddedDataProvider {
    var embeddedDataEtag: String

    var embeddedData: Data

    init(data: Data, etag: String) {
        embeddedData = data
        embeddedDataEtag = etag
    }
}

class MockAutoconsentPreferences: AutoconsentPreferences {
    var autoconsentPromptSeen: Bool = true
    var autoconsentEnabled: Bool = true
}

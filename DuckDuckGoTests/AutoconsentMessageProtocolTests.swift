//
//  AutoconsentMessageProtocolTests.swift
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
import WebKit
import BrowserServicesKit

final class AutoconsentMessageProtocolTests: XCTestCase {

    let userScript: AutoconsentUserScript = {
        let embeddedConfig =
        """
        {
            "features": {
                "autoconsent": {
                    "exceptions": [
                        {
                            "domain": "computerbild.de",
                            "reason": "Page renders but one cannot scroll (and no CMP is shown) for a few seconds."
                        },
                        {
                            "domain": "spiegel.de",
                            "reason": "CMP gets incorrectly handled, gets stuck in preferences dialogue."
                        },
                    ],
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
        return AutoconsentUserScript(config: manager.privacyConfig, preferences: MockAutoconsentPreferences())
    }()

    func replyToJson(msg: Any) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: msg, options: .sortedKeys)
        return String(data: jsonData!, encoding: .ascii)!
    }

    @MainActor
    func testInitIgnoresNonHttp() {
        let expect = expectation(description: "tt")
        let message = MockWKScriptMessage(name: "init", body: [
            "type": "init",
            "url": "file://helicopter"
        ])
        userScript.handleMessage(
            replyHandler: {(msg: Any?, _: String?) in
                expect.fulfill()
                XCTAssertEqual(self.replyToJson(msg: msg!), """
                {"type":"ok"}
                """)
            },
            message: message
        )
        waitForExpectations(timeout: 1.0)
    }
    
    @MainActor
    func testInitResponds() {
        let expect = expectation(description: "tt")
        let message = MockWKScriptMessage(name: "init", body: [
            "type": "init",
            "url": "https://example.com"
        ])
        userScript.handleMessage(
            replyHandler: {(msg: Any?, _: String?) in
                expect.fulfill()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: msg!, options: .sortedKeys),
                      let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                      let dict = json as? [String: Any],
                      let config = dict["config"] as? [String: Any]
                else {
                    XCTFail("Could not parse init response")
                    return
                }

                XCTAssertEqual(dict["type"] as? String, "initResp")
                XCTAssertEqual(config["autoAction"] as? String, "optOut")
            },
            message: message
        )
        waitForExpectations(timeout: 1.0)
    }

    @MainActor
    func testEval() {
        let message = MockWKScriptMessage(name: "eval", body: [
            "type": "eval",
            "id": "some id",
            "code": "1+1==2"
        ], webView: WKWebView())
        let expect = expectation(description: "testEval")
        userScript.handleMessage(
            replyHandler: {(msg: Any?, _: String?) in
                expect.fulfill()
                XCTAssertEqual(self.replyToJson(msg: msg!), """
                {"id":"some id","result":true,"type":"evalResp"}
                """)
            },
            message: message
        )
        waitForExpectations(timeout: 15.0)
    }

    @MainActor
    func testPopupFoundNoPromptIfEnabled() {
        let expect = expectation(description: "tt")
        let message = MockWKScriptMessage(name: "popupFound", body: [
            "type": "popupFound",
            "cmp": "some cmp",
            "url": "some url"
        ])
        userScript.handleMessage(
            replyHandler: {(msg: Any?, _: String?) in
                expect.fulfill()
                XCTAssertEqual(self.replyToJson(msg: msg!), """
                {"type":"ok"}
                """)
            },
            message: message
        )
        waitForExpectations(timeout: 1.0)
    }
}

class MockWKScriptMessage: WKScriptMessage {

    let mockedName: String
    let mockedBody: Any
    let mockedWebView: WKWebView?

    override var name: String {
        return mockedName
    }

    override var body: Any {
        return mockedBody
    }

    override var webView: WKWebView? {
        return mockedWebView
    }

    init(name: String, body: Any, webView: WKWebView? = nil) {
        self.mockedName = name
        self.mockedBody = body
        self.mockedWebView = webView
        super.init()
    }
}

class MockAutoconsentPreferences: AutoconsentPreferences {
    var autoconsentPromptSeen: Bool = true
    var autoconsentEnabled: Bool = true
}

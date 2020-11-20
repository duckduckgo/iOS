//
//  EmailUserScriptTests.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
@testable import Core

class EmailUserScriptTests: XCTestCase {

    let emailUserScript = EmailUserScript()
    let userContentController = WKUserContentController()

    func testWhenReceivesStoreTokenMessageThenCallsDelegateMethodWithCorrectTokenAndUsername() {
        let mock = MockEmailUserScriptDelegate()
        emailUserScript.delegate = mock
        
        let token = "testToken"
        let username = "testUsername"
                
        let expect = expectation(description: "testWhenReceivesStoreTokenMessageThenCallsDelegateMethod")
        mock.requestStoreTokenCallback = { callbackToken, callbackUsername in
            XCTAssertEqual(token, callbackToken)
            XCTAssertEqual(username, callbackUsername)
            expect.fulfill()
        }
        
        let message = MockWKScriptMessage(name: "emailHandlerStoreToken", body: [ "token": "testToken", "username": "testUsername"])
        emailUserScript.userContentController(userContentController, didReceive: message)

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenReceivesCheckSignedInMessageThenCallsDelegateMethod() {
        let mock = MockEmailUserScriptDelegate()
        emailUserScript.delegate = mock
        
        let expect = expectation(description: "testWhenReceivesCheckSignedInMessageThenCallsDelegateMethod")
        mock.signedInCallback = {
            expect.fulfill()
        }
        
        let message = MockWKScriptMessage(name: "emailHandlerCheckAppSignedInStatus", body: "")
        emailUserScript.userContentController(userContentController, didReceive: message)

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenReceivesCheckCanInjectMessageThenCallsDelegateMethod() {
        let mock = MockEmailUserScriptDelegate()
        emailUserScript.delegate = mock
        
        let expect = expectation(description: "testWhenReceivesCheckCanInjectMessageThenCallsDelegateMethod")
        mock.signedInCallback = {
            expect.fulfill()
        }
        
        let message = MockWKScriptMessage(name: "emailHandlerCheckCanInjectAutoFill", body: "")
        emailUserScript.userContentController(userContentController, didReceive: message)

        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWhenReceivesGetAliasMessageThenCallsDelegateMethod() {
        let mock = MockEmailUserScriptDelegate()
        emailUserScript.delegate = mock
        
        let expect = expectation(description: "testWhenReceivesGetAliasMessageThenCallsDelegateMethod")
        mock.requestAliasCallback = {
            expect.fulfill()
        }
        
        let message = MockWKScriptMessage(name: "emailHandlerGetAlias", body: "")
        emailUserScript.userContentController(userContentController, didReceive: message)

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

class MockWKScriptMessage: WKScriptMessage {
    
    let mockedName: String
    let mockedBody: Any
    
    override var name: String {
        return mockedName
    }
    
    override var body: Any {
        return mockedBody
    }
    
    init(name: String, body: Any) {
        self.mockedName = name
        self.mockedBody = body
        super.init()
    }
}

class MockEmailUserScriptDelegate: EmailUserScriptDelegate {
    
    var signedInCallback: (() -> Void)?
    var requestAliasCallback: (() -> Void)?
    var requestStoreTokenCallback: ((String, String) -> Void)?
    
    func emailUserScriptDidRequestSignedInStatus(emailUserScript: EmailUserScript) -> Bool {
        signedInCallback!()
        return false
    }
    
    func emailUserScriptDidRequestAlias(emailUserScript: EmailUserScript, completionHandler: @escaping AliasCompletion) {
        requestAliasCallback!()
    }
    
    func emailUserScript(_ emailUserScript: EmailUserScript, didRequestStoreToken token: String, username: String) {
        requestStoreTokenCallback!(token, username)
    }
}

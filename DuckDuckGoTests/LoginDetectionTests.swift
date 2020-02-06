//
//  LoginDetectionTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

class LoginDetectionTests: XCTestCase {
    
    func testWhenMethodIsNotPostAndCookiesHaveChangedCountAfterFinishingLoadingThenProbablyNotALogin() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "GET")

        let expect = expectation(description: #function)

        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNil($0)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveSameCookiesAfterFinishingLoadingThenProbablyNotALogin() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [cookie("name", "value")])
        let action = Action(method: "POST")

        let creationExpectation = expectation(description: "\(#function) create")
        var detection: LoginDetection?

        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNotNil($0)
            detection = $0
            creationExpectation.fulfill()
        }
        wait(for: [creationExpectation], timeout: 5.0)

        let updatedCookies = CookiesProvider(cookies: [cookie("name", "value")])

        let finishExpectation = expectation(description: "\(#function) finish")
        detection?.webViewDidFinishNavigation(withCookies: updatedCookies) { possibleLogin in
            XCTAssertFalse(possibleLogin)
            finishExpectation.fulfill()
        }
        
        wait(for: [finishExpectation], timeout: 5.0)
    }

    func testWhenMethodIsPostAndCookiesHaveDifferentPathsAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [cookie("name", "value", path: "/")])
        let action = Action(method: "POST")

        let creationExpectation = expectation(description: "\(#function) create")
        var detection: LoginDetection?

        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNotNil($0)
            detection = $0
            creationExpectation.fulfill()
        }
        wait(for: [creationExpectation], timeout: 5.0)

        let updatedCookies = CookiesProvider(cookies: [cookie("name", "other value", path: "/path")])

        let finishExpectation = expectation(description: "\(#function) finish")
        detection?.webViewDidFinishNavigation(withCookies: updatedCookies) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            finishExpectation.fulfill()
        }
        
        wait(for: [finishExpectation], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveChangedNamesAndValuesAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [cookie("name", "value")])
        let action = Action(method: "POST")

        let creationExpectation = expectation(description: "\(#function) create")
        var detection: LoginDetection?

        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNotNil($0)
            detection = $0
            creationExpectation.fulfill()
        }
        wait(for: [creationExpectation], timeout: 5.0)
        
        let updatedCookies = CookiesProvider(cookies: [cookie("name", "other value")])
        
        let finishExpectation = expectation(description: "\(#function) finish")
        detection?.webViewDidFinishNavigation(withCookies: updatedCookies) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            finishExpectation.fulfill()
        }
        
        wait(for: [finishExpectation], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveChangedCountAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "POST")

        let creationExpectation = expectation(description: "\(#function) create")
        var detection: LoginDetection?

        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNotNil($0)
            detection = $0
            creationExpectation.fulfill()
        }
        wait(for: [creationExpectation], timeout: 5.0)
        
        let updatedCookies = CookiesProvider(cookies: [cookie("name", "value")])
        
        let finishExpectation = expectation(description: "\(#function) finish")
        detection?.webViewDidFinishNavigation(withCookies: updatedCookies) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            finishExpectation.fulfill()
        }
        
        wait(for: [finishExpectation], timeout: 5.0)
    }
    
    func testWhenWebViewAllowsNotPostActionThenCompletionCalled() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "GET")

        let expect = expectation(description: #function)
        
        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNil($0)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }

    func testWhenWebViewAllowsPostActionThenCompletionCalled() {
        let url = URL(string: "http://example.com")!
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        
        LoginDetection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertNotNil($0)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    private func cookie(_ name: String, _ value: String, path: String = "/") -> HTTPCookie {
        return HTTPCookie(properties: [.path: path, .name: name, .value: value, .domain: "example.com"])!
    }
    
    struct CookiesProvider: LoginDetectionCookiesProvider {
        let cookies: [HTTPCookie]
        
        func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void) {
            completionHandler(cookies)
        }
    }
    
    struct Action: LoginDetectionAction {
        let method: String?
    }
    
    class MockPreserveLogins: PreserveLogins {
        
        convenience init(decision: UserDecision) {
            let userDefaults = UserDefaults(suiteName: "test")!
            userDefaults.removePersistentDomain(forName: "test")
            self.init(userDefaults: userDefaults)
            self.userDecision = decision
        }
        
    }
    
}

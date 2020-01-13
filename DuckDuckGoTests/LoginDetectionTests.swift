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

class LoginDetectionTests: XCTestCase {

    func testWhenMethodIsNotPostAndCookiesHaveChangedCountAfterFinishingLoadingThenProbablyNotALogin() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "GET")

        let expect = expectation(description: #function)
        let detection = LoginDetection()

        detection.webView(withURL: url, andCookies: cookies, allowedAction: action, completion: { _ in })
        
        detection.webViewDidFinishNavigation(withCookies: CookiesProvider(cookies: [cookie("name", "value")])) { possibleLogin in
            XCTAssertFalse(possibleLogin)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveSameCookiesAfterFinishingLoadingThenProbablyNotALogin() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [cookie("name", "value")])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        let detection = LoginDetection()

        detection.webView(withURL: url, andCookies: cookies, allowedAction: action, completion: { _ in })
        
        let newCookies = CookiesProvider(cookies: [cookie("name", "value")])

        detection.webViewDidFinishNavigation(withCookies: newCookies) { possibleLogin in
            XCTAssertFalse(possibleLogin)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }

    func testWhenMethodIsPostAndCookiesHaveDifferentPathsAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [cookie("name", "value", path: "/")])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        let detection = LoginDetection()

        detection.webView(withURL: url, andCookies: cookies, allowedAction: action, completion: { _ in })
        
        let newCookies = CookiesProvider(cookies: [cookie("name", "value", path: "/path")])

        detection.webViewDidFinishNavigation(withCookies: newCookies) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveChangedNamesAndValuesAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [cookie("name", "value")])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        let detection = LoginDetection()

        detection.webView(withURL: url, andCookies: cookies, allowedAction: action, completion: { _ in })
        
        let newCookies = CookiesProvider(cookies: [cookie("name", "other value")])

        detection.webViewDidFinishNavigation(withCookies: newCookies) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func testWhenMethodIsPostAndCookiesHaveChangedCountAfterFinishingLoadingThenIndicatePossibleLogin() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        let detection = LoginDetection()

        detection.webView(withURL: url, andCookies: cookies, allowedAction: action, completion: { _ in })
        
        detection.webViewDidFinishNavigation(withCookies: CookiesProvider(cookies: [cookie("name", "value")])) { possibleLogin in
            XCTAssertTrue(possibleLogin)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    func testWhenWebViewAllowsNotPostActionThenCompletionCalled() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "GET")

        let expect = expectation(description: #function)
        let detection = LoginDetection()
        
        detection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertFalse($0)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }

    func testWhenWebViewAllowsPostActionThenCompletionCalled() {
        let url = URLProvider(url: URL(string: "http://example.com")!)
        let cookies = CookiesProvider(cookies: [])
        let action = Action(method: "POST")

        let expect = expectation(description: #function)
        let detection = LoginDetection()
        
        detection.webView(withURL: url, andCookies: cookies, allowedAction: action) {
            XCTAssertTrue($0)
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 5.0)
    }
    
    private func cookie(_ name: String, _ value: String, path: String = "/") -> HTTPCookie {
        return HTTPCookie(properties: [.path: path, .name: name, .value: value, .domain: "example.com"])!
    }
    
    struct URLProvider: LoginDetectionURLProvider {
        let url: URL?
    }
    
    struct CookiesProvider: LoginDetectionCookiesProvider {
        let cookies: [HTTPCookie]
        
        func getAllCookies(completion: @escaping ([HTTPCookie]) -> Void) {
            completion(cookies)
        }
    }
    
    struct Action: LoginDetectionAction {
        let method: String?
    }
}

//
//  FeatureFlaggingTests.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
@testable import Core

class DefaultFeatureFlaggerTests: XCTestCase {
    
    let correctURL = URL(string: "login.duckduckgo.com")!
    let correctStatusCode = 200
    
    func testShouldMarkUserAsInternalWhenURLAndStatusCodeCorrectThenReturnsTrue() {
        let featureFlagger = DefaultFeatureFlagger()
        let response = MockHTTPURLResponse(statusCode: correctStatusCode)
        let result = featureFlagger.shouldMarkUserAsInternal(forUrl: correctURL, response: response)
        XCTAssertTrue(result)
    }

    func testShouldMarkUserAsInternalWhenURLIsCorrectAndStatusCodeisIncorrectThenReturnsFalse() {
        let featureFlagger = DefaultFeatureFlagger()
        let response = MockHTTPURLResponse(statusCode: 300)
        let result = featureFlagger.shouldMarkUserAsInternal(forUrl: correctURL, response: response)
        XCTAssertFalse(result)
    }
    
    func testShouldMarkUserAsInternalWhenURLIsIncorrectButSubdomainIsCorrectAndStatusCodeIsCorrectThenReturnsFalse() {
        let featureFlagger = DefaultFeatureFlagger()
        let url = URL(string: "login.fishtown.com")!
        let response = MockHTTPURLResponse(statusCode: 200)
        let result = featureFlagger.shouldMarkUserAsInternal(forUrl: url, response: response)
        XCTAssertFalse(result)
    }
    
    func testShouldMarkUserAsInternalWhenURLIsIncorrectButdomainIsCorrectAndStatusCodeIsCorrectThenReturnsFalse() {
        let featureFlagger = DefaultFeatureFlagger()
        let url = URL(string: "sso.duckduckgo.com")!
        let response = MockHTTPURLResponse(statusCode: 200)
        let result = featureFlagger.shouldMarkUserAsInternal(forUrl: url, response: response)
        XCTAssertFalse(result)
    }
}

class MockHTTPURLResponse: HTTPURLResponse {
    
    let mockStatusCode: Int
    
    override var statusCode: Int {
        return mockStatusCode
    }
    
    init(statusCode: Int) {
        self.mockStatusCode = statusCode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

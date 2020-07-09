//
//  UserAgentTests.swift
//  UnitTests
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

import WebKit
import XCTest
@testable import Core

class UserAgentTests: XCTestCase {
    
    private struct DefaultAgent {
        static let mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        static let tablet = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    }
    
    private struct ExpectedAgent {
        // swiftlint:disable line_length
        
        // Based on DefaultAgent values
        static let mobile = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let tablet = "Mozilla/5.0 (iPad; CPU OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let desktop = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 DuckDuckGo/7 Safari/605.1.15"
        
        static let mobileNoApplication = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.4 Mobile/15E148 Safari/605.1.15"
        
        // Based on fallback constants in UserAgent
        static let mobileFallback = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.5 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15"
        static let desktopFallback = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.5 DuckDuckGo/7 Safari/605.1.15"
        
        // swiftlint:enable line_length
    }
    
    private struct Constants {
        static let url = URL(string: "http://example.com/index.html")
        static let noAppUrl = URL(string: "http://cvs.com/index.html")
        static let noAppSubdomainUrl = URL(string: "http://subdomain.cvs.com/index.html")
    }
    
    func testWhenMobileUaAndDektopFalseThenMobileAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobile, testee.agent(forUrl: Constants.url, isDesktop: false))
    }
    
    func testWhenMobileUaAndDektopTrueThenDesktopAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.desktop, testee.agent(forUrl: Constants.url, isDesktop: true))
    }
    
    func testWhenTabletUaAndDektopFalseThenTabletAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        XCTAssertEqual(ExpectedAgent.tablet, testee.agent(forUrl: Constants.url, isDesktop: false))
    }
    
    func testWhenTabletUaAndDektopTrueThenDesktopAgentCreatedWithApplicationAndSafariSuffix() {
        let testee = UserAgent(defaultAgent: DefaultAgent.tablet)
        XCTAssertEqual(ExpectedAgent.desktop, testee.agent(forUrl: Constants.url, isDesktop: true))
    }
    
    func testWhenNoUaAndDesktopFalseThenFallbackMobileAgentIsUsed() {
        let testee = UserAgent()
        XCTAssertEqual(ExpectedAgent.mobileFallback, testee.agent(forUrl: Constants.url, isDesktop: false))
    }
    
    func testWhenNoUaAndDesktopTrueThenFallbackDesktopAgentIsUsed() {
        let testee = UserAgent()
        XCTAssertEqual(ExpectedAgent.desktopFallback, testee.agent(forUrl: Constants.url, isDesktop: true))
    }
    
    func testWhenDomainDoesNotSupportApplicationComponentThenApplicationIsOmittedFromUa() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobileNoApplication, testee.agent(forUrl: Constants.noAppUrl, isDesktop: false))
    }
    
    func testWhenSubdomainDoesNotSupportApplicationComponentThenApplicationIsOmittedFromUa() {
        let testee = UserAgent(defaultAgent: DefaultAgent.mobile)
        XCTAssertEqual(ExpectedAgent.mobileNoApplication, testee.agent(forUrl: Constants.noAppSubdomainUrl, isDesktop: false))
    }
}

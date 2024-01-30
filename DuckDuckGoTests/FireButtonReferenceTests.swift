//
//  FireButtonReferenceTests.swift
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
import os.log
import WebKit
@testable import Core

final class FireButtonReferenceTests: XCTestCase {

    private enum Resource {
        static let tests = "privacy-reference-tests/storage-clearing/tests.json"
    }
    
    private lazy var testData: TestData = {
        let testJSON = JsonTestDataLoader().fromJsonFile(Resource.tests)
        // swiftlint:disable:next force_try
        return try! JSONDecoder().decode(TestData.self, from: testJSON)
    }()
    
    private func sanitizedSite(_ site: String) -> String {
        let url: URL
        if site.hasPrefix("http") {
            url = URL(string: site)!
        } else {
            url = URL(string: "https://" + site)!
        }
        return url.host!
    }

    func testCookieStorage() {
        let preservedLogins = PreserveLogins.shared
        preservedLogins.clearAll()
        
        for site in testData.fireButtonFireproofing.fireproofedSites {
            let sanitizedSite = sanitizedSite(site)
            os_log("Adding %s to fireproofed sites", sanitizedSite)
            preservedLogins.addToAllowed(domain: sanitizedSite)
        }
        
        let referenceTests = testData.fireButtonFireproofing.tests.filter {
            $0.exceptPlatforms.contains("ios-browser") == false
        }
            
        let cookieStorage = CookieStorage()
        for test in referenceTests {
            guard let cookie = cookie(for: test) else {
                XCTFail("Cookie should exist for test \(test.name)")
                return
            }
            
            cookieStorage.updateCookies([
                cookie
            ], keepingPreservedLogins: preservedLogins)
            
            let testCookie = cookieStorage.cookies.filter { $0.name == test.cookieName }.first

            if test.expectCookieRemoved {
                XCTAssertNil(testCookie, "Cookie should not exist for test: \(test.name)")
            } else {
                XCTAssertNotNil(testCookie, "Cookie should exist for test: \(test.name)")
            }
            
            // Reset cache
            cookieStorage.cookies = []
        }
    }
    
    private func cookie(for test: Test) -> HTTPCookie? {
        HTTPCookie(properties: [.name: test.cookieName,
                                .path: "",
                                .domain: test.cookieDomain,
                                .value: "123"])
    }
}

// MARK: - TestData
private struct TestData: Codable {
    let fireButtonFireproofing: FireButtonFireproofing
}

// MARK: - FireButtonFireproofing
private struct FireButtonFireproofing: Codable {
    let name, desc: String
    let fireproofedSites: [String]
    let tests: [Test]
}

// MARK: - Test
private struct Test: Codable {
    let name, cookieDomain, cookieName: String
    let expectCookieRemoved: Bool
    let exceptPlatforms: [String]
}

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
    private var referenceTests = [Test]()
    private let preservedLogins = PreserveLogins.shared
    private let dataStore = WKWebsiteDataStore.default()

    private enum Resource {
        static let tests = "privacy-reference-tests/storage-clearing/tests.json"
    }
    
    private lazy var testData: TestData = {
        let testJSON = JsonTestDataLoader().fromJsonFile(Resource.tests)
        // swiftlint:disable:next force_try
        return try! JSONDecoder().decode(TestData.self, from: testJSON)
    }()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        // Remove fireproofed sites
        for site in testData.fireButtonFireproofing.fireproofedSites {
            let sanitizedSite = sanitizedSite(site)
            os_log("Removing %s from fireproofed sites", sanitizedSite)
            PreserveLogins.shared.remove(domain: sanitizedSite)
        }
        
        referenceTests.removeAll()
    }
    
    private func sanitizedSite(_ site: String) -> String {
        let url: URL
        if site.hasPrefix("http") {
            url = URL(string: site)!
        } else {
            url = URL(string: "https://" + site)!
        }
        return url.host!
    }

    func testFireproofing() throws {
        // Setup fireproofed sites
        for site in testData.fireButtonFireproofing.fireproofedSites {
            let sanitizedSite = sanitizedSite(site)
            os_log("Adding %s to fireproofed sites", sanitizedSite)
            preservedLogins.addToAllowed(domain: sanitizedSite)

        }
       
        referenceTests = testData.fireButtonFireproofing.tests.filter {
            $0.exceptPlatforms.contains("ios-browser") == false
        }
        
        let testsExecuted = expectation(description: "tests executed")
        testsExecuted.expectedFulfillmentCount = referenceTests.count

        runReferenceTests(onTestExecuted: testsExecuted)
        waitForExpectations(timeout: 30, handler: nil)
    }
    
    private func runReferenceTests(onTestExecuted: XCTestExpectation) {
        guard let test = referenceTests.popLast() else {
            return
        }
        
        guard let cookie = cookie(for: test) else {
            XCTFail("Cookie should exist for test \(test.name)")
            return
        }
        
        dataStore.cookieStore?.setCookie(cookie, completionHandler: {
            
            WebCacheManager.shared.clear(dataStore: self.dataStore,
                                         logins: self.preservedLogins) {
                
                self.dataStore.cookieStore?.getAllCookies { hotCookies in
                    let testCookie = hotCookies.filter { $0.name == test.cookieName }.first
                    
                    if test.expectCookieRemoved {
                        XCTAssertNil(testCookie, "Cookie should not exist for test: \(test.name)")
                    } else {
                        XCTAssertNotNil(testCookie, "Cookie should exist for test: \(test.name)")
                    }
                    
                    
                    // Remove all cookies from this test
                    let group = DispatchGroup()
                    for cookie in hotCookies {
                        group.enter()
                        self.dataStore.cookieStore?.delete(cookie, completionHandler: {
                            group.leave()
                        })
                    }
                    
                    group.notify(queue: .main) {
                        onTestExecuted.fulfill()
                        self.runReferenceTests(onTestExecuted: onTestExecuted)
                    }
                }
            }
        })
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

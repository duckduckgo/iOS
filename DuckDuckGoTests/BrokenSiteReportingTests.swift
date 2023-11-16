//
//  BrokenSiteReportingTests.swift
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
import BrowserServicesKit
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import Core

@testable import DuckDuckGo

final class BrokenSiteReportingTests: XCTestCase {
    private let data = JsonTestDataLoader()
    private let host = "improving.duckduckgo.com"
    private let testAgent = "Test Agent"
    private let userAgentName = "User-Agent"
    private var referenceTests = [Test]()

    private enum Resource {
        static let tests = "privacy-reference-tests/broken-site-reporting/tests.json"
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testBrokenSiteReporting() throws {
        let testJSON = data.fromJsonFile(Resource.tests)
        let testString = String(data: testJSON, encoding: .utf8)
        let testData = try JSONDecoder().decode(BrokenSiteReportingTestData.self, from: testJSON)

        referenceTests = testData.reportURL.tests.filter {
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
        
        os_log("Testing [%s]", type: .info, test.name)
        
        let brokenSiteInfo = BrokenSiteInfo(url: URL(string: test.siteURL),
                                            httpsUpgrade: test.wasUpgraded,
                                            blockedTrackerDomains: test.blockedTrackers,
                                            installedSurrogates: test.surrogates,
                                            isDesktop: true,
                                            tdsETag: test.blocklistVersion,
                                            ampUrl: nil,
                                            urlParametersRemoved: false,
                                            protectionsState: test.protectionsEnabled,
                                            model: test.model ?? "",
                                            manufacturer: test.manufacturer ?? "",
                                            systemVersion: test.os ?? "",
                                            gpc: test.gpcEnabled)
        
        stub(condition: isHost(host)) { request -> HTTPStubsResponse in
            
            guard let requestURL = request.url else {
                XCTFail("Couldn't create request URL")
                return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
            }

            let absoluteURL = requestURL.absoluteString
                .replacingOccurrences(of: "%20", with: " ")

            if test.expectReportURLPrefix.count > 0 {
                XCTAssertTrue(requestURL.absoluteString.contains(test.expectReportURLPrefix), "Prefix [\(test.expectReportURLPrefix)] not found")
            }

            for param in test.expectReportURLParams {
                let pattern = "[?&]\(param.name)=\(param.value)[&$]?"

                guard let regex = try? NSRegularExpression(pattern: pattern,
                                                           options: []) else {
                    XCTFail("Couldn't create regex")
                    return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
                }

                let match = regex.matches(in: absoluteURL, range: NSRange(location: 0, length: absoluteURL.count))
                XCTAssertEqual(match.count, 1, "Param [\(param.name)] with value [\(param.value)] not found in [\(absoluteURL)]")
            }

            DispatchQueue.main.async {
                onTestExecuted.fulfill()
                self.runReferenceTests(onTestExecuted: onTestExecuted)
            }
            
            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        
        brokenSiteInfo.send(with: test.category, description: "", source: .dashboard)
    }
}

// MARK: - BrokenSiteReportingTestData

private struct BrokenSiteReportingTestData: Codable {
    let reportURL: ReportURL
}

// MARK: - ReportURL

private struct ReportURL: Codable {
    let name: String
    let tests: [Test]
}

// MARK: - Test
private struct Test: Codable {
    let name: String
    let siteURL: String
    let wasUpgraded: Bool
    let category: String
    let blockedTrackers, surrogates: [String]
    let atb, blocklistVersion: String
    let expectReportURLPrefix: String
    let expectReportURLParams: [ExpectReportURLParam]
    let exceptPlatforms: [String]
    let manufacturer, model, os: String?
    let gpcEnabled: Bool?
    let protectionsEnabled: Bool
}

// MARK: - ExpectReportURLParam

private struct ExpectReportURLParam: Codable {
    let name, value: String
}

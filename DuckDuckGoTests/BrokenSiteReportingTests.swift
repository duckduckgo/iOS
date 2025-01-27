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
import PrivacyDashboard
@testable import DuckDuckGo
import PersistenceTestingUtils

final class BrokenSiteReportingTests: XCTestCase {
    private let data = JsonTestDataLoader()
    private let host = "improving.duckduckgo.com"
    private let testAgent = "Test Agent"
    private let userAgentName = "User-Agent"
    private var referenceTests = [Test]()

    private enum Resource {
        static let tests = "privacy-reference-tests/broken-site-reporting/tests.json"
    }

    struct MockError: LocalizedError {
        let description: String

        init(_ description: String) {
            self.description = description
        }

        var errorDescription: String? {
            description
        }

        var localizedDescription: String? {
            description
        }
    }

    override func setUp() {
        super.setUp()

        Pixel.isDryRun = false
    }

    override func tearDown() {
        Pixel.isDryRun = true
        
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testBrokenSiteReporting() throws {
        let testJSON = data.fromJsonFile(Resource.tests)
        let testData = try JSONDecoder().decode(BrokenSiteReportingTestData.self, from: testJSON)

        referenceTests = testData.reportURL.tests.filter {
            $0.exceptPlatforms.contains("ios-browser") == false
        }
        
        let testsExecuted = expectation(description: "tests executed")
        testsExecuted.expectedFulfillmentCount = referenceTests.count
        
        try runReferenceTests(onTestExecuted: testsExecuted)
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    private func runReferenceTests(onTestExecuted: XCTestExpectation) throws {
        
        guard let test = referenceTests.popLast() else {
            return
        }
        
        print("Testing [%s]", test.name)

        var errors: [Error]?
        if let errs = test.errorDescriptions {
            errors = errs.map { MockError($0) }
        }

        let report = BrokenSiteReport(siteUrl: URL(string: test.siteURL)!,
                                      category: test.category,
                                      description: test.providedDescription,
                                      osVersion: test.os ?? "",
                                      manufacturer: test.manufacturer ?? "",
                                      upgradedHttps: test.wasUpgraded,
                                      tdsETag: test.blocklistVersion,
                                      configVersion: test.remoteConfigVersion,
                                      blockedTrackerDomains: test.blockedTrackers,
                                      installedSurrogates: test.surrogates,
                                      isGPCEnabled: test.gpcEnabled ?? false,
                                      ampURL: "",
                                      urlParametersRemoved: false,
                                      protectionsState: test.protectionsEnabled,
                                      reportFlow: .dashboard,
                                      siteType: .mobile,
                                      atb: "",
                                      model: test.model ?? "",
                                      errors: errors,
                                      httpStatusCodes: test.httpErrorCodes ?? [],
                                      openerContext: nil,
                                      vpnOn: false,
                                      jsPerformance: nil,
                                      userRefreshCount: 0,
                                      variant: "")

        let reporter = BrokenSiteReporter(pixelHandler: { params in
            
            for expectedParam in test.expectReportURLParams {
                
                if let actualValue = params[expectedParam.name],
                   let expectedCleanValue = expectedParam.value.removingPercentEncoding {
                    if expectedParam.name == "errorDescriptions" {
                        // This will be fixed once the privacy ref tests contain error code and error domain so we can construct right MockError

                        // `localizedDescription` includes class information. This format is likely to differ per platform
                        // anyway. So we'll just check if the value contains an array of strings
//                        XCTAssert(actualValue.split(separator: ",").count > 1,
//                                  "Param \(expectedParam.name) expected to be an array of strings. Received: \(actualValue)")
                    } else if actualValue != expectedCleanValue {
                        XCTFail("Mismatching param: \(expectedParam.name) => \(expectedCleanValue) != \(actualValue)")
                    }
                } else {
                    XCTFail("Missing param: \(expectedParam.name)")
                }
            }
            onTestExecuted.fulfill()
            try? self.runReferenceTests(onTestExecuted: onTestExecuted)
        }, keyValueStoring: MockKeyValueStore())
        try reporter.report(report, reportMode: .regular)
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
    let providedDescription: String?
    let blockedTrackers, surrogates: [String]
    let atb, blocklistVersion: String
    let remoteConfigVersion: String?
    let expectReportURLPrefix: String
    let expectReportURLParams: [ExpectReportURLParam]
    let exceptPlatforms: [String]
    let manufacturer, model, os: String?
    let gpcEnabled: Bool?
    let protectionsEnabled: Bool
    let errorDescriptions: [String]?
    let httpErrorCodes: [Int]?
}

// MARK: - ExpectReportURLParam

private struct ExpectReportURLParam: Codable {
    let name, value: String
}

//
//  CrashCollectionExtensionTests.swift
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
@testable import DuckDuckGo
@testable import Crashes
import MetricKit
import OHHTTPStubs
import OHHTTPStubsSwift

class CrashCollectionExtensionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
        clearUserDefaults()
    }

    func testSubsequentPixelsDontSendFirstFlag() {

        let expectation = XCTestExpectation()
        var pixelCount = 0

        stub(condition: { req in
            return req.url?.path.hasPrefix("/t/m_d_crash_") == true
        }, response: { request -> HTTPStubsResponse in
            XCTAssertNil(request.url?.getParameter(named: "first"))
            pixelCount += 1

            if pixelCount == 2 {
                expectation.fulfill()
            }

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        // 2 pixels with no first parameter
        CrashCollection.firstCrash = false
        CrashCollection.start()
        CrashCollection.collector.didReceive([
            MockPayload(mockCrashes: [
                MXCrashDiagnostic(),
                MXCrashDiagnostic()
            ])
        ])
        XCTAssertFalse(CrashCollection.firstCrash)

        wait(for: [expectation], timeout: 3.0)

    }

    func testFirstCrashFlagSent() {
        let expectation = XCTestExpectation()
        var pixelCount = 0

        stub(condition: { req in
            return req.url?.path.hasPrefix("/t/m_d_crash_") == true
        }, response: { request -> HTTPStubsResponse in
            XCTAssertEqual("1", request.url?.getParameter(named: "first"))
            pixelCount += 1

            if pixelCount == 2 {
                expectation.fulfill()
            }

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        })

        // 2 pixels with first = true attached
        XCTAssertTrue(CrashCollection.firstCrash)
        CrashCollection.start()
        CrashCollection.collector.didReceive([
            MockPayload(mockCrashes: [
                MXCrashDiagnostic(),
                MXCrashDiagnostic()
            ])
        ])
        XCTAssertFalse(CrashCollection.firstCrash)

        wait(for: [expectation], timeout: 3.0)
    }

    private func clearUserDefaults() {
        UserDefaults().removeObject(forKey: CrashCollection.firstCrashKey)
    }
}

class MockPayload: MXDiagnosticPayload {

    var mockCrashes: [MXCrashDiagnostic]?

    init(mockCrashes: [MXCrashDiagnostic]?) {
        self.mockCrashes = mockCrashes
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var crashDiagnostics: [MXCrashDiagnostic]? {
        return mockCrashes
    }

}

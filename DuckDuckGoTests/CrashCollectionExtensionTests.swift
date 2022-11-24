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
        // 2 pixels with no first parameter
        CrashCollection.firstCrash = false
        CrashCollection.start {
            XCTAssertNil($0["first"])
        }
        CrashCollection.collector.didReceive([
            MockPayload(mockCrashes: [
                MXCrashDiagnostic(),
                MXCrashDiagnostic()
            ])
        ])
        XCTAssertFalse(CrashCollection.firstCrash)
    }

    func testFirstCrashFlagSent() {
        // 2 pixels with first = true attached
        XCTAssertTrue(CrashCollection.firstCrash)
        CrashCollection.start {
            XCTAssertNotNil($0["first"])
        }
        CrashCollection.collector.didReceive([
            MockPayload(mockCrashes: [
                MXCrashDiagnostic(),
                MXCrashDiagnostic()
            ])
        ])
        XCTAssertFalse(CrashCollection.firstCrash)
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

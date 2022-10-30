//
//  AppVersionTests.swift
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
@testable import Core
@testable import BrowserServicesKit

class AppVersionTests: XCTestCase {

    struct Constants {
        static let name = "DuckDuckGo"
        static let version = "2.0.4"
        static let build = "14"
        static let identifier = "com.duckduckgo.mobile.ios"
    }

    private var mockBundle: MockBundle!
    private var testee: AppVersion!

    override func setUp() {
        super.setUp()
        
        mockBundle = MockBundle()
        testee = AppVersion(bundle: mockBundle)
    }

    func testName() {
        mockBundle.add(name: AppVersion.Keys.name, value: Constants.name)
        XCTAssertEqual(Constants.name, testee.name)
    }

    func testMajorNumber() {
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: Constants.version)
        XCTAssertEqual("2", testee.majorVersionNumber)
    }
    
    func testVersionNumber() {
        mockBundle.add(name: AppVersion.Keys.versionNumber, value: Constants.version)
        XCTAssertEqual(Constants.version, testee.versionNumber)
    }

    func testIdentifier() {
        mockBundle.add(name: AppVersion.Keys.identifier, value: Constants.identifier)
        XCTAssertEqual(Constants.identifier, testee.identifier)
    }

    func testBuildNumber() {
        mockBundle.add(name: AppVersion.Keys.buildNumber, value: Constants.build)
        XCTAssertEqual(Constants.build, testee.buildNumber)
    }
}

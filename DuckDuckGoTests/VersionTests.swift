//
//  VersionTests.swift
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

class VersionTests: XCTestCase {
    
    private static let name = "DuckDuckGo"
    private static let version = "2.0.4"
    private static let build = "14"
    
    private var mockBundle: MockBundle!
    private var testee: Version!
    
    override func setUp() {
        mockBundle = MockBundle()
        testee = Version(bundle: mockBundle)
    }
    
    func testName() {
        mockBundle.add(name: Version.Keys.name, value: VersionTests.name)
        XCTAssertEqual(VersionTests.name, testee.name())
    }
    
    func testVersionNumber() {
        mockBundle.add(name: Version.Keys.versionNumber, value: VersionTests.version)
        XCTAssertEqual(VersionTests.version, testee.versionNumber())
    }
    
    func testBuildNumber() {
        mockBundle.add(name: Version.Keys.buildNumber, value: VersionTests.build)
        XCTAssertEqual(VersionTests.build, testee.buildNumber())
    }
    
    func testLocalisedTextContainsNameVersionAndBuild() {
        mockBundle.add(name: Version.Keys.name, value: VersionTests.name)
        mockBundle.add(name: Version.Keys.versionNumber, value: VersionTests.version)
        mockBundle.add(name: Version.Keys.buildNumber, value: VersionTests.build)
        XCTAssertEqual("DuckDuckGo 2.0.4 (14)", testee.localized())
    }
    
    func testLocalisedTextContainsNameAndVersionButNotBuildWhenBuildAndVersionSame() {
        mockBundle.add(name: Version.Keys.name, value: VersionTests.name)
        mockBundle.add(name: Version.Keys.versionNumber, value: VersionTests.version)
        mockBundle.add(name: Version.Keys.buildNumber, value: VersionTests.version)
        XCTAssertEqual("DuckDuckGo 2.0.4", testee.localized())
    }
}

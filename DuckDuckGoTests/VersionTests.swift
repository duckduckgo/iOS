//
//  VersionTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 31/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest

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

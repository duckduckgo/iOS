//
//  AppTrackingProtectionAllowlistModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

final class AppTrackingProtectionAllowlistModelTests: XCTestCase {

    private struct Constants {
        static let testFilename = "testsAllowlist"
    }
    
    var allowlist: AppTrackingProtectionAllowlistModel!
    
    override func setUp() {
        super.setUp()
        allowlist = AppTrackingProtectionAllowlistModel(filename: Constants.testFilename)
    }
    
    override func tearDown() {
        super.tearDown()
        let groupContainerUrl = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppTrackingProtectionAllowlistModel.Constants.groupID
        )
        if let url = groupContainerUrl?.appendingPathComponent(Constants.testFilename, conformingTo: .text) {
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    func testAllowlistInitSucceeds() {
        XCTAssertNotNil(allowlist, "Allowlist not initialized")
    }
    
    func testAllowlistReturnsTrueForAllowedDomains() {
        allowlist.allow(domain: "example.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
    }
    
    func testAllowlistPersistsDomainsToFile() {
        allowlist.allow(domain: "example.com")
        
        let allowlist2 = AppTrackingProtectionAllowlistModel(filename: Constants.testFilename)
        XCTAssert(allowlist2.contains(domain: "example.com"), "example.com not persisted in the allowlist file")
    }
    
    func testAllowlistRemovesDomainsFromSet() {
        allowlist.allow(domain: "example.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
        
        allowlist.remove(domain: "example.com")
        XCTAssert(!allowlist.contains(domain: "example.com"), "example.com not removed from the allowlist")
    }
    
    func testAllowlistPersistsRemovedDomains() {
        allowlist.allow(domain: "example.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
        
        allowlist.remove(domain: "example.com")
        
        let allowlist2 = AppTrackingProtectionAllowlistModel()
        XCTAssert(!allowlist2.contains(domain: "example.com"), "example.com still persisted in the allowlist file")
    }
    
    func testAllowlistClearsAllDomains() {
        allowlist.allow(domain: "example.com")
        allowlist.allow(domain: "example2.com")
        allowlist.allow(domain: "example3.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
        XCTAssert(allowlist.contains(domain: "example2.com"), "example2.com not contained in the allowlist")
        XCTAssert(allowlist.contains(domain: "example3.com"), "example3.com not contained in the allowlist")
        
        allowlist.clearList()
        
        XCTAssert(!allowlist.contains(domain: "example.com"), "example.com still contained in the allowlist")
        XCTAssert(!allowlist.contains(domain: "example2.com"), "example2.com still contained in the allowlist")
        XCTAssert(!allowlist.contains(domain: "example3.com"), "example3.com still contained in the allowlist")
    }

}

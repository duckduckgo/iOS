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
import Core

final class AppTrackingProtectionAllowlistModelTests: XCTestCase {

    func testAllowlistInitSucceeds() {
        let allowlist = AppTrackingProtectionAllowlistModel()
        XCTAssertNotNil(allowlist, "Allowlist not initialized")
    }
    
    func testAllowlistReturnsTrueForAllowedDomains() {
        var allowlist = AppTrackingProtectionAllowlistModel()
        allowlist.allow(domain: "example.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
    }
    
    func testAllowlistPersistsDomainsToFile() {
        var allowlist = AppTrackingProtectionAllowlistModel()
        allowlist.allow(domain: "example.com")
        
        let allowlist2 = AppTrackingProtectionAllowlistModel()
        XCTAssert(allowlist2.contains(domain: "example.com"), "example.com not persisted in the allowlist file")
    }
    
    func testAllowlistRemovesDomainsFromSet() {
        var allowlist = AppTrackingProtectionAllowlistModel()
        allowlist.allow(domain: "example.com")
        XCTAssert(allowlist.contains(domain: "example.com"), "example.com not contained in the allowlist")
        
        allowlist.remove(domain: "example.com")
        XCTAssert(!allowlist.contains(domain: "example.com"), "example.com not removed from the allowlist")
    }

}

//
//  ContentBlockerUserDefaultsTests.swift
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
import Core

class ContentBlockerUserDefaultsTests: XCTestCase {
    
    struct Constants {
        static let userDefaultsSuit = "ContentBlockerUserDefaultsTestsSuit"
        static let domain = "somedomain.com"
        static let someOtherDomain = "someotherdomain.com"
    }
    
    var testee: ContentBlockerConfigurationUserDefaults!
    
    override func setUp() {
        UserDefaults().removePersistentDomain(forName: Constants.userDefaultsSuit)
        testee = ContentBlockerConfigurationUserDefaults(suitName: Constants.userDefaultsSuit)
    }
    
    func testWhenInitialisedThenEnableIsTrue() {
        XCTAssertTrue(testee.enabled)
    }
    
    func testWhenBlockingDisabledThenDisabledIsTrue() {
        testee.enabled = false
        XCTAssertFalse(testee.enabled)
    }
    
    func testWhenBlockingEnabledThenEnabledIsTrue() {
        // default value is true so start be setting to false to ensure test is accurate
        testee.enabled = false
        
        testee.enabled = true
        XCTAssertTrue(testee.enabled)
    }

    func testWhenNothingInWhitelistThenWhitelistedIsFalse() {
        XCTAssertFalse(testee.whitelisted(domain: Constants.domain))
    }
    
    func testWhenDomainAddedToWhitelistThenWhitelistedIsTrue() {
        testee.addToWhitelist(domain: Constants.domain)
        XCTAssertTrue(testee.whitelisted(domain: Constants.domain))
    }
    
    func testWhenRemovedFromWhitelistThenWhitelistedIsFalse() {
        testee.addToWhitelist(domain: Constants.domain)
        testee.removeFromWhitelist(domain: Constants.domain)
        XCTAssertFalse(testee.whitelisted(domain: Constants.domain))
    }
}

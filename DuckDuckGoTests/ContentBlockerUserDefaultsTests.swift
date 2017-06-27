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
    
    func testWhenInitialisedThenBlockAdvertisersIsTrue() {
        let testee = ContentBlockerConfigurationUserDefaults()
        XCTAssertTrue(testee.blockAdvertisers)
    }
    
    func testWhenBlockAdvertisersIsSetThenValueIsUpdated() {
        let testee = ContentBlockerConfigurationUserDefaults()
        
        testee.blockAdvertisers = false
        XCTAssertFalse(testee.blockAdvertisers)

        testee.blockAdvertisers = true
        XCTAssertTrue(testee.blockAdvertisers)
    }
    
    func testWhenInitialisedThenBlockAnalyticssIsTrue() {
        let testee = ContentBlockerConfigurationUserDefaults()
        XCTAssertTrue(testee.blockAnalytics)
    }
    
    func testWhenBlockAnalyticsIsSetThenValueIsUpdated() {
        let testee = ContentBlockerConfigurationUserDefaults()
        
        testee.blockAnalytics = false
        XCTAssertFalse(testee.blockAnalytics)
        
        testee.blockAnalytics = true
        XCTAssertTrue(testee.blockAnalytics)
    }
    
    func testWhenInitialisedThenBlockSocialIsTrue() {
        let testee = ContentBlockerConfigurationUserDefaults()
        XCTAssertTrue(testee.blockSocial)
    }
    
    func testWhenBlockSocialIsSetThenValueIsUpdated() {
        let testee = ContentBlockerConfigurationUserDefaults()
        
        testee.blockSocial = false
        XCTAssertFalse(testee.blockSocial)
        
        testee.blockSocial = true
        XCTAssertTrue(testee.blockSocial)
    }
}

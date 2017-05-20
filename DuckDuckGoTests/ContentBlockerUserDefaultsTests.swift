//
//  ContentBlockerUserDefaultsTests.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import XCTest
import Core

class  ContentBlockerUserDefaultsTests: XCTestCase {
    
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

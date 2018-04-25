//
//  FeatureManagerTests.swift
//  UnitTests
//
//  Created by Chris Brind on 25/04/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

import XCTest
import Core

class FeatureManagerTests: XCTestCase {

    func testWhenVariantIsM3ThenHomeRowOnboardingAndReminderAreEnabled() {
        
        let featureManager = FeatureManager(variantManager: MockVariantManager(currentVariant: "m3"))
        XCTAssertTrue(featureManager.feature(named: "homerow_onboarding").isEnabled)
        XCTAssertTrue(featureManager.feature(named: "homerow_reminder").isEnabled)
        
    }

    func testWhenVariantIsM2ThenHomeRowOnboardingIsEnabledAndReminderIsNotEnabled() {
        
        let featureManager = FeatureManager(variantManager: MockVariantManager(currentVariant: "m2"))
        XCTAssertTrue(featureManager.feature(named: "homerow_onboarding").isEnabled)
        XCTAssertFalse(featureManager.feature(named: "homerow_reminder").isEnabled)
        
    }

    func testWhenVariantIsM1ThenHomeRowOnboardingAndReminderAreNotEnabled() {

        let featureManager = FeatureManager(variantManager: MockVariantManager(currentVariant: "m1"))
        XCTAssertFalse(featureManager.feature(named: "homerow_onboarding").isEnabled)
        XCTAssertFalse(featureManager.feature(named: "homerow_reminder").isEnabled)

    }

    func testWhenUnknownFeatureIsRequestedThenDisabledFeatureReturned() {
        
        let featureManager = FeatureManager(variantManager: MockVariantManager(currentVariant: "m1"))
        let feature = featureManager.feature(named: "example")
        XCTAssertEqual("example", feature.name)
        XCTAssertFalse(feature.isEnabled)

    }

}

class FeatureManager {
    
    struct Feature {
        let name: String
        let isEnabled: Bool
    }
    
    let featuresEnabledForVariants: [String: [String]] = [
        "homerow_onboarding": ["m2", "m3"],
        "homerow_reminder": ["m3"]
    ]
    
    private let variantManager: VariantManager
    
    init(variantManager: VariantManager = DefaultVariantManager()) {
        self.variantManager = variantManager
    }
    
    func feature(named: String) -> Feature {
        let variants = featuresEnabledForVariants[named, default: []]
        let enabled = variants.contains(variantManager.currentVariant)
        return Feature(name: named, isEnabled: enabled)
    }
    
}


struct MockVariantManager: VariantManager {
    
    var currentVariant: String
    
}

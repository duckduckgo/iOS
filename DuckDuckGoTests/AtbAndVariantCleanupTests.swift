//
//  AtbAndVariantCleanupTests.swift
//  UnitTests
//
//  Created by Chris Brind on 18/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation
import XCTest
@testable import Core

class AtbAndVariantCleanupTests: XCTestCase {

    struct Constants {
        
        static let atb = "atb"
        static let variant = "variant"
        
    }
    
    let mockStorage = MockStatisticsStore()
    let mockVariantManager = MockVariantManager()

    func testWhenAtbHasVariantThenAtbStoredWithVariantRemoved() {
        
        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant
        
        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)
        
        XCTAssertEqual(Constants.atb, mockStorage.atb)
        
    }
   
    func testWhenVariantIsNotInCurrentExperimentThenVariantRemovedFromStorage() {
        
        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)
        
        XCTAssertNil(mockStorage.variant)
        
    }
    
    func testWhenVariantIsInCurrentExperimentThenVariantIsNotRemovedFromStorage() {

        let mockVariantManager = MockVariantManager(currentVariant: Variant(name: Constants.variant, percent: 100, features: []))
        
        mockStorage.atb = "\(Constants.atb)\(Constants.variant)"
        mockStorage.variant = Constants.variant

        AtbAndVariantCleanup.cleanup(statisticsStorage: mockStorage, variantManager: mockVariantManager)
        
        XCTAssertEqual(Constants.variant, mockStorage.variant)
        
    }

}

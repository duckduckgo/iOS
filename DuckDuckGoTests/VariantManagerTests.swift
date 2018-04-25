//
//  VariantManagerTests.swift
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

class VariantManagerTests: XCTestCase {
    
    func testWhenNewAndUsingDefaultRNGThenReturnsValidVariant() {
        
        let subject = VariantManager(variants: ["v1"], storage: MockVariantStorage())
        XCTAssertEqual("v1", subject.currentVariant)

    }
    
    func testWhenAlreadyInitialsedThenReturnsPreviouslySelectedVariant() {

        let mockVariantStorage = MockVariantStorage()
        mockVariantStorage.currentVariant = "x1"
        let subject = VariantManager(storage: mockVariantStorage)
        XCTAssertEqual("x1", subject.currentVariant)
        XCTAssertEqual("x1", mockVariantStorage.currentVariant)

    }
    
    func testWhenNewWithDefaultVariantsThenReturnsRandomVariant() {
        XCTAssertEqual("m1", VariantManager(storage: MockVariantStorage(), rng: MockVariantRNG(returnValue: 0)).currentVariant)
        XCTAssertEqual("m1", VariantManager(storage: MockVariantStorage(), rng: MockVariantRNG(returnValue: 1)).currentVariant)
        XCTAssertEqual("m2", VariantManager(storage: MockVariantStorage(), rng: MockVariantRNG(returnValue: 2)).currentVariant)
        XCTAssertEqual("m3", VariantManager(storage: MockVariantStorage(), rng: MockVariantRNG(returnValue: 3)).currentVariant)
    }
    
    func testWhenNewThenReturnsRandomVariantAndSavesIt() {
        
        let mockVariantStorage = MockVariantStorage()
        let subject = VariantManager(variants: ["v1"], storage: mockVariantStorage, rng: MockVariantRNG(returnValue: 0))
        XCTAssertEqual("v1", subject.currentVariant)
        XCTAssertEqual("v1", mockVariantStorage.currentVariant)
        
    }
    
}

class MockVariantStorage: VariantStorage {
    
    var currentVariant: String?
    
}

struct MockVariantRNG: VariantRNG {
    
    let returnValue: Int
    
    func nextInt(upperBound: Int) -> Int {
        return returnValue
    }
    
}

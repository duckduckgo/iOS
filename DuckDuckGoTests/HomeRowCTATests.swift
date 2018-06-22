//
//  HomeRowCTATests.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class HomeRowCTATests: XCTestCase {

    let enabledAlternativeVariantManager = MockVariantManager(currentVariant: Variant(name: "anything", percent: 100, features: [ .homeRowCTAAlternative1 ]))
    let enabledDefaultVariantManager = MockVariantManager(currentVariant: Variant(name: "anything", percent: 100, features: [ .homeRowCTADefault ]))
    let disabledVariantManager = MockVariantManager(currentVariant: Variant(name: "anything", percent: 100, features: [ ]))

    func testWhenShownAndAlternativeCTAThenDismissedNotSet() {
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: enabledAlternativeVariantManager)
        feature.shown()
        XCTAssertFalse(storage.dismissed)
    }

    func testWhenShownAndDefaultCTAThenDismissedStateStored() {
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: enabledDefaultVariantManager)
        feature.shown()
        XCTAssertTrue(storage.dismissed)
    }

    func testWhenDismissedThenDismissedStateStored() {
        let storage = MockHomeRowOnboardingStorage(dismissed: false)
        let feature = HomeRowCTA(storage: storage, variantManager: enabledDefaultVariantManager)
        feature.dismissed()
        XCTAssertTrue(storage.dismissed)
    }
    
    func testWhenFeatureHasBeenDismissedAndIsEnabledThenDontShowNow() {
        XCTAssertNil(HomeRowCTA(storage: MockHomeRowOnboardingStorage(dismissed: true), variantManager: enabledDefaultVariantManager).ctaToShow())
    }

    func testWhenFeatureHasNotBeenDismissedAndIsDisabledThenDontShowNow() {
        XCTAssertNil(HomeRowCTA(storage: MockHomeRowOnboardingStorage(dismissed: false), variantManager: disabledVariantManager).ctaToShow())
    }

    func testWhenFeatureHasNotBeenDismissedAndIsEnabledThenDefaultCTA() {
        XCTAssertEqual(.default, HomeRowCTA(storage: MockHomeRowOnboardingStorage(dismissed: false), variantManager: enabledDefaultVariantManager).ctaToShow())
    }

    func testWhenFeatureHasNotBeenDismissedAndIsAlternativeAndEnabledThenAlternativeCTA() {
        XCTAssertEqual(.alternative1, HomeRowCTA(storage: MockHomeRowOnboardingStorage(dismissed: false), variantManager: enabledAlternativeVariantManager).ctaToShow())
    }

}

class MockHomeRowOnboardingStorage: HomeRowCTAStorage {
    
    var dismissed: Bool = false
    
    init(dismissed: Bool) {
        self.dismissed = dismissed
    }
    
}

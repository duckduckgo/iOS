//
//  HomeScreenTipsTests.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class HomeScreenTipsTests: XCTestCase {

    // swiftlint:disable weak_delegate
    let delegate = MockHomeScreenTipsDelegate()
    // swiftlint:enable weak_delegate

    var storage = MockContextualTipsStorage()
    var tutorialSettings = MockTutorialSettings()
    var variantManager = MockVariantManager()

    func testWhenFeatureEnabledButOnboardingNotShownThenTriggerDoesNothing() {

        variantManager.currentVariant = Variant(name: "", weight: 0, features: [ .onboardingContextual ])
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage, variantManager: variantManager)
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

        tips?.trigger()
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

    }

    func testWhenFeatureNotEnabledThenInstanciationFails() {
        
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage, variantManager: variantManager)
        XCTAssertNil(tips)
        
    }
    
    func testWhenFeatureEnabledAndOnboardingShownAndTipsTriggeredThenDelegateCalledCorrectNumberOfTimes() {

        variantManager.isSupportedReturns = true
        tutorialSettings.hasSeenOnboarding = true

        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage, variantManager: variantManager)

        XCTAssertNotNil(tips)

        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

        tips?.trigger()
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)

        tips?.trigger()
        XCTAssertEqual(1, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)

        tips?.trigger()
        XCTAssertEqual(1, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)
    }
    
}

class MockHomeScreenTipsDelegate: NSObject, HomeScreenTipsDelegate {

    var showPrivateSearchTipCounter = 0
    var showCustomizeTipCounter = 0
    
    func showPrivateSearchTip() {
        showPrivateSearchTipCounter += 1
    }
    
    func showCustomizeTip() {
        showCustomizeTipCounter += 1
    }
    
}

class MockTutorialSettings: TutorialSettings {

    var lastVersionSeen: Int = 0

    var hasSeenOnboarding: Bool

    init(hasSeenOnboarding: Bool = false) {
        self.hasSeenOnboarding = hasSeenOnboarding
    }

}

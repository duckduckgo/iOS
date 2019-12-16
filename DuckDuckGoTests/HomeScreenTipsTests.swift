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
    let ctaStorage = MockCTAStorage()
    
    var tutorialSettings = MockTutorialSettings()

    func testWhenNotShownThenNextTipIsUnchanged() {

        storage.isEnabled = true
        tutorialSettings.hasSeenOnboarding = true
        delegate.shown = false
        
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage)
        XCTAssertNotNil(tips)

        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)

        XCTAssertEqual(0, storage.nextHomeScreenTip)
    }
    
    func testWhenFeatureEnabledButOnboardingNotShownThenTriggerDoesNothing() {

        storage.isEnabled = true
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage)
        XCTAssertNotNil(tips)
        
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

    }
    
    func testWhenFeatureEnabledOnboardingShownButCTANotDismissedThenTriggerDoesNothing() {

        storage.isEnabled = true
        tutorialSettings.hasSeenOnboarding = true
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage)
        XCTAssertNotNil(tips)

        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

        ctaStorage.dismissed = false
        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)

    }

    func testWhenFeatureNotEnabledThenInstanciationFails() {
        
        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage)
        XCTAssertNil(tips)
        
    }
    
    func testWhenFeatureEnabledAndOnboardingShownAndTipsTriggeredThenDelegateCalledCorrectNumberOfTimes() {

        storage.isEnabled = true
        tutorialSettings.hasSeenOnboarding = true

        let tips = HomeScreenTips(delegate: delegate, tutorialSettings: tutorialSettings, storage: storage)
        XCTAssertNotNil(tips)

        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(0, delegate.showPrivateSearchTipCounter)
        XCTAssertEqual(0, storage.nextHomeScreenTip)

        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(0, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)
        XCTAssertEqual(1, storage.nextHomeScreenTip)

        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(1, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)
        XCTAssertEqual(2, storage.nextHomeScreenTip)

        tips?.trigger(ctaStorage: ctaStorage)
        XCTAssertEqual(1, delegate.showCustomizeTipCounter)
        XCTAssertEqual(1, delegate.showPrivateSearchTipCounter)
        XCTAssertEqual(2, storage.nextHomeScreenTip)
    }
    
}

class MockHomeScreenTipsDelegate: NSObject, HomeScreenTipsDelegate {

    var shown = true
    var showPrivateSearchTipCounter = 0
    var showCustomizeTipCounter = 0
    
    func showPrivateSearchTip(didShow: (Bool) -> Void) {
        showPrivateSearchTipCounter += 1
        didShow(shown)
    }
    
    func showCustomizeTip(didShow: (Bool) -> Void) {
        showCustomizeTipCounter += 1
        didShow(shown)
    }
    
}

class MockCTAStorage: HomeRowCTAStorage {
    var dismissed = true
}

class MockTutorialSettings: TutorialSettings {

    var lastVersionSeen: Int = 0

    var hasSeenOnboarding: Bool

    init(hasSeenOnboarding: Bool = false) {
        self.hasSeenOnboarding = hasSeenOnboarding
    }

}

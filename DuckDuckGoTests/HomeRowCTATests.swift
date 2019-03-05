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

    var variantManager = MockVariantManager()
    var tipsStorage = MockContextualTipsStorage()
    var storage = MockHomeRowOnboardingStorage(dismissed: false)
    var tutorialSettings = MockTutorialSettings()

    func testWhenOnboardingHasNotBeenShownThenShouldNotShow() {

        tutorialSettings.hasSeenOnboarding = false
        variantManager.isSupportedReturns = true
        tipsStorage.nextHomeScreenTip = HomeScreenTips.Tips.allCases.count

        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tipsStorage: tipsStorage, tutorialSettings: tutorialSettings)
        XCTAssertFalse(feature.shouldShow())

    }

    func testWhenContextualOnboardingFeatureEnabledAndAllHomeScreenTipsShownThenCanShowCTA() {
        
        tutorialSettings.hasSeenOnboarding = true
        variantManager.isSupportedReturns = true
        tipsStorage.nextHomeScreenTip = HomeScreenTips.Tips.allCases.count

        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tipsStorage: tipsStorage, tutorialSettings: tutorialSettings)
        XCTAssertTrue(feature.shouldShow())
        
    }
    
    func testWhenContextualOnboardingFeatureEnabledAndNotAllHomeScreenTipsShownThenDontShowCTA() {
        
        tutorialSettings.hasSeenOnboarding = true
        variantManager.isSupportedReturns = true
        tipsStorage.nextHomeScreenTip = 0
        
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tipsStorage: tipsStorage, tutorialSettings: tutorialSettings)
        XCTAssertFalse(feature.shouldShow())

    }

    func testWhenDismissedThenDismissedStateStored() {
        tutorialSettings.hasSeenOnboarding = true
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tutorialSettings: tutorialSettings)
        feature.dismissed()
        XCTAssertTrue(storage.dismissed)
    }

    func testWhenDismissedThenShouldNotShow() {
        tutorialSettings.hasSeenOnboarding = true
        storage.dismissed = true
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tutorialSettings: tutorialSettings)
        XCTAssertFalse(feature.shouldShow())
    }

    func testWhenNotDismissedThenShouldShow() {
        tutorialSettings.hasSeenOnboarding = true
        let feature = HomeRowCTA(storage: storage, variantManager: variantManager, tutorialSettings: tutorialSettings)
        XCTAssertTrue(feature.shouldShow())
    }
    
}

class MockHomeRowOnboardingStorage: HomeRowCTAStorage {

    var dismissed: Bool = false

    init(dismissed: Bool) {
        self.dismissed = dismissed
    }

}

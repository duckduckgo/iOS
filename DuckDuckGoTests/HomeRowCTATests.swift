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

    var storage = MockHomeRowOnboardingStorage(dismissed: false)
    var tutorialSettings = MockTutorialSettings()
    var statistics = MockStatisticsStore()

    func testWhenOnboardingHasNotBeenShownThenShouldNotShow() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = false

        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        
        XCTAssertFalse(feature.shouldShow())
    }

    func testWhenContextualOnboardingFeatureEnabledAndAllHomeScreenTipsShownThenCanShowCTA() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = true

        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        
        XCTAssertTrue(feature.shouldShow())
    }
    
    func testWhenNotAllHomeScreenTipsShownThenDontShowCTA() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = true
        
        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        XCTAssert(feature.shouldShow())
    }

    func testWhenDismissedThenDismissedStateStored() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = true
        
        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        feature.dismissed()
        
        XCTAssertTrue(storage.dismissed)
    }

    func testWhenDismissedThenShouldNotShow() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = true
        storage.dismissed = true
        
        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        
        XCTAssertFalse(feature.shouldShow())
    }

    func testWhenNotDismissedThenShouldShow() {
        statistics.installDate = Date.distantPast
        tutorialSettings.hasSeenOnboarding = true
        
        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        
        XCTAssertTrue(feature.shouldShow())
    }
    
    func testWhenOnInstallDayThenShouldShow() {
        let installDate = Date()
        
        statistics.installDate = installDate
        tutorialSettings.hasSeenOnboarding = true
        
        let feature = HomeRowCTA(storage: storage, tutorialSettings: tutorialSettings, statistics: statistics)
        XCTAssert(feature.shouldShow(currentDate: installDate))
    }
    
}

class MockHomeRowOnboardingStorage: HomeRowCTAStorage {

    var dismissed: Bool = false

    init(dismissed: Bool) {
        self.dismissed = dismissed
    }

}

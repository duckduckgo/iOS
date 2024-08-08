//
//  NewTabPageIntroMessageSetupTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

final class NewTabPageIntroMessageSetupTests: XCTestCase {

    private let appSettings = AppSettingsMock()
    private let statistics = MockStatisticsStore()
    private let ntpManagerMock = NewTabPageManagerMock()

    func testEnablesFeatureForExistingUser() {
        let sut = createSUT()
        statistics.installDate = Date()

        sut.perform()

        XCTAssertEqual(appSettings.newTabPageIntroMessageEnabled, true)
    }

    func testDisablesFeatureForNewUser() {
        let sut = createSUT()
        statistics.installDate = nil

        sut.perform()

        XCTAssertEqual(appSettings.newTabPageIntroMessageEnabled, false)
    }

    func testDoesNothingIfSetAlready() {
        let sut = createSUT()
        statistics.installDate = nil
        appSettings.newTabPageIntroMessageEnabled = true

        sut.perform()

        XCTAssertEqual(appSettings.newTabPageIntroMessageEnabled, true)
    }

    func testDoesNothingIfNotPubliclyReleased() {
        let sut = createSUT()
        statistics.installDate = nil
        ntpManagerMock.isAvailableInPublicRelease = false
        appSettings.newTabPageIntroMessageEnabled = nil

        sut.perform()

        XCTAssertNil(appSettings.newTabPageIntroMessageEnabled)
    }

    private func createSUT() -> NewTabPageIntroMessageSetup {
        NewTabPageIntroMessageSetup(appSettings: appSettings, statistics: statistics, newTabPageManager: ntpManagerMock)
    }
}

private final class NewTabPageManagerMock: NewTabPageManaging {
    var isNewTabPageSectionsEnabled: Bool = true
    var isAvailableInPublicRelease: Bool = true
}

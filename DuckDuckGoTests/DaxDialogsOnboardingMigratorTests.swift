//
//  DaxDialogsOnboardingMigratorTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

final class DaxDialogsOnboardingMigratorTests: XCTestCase {
    private var sut: DaxDialogsOnboardingMigrator!
    private var daxDialogsSettingsMock: MockDaxDialogsSettings!

    override func setUpWithError() throws {
        try super.setUpWithError()
        daxDialogsSettingsMock = MockDaxDialogsSettings()
        sut = DaxDialogsOnboardingMigrator(daxDialogsSettings: daxDialogsSettingsMock)
    }

    override func tearDownWithError() throws {
        daxDialogsSettingsMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenDaxDialogsHomeScreenMessagesSeenSettingIsNotZero_ThenSetIsDismissedToTrue() throws {
        // GIVEN
        daxDialogsSettingsMock.homeScreenMessagesSeen = 1
        XCTAssertFalse(daxDialogsSettingsMock.isDismissed)

        // WHEN
        sut.migrateFromOldToNewOboarding()

        // THEN
        XCTAssertTrue(daxDialogsSettingsMock.isDismissed)
    }

    func testWhenDaxDialogsHomeScreenMessagesSeenSettingIsZero_ThenDoNotSetIsDismissedToTrue() throws {
        // GIVEN
        daxDialogsSettingsMock.homeScreenMessagesSeen = 0
        XCTAssertFalse(daxDialogsSettingsMock.isDismissed)

        // WHEN
        sut.migrateFromOldToNewOboarding()

        // THEN
        XCTAssertFalse(daxDialogsSettingsMock.isDismissed)
    }
}

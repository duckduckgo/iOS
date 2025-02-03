//
//  NewTabPageShortcutsSettingsModelTests.swift
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
import BrowserServicesKit

@testable import Core
@testable import DuckDuckGo

final class NewTabPageShortcutsSettingsModelTests: XCTestCase {

    override func tearDown() {
        PixelFiringMock.tearDown()
    }

    func testFiresPixelWhenItemEnabled() throws {
        let sut = createSUT()

        let passwordsSettings = try XCTUnwrap(sut.itemsSettings.first { setting in
            setting.item == .passwords
        })

        passwordsSettings.isEnabled.wrappedValue = true

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageCustomizeShortcutAdded("passwords").name)
    }

    func testFiresPixelWhenItemDisabled() throws {
        let sut = createSUT()

        let passwordsSettings = try XCTUnwrap(sut.itemsSettings.first { setting in
            setting.item == .passwords
        })

        passwordsSettings.isEnabled.wrappedValue = false

        XCTAssertEqual(PixelFiringMock.lastPixelName, Pixel.Event.newTabPageCustomizeShortcutRemoved("passwords").name)
    }

    private func createSUT() -> NewTabPageShortcutsSettingsModel {
        let storage = NewTabPageShortcutsSettingsStorage(
            persistentStore: NewTabPageSettingsPersistentStoreMock(),
            defaultOrder: NewTabPageShortcut.allCases,
            defaultEnabledItems: NewTabPageShortcut.allCases
        )
        
        return NewTabPageShortcutsSettingsModel(storage: storage,
                                                featureFlagger: AlwaysTrueFeatureFlagger(),
                                                pixelFiring: PixelFiringMock.self)
    }
}

private final class AlwaysTrueFeatureFlagger: FeatureFlagger {
    var internalUserDecider: InternalUserDecider = DefaultInternalUserDecider(store: MockInternalUserStoring())
    var localOverrides: FeatureFlagLocalOverriding?

    func isFeatureOn<Flag: FeatureFlagDescribing>(for featureFlag: Flag, allowOverride: Bool) -> Bool {
        true
    }

    func getCohortIfEnabled(_ subfeature: any PrivacySubfeature) -> CohortID? {
        return nil
    }

    func resolveCohort<Flag>(for featureFlag: Flag, allowOverride: Bool) -> (any FeatureFlagCohortDescribing)? where Flag: FeatureFlagDescribing {
        return nil
    }

    var allActiveExperiments: Experiments = [:]
}

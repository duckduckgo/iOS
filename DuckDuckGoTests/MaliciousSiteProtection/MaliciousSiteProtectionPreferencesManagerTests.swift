//
//  MaliciousSiteProtectionPreferencesManagerTests.swift
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

import Testing
import Combine
@testable import DuckDuckGo

final class MaliciousSiteProtectionPreferencesManagerTests {
    private var sut: MaliciousSiteProtectionPreferencesManager!
    private var store: MockMaliciousSiteProtectionPreferencesStore!
    private var cancellables: Set<AnyCancellable>!

    init() {
        cancellables = []
        store = MockMaliciousSiteProtectionPreferencesStore()
        sut = MaliciousSiteProtectionPreferencesManager(store: store)
    }

    @Test(
        "Update Malicious Site Protection Storage",
        arguments: [
            true,
            false
        ]
    )
    func whenIsEnabledIsSet_ThenStoreIsUpdated(value: Bool) {
        // GIVEN
        store.isEnabled = !value

        // WHEN
        sut.isMaliciousSiteProtectionOn = value

        // THEN
        #expect(store.isEnabled == value)
    }

    @Test(
        "Publish Malicious Site Protection User Preferences",
        arguments: [
            true,
            false
        ]
    )
    func whenIsEnabledIsSet_ThenValueIsPublished(value: Bool) {
        // GIVEN
        var capturedIsEnabled: Bool?
        sut.isMaliciousSiteProtectionOnPublisher.sink { isEnabled in
            capturedIsEnabled = isEnabled
        }
        .store(in: &cancellables)

        // WHEN
        sut.isMaliciousSiteProtectionOn = value

        // THEN
        #expect(capturedIsEnabled == value)
    }
}

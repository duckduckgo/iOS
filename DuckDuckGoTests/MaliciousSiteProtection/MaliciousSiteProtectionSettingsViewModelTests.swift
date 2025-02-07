//
//  MaliciousSiteProtectionSettingsViewModelTests.swift
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
@testable import DuckDuckGo

@Suite("Malicious Site Protection - Settings View Model Unit Tests")
final class MaliciousSiteProtectionSettingsViewModelTests {
    private var sut: MaliciousSiteProtectionSettingsViewModel!
    private var preferencesManager: MockMaliciousSiteProtectionPreferencesManager!
    private var featureFlagger: MockMaliciousSiteProtectionFeatureFlags!
    private var urlOpener: MockURLOpener!

    init() {
        preferencesManager = MockMaliciousSiteProtectionPreferencesManager()
        featureFlagger = MockMaliciousSiteProtectionFeatureFlags()
        urlOpener = MockURLOpener()
        setupSUT()
    }

    @Test("Malicious Site Protection Settings Section should be shown")
    func whenInit_AndIsMaliciousSiteProtectionSetToTrue_ThenShouldShowMaliciousSiteProtectionSectionReturnsTrue() {
        // GIVEN
        featureFlagger.isMaliciousSiteProtectionEnabled = true
        setupSUT()

        // WHEN
        let result = sut.shouldShowMaliciousSiteProtectionSection

        // THEN
        #expect(result)
    }

    @Test("Malicious Site Protection Settings Section should not be shown")
    func whenInit_AndIsMaliciousSiteProtectionSetToFalse_ThenShouldShowMaliciousSiteProtectionSectionReturnsFalse() {
        // GIVEN
        featureFlagger.isMaliciousSiteProtectionEnabled = false
        setupSUT()

        // WHEN
        let result = sut.shouldShowMaliciousSiteProtectionSection

        // THEN
        #expect(!result)
    }

    @Test("Malicious Site Protection preference is On")
    func whenInit_AndIsEnabledPreferenceSetToTrue_ThenIsMaliciousSiteProtectionEnabledReturnsTrue() {
        // GIVEN
        preferencesManager.isMaliciousSiteProtectionOn = true
        setupSUT()

        // WHEN
        let result = sut.isMaliciousSiteProtectionOn

        // THEN
        #expect(result)
    }

    @Test("Malicious Site Protection preference is Off")
    func whenInit_AndIsEnabledPreferenceSetToFalse_ThenIsMaliciousSiteProtectionEnabledReturnsFalse() {
        // GIVEN
        preferencesManager.isMaliciousSiteProtectionOn = false
        setupSUT()

        // WHEN
        let result = sut.isMaliciousSiteProtectionOn

        // THEN
        #expect(!result)
    }


    @Test("Turning On Malicious Site Protection Settings Save User Preference")
    func whenMaliciousSiteProtectionBindingIsSetToTrue_ThenIsMaliciousSiteProtectionEnabledIsSetToTrue() {
        // GIVEN
        preferencesManager.isMaliciousSiteProtectionOn = false
        #expect(!preferencesManager.isMaliciousSiteProtectionOn)

        // WHEN
        sut.isMaliciousSiteProtectionOn = true

        // THEN
        #expect(preferencesManager.isMaliciousSiteProtectionOn)
    }

    @Test("Turning Off Malicious Site Protection Settings Save User Preference")
    func whenMaliciousSiteProtectionBindingIsSetToFalse_ThenIsMaliciousSiteProtectionEnabledIsSetToFalse() {
        // GIVEN
        preferencesManager.isMaliciousSiteProtectionOn = true
        #expect(preferencesManager.isMaliciousSiteProtectionOn)

        // WHEN
        sut.isMaliciousSiteProtectionOn = false

        // THEN
        #expect(!preferencesManager.isMaliciousSiteProtectionOn)
    }

    @Test("Open Malicious Site Protection Learn More")
    func whenLearnMoreAction_ThenShouldNavigateToLearnMorePage() {
        // GIVEN
        #expect(!urlOpener.didCallOpenURL)
        #expect(urlOpener.capturedURL == nil)
        setupSUT()

        // WHEN
        sut.learnMoreAction()

        // THEN
        #expect(urlOpener.didCallOpenURL)
        #expect(urlOpener.capturedURL == .maliciousSiteProtectionLearnMore)
    }
}

extension MaliciousSiteProtectionSettingsViewModelTests {

    func setupSUT() {
        sut = MaliciousSiteProtectionSettingsViewModel(
            manager: preferencesManager,
            featureFlagger: featureFlagger,
            urlOpener: urlOpener
        )
    }

}

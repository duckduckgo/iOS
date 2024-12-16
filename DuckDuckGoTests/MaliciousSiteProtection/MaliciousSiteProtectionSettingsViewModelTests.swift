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

    @Test("Malicious Site Protection preference is enabled")
    func whenInit_AndIsEnabledPreferenceSetToTrue_ThenIsMaliciousSiteProtectionEnabledReturnsTrue() {
        // GIVEN
        preferencesManager.isEnabled = true
        setupSUT()

        // WHEN
        let result = sut.isMaliciousSiteProtectionEnabled

        // THEN
        #expect(result)
    }

    @Test("Malicious Site Protection preference is disabled")
    func whenInit_AndIsEnabledPreferenceSetToFalse_ThenIsMaliciousSiteProtectionEnabledReturnsFalse() {
        // GIVEN
        preferencesManager.isEnabled = false
        setupSUT()

        // WHEN
        let result = sut.isMaliciousSiteProtectionEnabled

        // THEN
        #expect(!result)
    }

    @Test("Malicious Site Protection Settings binding value is true")
    func whenMaliciousSiteProtectionBindingIsCalled_AndValueIsTrue_ThenReturnTrue() {
        // GIVEN
        preferencesManager.isEnabled = true

        // WHEN
        let result = sut.maliciousSiteProtectionBinding

        // THEN
        #expect(result.wrappedValue)
    }

    @Test("Malicious Site Protection Settings binding value is false")
    func whenMaliciousSiteProtectionBindingIsCalled_AndValueIsFalse_ThenReturnFalse() {
        // GIVEN
        preferencesManager.isEnabled = false

        // WHEN
        let result = sut.maliciousSiteProtectionBinding

        // THEN
        #expect(!result.wrappedValue)
    }

    @Test("Malicious Site Protection Settings binding value is set to true")
    func whenMaliciousSiteProtectionBindingIsSetToTrue_ThenIsMaliciousSiteProtectionEnabledIsSetToTrue() {
        // GIVEN
        preferencesManager.isEnabled = false
        #expect(!preferencesManager.isEnabled)

        // WHEN
        sut.maliciousSiteProtectionBinding.wrappedValue = true

        // THEN
        #expect(preferencesManager.isEnabled)
    }

    @Test("Malicious Site Protection Settings binding value is set to false")
    func whenMaliciousSiteProtectionBindingIsSetToFalse_ThenIsMaliciousSiteProtectionEnabledIsSetToFalse() {
        // GIVEN
        preferencesManager.isEnabled = true
        #expect(preferencesManager.isEnabled)

        // WHEN
        sut.maliciousSiteProtectionBinding.wrappedValue = false

        // THEN
        #expect(!preferencesManager.isEnabled)
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

//
//  OnboardingIntroViewModelTests.swift
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

final class OnboardingIntroViewModelTests: XCTestCase {

    // MARK: - State + Actions

    func testWhenSubscribeToViewStateThenShouldSendLanding() {
        // GIVEN
        let sut = OnboardingIntroViewModel()

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledThenViewStateChangesToStartOnboardingDialog() {
        // GIVEN
        let sut = OnboardingIntroViewModel()
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.startOnboardingDialog))
    }

    func testWhenStartOnboardingActionIsCalledThenViewStateChangesToBrowsersComparisonDialog() {
        // GIVEN
        let sut = OnboardingIntroViewModel()
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.browsersComparisonDialog))
    }

    func testWhenSetDefaultBrowserActionIsCalledThenURLOpenerOpensSettingsURL() {
        // GIVEN
        let urlOpenerMock = MockURLOpener()
        let sut = OnboardingIntroViewModel(urlOpener: urlOpenerMock)
        XCTAssertFalse(urlOpenerMock.didCallOpenURL)
        XCTAssertNil(urlOpenerMock.capturedURL)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(urlOpenerMock.didCallOpenURL)
        XCTAssertEqual(urlOpenerMock.capturedURL?.absoluteString, UIApplication.openSettingsURLString)
    }

    func testWhenSetDefaultBrowserActionIsCalledThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    // MARK: - Pixels

    func testWhenOnAppearIsCalledThenPixelReporterTrackOnboardingIntroImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock)
        XCTAssertFalse(pixelReporterMock.didCallTrackOnboardingIntroImpression)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackOnboardingIntroImpression)
    }

    func testWhenStartOnboardingActionIsCalledThenPixelReporterTrackBrowserComparisonImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock)
        XCTAssertFalse(pixelReporterMock.didCallTrackBrowserComparisonImpression)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackBrowserComparisonImpression)
    }

    func testWhenChooseBrowserIsCalledThenPixelReporterTrackChooseBrowserCTAAction() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock)
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBrowserCTAAction)

        // WHEN
        sut.chooseBrowserAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseBrowserCTAAction)
    }

}

private final class OnboardingIntroPixelReporterMock: OnboardingIntroPixelReporter {
    private(set) var didCallTrackOnboardingIntroImpression = false
    private(set) var didCallTrackBrowserComparisonImpression = false
    private(set) var didCallTrackChooseBrowserCTAAction = false

    func trackOnboardingIntroImpression() {
        didCallTrackOnboardingIntroImpression = true
    }

    func trackBrowserComparisonImpression() {
        didCallTrackBrowserComparisonImpression = true
    }

    func trackChooseBrowserCTAAction() {
        didCallTrackChooseBrowserCTAAction = true
    }
}

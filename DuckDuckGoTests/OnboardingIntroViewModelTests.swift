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
    private var onboardingManager: OnboardingHighlightsManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        onboardingManager = OnboardingHighlightsManagerMock()
    }

    override func tearDownWithError() throws {
        onboardingManager = nil
        try super.tearDownWithError()
    }

    // MARK: - State + Actions

    func testWhenSubscribeToViewStateThenShouldSendLanding() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledThenViewStateChangesToStartOnboardingDialog() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }

    func testWhenStartOnboardingActionIsCalledThenViewStateChangesToBrowsersComparisonDialog() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .browsersComparisonDialog, step: .hidden)))
    }

    func testWhenSetDefaultBrowserActionIsCalledThenURLOpenerOpensSettingsURL() {
        // GIVEN
        let urlOpenerMock = MockURLOpener()
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: urlOpenerMock)
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
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
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
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    // MARK: - Highlights State + Actions

    func testWhenSubscribeToViewStateAndIsHighlightsFlowThenShouldSendLanding() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledAndIsHighlightsFlowThenViewStateChangesToStartOnboardingDialogAndProgressIsHidden() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }

    func testWhenStartOnboardingActionIsCalledAndIsHighlightsFlowThenViewStateChangesToBrowsersComparisonDialogAndProgressIs1Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .browsersComparisonDialog, step: .init(currentStep: 1, totalSteps: 3))))
    }

    func testWhenSetDefaultBrowserActionIsCalledAndIsHighlightsFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledAndIsHighlightsFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIsHighlightsFlowThenViewStateChangesToChooseAddressBarPositionDialogAndProgressIs3Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAddressBarPositionDialog, step: .init(currentStep: 3, totalSteps: 3))))
    }

    func testWhenSelectAddressBarPositionActionIsCalledAndIsHighlightsFlowThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.selectAddressBarPositionAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    // MARK: - Pixels

    func testWhenOnAppearIsCalledThenPixelReporterTrackOnboardingIntroImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackOnboardingIntroImpression)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackOnboardingIntroImpression)
    }

    func testWhenStartOnboardingActionIsCalledThenPixelReporterTrackBrowserComparisonImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackBrowserComparisonImpression)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackBrowserComparisonImpression)
    }

    func testWhenChooseBrowserIsCalledThenPixelReporterTrackChooseBrowserCTAAction() {
        // GIVEN
        let pixelReporterMock = OnboardingIntroPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBrowserCTAAction)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseBrowserCTAAction)
    }

}

private final class OnboardingIntroPixelReporterMock: OnboardingIntroPixelReporting {
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

private class OnboardingHighlightsManagerMock: OnboardingHighlightsManaging {
    var isOnboardingHighlightsEnabled: Bool = false
}

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
    private var onboardingManager: OnboardingManagerMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        onboardingManager = OnboardingManagerMock()
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
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    // MARK: - Highlights State + Actions iPhone

    // MARK: iPhone

    func testWhenSubscribeToViewStateAndIsHighlightsIphoneFlowThenShouldSendLanding() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledAndAndIsHighlightsIphoneFlowThenViewStateChangesToStartOnboardingDialogAndProgressIsHidden() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }

    func testWhenStartOnboardingActionIsCalledAndIsHighlightsIphoneFlowThenViewStateChangesToBrowsersComparisonDialogAndProgressIs1Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .browsersComparisonDialog, step: .init(currentStep: 1, totalSteps: 3))))
    }

    func testWhenSetDefaultBrowserActionIsCalledAndIsHighlightsIphoneFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledAndIsHighlightsIphoneFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIsHighlightsIphoneFlowThenViewStateChangesToChooseAddressBarPositionDialogAndProgressIs3Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAddressBarPositionDialog, step: .init(currentStep: 3, totalSteps: 3))))
    }

    func testWhenSelectAddressBarPositionActionIsCalledAndIsHighlightsIphoneFlowThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.selectAddressBarPositionAction()

        // THEN
        XCTAssertTrue(didCallOnCompletingOnboardingIntro)
    }

    // MARK: iPad

    func testWhenSubscribeToViewStateAndIsHighlightsIpadFlowThenShouldSendLanding() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledAndAndIsHighlightsIpadFlowThenViewStateChangesToStartOnboardingDialogAndProgressIsHidden() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }
    //
    func testWhenStartOnboardingActionIsCalledAndIsHighlightsIpadFlowThenViewStateChangesToBrowsersComparisonDialogAndProgressIs1Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .browsersComparisonDialog, step: .init(currentStep: 1, totalSteps: 2))))
    }

    func testWhenSetDefaultBrowserActionIsCalledAndIsHighlightsIpadFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 2))))
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledAndIsHighlightsIpadFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 2))))
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIsHighlightsIphoneFlowThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        sut.onCompletingOnboardingIntro = {
            didCallOnCompletingOnboardingIntro = true
        }
        XCTAssertFalse(didCallOnCompletingOnboardingIntro)

        // WHEN
        sut.appIconPickerContinueAction()

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

    // MARK: - Copy

    func testWhenIsNotHighlightsThenIntroTitleIsCorrect() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.introTitle

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.Intro.title)
    }

    func testWhenIsHighlightsThenIntroTitleIsCorrect() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.introTitle

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.Intro.title)
    }

    func testWhenIsNotHighlightsThenBrowserComparisonTitleIsCorrect() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.browserComparisonTitle

        // THEN
        XCTAssertEqual(result, UserText.DaxOnboardingExperiment.BrowsersComparison.title)
    }

    func testWhenIsHighlightsThenBrowserComparisonTitleIsCorrect() {
        // GIVEN
        onboardingManager.isOnboardingHighlightsEnabled = true
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingIntroPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.browserComparisonTitle

        // THEN
        XCTAssertEqual(result, UserText.HighlightsOnboardingExperiment.BrowsersComparison.title)
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

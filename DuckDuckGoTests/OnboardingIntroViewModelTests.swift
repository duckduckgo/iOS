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
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledThenViewStateChangesToStartOnboardingDialog() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }

    func testWhenSetDefaultBrowserActionIsCalledThenURLOpenerOpensSettingsURL() {
        // GIVEN
        let urlOpenerMock = MockURLOpener()
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: urlOpenerMock)
        XCTAssertFalse(urlOpenerMock.didCallOpenURL)
        XCTAssertNil(urlOpenerMock.capturedURL)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(urlOpenerMock.didCallOpenURL)
        XCTAssertEqual(urlOpenerMock.capturedURL?.absoluteString, UIApplication.openSettingsURLString)
    }

    // MARK: iPhone Flow

    func testWhenSubscribeToViewStateAndIsIphoneFlowThenShouldSendLanding() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledAndAndIsIphoneFlowThenViewStateChangesToStartOnboardingDialogAndProgressIsHidden() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }


    func testWhenSetDefaultBrowserActionIsCalledAndIsIphoneFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledAndIsIphoneFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 3))))
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIsIphoneFlowThenViewStateChangesToChooseAddressBarPositionDialogAndProgressIs3Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAddressBarPositionDialog, step: .init(currentStep: 3, totalSteps: 3))))
    }

    func testWhenSelectAddressBarPositionActionIsCalledAndIsIphoneFlowThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
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

    func testWhenSubscribeToViewStateAndIsIpadFlowThenShouldSendLanding() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.state

        // THEN
        XCTAssertEqual(result, .landing)
    }

    func testWhenOnAppearIsCalledAndAndIsIpadFlowThenViewStateChangesToStartOnboardingDialogAndProgressIsHidden() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .startOnboardingDialog, step: .hidden)))
    }

    func testWhenStartOnboardingActionIsCalledAndIsIpadFlowThenViewStateChangesToBrowsersComparisonDialogAndProgressIs1Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .browsersComparisonDialog, step: .init(currentStep: 1, totalSteps: 2))))
    }

    func testWhenSetDefaultBrowserActionIsCalledAndIsIpadFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 2))))
    }

    func testWhenCancelSetDefaultBrowserActionIsCalledAndIsIpadFlowThenViewStateChangesToChooseAppIconDialogAndProgressIs2Of3() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.cancelSetDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 2, totalSteps: 2))))
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIsIphoneFlowThenOnCompletingOnboardingIntroIsCalled() {
        // GIVEN
        var didCallOnCompletingOnboardingIntro = false
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: true, urlOpener: MockURLOpener())
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
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackOnboardingIntroImpression)

        // WHEN
        sut.onAppear()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackOnboardingIntroImpression)
    }

    func testWhenStartOnboardingActionIsCalledThenPixelReporterTrackBrowserComparisonImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackBrowserComparisonImpression)

        // WHEN
        sut.startOnboardingAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackBrowserComparisonImpression)
    }

    func testWhenChooseBrowserIsCalledThenPixelReporterTrackChooseBrowserCTAAction() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBrowserCTAAction)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseBrowserCTAAction)
    }

    func testWhenStateChangesToChooseAppIconThenPixelReporterTrackAppIconImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackBrowserComparisonImpression)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseAppIconImpression)
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIconIsCustomColorThenPixelReporterTrackCustomAppIconColor() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener(), appIconProvider: { .purple })
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseCustomAppIconColor)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseCustomAppIconColor)
    }

    func testWhenAppIconPickerContinueActionIsCalledAndIconIsDefaultColorThenPixelReporterDoNotTrackCustomAppIconColor() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener(), appIconProvider: { .defaultAppIcon })
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseCustomAppIconColor)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseCustomAppIconColor)
    }

    func testWhenStateChangesToChooseAddressBarPositionThenPixelReporterTrackAddressBarSelectionImpression() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackAddressBarPositionSelectionImpression)

        // WHEN
        sut.appIconPickerContinueAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddressBarPositionSelectionImpression)
    }

    func testWhenSelectAddressBarPositionActionIsCalledAndAddressBarPositionIsBottomThenPixelReporterTrackChooseBottomAddressBarPosition() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener(), addressBarPositionProvider: { .bottom })
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBottomAddressBarPosition)

        // WHEN
        sut.selectAddressBarPositionAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackChooseBottomAddressBarPosition)
    }

    func testWhenSelectAddressBarPositionActionIsCalledAndAddressBarPositionIsTopThenPixelReporterDoNotTrackChooseBottomAddressBarPosition() {
        // GIVEN
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener(), addressBarPositionProvider: { .top })
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBottomAddressBarPosition)

        // WHEN
        sut.selectAddressBarPositionAction()

        // THEN
        XCTAssertFalse(pixelReporterMock.didCallTrackChooseBottomAddressBarPosition)
    }

    // MARK: - Copy

    func testIntroTitleIsCorrect() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.introTitle

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.Intro.title)
    }

    func testBrowserComparisonTitleIsCorrect() {
        // GIVEN
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, urlOpener: MockURLOpener())

        // WHEN
        let result = sut.copy.browserComparisonTitle

        // THEN
        XCTAssertEqual(result, UserText.Onboarding.BrowsersComparison.title)
    }

    // MARK: - Add To Dock

    func testWhenSetDefaultBrowserActionIsCalledAndIsIphoneFlowThenViewStateChangesToAddToDockPromoDialogAndProgressIs2Of4() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false, urlOpener: MockURLOpener())
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .addToDockPromoDialog, step: .init(currentStep: 2, totalSteps: 4))))
    }

    func testWhenAddtoDockContinueActionIsCalledAndIsIphoneFlowThenThenViewStateChangesToChooseAppIconAndProgressIs3of4() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let sut = OnboardingIntroViewModel(pixelReporter: OnboardingPixelReporterMock(), onboardingManager: onboardingManager, isIpad: false)
        XCTAssertEqual(sut.state, .landing)

        // WHEN
        sut.addToDockContinueAction(isShowingAddToDockTutorial: false)

        // THEN
        XCTAssertEqual(sut.state, .onboarding(.init(type: .chooseAppIconDialog, step: .init(currentStep: 3, totalSteps: 4))))
    }

    // MARK: - Pixel Add To Dock

    func testWhenStateChangesToAddToDockPromoThenPixelReporterTrackAddToDockPromoImpression() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockPromoImpression)

        // WHEN
        sut.setDefaultBrowserAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockPromoImpression)
    }

    func testWhenAddToDockShowTutorialActionIsCalledThenPixelReporterTrackAddToDockPromoShowTutorialCTA() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockPromoShowTutorialCTAAction)

        // WHEN
        sut.addtoDockShowTutorialAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockPromoShowTutorialCTAAction)
    }

    func testWhenAddToDockContinueActionIsCalledAndIsShowingFromAddToDockTutorialIsTrueThenPixelReporterTrackAddToDockTutorialDismissCTA() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockTutorialDismissCTAAction)

        // WHEN
        sut.addToDockContinueAction(isShowingAddToDockTutorial: true)

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockTutorialDismissCTAAction)
    }

    func testWhenAddToDockContinueActionIsCalledAndIsShowingFromAddToDockTutorialIsFalseThenPixelReporterTrackAddToDockTutorialDismissCTA() {
        // GIVEN
        onboardingManager.addToDockEnabledState = .intro
        let pixelReporterMock = OnboardingPixelReporterMock()
        let sut = OnboardingIntroViewModel(pixelReporter: pixelReporterMock, onboardingManager: onboardingManager, urlOpener: MockURLOpener())
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockPromoDismissCTAAction)

        // WHEN
        sut.addToDockContinueAction(isShowingAddToDockTutorial: false)

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockPromoDismissCTAAction)
    }

}

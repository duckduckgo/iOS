//
//  ContextualOnboardingNewTabDialogFactoryTests.swift
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
import SwiftUI
import Core
import Onboarding
@testable import DuckDuckGo

class ContextualOnboardingNewTabDialogFactoryTests: XCTestCase {

    var factory: NewTabDaxDialogFactory!
    var mockDelegate: CapturingOnboardingNavigationDelegate!
    var contextualOnboardingLogicMock: ContextualOnboardingLogicMock!
    var pixelReporterMock: OnboardingPixelReporterMock!
    var onboardingManagerMock: OnboardingManagerMock!
    var onDismissCalled: Bool!
    var window: UIWindow!

    override func setUpWithError() throws {
        throw XCTSkip("Potentially flaky")
        try super.setUpWithError()
        mockDelegate = CapturingOnboardingNavigationDelegate()
        contextualOnboardingLogicMock = ContextualOnboardingLogicMock()
        onboardingManagerMock = OnboardingManagerMock()
        onDismissCalled = false
        pixelReporterMock = OnboardingPixelReporterMock()
        factory = NewTabDaxDialogFactory(
            delegate: mockDelegate,
            contextualOnboardingLogic: contextualOnboardingLogicMock,
            onboardingPixelReporter: pixelReporterMock,
            onboardingManager: onboardingManagerMock
        )
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        window?.isHidden = true
        window = nil
        factory = nil
        mockDelegate = nil
        onDismissCalled = nil
        contextualOnboardingLogicMock = nil
        pixelReporterMock = nil
        onboardingManagerMock = nil
        super.tearDown()
    }

    func testCreateInitialDialogCreatesAnOnboardingTrySearchDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.initial

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let trySearchDialog = find(OnboardingTrySearchDialog.self, in: host)
        XCTAssertNotNil(trySearchDialog)
        XCTAssertTrue(trySearchDialog?.viewModel.delegate === mockDelegate)
    }

    func testCreateSubsequentDialogCreatesAnOnboardingTryVisitingSiteDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.subsequent

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let trySiteDialog = find(OnboardingTryVisitingSiteDialog.self, in: host)
        XCTAssertNotNil(trySiteDialog)
        XCTAssertTrue(trySiteDialog?.viewModel.delegate === mockDelegate)
    }

    func testCreateFinalDialogCreatesAnOnboardingFinalDialog() {
        // Given
        let expectation = XCTestExpectation(description: "action triggered")
        contextualOnboardingLogicMock.expectation = expectation
        var onDismissedRun = false
        let homeDialog = DaxDialogs.HomeScreenSpec.final
        let onDimsiss = { onDismissedRun = true }

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: onDimsiss)
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        XCTAssertNotNil(host.view)

        // Then
        let finalDialog = find(OnboardingFinalDialog.self, in: host)
        XCTAssertNotNil(finalDialog)
        finalDialog?.dismissAction(false)
        XCTAssertTrue(onDismissedRun)
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(contextualOnboardingLogicMock.didCallsetFinalOnboardingDialogSeen)
    }

    func testCreateAddFavoriteDialogCreatesAContextualDaxDialog() {
        // Given
        let homeDialog = DaxDialogs.HomeScreenSpec.addFavorite

        // When
        let view = factory.createDaxDialog(for: homeDialog, onDismiss: {})
        let host = UIHostingController(rootView: view)
        XCTAssertNotNil(host.view)

        // Then
        let addFavoriteDialog = find(ContextualDaxDialogContent.self, in: host)
        XCTAssertNotNil(addFavoriteDialog)
        XCTAssertEqual(addFavoriteDialog?.message.string, homeDialog.message)
    }

    // MARK: - Pixels

    func testWhenOnboardingTrySearchDialogAppearForTheFirstTime_ThenFireExpectedPixel() {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.initial
        let pixelEvent = Pixel.Event.onboardingContextualTrySearchUnique
        // TEST
        testDialogDefinedBy(spec: spec, firesEvent: pixelEvent)
    }

    func testWhenOnboardingTryVisitSiteDialogAppearForTheFirstTime_ThenFireExpectedPixel() {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.subsequent
        let pixelEvent = Pixel.Event.onboardingContextualTryVisitSiteUnique
        // TEST
        testDialogDefinedBy(spec: spec, firesEvent: pixelEvent)
    }

    func testWhenOnboardingFinalDialogAppearForTheFirstTime_ThenFireExpectedPixel() {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        let pixelEvent = Pixel.Event.daxDialogsEndOfJourneyNewTabUnique
        // TEST
        testDialogDefinedBy(spec: spec, firesEvent: pixelEvent)
    }

    func testWhenOnboardingFinalDialogCTAIsTapped_ThenFireExpectedPixel() throws {
        // GIVEN
        let view = factory.createDaxDialog(for: DaxDialogs.HomeScreenSpec.final, onDismiss: {})
        let host = UIHostingController(rootView: view)
        window.rootViewController = host
        let finalDialog = try XCTUnwrap(find(OnboardingFinalDialog.self, in: host))
        XCTAssertFalse(pixelReporterMock.didCallTrackEndOfJourneyDialogDismiss)

        // WHEN
        finalDialog.dismissAction(false)

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackEndOfJourneyDialogDismiss)
    }

    // MARK: - Add To Dock

    func testWhenEndOfJourneyDialogAndAddToDockIsContextualThenReturnExpectedCopy() throws {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        onboardingManagerMock.addToDockEnabledState = .contextual
        let dialog = factory.createDaxDialog(for: spec, onDismiss: {})

        // WHEN
        let result = try XCTUnwrap(find(OnboardingFinalDialog.self, in: dialog))

        // THEN
        XCTAssertEqual(result.message, UserText.AddToDockOnboarding.Promo.contextualMessage)
        XCTAssertEqual(result.cta, UserText.AddToDockOnboarding.Buttons.startBrowsing)
    }

    func testWhenEndOfJourneyDialogAndAddToDockIsContextualThenCanShowAddToDockTutorialIsTrue() throws {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        onboardingManagerMock.addToDockEnabledState = .contextual
        let dialog = factory.createDaxDialog(for: spec, onDismiss: {})
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: dialog))

        // WHEN
        let result = view.canShowAddToDockTutorial

        // THEN
        XCTAssertTrue(result)
    }

    // MARK: - Add To Dock Pixels

    func testWhenEndOfJourneyAddToDockPromoDialogAppearForTheFirstTimeThenFireExpectedPixel() throws {
        // GIVEN
        onboardingManagerMock.addToDockEnabledState = .contextual
        let spec = DaxDialogs.HomeScreenSpec.final
        // TEST
        waitForDialogDefinedBy(spec: spec) {
            XCTAssertTrue(self.pixelReporterMock.didCallTrackAddToDockPromoImpression)
        }
    }

    func testWhenEndOfJourneyAndAddToDockPromoShowTutorialButtonActionThenFireExpectedPixel() throws {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        onboardingManagerMock.addToDockEnabledState = .contextual
        let dialog = factory.createDaxDialog(for: spec, onDismiss: {})
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: dialog))
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockPromoShowTutorialCTAAction)

        // WHEN
        view.showAddToDockTutorialAction()

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockPromoShowTutorialCTAAction)
    }

    func testWhenEndOfJourneyAndAddToDockPromoDismissButtonActionThenFireExpectedPixel() throws {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        onboardingManagerMock.addToDockEnabledState = .contextual
        let dialog = factory.createDaxDialog(for: spec, onDismiss: {})
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: dialog))
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockPromoDismissCTAAction)

        // WHEN
        view.dismissAction(false)

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockPromoDismissCTAAction)
    }

    func testWhenEndOfJourneyAndAddToDockTutorialDismissButtonActionThenFireExpectedPixel() throws {
        // GIVEN
        let spec = DaxDialogs.HomeScreenSpec.final
        onboardingManagerMock.addToDockEnabledState = .contextual
        let dialog = factory.createDaxDialog(for: spec, onDismiss: {})
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: dialog))
        XCTAssertFalse(pixelReporterMock.didCallTrackAddToDockTutorialDismissCTAAction)

        // WHEN
        view.dismissAction(true)

        // THEN
        XCTAssertTrue(pixelReporterMock.didCallTrackAddToDockTutorialDismissCTAAction)
    }

}

private extension ContextualOnboardingNewTabDialogFactoryTests {

    func testDialogDefinedBy(spec: DaxDialogs.HomeScreenSpec, firesEvent event: Pixel.Event) {
        waitForDialogDefinedBy(spec: spec) {
            // THEN
            XCTAssertTrue(self.pixelReporterMock.didCallTrackScreenImpressionCalled)
            XCTAssertEqual(self.pixelReporterMock.capturedScreenImpression, event)
        }
    }

    func waitForDialogDefinedBy(spec: DaxDialogs.HomeScreenSpec, completionHandler: @escaping () -> Void) {
        // GIVEN
        let expectation = self.expectation(description: #function)
        XCTAssertFalse(pixelReporterMock.didCallTrackScreenImpressionCalled)
        XCTAssertNil(pixelReporterMock.capturedScreenImpression)

        // WHEN
        let view = factory.createDaxDialog(for: spec, onDismiss: {})
        let host = OnboardingHostingControllerMock(rootView: AnyView(view))
        host.onAppearExpectation = expectation
        window.rootViewController = host
        XCTAssertNotNil(host.view)

        // THEN
        waitForExpectations(timeout: 2.0)
        completionHandler()
    }

}

class CapturingOnboardingNavigationDelegate: OnboardingNavigationDelegate {
    var suggestedSearchQuery: String?
    var urlToNavigateTo: URL?

    func searchFromOnboarding(for query: String) {
        suggestedSearchQuery = query
    }

    func navigateFromOnboarding(to url: URL) {
        urlToNavigateTo = url
    }
}

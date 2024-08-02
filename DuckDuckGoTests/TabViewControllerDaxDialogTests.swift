//
//  TabViewControllerDaxDialogTests.swift
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
import Persistence
import Core
@testable import DuckDuckGo

final class TabViewControllerDaxDialogTests: XCTestCase {
    private var sut: TabViewController!
    private var delegateMock: MockTabDelegate!
    private var onboardingPresenterMock: ContextualOnboardingPresenterMock!
    private var onboardingLogicMock: ContextualOnboardingLogicMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        delegateMock = MockTabDelegate()
        onboardingPresenterMock = ContextualOnboardingPresenterMock()
        onboardingLogicMock = ContextualOnboardingLogicMock()
        sut = .fake(contextualOnboardingPresenter: onboardingPresenterMock, contextualOnboardingLogic: onboardingLogicMock)
        sut.delegate = delegateMock
    }

    override func tearDownWithError() throws {
        delegateMock = nil
        onboardingPresenterMock = nil
        onboardingLogicMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testWhenSearchForQueryIsCalledThenDidRequestLoadQueryIsCalledOnDelegate() {
        // GIVEN
        let query = "How to say Duck in Spanish"
        XCTAssertFalse(delegateMock.didRequestLoadQueryCalled)
        XCTAssertNil(delegateMock.capturedQuery)

        // WHEN
        sut.searchFor(query)

        // THEN
        XCTAssertTrue(delegateMock.didRequestLoadQueryCalled)
        XCTAssertEqual(delegateMock.capturedQuery, query)
    }

    func testWhenNavigateToURLIsCalledThenDidRequestLoadURLIsCalledOnDelegate() {
        // GIVEN
        XCTAssertFalse(delegateMock.didRequestLoadURLCalled)
        XCTAssertNil(delegateMock.capturedURL)

        // WHEN
        sut.navigateTo(url: .ddg)

        // THEN
        XCTAssertTrue(delegateMock.didRequestLoadURLCalled)
        XCTAssertEqual(delegateMock.capturedURL, .ddg)
    }

    func testWhenDidShowTrackersDialogIsCalled_AndShouldShowPrivacyAnimation_ThenTabDidRequestPrivacyDashboardButtonPulseIsCalledOnDelegate() {
        // GIVEN
        onboardingLogicMock.shouldShowPrivacyButtonPulse = true
        XCTAssertFalse(delegateMock.tabDidRequestPrivacyDashboardButtonPulseCalled)

        // WHEN
        sut.didShowContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertTrue(delegateMock.tabDidRequestPrivacyDashboardButtonPulseCalled)
    }

    func testWhenDidShowTrackersDialogIsCalled_AndShouldNotShowPrivacyAnimation_ThenTabDidRequestPrivacyDashboardButtonPulseIsNotCalledOnDelegate() {
        // GIVEN
        onboardingLogicMock.shouldShowPrivacyButtonPulse = false
        XCTAssertFalse(delegateMock.tabDidRequestPrivacyDashboardButtonPulseCalled)

        // WHEN
        sut.didShowContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertFalse(delegateMock.tabDidRequestPrivacyDashboardButtonPulseCalled)
    }

    func testWhenDidAcknowledgeTrackersDialogIsCalledThenTabDidRequestFireButtonPulseIsCalledOnDelegate() {
        // GIVEN
        XCTAssertFalse(delegateMock.didRequestFireButtonPulseCalled)

        // WHEN
        sut.didAcknowledgeContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertTrue(delegateMock.didRequestFireButtonPulseCalled)
    }

    func testWhenDidTapDismissActionIsCalledThenAskPresenterToDismissContextualOnboarding() {
        // GIVEN
        XCTAssertFalse(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)

        // WHEN
        sut.didTapDismissContextualOnboardingAction()

        // THEN
        XCTAssertTrue(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)
    }

    func testWhenDidAcknowledgedTrackersDialogIsCalledThenSetFireEducationMessageSeenIsCalledOnLogic() {
        // GIVEN
        XCTAssertFalse(onboardingLogicMock.didCallSetFireEducationMessageSeen)

        // WHEN
        sut.didAcknowledgeContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertTrue(onboardingLogicMock.didCallSetFireEducationMessageSeen)
    }

    func testWhenDidAcknowledgeContextualOnboardingSearchIsCalledThenSetSearchMessageSeenOnLogic() {
        // GIVEN
        XCTAssertFalse(onboardingLogicMock.didCallsetsetSearchMessageSeen)

        // WHEN
        sut.didAcknowledgeContextualOnboardingSearch()

        // THEN
        XCTAssertTrue(onboardingLogicMock.didCallsetsetSearchMessageSeen)
    }

    func testWhenDidShowContextualOnboardingTrackersDialog_AndShouldShowPrivacyAnimation_ShieldIconAnimationActivated() {
        // GIVEN
        onboardingLogicMock.shouldShowPrivacyButtonPulse = true
        XCTAssertNil(delegateMock.privacyDashboardAnimated)

        // WHEN
        sut.didShowContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertTrue(delegateMock.privacyDashboardAnimated ?? false)
    }

    func testWhenDismissContextualDaxFireDialog_andNewOnboarding_andFireDialogPresented_ThenAskPresenterToDismissDialog() {
        // GIVEN
        onboardingLogicMock.isShowingFireDialog = true
        XCTAssertFalse(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)

        // WHEN
        sut.dismissContextualDaxFireDialog()

        // THEN
        XCTAssertTrue(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)
    }

    func testWhenDismissContextualDaxFireDialog_andNewOnboarding_andFireDialogIsNotPresented_ThenDoNotAskPresenterToDismissDialog() {
        // GIVEN
        onboardingLogicMock.isShowingFireDialog = false
        XCTAssertFalse(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)

        // WHEN
        sut.dismissContextualDaxFireDialog()

        // THEN
        XCTAssertFalse(onboardingPresenterMock.didCallDismissContextualOnboardingIfNeeded)
    }

}

final class ContextualOnboardingLogicMock: ContextualOnboardingLogic {
    
    var expectation: XCTestExpectation?
    private(set) var didCallSetFireEducationMessageSeen = false
    private(set) var didCallsetFinalOnboardingDialogSeen = false
    private(set) var didCallsetsetSearchMessageSeen = false
    private(set) var didCallCanEnableAddFavoriteFlow = false
    private(set) var didCallEnableAddFavoriteFlow = false

    var canStartFavoriteFlow = false

    var isShowingFireDialog: Bool = false
    var shouldShowPrivacyButtonPulse: Bool = false

    func setFireEducationMessageSeen() {
        didCallSetFireEducationMessageSeen = true
    }

    func setFinalOnboardingDialogSeen() {
        didCallsetFinalOnboardingDialogSeen = true
        expectation?.fulfill()
    }

    func setSearchMessageSeen() {
        didCallsetsetSearchMessageSeen = true
    }

    func setPrivacyButtonPulseSeen() {

    }

    func canEnableAddFavoriteFlow() -> Bool {
        didCallCanEnableAddFavoriteFlow = true
        return canStartFavoriteFlow
    }

    func enableAddFavoriteFlow() {
        didCallEnableAddFavoriteFlow = true
    }
    
}

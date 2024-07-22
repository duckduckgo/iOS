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

    func testWhenDidShowTrackersDialogIsCalledThenTabDidRequestPrivacyDashboardButtonPulseIsCalledOnDelegate() {
        // GIVEN
        XCTAssertFalse(delegateMock.didRequestPrivacyDashboardButtonPulseCalled)

        // WHEN
        sut.didShowContextualOnboardingTrackersDialog()

        // THEN
        XCTAssertTrue(delegateMock.didRequestPrivacyDashboardButtonPulseCalled)
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

}

final class ContextualOnboardingLogicMock: ContextualOnboardingLogic {
    var expectation: XCTestExpectation?
    private(set) var didCallSetFireEducationMessageSeen = false
    private(set) var didCallsetFinalOnboardingDialogSeen = false

    func setFireEducationMessageSeen() {
        didCallSetFireEducationMessageSeen = true
    }

    func setFinalOnboardingDialogSeen() {
        didCallsetFinalOnboardingDialogSeen = true
        expectation?.fulfill()
    }

}

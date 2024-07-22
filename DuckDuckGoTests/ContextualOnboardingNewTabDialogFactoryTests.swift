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
@testable import DuckDuckGo

class ContextualOnboardingNewTabDialogFactoryTests: XCTestCase {

    var factory: NewTabDaxDialogFactory!
    var mockDelegate: CapturingOnboardingNavigationDelegate!
    var contextualOnboardingLogicMock: ContextualOnboardingLogicMock!
    var onDismissCalled: Bool!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        mockDelegate = CapturingOnboardingNavigationDelegate()
        contextualOnboardingLogicMock = ContextualOnboardingLogicMock()
        onDismissCalled = false
        factory = NewTabDaxDialogFactory(delegate: mockDelegate, contextualOnboardingLogic: contextualOnboardingLogicMock)
        window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        window.isHidden = true
        window = nil
        factory = nil
        mockDelegate = nil
        onDismissCalled = nil
        contextualOnboardingLogicMock = nil
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
        finalDialog?.highFiveAction()
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

}

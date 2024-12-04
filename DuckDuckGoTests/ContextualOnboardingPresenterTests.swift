//
//  ContextualOnboardingPresenterTests.swift
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

final class ContextualOnboardingPresenterTests: XCTestCase {
    private var contextualDaxDialogsFactory: ExperimentContextualDaxDialogsFactory!

    override func setUpWithError() throws {
        contextualDaxDialogsFactory = ExperimentContextualDaxDialogsFactory(contextualOnboardingLogic: DaxDialogs.shared, contextualOnboardingPixelReporter: OnboardingPixelReporterMock())
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        contextualDaxDialogsFactory = nil
        try super.tearDownWithError()
    }

    func testWhenPresentContextualOnboardingThenNewContextualOnboardingIsPresented() {
        // GIVEN
        let sut = ContextualOnboardingPresenter(variantManager: MockVariantManager(), daxDialogsFactory: contextualDaxDialogsFactory)
        let parent = TabViewControllerMock()
        XCTAssertFalse(parent.didCallAddChild)
        XCTAssertNil(parent.capturedChild)

        // WHEN
        sut.presentContextualOnboarding(for: .afterSearch, in: parent)

        // THEN
        XCTAssertTrue(parent.didCallAddChild)
        XCTAssertNotNil(parent.capturedChild)
    }

    func testWhenPresentContextualOnboardingForFireEducational_andBarAtTheTop_TheMessageHandPointsInTheRightDirection() throws {
        // GIVEN
        let appSettings = AppSettingsMock()
        let sut = ContextualOnboardingPresenter(variantManager: MockVariantManager(), daxDialogsFactory: contextualDaxDialogsFactory, appSettings: appSettings)
        let parent = TabViewControllerMock()

        // WHEN
        sut.presentContextualOnboarding(for: .withOneTracker, in: parent)
        let view = try XCTUnwrap(find(OnboardingTrackersDoneDialog.self, in: parent))

        // THEN
        XCTAssertTrue(view.message.string.contains("☝️"))
    }

    func testWhenPresentContextualOnboardingForFireEducational_andBarAtTheBottom_TheMessageHandPointsInTheRightDirection() throws {
        // GIVEN
        let appSettings = AppSettingsMock()
        appSettings.currentAddressBarPosition = .bottom
        let sut = ContextualOnboardingPresenter(variantManager: MockVariantManager(), daxDialogsFactory: contextualDaxDialogsFactory, appSettings: appSettings)
        let parent = TabViewControllerMock()

        // WHEN
        sut.presentContextualOnboarding(for: .withOneTracker, in: parent)
        let view = try XCTUnwrap(find(OnboardingTrackersDoneDialog.self, in: parent))

        // THEN
        XCTAssertTrue(view.message.string.contains("👇"))
    }

    func testWhenDismissContextualOnboardingThenContextualOnboardingIsDismissed() {
        // GIVEN
        let expectation = self.expectation(description: #function)
        let sut = ContextualOnboardingPresenter(variantManager: MockVariantManager(), daxDialogsFactory: contextualDaxDialogsFactory)
        let parent = TabViewControllerMock()
        let daxController = DaxContextualOnboardingControllerMock()
        daxController.removeFromParentExpectation = expectation
        parent.daxContextualOnboardingController = daxController
        parent.daxDialogsStackView.addArrangedSubview(daxController.view)
        XCTAssertFalse(daxController.didCallRemoveFromParent)
        XCTAssertNotNil(parent.daxContextualOnboardingController)
        XCTAssertTrue(parent.daxDialogsStackView.arrangedSubviews.contains(daxController.view))

        // WHEN
        sut.dismissContextualOnboardingIfNeeded(from: parent)

        // THEN
        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(daxController.didCallRemoveFromParent)
        XCTAssertNil(parent.daxContextualOnboardingController)
        XCTAssertFalse(parent.daxDialogsStackView.arrangedSubviews.contains(daxController.view))
    }

}

final class TabViewControllerMock: UIViewController, TabViewOnboardingDelegate {
    
    var daxDialogsStackView: UIStackView = UIStackView()
    var webViewContainerView: UIView  = UIView()
    var daxContextualOnboardingController: UIViewController?

    private(set) var didCallPerformSegue = false
    private(set) var capturedSegueIdentifier: String?
    private(set) var capturedSender: Any?

    private(set) var didCallAddChild = false
    private(set) var capturedChild: UIViewController?

    private(set) var didCalldidShowTrackersDialog = false
    private(set) var didCallDidShowTrackersDialog = false
    private(set) var didCallDidAcknowledgeTrackersDialog = false
    private(set) var didCallDidTapDismissAction = false
    private(set) var didCallSearchForQuery = false
    private(set) var capturedQuery: String?
    private(set) var didCallNavigateToURL = false
    private(set) var capturedURL: URL?

    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        didCallPerformSegue = true
        capturedSegueIdentifier = identifier
        capturedSender = sender
    }

    override func addChild(_ childController: UIViewController) {
        didCallAddChild = true
        capturedChild = childController
    }

    func didShowContextualOnboardingTrackersDialog() {
        didCalldidShowTrackersDialog = true
    }

    func didAcknowledgeContextualOnboardingTrackersDialog() {
        didCallDidAcknowledgeTrackersDialog = true
    }

    func didTapDismissContextualOnboardingAction() {
        didCallDidTapDismissAction = true
    }

    func searchFromOnboarding(for query: String) {
        didCallSearchForQuery = true
        capturedQuery = query
    }

    func navigateFromOnboarding(to url: URL) {
        didCallNavigateToURL = true
        capturedURL = url
    }

    func didAcknowledgeContextualOnboardingSearch() {
        
    }

}

final class DaxContextualOnboardingControllerMock: UIViewController {

    private(set) var didCallRemoveFromParent = false

    var removeFromParentExpectation: XCTestExpectation?

    override func removeFromParent() {
        didCallRemoveFromParent = true
        removeFromParentExpectation?.fulfill()
    }

}

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

    func testWhenPresentContextualOnboardingAndVariantDoesNotSupportOnboardingIntroThenOldContextualOnboardingIsPresented() throws {
        // GIVEN
        var variantManagerMock = MockVariantManager()
        variantManagerMock.isSupportedBlock = { feature in
            feature != .newOnboardingIntro
        }
        let sut = ContextualOnboardingPresenter(variantManager: variantManagerMock)
        let parent = TabViewControllerMock()
        XCTAssertFalse(parent.didCallPerformSegue)
        XCTAssertNil(parent.capturedSegueIdentifier)
        XCTAssertNil(parent.capturedSender)

        // WHEN
        sut.presentContextualOnboarding(for: .afterSearch, in: parent)

        // THEN
        XCTAssertTrue(parent.didCallPerformSegue)
        XCTAssertEqual(parent.capturedSegueIdentifier, "DaxDialog")
        let sender = try XCTUnwrap(parent.capturedSender as? DaxDialogs.BrowsingSpec)
        XCTAssertEqual(sender, DaxDialogs.BrowsingSpec.afterSearch)
    }

    func testWhenPresentContextualOnboardingAndVariantSupportsNewOnboardingIntroThenThenNewContextualOnboardingIsPresented() {
        // GIVEN
        var variantManagerMock = MockVariantManager()
        variantManagerMock.isSupportedBlock = { feature in
            feature == .newOnboardingIntro
        }
        let sut = ContextualOnboardingPresenter(variantManager: variantManagerMock)
        let parent = TabViewControllerMock()
        XCTAssertFalse(parent.didCallAddChild)
        XCTAssertNil(parent.capturedChild)

        // WHEN
        sut.presentContextualOnboarding(for: .afterSearch, in: parent)

        // THEN
        XCTAssertTrue(parent.didCallAddChild)
        XCTAssertNotNil(parent.capturedChild)
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

    func didShowTrackersDialog() {
        didCalldidShowTrackersDialog = true
    }

    func didAcknowledgeTrackersDialog() {
        didCallDidAcknowledgeTrackersDialog = true
    }

    func didTapDismissAction() {
        didCallDidTapDismissAction = true
    }

    func searchFor(_ query: String) {
        didCallSearchForQuery = true
        capturedQuery = query
    }

    func navigateTo(url: URL) {
        didCallNavigateToURL = true
        capturedURL = url
    }

}

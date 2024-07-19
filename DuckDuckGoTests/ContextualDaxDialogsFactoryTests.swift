//
//  ContextualDaxDialogsFactoryTests.swift
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

final class ContextualDaxDialogsFactoryTests: XCTestCase {
    private var sut: ExperimentContextualDaxDialogsFactory!
    private var delegate: ContextualOnboardingDelegateMock!
    private var settingsMock: ContextualOnboardingSettingsMock!


    override func setUpWithError() throws {
        try super.setUpWithError()
        delegate = ContextualOnboardingDelegateMock()
        settingsMock = ContextualOnboardingSettingsMock()
        sut = ExperimentContextualDaxDialogsFactory(contextualOnboardingSettings: settingsMock)
    }

    override func tearDownWithError() throws {
        delegate = nil
        settingsMock = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - After Search

    func testWhenMakeViewForAfterSearchSpecThenCreatesOnboardingFirstSearchDoneDialog() throws {
        // GIVEN
        let spec = DaxDialogs.BrowsingSpec.afterSearch

        // WHEN
        let result = sut.makeView(for: spec, delegate: delegate)

        // THEN
        let view = try XCTUnwrap(find(OnboardingFirstSearchDoneDialog.self, in: result))
        XCTAssertTrue(view.viewModel.delegate === delegate)
    }

    func test_WhenMakeViewForAfterSearchSpec_AndActionIsTapped_AndTrackersDialogHasShown_ThenDidTapDismissContextualOnboardingActionIsCalledOnDelegate() throws {
        // GIVEN
        settingsMock.userHasSeenTrackersDialog = true
        let spec = DaxDialogs.BrowsingSpec.afterSearch
        let result = sut.makeView(for: spec, delegate: delegate)
        let view = try XCTUnwrap(find(OnboardingFirstSearchDoneDialog.self, in: result))
        XCTAssertFalse(delegate.didCallDidTapDismissContextualOnboardingAction)

        // WHEN
        view.gotItAction()

        // THEN
        XCTAssertTrue(delegate.didCallDidTapDismissContextualOnboardingAction)
    }

    func test_WhenMakeViewForAfterSearchSpec_AndActionIsTapped_AndTrackersDialogHasNotShown_ThenDidTapDismissContextualOnboardingActionIsCalledOnDelegate() throws {
        // GIVEN
        settingsMock.userHasSeenTrackersDialog = false
        let spec = DaxDialogs.BrowsingSpec.afterSearch
        let result = sut.makeView(for: spec, delegate: delegate)
        let view = try XCTUnwrap(find(OnboardingFirstSearchDoneDialog.self, in: result))
        XCTAssertFalse(delegate.didCallDidTapDismissContextualOnboardingAction)

        // WHEN
        view.gotItAction()

        // THEN
        XCTAssertFalse(delegate.didCallDidTapDismissContextualOnboardingAction)
    }

    // MARK: - Trackers

    func test_WhenMakeViewForTrackerSpec_ThenReturnViewOnboardingTrackersDoneDialog() throws {
        // GIVEN
        try [DaxDialogs.BrowsingSpec.siteIsMajorTracker, .siteOwnedByMajorTracker, .withMultipleTrackers, .withoutTrackers, .withoutTrackers].forEach { spec in
            // WHEN
            let result = sut.makeView(for: spec, delegate: delegate)

            // THEN
            let view = try XCTUnwrap(find(OnboardingTrackersDoneDialog.self, in: result))
            XCTAssertNotNil(view)
        }
    }

    func test_WhenMakeViewForTrackerSpec_AndFireDialogHasNotShown_ThenActionCallsDidAcknowledgeContextualOnboardingTrackersDialog() throws {
        try [DaxDialogs.BrowsingSpec.siteIsMajorTracker, .siteOwnedByMajorTracker, .withMultipleTrackers, .withoutTrackers, .withoutTrackers].forEach { spec in
            // GIVEN
            delegate = ContextualOnboardingDelegateMock()
            settingsMock.userHasSeenFireDialog = false
            let result = sut.makeView(for: spec, delegate: delegate)
            let view = try XCTUnwrap(find(OnboardingTrackersDoneDialog.self, in: result))
            XCTAssertFalse(delegate.didCallDidAcknowledgeContextualOnboardingTrackersDialog)

            // WHEN
            view.blockedTrackersCTAAction()

            // THEN
            XCTAssertTrue(delegate.didCallDidAcknowledgeContextualOnboardingTrackersDialog)
        }
    }

    func test_WhenMakeViewForTrackerSpec_AndFireDialogHasShown_ThenActionCallsDidTapDismissContextualOnboardingAction() throws {
        try [DaxDialogs.BrowsingSpec.siteIsMajorTracker, .siteOwnedByMajorTracker, .withMultipleTrackers, .withoutTrackers, .withoutTrackers].forEach { spec in
            // GIVEN
            delegate = ContextualOnboardingDelegateMock()
            settingsMock.userHasSeenFireDialog = true
            let result = sut.makeView(for: spec, delegate: delegate)
            let view = try XCTUnwrap(find(OnboardingTrackersDoneDialog.self, in: result))
            XCTAssertFalse(delegate.didCallDidTapDismissContextualOnboardingAction)

            // WHEN
            view.blockedTrackersCTAAction()

            // THEN
            XCTAssertTrue(delegate.didCallDidTapDismissContextualOnboardingAction)
        }
    }

    // MARK: - Final

    func test_WhenMakeViewForFinalSpec_ThenReturnViewOnboardingFinalDialog() throws {
        // GIVEN
        let spec = DaxDialogs.BrowsingSpec.final

        // WHEN
        let result = sut.makeView(for: spec, delegate: delegate)

        // THEN
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: result))
        XCTAssertNotNil(view)
    }

    func test_WhenCallActionOnOnboardingFinalDialog_ThenDidTapDismissContextualOnboardingActionOnDelegateIsCalled() throws {
        // GIVEN
        let spec = DaxDialogs.BrowsingSpec.final
        let result = sut.makeView(for: spec, delegate: delegate)
        let view = try XCTUnwrap(find(OnboardingFinalDialog.self, in: result))
        XCTAssertFalse(delegate.didCallDidTapDismissContextualOnboardingAction)

        // WHEN
        view.highFiveAction()

        // THEN
        XCTAssertTrue(delegate.didCallDidTapDismissContextualOnboardingAction)
    }
}

final class ContextualOnboardingSettingsMock: ContextualOnboardingSettings {
    var userHasSeenTrackersDialog: Bool = false
    var userHasSeenFireDialog: Bool = false
}


final class ContextualOnboardingDelegateMock: ContextualOnboardingDelegate {
    private(set) var didCallDidShowContextualOnboardingTrackersDialog = false
    private(set) var didCallDidAcknowledgeContextualOnboardingTrackersDialog = false
    private(set) var didCallDidTapDismissContextualOnboardingAction = false
    private(set) var didCallSearchForQuery = false
    private(set) var didCallNavigateToURL = false

    func didShowContextualOnboardingTrackersDialog() {
        didCallDidShowContextualOnboardingTrackersDialog = true
    }
    
    func didAcknowledgeContextualOnboardingTrackersDialog() {
        didCallDidAcknowledgeContextualOnboardingTrackersDialog = true
    }
    
    func didTapDismissContextualOnboardingAction() {
        didCallDidTapDismissContextualOnboardingAction = true
    }
    
    func searchFor(_ query: String) {
        didCallSearchForQuery = true
    }
    
    func navigateTo(url: URL) {
        didCallNavigateToURL = true
    }

}

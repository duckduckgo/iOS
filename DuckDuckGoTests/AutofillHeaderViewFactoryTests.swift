//
//  AutofillHeaderViewFactoryTests.swift
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

class MockAutofillHeaderViewDelegate: AutofillHeaderViewDelegate {
    var didHandlePrimaryAction = false
    var didHandleDismissAction = false
    var lastHandledHeaderType: AutofillHeaderViewFactory.ViewType?

    func handlePrimaryAction(for headerType: AutofillHeaderViewFactory.ViewType) {
        didHandlePrimaryAction = true
        lastHandledHeaderType = headerType
    }

    func handleDismissAction(for headerType: AutofillHeaderViewFactory.ViewType) {
        didHandleDismissAction = true
        lastHandledHeaderType = headerType
    }
}

final class AutofillHeaderViewFactoryTests: XCTestCase {

    var factory: AutofillHeaderViewFactory!
    var mockDelegate: MockAutofillHeaderViewDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockDelegate = MockAutofillHeaderViewDelegate()
        factory = AutofillHeaderViewFactory(delegate: mockDelegate)
    }

    override func tearDownWithError() throws {
        factory = nil
        mockDelegate = nil

        try super.tearDownWithError()
    }

    func testWhenMakeHeaderViewForSyncPromoThenSyncPromoViewIsReturned() {
        let viewController = factory.makeHeaderView(for: .syncPromo(.passwords))
        XCTAssertTrue(viewController is UIHostingController<SyncPromoView>)
        if let hostingController = viewController as? UIHostingController<SyncPromoView> {
            XCTAssertNotNil(hostingController.rootView)
        }
    }

    func testWhenMakeHeaderViewForSurveyThenAutofillSurveyViewIsReturned() {
        let survey = AutofillSurveyManager.AutofillSurvey(id: "testSurvey", url: "https://example.com")
        let viewController = factory.makeHeaderView(for: .survey(survey))

        XCTAssertTrue(viewController is UIHostingController<AutofillSurveyView>)
        if let hostingController = viewController as? UIHostingController<AutofillSurveyView> {
            XCTAssertNotNil(hostingController.rootView)
        }
    }

    func testWhenSyncPromoPrimaryButtonActionIsCalledThenDelegateHandlePrimaryActionIsCalled() throws {
        let touchpoint = SyncPromoManager.Touchpoint.passwords
        let viewController = try XCTUnwrap(factory.makeHeaderView(for: .syncPromo(touchpoint)) as? UIHostingController<SyncPromoView>, "Expected a UIHostingController<SyncPromoView>")

        let primaryButtonAction = try XCTUnwrap(viewController.rootView.viewModel.primaryButtonAction, "Primary button action should not be nil")
        primaryButtonAction()

        XCTAssertTrue(mockDelegate.didHandlePrimaryAction)
        if case .syncPromo(let receivedTouchpoint) = mockDelegate.lastHandledHeaderType {
            XCTAssertEqual(receivedTouchpoint, touchpoint)
        } else {
            XCTFail("Expected .syncPromo ViewType with touchpoint \(touchpoint)")
        }
    }

    func testWhenSyncPromoDismissButtonActionIsCalledThenDelegateHandleDismissActionIsCalled() throws {
        let touchpoint = SyncPromoManager.Touchpoint.passwords

        let viewController = try XCTUnwrap(factory.makeHeaderView(for: .syncPromo(touchpoint)) as? UIHostingController<SyncPromoView>, "Expected a UIHostingController<SyncPromoView>")

        let dismissButtonAction = try XCTUnwrap(viewController.rootView.viewModel.dismissButtonAction, "Dismiss button action should not be nil")
        dismissButtonAction()

        XCTAssertTrue(mockDelegate.didHandleDismissAction)

        if case .syncPromo(let receivedTouchpoint) = mockDelegate.lastHandledHeaderType {
            XCTAssertEqual(receivedTouchpoint, touchpoint)
        } else {
            XCTFail("Expected .syncPromo ViewType with touchpoint \(touchpoint)")
        }
    }

    func testWhenSurveyPrimaryButtonActionIsCalledThenDelegateHandlePrimaryActionIsCalled() throws {
        let survey = AutofillSurveyManager.AutofillSurvey(id: "testSurvey", url: "https://example.com")

        let viewController = try XCTUnwrap(factory.makeHeaderView(for: .survey(survey)) as? UIHostingController<AutofillSurveyView>, "Expected a UIHostingController<AutofillSurveyView>")

        let primaryButtonAction = try XCTUnwrap(viewController.rootView.primaryButtonAction, "Primary button action should not be nil")
        primaryButtonAction()

        XCTAssertTrue(mockDelegate.didHandlePrimaryAction)

        if case .survey(let receivedSurvey) = mockDelegate.lastHandledHeaderType {
            XCTAssertEqual(receivedSurvey.id, survey.id)
            XCTAssertEqual(receivedSurvey.url, survey.url)
        } else {
            XCTFail("Expected .survey ViewType with survey \(survey)")
        }
    }

    func testWhenSurveyDismissButtonActionIsCalledThenDelegateHandleDismissActionIsCalled() throws {
        let survey = AutofillSurveyManager.AutofillSurvey(id: "testSurvey", url: "https://example.com")

        let viewController = try XCTUnwrap(factory.makeHeaderView(for: .survey(survey)) as? UIHostingController<AutofillSurveyView>, "Expected a UIHostingController<AutofillSurveyView>")

        let dismissButtonAction = try XCTUnwrap(viewController.rootView.dismissButtonAction, "Dismiss button action should not be nil")
        dismissButtonAction()

        XCTAssertTrue(mockDelegate.didHandleDismissAction)

        if case .survey(let receivedSurvey) = mockDelegate.lastHandledHeaderType {
            XCTAssertEqual(receivedSurvey.id, survey.id)
            XCTAssertEqual(receivedSurvey.url, survey.url)
        } else {
            XCTFail("Expected .survey ViewType with survey \(survey)")
        }
    }
}

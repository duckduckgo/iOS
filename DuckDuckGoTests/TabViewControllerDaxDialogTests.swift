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
import WebKit
@testable import DuckDuckGo

final class TabViewControllerDaxDialogTests: XCTestCase {
    private var sut: TabViewController!
    private var delegateMock: MockTabDelegate!
    private var onboardingPresenterMock: ContextualOnboardingPresenterMock!
    private var onboardingLogicMock: ContextualOnboardingLogicMock!
    private var onboardingPixelReporterMock: OnboardingPixelReporterMock!

    override func setUpWithError() throws {
        throw XCTSkip("Potentially Flaky")

        try super.setUpWithError()
        delegateMock = MockTabDelegate()
        onboardingPresenterMock = ContextualOnboardingPresenterMock()
        onboardingLogicMock = ContextualOnboardingLogicMock()
        onboardingPixelReporterMock = OnboardingPixelReporterMock()
        sut = .fake(contextualOnboardingPresenter: onboardingPresenterMock, contextualOnboardingLogic: onboardingLogicMock, contextualOnboardingPixelReporter: onboardingPixelReporterMock)
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
        sut.searchFromOnboarding(for: query)

        // THEN
        XCTAssertTrue(delegateMock.didRequestLoadQueryCalled)
        XCTAssertEqual(delegateMock.capturedQuery, query)
    }

    func testWhenNavigateToURLIsCalledThenDidRequestLoadURLIsCalledOnDelegate() {
        // GIVEN
        XCTAssertFalse(delegateMock.didRequestLoadURLCalled)
        XCTAssertNil(delegateMock.capturedURL)

        // WHEN
        sut.navigateFromOnboarding(to: .ddg)

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

    func testWhenDidTapDismissActionIsCalledThenAskDaxDialogsLogicToSetDialogDismiss() {
        // GIVEN
        XCTAssertFalse(onboardingLogicMock.didCallSetDaxDialogDismiss)

        // WHEN
        sut.didTapDismissContextualOnboardingAction()

        // THEN
        XCTAssertTrue(onboardingLogicMock.didCallSetDaxDialogDismiss)
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

    // MARK: - SecondSite Visit Pixel

    func testWhenWebsiteFinishLoading_andIsNotSERP_ThenFireSecondSiteVisitPixel() {
        // GIVEN
        WKNavigation.swizzleDealloc()
        let url = URL.ddg
        let webView = MockWebView()
        webView.setCurrentURL(url)
        XCTAssertFalse(onboardingPixelReporterMock.didCallTrackSecondSiteVisit)

        // WHEN
        sut.webView(webView, didFinish: WKNavigation())

        // THEN
        XCTAssertTrue(onboardingPixelReporterMock.didCallTrackSecondSiteVisit)
        WKNavigation.restoreDealloc()
    }

    func testWhenWebsiteFinishLoading_andIsSERP_ThenDoNotFireSecondSiteVisitPixel() throws {
        // GIVEN
        WKNavigation.swizzleDealloc()
        let url = try XCTUnwrap(URL.makeSearchURL(text: "test"))
        let webView = MockWebView()
        webView.setCurrentURL(url)
        XCTAssertFalse(onboardingPixelReporterMock.didCallTrackSecondSiteVisit)

        // WHEN
        sut.webView(webView, didFinish: WKNavigation())

        // THEN
        XCTAssertFalse(onboardingPixelReporterMock.didCallTrackSecondSiteVisit)
        WKNavigation.restoreDealloc()
    }

}

final class ContextualOnboardingLogicMock: ContextualOnboardingLogic {
    var expectation: XCTestExpectation?
    private(set) var didCallSetFireEducationMessageSeen = false
    private(set) var didCallsetFinalOnboardingDialogSeen = false
    private(set) var didCallsetsetSearchMessageSeen = false
    private(set) var didCallEnableAddFavoriteFlow = false
    private(set) var didCallSetDaxDialogDismiss = false
    private(set) var didCallClearedBrowserData = false

    var canStartFavoriteFlow = false

    var isShowingFireDialog: Bool = false
    var shouldShowPrivacyButtonPulse: Bool = false
    var isShowingSearchSuggestions: Bool = false
    var isShowingSitesSuggestions: Bool = false
    var isShowingAddToDockDialog: Bool = false

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

    func enableAddFavoriteFlow() {
        didCallEnableAddFavoriteFlow = true
    }

    func setDaxDialogDismiss() {
        didCallSetDaxDialogDismiss = true
    }

    func clearedBrowserData() {
        didCallClearedBrowserData = true
    }

}

extension WKNavigation {
    private static var isSwizzled = false
    private static let originalDealloc = { class_getInstanceMethod(WKNavigation.self, NSSelectorFromString("dealloc"))! }()
    private static let swizzledDealloc = { class_getInstanceMethod(WKNavigation.self, #selector(swizzled_dealloc))! }()

    static func swizzleDealloc() {
        guard !self.isSwizzled else { return }
        self.isSwizzled = true
        method_exchangeImplementations(originalDealloc, swizzledDealloc)
    }

    static func restoreDealloc() {
        guard self.isSwizzled else { return }
        self.isSwizzled = false
        method_exchangeImplementations(originalDealloc, swizzledDealloc)
    }

    @objc
    func swizzled_dealloc() { }
}

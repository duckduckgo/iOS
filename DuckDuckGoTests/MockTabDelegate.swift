//
//  MockTabDelegate.swift
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

import Foundation
import struct UIKit.UIKeyModifierFlags
import WebKit
import BrowserServicesKit
import PrivacyDashboard
import Core
import Persistence
@testable import DuckDuckGo

final class MockTabDelegate: TabDelegate {
    private(set) var didRequestLoadQueryCalled = false
    private(set) var capturedQuery: String?
    private(set) var didRequestLoadURLCalled = false
    private(set) var capturedURL: URL?
    private(set) var didRequestFireButtonPulseCalled = false
    private(set) var didRequestPrivacyDashboardButtonPulseCalled = false


    func tabWillRequestNewTab(_ tab: DuckDuckGo.TabViewController) -> UIKeyModifierFlags? { nil }

    func tabDidRequestNewTab(_ tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestNewWebViewWithConfiguration configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, inheritingAttribution: BrowserServicesKit.AdClickAttributionLogic.State?) -> WKWebView? { nil }

    func tabDidRequestClose(_ tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestNewTabForUrl url: URL, openedByPage: Bool, inheritingAttribution: BrowserServicesKit.AdClickAttributionLogic.State?) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestNewBackgroundTabForUrl url: URL, inheritingAttribution: BrowserServicesKit.AdClickAttributionLogic.State?) {}

    func tabLoadingStateDidChange(tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didUpdatePreview preview: UIImage) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didChangePrivacyInfo privacyInfo: PrivacyDashboard.PrivacyInfo?) {}

    func tabDidRequestReportBrokenSite(tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestToggleReportWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {}

    func tabDidRequestBookmarks(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestEditBookmark(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestDownloads(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestAutofillLogins(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestSettings(tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestSettingsToLogins account: BrowserServicesKit.SecureVaultModels.WebsiteAccount) {}

    func tabDidRequestFindInPage(tab: DuckDuckGo.TabViewController) {}

    func closeFindInPage(tab: DuckDuckGo.TabViewController) {}

    func tabContentProcessDidTerminate(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestForgetAll(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestFireButtonPulse(tab: DuckDuckGo.TabViewController) {
        didRequestFireButtonPulseCalled = true
    }

    func tabDidRequestPrivacyDashboardButtonPulse(tab: DuckDuckGo.TabViewController) {
        didRequestPrivacyDashboardButtonPulseCalled = true
    }

    func tabDidRequestSearchBarRect(tab: DuckDuckGo.TabViewController) -> CGRect { .zero }

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestPresentingTrackerAnimation privacyInfo: PrivacyDashboard.PrivacyInfo, isCollapsing: Bool) {}

    func tabDidRequestShowingMenuHighlighter(tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestPresentingAlert alert: UIAlertController) {}

    func tabCheckIfItsBeingCurrentlyPresented(_ tab: DuckDuckGo.TabViewController) -> Bool { false }

    func showBars() {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestLoadURL url: URL) {
        didRequestLoadURLCalled = true
        capturedURL = url
    }

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestLoadQuery query: String) {
        didRequestLoadQueryCalled = true
        capturedQuery = query
    }

}

extension TabViewController {

    static func mock(contextualOnboardingPresenter: ContextualOnboardingPresenting = ContextualOnboardingPresenterMock()) -> TabViewController {
        let tab = TabViewController.loadFromStoryboard(
            model: .init(link: Link(title: nil, url: .ddg)),
            appSettings: AppSettingsMock(),
            bookmarksDatabase: CoreDataDatabase.bookmarksMock,
            historyManager: MockHistoryManager(historyCoordinator: MockHistoryCoordinator(), isEnabledByUser: true, historyFeatureEnabled: true),
            syncService: MockDDGSyncing(authState: .active, isSyncInProgress: false),
            contextualOnboardingPresenter: contextualOnboardingPresenter
        )
        tab.attachWebView(configuration: .nonPersistent(), andLoadRequest: nil, consumeCookies: false)
        return tab
    }

}

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
import Subscription
import SubscriptionTestingUtilities
import SpecialErrorPages
import MaliciousSiteProtection
@testable import DuckDuckGo

final class MockTabDelegate: TabDelegate {
    private(set) var didRequestLoadQueryCalled = false
    private(set) var capturedQuery: String?
    private(set) var didRequestLoadURLCalled = false
    private(set) var capturedURL: URL?
    private(set) var didRequestFireButtonPulseCalled = false
    private(set) var tabDidRequestPrivacyDashboardButtonPulseCalled = false
    private(set) var privacyDashboardAnimated: Bool?


    func tabWillRequestNewTab(_ tab: DuckDuckGo.TabViewController) -> UIKeyModifierFlags? { nil }

    func tabDidRequestNewTab(_ tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestNewWebViewWithConfiguration configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, inheritingAttribution: BrowserServicesKit.AdClickAttributionLogic.State?) -> WKWebView? { nil }

    func tabDidRequestClose(_ tab: DuckDuckGo.TabViewController, shouldCreateEmptyTabAtSamePosition: Bool) {}

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

    func tabDidRequestAIChat(tab: TabViewController) {}
    
    func tabDidRequestSettings(tab: DuckDuckGo.TabViewController) {}

    func tab(_ tab: DuckDuckGo.TabViewController, didRequestSettingsToLogins account: BrowserServicesKit.SecureVaultModels.WebsiteAccount) {}

    func tabDidRequestFindInPage(tab: DuckDuckGo.TabViewController) {}

    func closeFindInPage(tab: DuckDuckGo.TabViewController) {}

    func tabContentProcessDidTerminate(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestFireButtonPulse(tab: DuckDuckGo.TabViewController) {
        didRequestFireButtonPulseCalled = true
    }

    func tabDidRequestPrivacyDashboardButtonPulse(tab: DuckDuckGo.TabViewController, animated: Bool) {
        tabDidRequestPrivacyDashboardButtonPulseCalled = true
        privacyDashboardAnimated = animated
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

    func tabDidRequestRefresh(tab: DuckDuckGo.TabViewController) {}

    func tabDidRequestNavigationToDifferentSite(tab: DuckDuckGo.TabViewController) {}

}

extension TabViewController {

    static func fake(
        customWebView: ((WKWebViewConfiguration) -> WKWebView)? = nil,
        contextualOnboardingPresenter: ContextualOnboardingPresenting = ContextualOnboardingPresenterMock(),
        contextualOnboardingLogic: ContextualOnboardingLogic = ContextualOnboardingLogicMock(),
        contextualOnboardingPixelReporter: OnboardingCustomInteractionPixelReporting = OnboardingPixelReporterMock(),
        featureFlagger: MockFeatureFlagger = MockFeatureFlagger()
    ) -> TabViewController {
        let tab = TabViewController.loadFromStoryboard(
            model: .init(link: Link(title: nil, url: .ddg)),
            appSettings: AppSettingsMock(),
            bookmarksDatabase: CoreDataDatabase.bookmarksMock,
            historyManager: MockHistoryManager(historyCoordinator: MockHistoryCoordinator(), isEnabledByUser: true, historyFeatureEnabled: true),
            syncService: MockDDGSyncing(authState: .active, isSyncInProgress: false),
            duckPlayer: MockDuckPlayer(settings: MockDuckPlayerSettings(appSettings: AppSettingsMock(), privacyConfigManager: PrivacyConfigurationManagerMock(), internalUserDecider: MockDuckPlayerInternalUserDecider()), featureFlagger: featureFlagger),
            privacyProDataReporter: MockPrivacyProDataReporter(),
            contextualOnboardingPresenter: contextualOnboardingPresenter,
            contextualOnboardingLogic: contextualOnboardingLogic,
            onboardingPixelReporter: contextualOnboardingPixelReporter,
            featureFlagger: featureFlagger,
            subscriptionCookieManager: SubscriptionCookieManagerMock(),
            textZoomCoordinator: MockTextZoomCoordinator(),
            websiteDataManager: MockWebsiteDataManager(),
            fireproofing: MockFireproofing(),
            tabInteractionStateSource: MockTabInteractionStateSource(),
            specialErrorPageNavigationHandler: DummySpecialErrorPageNavigationHandler()
        )
        tab.attachWebView(configuration: .nonPersistent(), andLoadRequest: nil, consumeCookies: false, customWebView: customWebView)
        return tab
    }

}

class DummySpecialErrorPageNavigationHandler: SpecialErrorPageManaging {
    var delegate: (any DuckDuckGo.SpecialErrorPageNavigationDelegate)?
    
    var isSpecialErrorPageVisible: Bool = false

    var failedURL: URL?
    
    var isSpecialErrorPageRequest: Bool = false

    var currentThreatKind: MaliciousSiteProtection.ThreatKind?

    func attachWebView(_ webView: WKWebView) {}
    
    func setUserScript(_ userScript: SpecialErrorPages.SpecialErrorPageUserScript?) {}
    
    func handleDecidePolicy(for navigationAction: WKNavigationAction, webView: WKWebView) {}
    
    func handleDecidePolicy(for navigationResponse: WKNavigationResponse, webView: WKWebView) async -> Bool {
        true
    }
    
    func handleWebView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

    }
    
    func handleWebView(_ webView: WKWebView, didFailProvisionalNavigation navigation: any DuckDuckGo.WebViewNavigation, withError error: NSError) {}
    
    func handleWebView(_ webView: WKWebView, didFinish navigation: any DuckDuckGo.WebViewNavigation) {}
    
    var errorData: SpecialErrorPages.SpecialErrorData?
    
    func leaveSiteAction() {}
    
    func visitSiteAction() {}
    
    func advancedInfoPresented() {}

}

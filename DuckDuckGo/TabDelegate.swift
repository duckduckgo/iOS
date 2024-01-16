//
//  TabDelegate.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import WebKit
import Core
import BrowserServicesKit
import PrivacyDashboard

protocol TabDelegate: AnyObject {

    func tabWillRequestNewTab(_ tab: TabViewController) -> UIKeyModifierFlags?

    func tabDidRequestNewTab(_ tab: TabViewController)

    func tab(_ tab: TabViewController,
             didRequestNewWebViewWithConfiguration configuration: WKWebViewConfiguration,
             for navigationAction: WKNavigationAction,
             inheritingAttribution: AdClickAttributionLogic.State?) -> WKWebView?

    func tabDidRequestClose(_ tab: TabViewController)

    func tab(_ tab: TabViewController,
             didRequestNewTabForUrl url: URL,
             openedByPage: Bool,
             inheritingAttribution: AdClickAttributionLogic.State?)

    func tab(_ tab: TabViewController,
             didRequestNewBackgroundTabForUrl url: URL,
             inheritingAttribution: AdClickAttributionLogic.State?)

    func tabLoadingStateDidChange(tab: TabViewController)
    func tab(_ tab: TabViewController, didUpdatePreview preview: UIImage)

    func tab(_ tab: TabViewController, didChangePrivacyInfo privacyInfo: PrivacyInfo?)

    func tabDidRequestReportBrokenSite(tab: TabViewController)
    
    func tabDidRequestBookmarks(tab: TabViewController)
    
    func tabDidRequestEditBookmark(tab: TabViewController)
    
    func tabDidRequestDownloads(tab: TabViewController)

    func tabDidRequestAutofillLogins(tab: TabViewController)

    func tabDidRequestSettings(tab: TabViewController)

    func tab(_ tab: TabViewController,
             didRequestSettingsToLogins account: SecureVaultModels.WebsiteAccount)
    
    func tabDidRequestFindInPage(tab: TabViewController)
    func closeFindInPage(tab: TabViewController)

    func tabContentProcessDidTerminate(tab: TabViewController)
    
    func tabDidRequestForgetAll(tab: TabViewController)
    
    func tabDidRequestFireButtonPulse(tab: TabViewController)
        
    func tabDidRequestSearchBarRect(tab: TabViewController) -> CGRect

    func tab(_ tab: TabViewController,
             didRequestPresentingTrackerAnimation privacyInfo: PrivacyInfo,
             isCollapsing: Bool)
    
    func tabDidRequestShowingMenuHighlighter(tab: TabViewController)
    
    func tab(_ tab: TabViewController, didRequestPresentingAlert alert: UIAlertController)

    func tabCheckIfItsBeingCurrentlyPresented(_ tab: TabViewController) -> Bool
    
    func showBars()
}

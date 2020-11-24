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

protocol TabDelegate: class {

    func tabWillRequestNewTab(_ tab: TabViewController) -> UIKeyModifierFlags?

    func tabDidRequestNewTab(_ tab: TabViewController)

    func tab(_ tab: TabViewController,
             didRequestNewWebViewWithConfiguration configuration: WKWebViewConfiguration,
             for navigationAction: WKNavigationAction) -> WKWebView?

    func tabDidRequestClose(_ tab: TabViewController)

    func tab(_ tab: TabViewController, didRequestNewTabForUrl url: URL, openedByPage: Bool)

    func tab(_ tab: TabViewController, didRequestNewBackgroundTabForUrl url: URL)
    
    func tabLoadingStateDidChange(tab: TabViewController)
    func tab(_ tab: TabViewController, didUpdatePreview preview: UIImage)

    func tab(_ tab: TabViewController, didChangeSiteRating siteRating: SiteRating?)

    func tabDidRequestReportBrokenSite(tab: TabViewController)

    func tabDidRequestSettings(tab: TabViewController)
    
    func tabDidRequestFindInPage(tab: TabViewController)

    func tabContentProcessDidTerminate(tab: TabViewController)

    func showBars()

}

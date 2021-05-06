//
//  TabViewControllerNavigationPolicyExtension.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import NavigationPolicy
import Core
import WebKit

extension TabViewController {

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
        url = webView.url
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        let tld = AppDependencyProvider.shared.storageCache.current.tld
        if navigationAction.isTargetingMainFrame()
            && tld.domain(navigationAction.request.url?.host) != tld.domain(lastUpgradedURL?.host) {
            lastUpgradedURL = nil
        }

        let policies: [NavigationActionPolicy] = [
            GPCPolicy(gpcEnabled: AppUserDefaults().sendDoNotSell) { webView.load($0) },

            makeOpenInNewTabPolicy(),

            BookmarkletPolicy(js: navigationAction.request.url?.toDecodedBookmarklet()) { self.webView.evaluateJavaScript($0) },

            OpenExternallyPolicy(openExternally: self.openExternally(url:)),

            OpenInExternalAppPolicy(presentOpenInExternalAppAlert: self.presentOpenInExternalAppAlert(url:)),

            ReissueSearchPolicy(isDuckDuckGoSearch: appUrls.isDuckDuckGo(url:),
                                hasCorrectStatsParams: appUrls.hasCorrectMobileStatsParams(url:),
                                hasCorrectSearchHeaderParams: appUrls.hasCorrectSearchHeaderParams(url:),
                                reissueSearch: self.reissueSearchWithRequiredParams(for:)),

            ReissueStaticNavigationPolicy(isDuckDuckGoStatic: appUrls.isDuckDuckGoStatic(url:),
                                          hasCorrectSearchHeaderParams: appUrls.hasCorrectSearchHeaderParams(url:),
                                          reissueSearch: self.reissueNavigationWithSearchHeaderParams(for:)),

            TargetBlankTabPolicy { self.delegate?.tab(self, didRequestNewTabForUrl: $0, openedByPage: true) },

            makeSmarterEncryptionPolicy()
        ]

        let tabModel = self.tabModel
        let url = self.url
        let allowPolicy = self.determineAllowPolicy()
        let appUrls = self.appUrls

        NavigationActionPolicyChecker.checkAllPolicies(policies, forNavigationAction: navigationAction) { decision, cancelAction in

            if decision == .cancel {
                decisionHandler(decision)
                cancelAction?()
                return
            }

            // From iOS 12 we can set the UA dynamically, this lets us update it as needed for specific sites
            if #available(iOS 12, *) {
                UserAgentManager.shared.update(webView: webView, isDesktop: tabModel.isDesktop, url: url)
            }

            if let url = navigationAction.request.url, appUrls.isDuckDuckGoSearch(url: url) {
                StatisticsLoader.shared.refreshSearchRetentionAtb()
                self.findInPage?.done()
            }

            decisionHandler(allowPolicy)

        }
    }

    func makeSmarterEncryptionPolicy() -> SmarterEncryptionUpgradePolicy {
        SmarterEncryptionUpgradePolicy(lastUpgradedURL: lastUpgradedURL,
                                       isProtected: contentBlockerProtection.isProtected(domain:),
                                       isUpgradeable: isUpgradeable(_:completion:)) {
            NetworkLeaderboard.shared.incrementHttpsUpgrades()
            self.lastUpgradedURL = $0
            self.load(url: $0)
        }
    }

    func makeOpenInNewTabPolicy() -> OpenInNewTabPolicy {
        return OpenInNewTabPolicy(keyModifiers: self.delegate?.tabWillRequestNewTab(self).map {
           (command: $0.contains(.command), shift: $0.contains(.shift))
        }, newTabForUrl: { [weak self] in
            self?.delegate?.tab(self!, didRequestNewTabForUrl: $0, openedByPage: false)
        }, newBackgroundTabForURL: { [weak self] in
            self?.delegate?.tab(self!, didRequestNewBackgroundTabForUrl: $0)
        })
    }

    func isUpgradeable(_ url: URL, completion: @escaping (Bool) -> Void) {
        HTTPSUpgrade.shared.isUgradeable(url: url, completion: completion)
    }

    func determineAllowPolicy() -> WKNavigationActionPolicy {
        let allowWithoutUniversalLinks = WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2) ?? .allow
        return AppUserDefaults().allowUniversalLinks ? .allow : allowWithoutUniversalLinks
    }

    func shouldReissueDDGStaticNavigation(for url: URL) -> Bool {
        guard appUrls.isDuckDuckGoStatic(url: url) else { return false }
        return  !appUrls.hasCorrectSearchHeaderParams(url: url)
    }

    func reissueNavigationWithSearchHeaderParams(for url: URL) {
        load(url: appUrls.applySearchHeaderParams(for: url))
    }

    func shouldReissueSearch(for url: URL) -> Bool {
        guard appUrls.isDuckDuckGoSearch(url: url) else { return false }
        return  !appUrls.hasCorrectMobileStatsParams(url: url) || !appUrls.hasCorrectSearchHeaderParams(url: url)
    }

    func reissueSearchWithRequiredParams(for url: URL) {
        let mobileSearch = appUrls.applyStatsParams(for: url)
        reissueNavigationWithSearchHeaderParams(for: mobileSearch)
    }

}

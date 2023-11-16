//
//  AppDelegate+AppDeepLinks.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

extension AppDelegate {

    // swiftlint:disable:next cyclomatic_complexity
    func handleAppDeepLink(_ app: UIApplication, _ mainViewController: MainViewController?, _ url: URL) -> Bool {
        guard let mainViewController else { return false }

        switch AppDeepLinkSchemes.fromURL(url) {

        case .newSearch:
            mainViewController.newTab(reuseExisting: true)
            mainViewController.enterSearch()

        case .favorites:
            mainViewController.newTab(reuseExisting: true, allowingKeyboard: false)

        case .quickLink:
            let query = AppDeepLinkSchemes.query(fromQuickLink: url)
            mainViewController.loadQueryInNewTab(query, reuseExisting: true)

        case .addFavorite:
            mainViewController.startAddFavoriteFlow()

        case .fireButton:
            mainViewController.forgetAllWithAnimation()

        case .voiceSearch:
            mainViewController.onVoiceSearchPressed()

        case .newEmail:
            mainViewController.newEmailAddress()

        case .openVPN:
#if NETWORK_PROTECTION
            presentNetworkProtectionStatusSettingsModal()
#endif

        default:
            guard app.applicationState == .active,
                  let currentTab = mainViewController.currentTab else {
                return false
            }

            // If app is in active state, treat this navigation as something initiated form the context of the current tab.
            mainViewController.tab(currentTab,
                                   didRequestNewTabForUrl: url,
                                   openedByPage: true,
                                   inheritingAttribution: nil)
        }

        return true
    }
}

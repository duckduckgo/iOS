//
//  MainViewController+Segues.swift
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
import Common
import Core
import Bookmarks
import BrowserServicesKit
import SwiftUI
import PrivacyDashboard
import Subscription

extension MainViewController {

    func segueToDaxOnboarding() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        let storyboard = UIStoryboard(name: "DaxOnboarding", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController(creator: { coder in
            DaxOnboardingViewController(coder: coder)
        }) else {
            assertionFailure()
            return
        }
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: false)
    }

    func segueToHomeRow() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: true)
    }

    func segueToBookmarks() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchBookmarksViewController()
    }

    func segueToEditCurrentBookmark() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        guard let link = currentTab?.link,
              let bookmark = menuBookmarksViewModel.favorite(for: link.url) ??
                menuBookmarksViewModel.bookmark(for: link.url) else {
            assertionFailure()
            return
        }
        segueToEditBookmark(bookmark)
    }

    func segueToEditBookmark(_ bookmark: BookmarkEntity) {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchBookmarksViewController {
            $0.openEditFormForBookmark(bookmark)
        }
    }

    private func launchBookmarksViewController(completion: ((BookmarksViewController) -> Void)? = nil) {
        os_log(#function, log: .generalLog, type: .debug)

        let storyboard = UIStoryboard(name: "Bookmarks", bundle: nil)
        let bookmarks = storyboard.instantiateViewController(identifier: "BookmarksViewController") { coder in
            BookmarksViewController(coder: coder,
                                    bookmarksDatabase: self.bookmarksDatabase,
                                    bookmarksSearch: self.bookmarksCachingSearch,
                                    syncService: self.syncService,
                                    syncDataProviders: self.syncDataProviders,
                                    appSettings: self.appSettings)
        }
        bookmarks.delegate = self

        let controller = UINavigationController(rootViewController: bookmarks)
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true) {
            completion?(bookmarks)
        }
    }

    func segueToActionSheetDaxDialogWithSpec(_ spec: DaxDialogs.ActionSheetSpec) {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()

        if spec == DaxDialogs.ActionSheetSpec.fireButtonEducation {
            ViewHighlighter.hideAll()
        }

        let storyboard = UIStoryboard(name: "DaxOnboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "ActionSheetDaxDialog", creator: { coder in
            ActionSheetDaxDialogViewController(coder: coder)
        })
        controller.spec = spec
        controller.delegate = self
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true)
    }

    func segueToReportBrokenSite(mode: PrivacyDashboardMode = .report) {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()

        guard let currentURL = currentTab?.url,
              let privacyInfo = currentTab?.makePrivacyInfo(url: currentURL) else {
            assertionFailure("Missing fundamental data")
            return
        }
        
        let storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: nil)
        let controller = storyboard.instantiateInitialViewController { coder in
            PrivacyDashboardViewController(coder: coder,
                                           privacyInfo: privacyInfo,
                                           dashboardMode: mode,
                                           privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
                                           contentBlockingManager: ContentBlocking.shared.contentBlockingManager,
                                           breakageAdditionalInfo: self.currentTab?.makeBreakageAdditionalInfo())
        }
        
        guard let controller = controller else {
            assertionFailure("PrivacyDashboardViewController not initialised")
            return
        }
        
        currentTab?.privacyDashboard = controller
        controller.popoverPresentationController?.delegate = controller

        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .formSheet
        } else {
            controller.modalPresentationStyle = .pageSheet
        }
        
        present(controller, animated: true)
    }

    func segueToDownloads() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()

        let storyboard = UIStoryboard(name: "Downloads", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        present(controller, animated: true)
    }

    func segueToTabSwitcher() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()

        let storyboard = UIStoryboard(name: "TabSwitcher", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController(creator: { coder in
            TabSwitcherViewController(coder: coder,
                                      bookmarksDatabase: self.bookmarksDatabase,
                                      syncService: self.syncService)
        }) else {
            assertionFailure()
            return
        }

        controller.transitioningDelegate = tabSwitcherTransition
        controller.delegate = self
        controller.tabsModel = tabManager.model
        controller.previewsSource = previewsSource
        controller.modalPresentationStyle = .overCurrentContext

        tabSwitcherController = controller

        present(controller, animated: true)
    }

    func segueToSettings() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchSettings()
    }

    func segueToPrivacyPro() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.triggerDeepLinkNavigation(to: .subscriptionFlow)
        }
    }

    func segueToDebugSettings() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchDebugSettings()
    }

    func segueToSettingsCookiePopupManagement() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.openCookiePopupManagement()
        }
    }

    func segueToSettingsLoginsWithAccount(_ account: SecureVaultModels.WebsiteAccount) {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.shouldPresentLoginsViewWithAccount(accountDetails: account)
        }
    }

    func segueToSettingsSync() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.presentLegacyView(.sync)
        }
    }
    
    func launchSettings(completion: ((SettingsViewModel) -> Void)? = nil,
                        deepLinkTarget: SettingsViewModel.SettingsDeepLinkSection? = nil) {
        let legacyViewProvider = SettingsLegacyViewProvider(syncService: syncService,
                                                            syncDataProviders: syncDataProviders,
                                                            appSettings: appSettings,
                                                            bookmarksDatabase: bookmarksDatabase,
                                                            tabManager: tabManager)

        let settingsViewModel = SettingsViewModel(legacyViewProvider: legacyViewProvider,
                                                  accountManager: AccountManager(),
                                                  deepLink: deepLinkTarget,
                                                  historyManager: historyManager)

        Pixel.fire(pixel: .settingsPresented,
                   withAdditionalParameters: PixelExperiment.parameters)
        let settingsController = SettingsHostingController(viewModel: settingsViewModel, viewProvider: legacyViewProvider)
        
        // We are still presenting legacy views, so use a Navcontroller
        let navController = UINavigationController(rootViewController: settingsController)
        settingsController.modalPresentationStyle = UIModalPresentationStyle.automatic
        
        present(navController, animated: true) {
            completion?(settingsViewModel)
        }
    }

    private func launchDebugSettings(completion: ((RootDebugViewController) -> Void)? = nil) {
        os_log(#function, log: .generalLog, type: .debug)

        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        let settings = storyboard.instantiateViewController(identifier: "DebugMenu") { coder in
            RootDebugViewController(coder: coder,
                                    sync: self.syncService,
                                    bookmarksDatabase: self.bookmarksDatabase,
                                    internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                    tabManager: self.tabManager)
        }

        let controller = UINavigationController(rootViewController: settings)
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true) {
            completion?(settings)
        }
    }

    private func hideAllHighlightsIfNeeded() {
        os_log(#function, log: .generalLog, type: .debug)
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
    }
    
}

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

        let controller = ThemableNavigationController(rootViewController: bookmarks)
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

    func segueToReportBrokenSite() {
        os_log(#function, log: .generalLog, type: .debug)
        hideAllHighlightsIfNeeded()

        let brokenSiteInfo = currentTab?.getCurrentWebsiteInfo()
        guard let currentURL = currentTab?.url,
              let privacyInfo = currentTab?.makePrivacyInfo(url: currentURL) else {
            assertionFailure("Missing fundamental data")
            return
        }
        
        let storyboard = UIStoryboard(name: "PrivacyDashboard", bundle: nil)
        let controller = storyboard.instantiateInitialViewController { coder in
             PrivacyDashboardViewController(coder: coder,
                                           privacyInfo: privacyInfo,
                                           privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager,
                                           contentBlockingManager: ContentBlocking.shared.contentBlockingManager,
                                           initMode: .reportBrokenSite)
        }
        
        guard let controller = controller else {
            assertionFailure("PrivacyDashboardViewController not initialised")
            return
        }
        
        currentTab?.privacyDashboard = controller
        controller.popoverPresentationController?.delegate = controller
        controller.brokenSiteInfo = brokenSiteInfo

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
    
    class HostingControllerCommunicator: ObservableObject {
        var pushView: (() -> Void)?

        func requestPush() {
            pushView?()
        }
    }
    
    private func launchSettings(completion: ((SettingsViewModel) -> Void)? = nil) {
        let legacyViewProvider = SettingsLegacyViewProvider(syncService: syncService,
                                                            syncDataProviders: syncDataProviders,
                                                            appSettings: appSettings,
                                                            bookmarksDatabase: bookmarksDatabase)
                        
        let settingsViewModel = SettingsViewModel(legacyViewProvider: legacyViewProvider)
        let settingsController = SettingsHostingController(viewModel: settingsViewModel, viewProvider: legacyViewProvider)
        settingsController.applyTheme(ThemeManager.shared.currentTheme)
        
        // We are still presenting legacy views, so use a Navcontroller
        let navController = UINavigationController(rootViewController: settingsController)
        navController.applyTheme(ThemeManager.shared.currentTheme)
        settingsController.modalPresentationStyle = .automatic

        present(navController, animated: true) {
            completion?(settingsViewModel)
        }
    }
    
    /*
    private func launchSettings(completion: ((SettingsViewModel) -> Void)? = nil) {
        os_log(#function, log: .generalLog, type: .debug)
        let settingsModel = SettingsViewModel(bookmarksDatabase: self.bookmarksDatabase,
                                              syncService: self.syncService,
                                              syncDataProviders: self.syncDataProviders,
                                              internalUserDecider: AppDependencyProvider.shared.internalUserDecider)
        
        let settingsController = SettingsHostingController(viewModel: settingsModel, rootView: AnyView(EmptyView()))
        settingsController.viewModel = settingsModel
        
        let settingsView = SettingsView(viewModel: settingsModel) { [weak settingsController] legacyVC in
            settingsController?.pushLegacyViewController(legacyVC)
        }
        settingsController.rootView = AnyView(settingsView)
        settingsController.modalPresentationStyle = .automatic
        present(settingsController, animated: true) {
            completion?(settingsModel)
        }
    }
     */

    private func hideAllHighlightsIfNeeded() {
        os_log(#function, log: .generalLog, type: .debug)
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
    }
    
    
    func presentTextSizeSettings() {
        if let presentingVC = self.presentedViewController {
            presentingVC.dismiss(animated: true) { [weak self] in
                self?.presentTextSizeSettingsViewController()
            }
        } else {
            presentTextSizeSettingsViewController()
        }
    }
    
    private func presentTextSizeSettingsViewController() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "TextSize") as! TextSizeSettingsViewController
        Pixel.fire(pixel: .textSizeSettingsShown)
        presentationController?.delegate = viewController
                
        if #available(iOS 15.0, *) {
            // Configure settingsVC as a sheet
            viewController.modalPresentationStyle = .pageSheet
            viewController.modalTransitionStyle = .coverVertical

            let presentationController = viewController.presentationController as? UISheetPresentationController
            presentationController?.detents = [.medium(), .large()]
            presentationController?.preferredCornerRadius = 16
            presentationController?.largestUndimmedDetentIdentifier = .medium
            presentationController?.prefersScrollingExpandsWhenScrolledToEdge = false
            
        }
        
        self.present(viewController, animated: true, completion: nil)
    }
}

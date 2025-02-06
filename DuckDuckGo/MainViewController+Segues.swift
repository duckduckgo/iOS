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
import os.log

extension MainViewController {

    func segueToDaxOnboarding() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()

        let controller = OnboardingIntroViewController(onboardingPixelReporter: contextualOnboardingPixelReporter)
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: false)
    }

    func segueToHomeRow() {
        Logger.lifecycle.debug(#function)
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
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchBookmarksViewController()
    }

    func segueToEditCurrentBookmark() {
        Logger.lifecycle.debug(#function)
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
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchBookmarksViewController {
            $0.openEditFormForBookmark(bookmark)
        }
    }

    private func launchBookmarksViewController(completion: ((BookmarksViewController) -> Void)? = nil) {
        Logger.lifecycle.debug(#function)

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

    func segueToReportBrokenSite(entryPoint: PrivacyDashboardEntryPoint = .report) {
        Logger.lifecycle.debug(#function)
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
                                           entryPoint: entryPoint,
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
        controller.view.backgroundColor = UIColor(designSystemColor: .backgroundSheets)

        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .formSheet
        } else {
            controller.modalPresentationStyle = .pageSheet
        }
        
        present(controller, animated: true)
    }

    func segueToNegativeFeedbackForm() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()

        let feedbackPicker = FeedbackPickerViewController.loadFromStoryboard()

        feedbackPicker.popoverPresentationController?.delegate = feedbackPicker
        feedbackPicker.view.backgroundColor = UIColor(designSystemColor: .backgroundSheets)
        feedbackPicker.modalPresentationStyle = isPad ? .formSheet : .pageSheet
        feedbackPicker.loadViewIfNeeded()
        feedbackPicker.configure(with: Feedback.Category.allCases)

        present(UINavigationController(rootViewController: feedbackPicker), animated: true)
    }

    func segueToDownloads() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()

        let storyboard = UIStoryboard(name: "Downloads", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        present(controller, animated: true)
    }

    func segueToTabSwitcher() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()

        let storyboard = UIStoryboard(name: "TabSwitcher", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController(creator: { coder in
            TabSwitcherViewController(coder: coder,
                                      bookmarksDatabase: self.bookmarksDatabase,
                                      syncService: self.syncService,
                                      featureFlagger: self.featureFlagger)
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
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings()
    }

    func segueToPrivacyPro() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.triggerDeepLinkNavigation(to: .subscriptionFlow())
        }
    }

    func segueToSubscriptionRestoreFlow() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.triggerDeepLinkNavigation(to: .restoreFlow)
        }
    }

    func segueToVPN() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.triggerDeepLinkNavigation(to: .netP)
        }
    }

    func segueToDebugSettings() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchDebugSettings()
    }

    func segueToSettingsCookiePopupManagement() {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.openCookiePopupManagement()
        }
    }

    func segueToSettingsLoginsWithAccount(_ account: SecureVaultModels.WebsiteAccount) {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            $0.shouldPresentLoginsViewWithAccount(accountDetails: account)
        }
    }

    func segueToSettingsSync(with source: String? = nil) {
        Logger.lifecycle.debug(#function)
        hideAllHighlightsIfNeeded()
        launchSettings {
            if let source = source {
                $0.shouldPresentSyncViewWithSource(source)
            } else {
                $0.presentLegacyView(.sync)
            }
        }
    }
    
    func launchSettings(completion: ((SettingsViewModel) -> Void)? = nil,
                        deepLinkTarget: SettingsViewModel.SettingsDeepLinkSection? = nil) {
        let legacyViewProvider = SettingsLegacyViewProvider(syncService: syncService,
                                                            syncDataProviders: syncDataProviders,
                                                            appSettings: appSettings,
                                                            bookmarksDatabase: bookmarksDatabase,
                                                            tabManager: tabManager,
                                                            syncPausedStateManager: syncPausedStateManager,
                                                            fireproofing: fireproofing,
                                                            websiteDataManager: websiteDataManager)

        let aiChatSettings = AIChatSettings(privacyConfigurationManager: ContentBlocking.shared.privacyConfigurationManager)

        let settingsViewModel = SettingsViewModel(legacyViewProvider: legacyViewProvider,
                                                  subscriptionManager: AppDependencyProvider.shared.subscriptionManager,
                                                  subscriptionFeatureAvailability: subscriptionFeatureAvailability,
                                                  voiceSearchHelper: voiceSearchHelper,
                                                  deepLink: deepLinkTarget,
                                                  historyManager: historyManager,
                                                  syncPausedStateManager: syncPausedStateManager,
                                                  privacyProDataReporter: privacyProDataReporter,
                                                  textZoomCoordinator: textZoomCoordinator,
                                                  aiChatSettings: aiChatSettings,
                                                  maliciousSiteProtectionPreferencesManager: maliciousSiteProtectionPreferencesManager)
        Pixel.fire(pixel: .settingsPresented)

        if let navigationController = self.presentedViewController as? UINavigationController,
           let settingsHostingController = navigationController.viewControllers.first as? SettingsHostingController {
            navigationController.popToRootViewController(animated: false)
            completion?(settingsHostingController.viewModel)
        } else {
            let settingsController = SettingsHostingController(viewModel: settingsViewModel, viewProvider: legacyViewProvider)

            // We are still presenting legacy views, so use a Navcontroller
            let navController = SettingsUINavigationController(rootViewController: settingsController)
            settingsController.modalPresentationStyle = UIModalPresentationStyle.automatic

            present(navController, animated: true) {
                completion?(settingsViewModel)
            }
        }
    }

    private func launchDebugSettings(completion: ((RootDebugViewController) -> Void)? = nil) {
        Logger.lifecycle.debug(#function)

        let storyboard = UIStoryboard(name: "Debug", bundle: nil)
        let settings = storyboard.instantiateViewController(identifier: "DebugMenu") { coder in
            RootDebugViewController(coder: coder,
                                    sync: self.syncService,
                                    bookmarksDatabase: self.bookmarksDatabase,
                                    internalUserDecider: AppDependencyProvider.shared.internalUserDecider,
                                    tabManager: self.tabManager,
                                    fireproofing: self.fireproofing)
        }

        let controller = UINavigationController(rootViewController: settings)
        controller.modalPresentationStyle = .automatic
        present(controller, animated: true) {
            completion?(settings)
        }
    }

    private func hideAllHighlightsIfNeeded() {
        Logger.lifecycle.debug(#function)
        if !DaxDialogs.shared.shouldShowFireButtonPulse {
            ViewHighlighter.hideAll()
        }
    }
    
}

// Exists to fire a did disappear notification for settings when the controller did disappear
//  so that we get the event regarldess of where in the UI hierarchy it happens.
class SettingsUINavigationController: UINavigationController {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(rootViewController: SettingsHostingController) {
        super.init(rootViewController: rootViewController)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .settingsDidDisappear, object: nil)
    }

}

extension NSNotification.Name {
    static let settingsDidDisappear: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.settings.didDisappear")
}

//
//  NewTabPageViewController.swift
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

import SwiftUI
import DDGSync
import Bookmarks
import BrowserServicesKit
import Core

final class NewTabPageViewController: UIHostingController<NewTabPageView<FavoritesDefaultViewModel>>, NewTabPage {

    private let syncService: DDGSyncing
    private let syncBookmarksAdapter: SyncBookmarksAdapter
    private let variantManager: VariantManager
    private let newTabDialogFactory: any NewTabDaxDialogProvider
    private let newTabDialogTypeProvider: NewTabDialogSpecProvider

    private(set) lazy var faviconsFetcherOnboarding = FaviconsFetcherOnboarding(syncService: syncService, syncBookmarksAdapter: syncBookmarksAdapter)

    private let newTabPageViewModel: NewTabPageViewModel
    private let messagesModel: NewTabPageMessagesModel
    private let favoritesModel: FavoritesDefaultViewModel
    private let shortcutsModel: ShortcutsModel
    private let shortcutsSettingsModel: NewTabPageShortcutsSettingsModel
    private let sectionsSettingsModel: NewTabPageSectionsSettingsModel
    private let associatedTab: Tab

    private var hostingController: UIHostingController<AnyView>?

    init(tab: Tab,
         interactionModel: FavoritesListInteracting,
         bookmarksInteracting: MenuBookmarksInteracting,
         syncService: DDGSyncing,
         syncBookmarksAdapter: SyncBookmarksAdapter,
         homePageMessagesConfiguration: HomePageMessagesConfiguration,
         privacyProDataReporting: PrivacyProDataReporting? = nil,
         variantManager: VariantManager,
         newTabDialogFactory: any NewTabDaxDialogProvider,
         newTabDialogTypeProvider: NewTabDialogSpecProvider,
         faviconLoader: FavoritesFaviconLoading) {

        self.associatedTab = tab
        self.syncService = syncService
        self.syncBookmarksAdapter = syncBookmarksAdapter
        self.variantManager = variantManager
        self.newTabDialogFactory = newTabDialogFactory
        self.newTabDialogTypeProvider = newTabDialogTypeProvider

        newTabPageViewModel = NewTabPageViewModel()
        shortcutsSettingsModel = NewTabPageShortcutsSettingsModel()
        sectionsSettingsModel = NewTabPageSectionsSettingsModel()
        favoritesModel = FavoritesDefaultViewModel(favoriteDataSource: FavoritesListInteractingAdapter(favoritesListInteracting: interactionModel), faviconLoader: faviconLoader)
        shortcutsModel = ShortcutsModel()
        messagesModel = NewTabPageMessagesModel(homePageMessagesConfiguration: homePageMessagesConfiguration, privacyProDataReporter: privacyProDataReporting)

        let newTabPageView = NewTabPageView(viewModel: newTabPageViewModel,
                                            messagesModel: messagesModel,
                                            favoritesModel: favoritesModel,
                                            bookmarksInteracting: bookmarksInteracting,
                                            shortcutsModel: shortcutsModel,
                                            shortcutsSettingsModel: shortcutsSettingsModel,
                                            sectionsSettingsModel: sectionsSettingsModel)

        super.init(rootView: newTabPageView)

        assignFavoriteModelActions()
        assignShorcutsModelActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        associatedTab.viewed = true

        presentNextDaxDialog()

        Pixel.fire(pixel: .homeScreenShown)
        sendDailyDisplayPixel()
    }

    // MARK: - Private

    private func assignFavoriteModelActions() {
        favoritesModel.onFaviconMissing = { [weak self] in
            guard let self else { return }
            self.faviconsFetcherOnboarding.presentOnboardingIfNeeded(from: self)
        }

        favoritesModel.onFavoriteURLSelected = { [weak self] url in
            guard let self else { return }

            delegate?.newTabPageDidOpenFavoriteURL(self, url: url)
        }

        favoritesModel.onFavoriteEdit = { [weak self] favorite in
            guard let self else { return }

            delegate?.newTabPageDidEditFavorite(self, favorite: favorite)
        }

        favoritesModel.onFavoriteDeleted = { [weak self] favorite in
            guard let self else { return }

            delegate?.newTabPageDidDeleteFavorite(self, favorite: favorite)
        }
    }

    private func assignShorcutsModelActions() {
        shortcutsModel.onShortcutOpened = { [weak self] shortcut in
            guard let self else { return }

            switch shortcut {
            case .aiChat:
                shortcutsDelegate?.newTabPageDidRequestAIChat(self)
            case .bookmarks:
                shortcutsDelegate?.newTabPageDidRequestBookmarks(self)
            case .downloads:
                shortcutsDelegate?.newTabPageDidRequestDownloads(self)
            case .passwords:
                shortcutsDelegate?.newTabPageDidRequestPasswords(self)
            case .settings:
                shortcutsDelegate?.newTabPageDidRequestSettings(self)
            }
        }
    }

    // MARK: - NewTabPage

    let isDragging: Bool = false

    weak var chromeDelegate: BrowserChromeDelegate?
    weak var delegate: NewTabPageControllerDelegate?
    weak var shortcutsDelegate: NewTabPageControllerShortcutsDelegate?

    func launchNewSearch() {
        chromeDelegate?.omniBar.becomeFirstResponder()
    }

    func openedAsNewTab(allowingKeyboard: Bool) {
        guard allowingKeyboard && KeyboardSettings().onNewTab else { return }

        // The omnibar is inside a collection view so this needs a chance to do its thing
        // which might also be async. Not great.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.launchNewSearch()
        }
    }

    func dismiss() {

    }

    func showNextDaxDialog() {
        showNextDaxDialogNew(dialogProvider: newTabDialogTypeProvider, factory: newTabDialogFactory)
    }

    func onboardingCompleted() {
        presentNextDaxDialog()
    }

    func reloadFavorites() {

    }

    // MARK: - Onboarding

    private func presentNextDaxDialog() {
        if variantManager.isSupported(feature: .newOnboardingIntro) {
            showNextDaxDialogNew(dialogProvider: newTabDialogTypeProvider, factory: newTabDialogFactory)
        }
    }

    // MARK: - Private

    private func sendDailyDisplayPixel() {

        let favoritesCount = favoritesModel.allFavorites.count
        let bucket = HomePageDisplayDailyPixelBucket(favoritesCount: favoritesCount)

        DailyPixel.fire(pixel: .newTabPageDisplayedDaily, withAdditionalParameters: [
            "FavoriteCount": bucket.value,
            "Shortcuts": sectionsSettingsModel.enabledItems.contains(.shortcuts) ? "1" : "0",
            "Favorites": sectionsSettingsModel.enabledItems.contains(.favorites) ? "1" : "0"
        ])
    }

    // MARK: -

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewTabPageViewController: HomeScreenTransitionSource {
    var snapshotView: UIView {
        view
    }

    var rootContainerView: UIView {
        view
    }
}

extension NewTabPageViewController {

    func showNextDaxDialogNew(dialogProvider: NewTabDialogSpecProvider, factory: any NewTabDaxDialogProvider) {
        dismissHostingController(didFinishNTPOnboarding: false)

        guard let spec = dialogProvider.nextHomeScreenMessageNew() else { return }

        let onDismiss = {
            dialogProvider.dismiss()
            self.dismissHostingController(didFinishNTPOnboarding: true)
        }
        let daxDialogView = AnyView(factory.createDaxDialog(for: spec, onDismiss: onDismiss))
        let hostingController = UIHostingController(rootView: daxDialogView)
        self.hostingController = hostingController

        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)

        newTabPageViewModel.startOnboarding()
    }

    private func dismissHostingController(didFinishNTPOnboarding: Bool) {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        if didFinishNTPOnboarding {
            self.newTabPageViewModel.finishOnboarding()
        }
    }
}

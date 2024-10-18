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

final class NewTabPageViewController: UIHostingController<AnyView>, NewTabPage {

    private let syncService: DDGSyncing
    private let syncBookmarksAdapter: SyncBookmarksAdapter
    private let variantManager: VariantManager
    private let newTabDialogFactory: any NewTabDaxDialogProvider
    private let newTabDialogTypeProvider: NewTabDialogSpecProvider

    private(set) lazy var faviconsFetcherOnboarding = FaviconsFetcherOnboarding(syncService: syncService, syncBookmarksAdapter: syncBookmarksAdapter)

    private let newTabPageViewModel: NewTabPageViewModel
    private let messagesModel: NewTabPageMessagesModel
    private let favoritesModel: FavoritesViewModel
    private let shortcutsModel: ShortcutsModel
    private let shortcutsSettingsModel: NewTabPageShortcutsSettingsModel
    private let sectionsSettingsModel: NewTabPageSectionsSettingsModel
    private let associatedTab: Tab

    private var hostingController: UIHostingController<AnyView>?

    private weak var daxDialogViewController: DaxDialogViewController?
    private var daxDialogHeightConstraint: NSLayoutConstraint?

    var isDaxDialogVisible: Bool {
        daxDialogViewController?.view.isHidden == false
    }

    init(tab: Tab,
         isNewTabPageCustomizationEnabled: Bool,
         interactionModel: FavoritesListInteracting,
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
        favoritesModel = FavoritesViewModel(isNewTabPageCustomizationEnabled: isNewTabPageCustomizationEnabled,
                                            favoriteDataSource: FavoritesListInteractingAdapter(favoritesListInteracting: interactionModel),
                                            faviconLoader: faviconLoader)
        shortcutsModel = ShortcutsModel()
        messagesModel = NewTabPageMessagesModel(homePageMessagesConfiguration: homePageMessagesConfiguration, privacyProDataReporter: privacyProDataReporting)

        if isNewTabPageCustomizationEnabled {
            super.init(rootView: AnyView(NewTabPageView(viewModel: self.newTabPageViewModel,
                                                        messagesModel: self.messagesModel,
                                                        favoritesViewModel: self.favoritesModel,
                                                        shortcutsModel: self.shortcutsModel,
                                                        shortcutsSettingsModel: self.shortcutsSettingsModel,
                                                        sectionsSettingsModel: self.sectionsSettingsModel)))
        } else {
            super.init(rootView: AnyView(SimpleNewTabPageView(viewModel: self.newTabPageViewModel,
                                                              messagesModel: self.messagesModel,
                                                              favoritesViewModel: self.favoritesModel)))
        }

        assignFavoriteModelActions()
        assignShorcutsModelActions()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpDaxDialog()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        associatedTab.viewed = true

        presentNextDaxDialog()

        Pixel.fire(pixel: .homeScreenShown)
        sendDailyDisplayPixel()

        view.backgroundColor = UIColor(designSystemColor: .background)
    }

    private func setUpDaxDialog() {
        let daxDialogController = DaxDialogViewController.loadFromStoryboard()
        guard let dialogView = daxDialogController.view else { return }

        self.addChild(daxDialogController)
        self.view.addSubview(dialogView)

        dialogView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.isHidden = true

        let widthConstraint = dialogView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1)
        widthConstraint.priority = .defaultHigh
        let heightConstraint = dialogView.heightAnchor.constraint(equalToConstant: 250)
        daxDialogHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            dialogView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44.0),
            dialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dialogView.widthAnchor.constraint(lessThanOrEqualToConstant: 375),
            heightConstraint,
            widthConstraint
        ])

        daxDialogController.didMove(toParent: self)
        daxDialogViewController = daxDialogController
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

        if !variantManager.isContextualDaxDialogsEnabled {
            // In the new onboarding this gets called twice (viewDidAppear in Tab) which then reset the spec to nil.
            presentNextDaxDialog()
        }
    }

    func dismiss() {

    }

    func showNextDaxDialog() {
        presentNextDaxDialog()
    }

    func onboardingCompleted() {
        presentNextDaxDialog()
    }

    func reloadFavorites() {

    }

    // MARK: - Onboarding

    private func presentNextDaxDialog() {
        if variantManager.isContextualDaxDialogsEnabled {
            showNextDaxDialogNew(dialogProvider: newTabDialogTypeProvider, factory: newTabDialogFactory)
        } else {
            showNextDaxDialog(dialogProvider: newTabDialogTypeProvider)
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

    func showNextDaxDialog(dialogProvider: NewTabDialogSpecProvider) {
        guard let spec = dialogProvider.nextHomeScreenMessage() else { return }
        guard !isDaxDialogVisible else { return }
        guard let daxDialogViewController = daxDialogViewController else { return }

        newTabPageViewModel.startOnboarding()

        daxDialogViewController.view.isHidden = false
        daxDialogViewController.view.alpha = 0.0

        daxDialogViewController.loadViewIfNeeded()
        daxDialogViewController.message = spec.message
        daxDialogViewController.accessibleMessage = spec.accessibilityLabel

        if spec == .initial {
            UniquePixel.fire(pixel: .onboardingContextualTryVisitSiteUnique, includedParameters: [.appVersion, .atb])
        }

        view.addGestureRecognizer(daxDialogViewController.tapToCompleteGestureRecognizer)

        daxDialogHeightConstraint?.constant = daxDialogViewController.calculateHeight()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.4, animations: {
                daxDialogViewController.view.alpha = 1.0
            }, completion: { _ in
                daxDialogViewController.start()
            })
        }
    }

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

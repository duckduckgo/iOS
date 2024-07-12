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
import Core

final class NewTabPageViewController: UIHostingController<NewTabPageView<FavoritesDefaultModel>>, NewTabPage {

    private let syncService: DDGSyncing
    private let syncBookmarksAdapter: SyncBookmarksAdapter

    private(set) lazy var faviconsFetcherOnboarding = FaviconsFetcherOnboarding(syncService: syncService, syncBookmarksAdapter: syncBookmarksAdapter)

    private let favoritesModel: FavoritesDefaultModel

    init(interactionModel: FavoritesListInteracting, syncService: DDGSyncing, syncBookmarksAdapter: SyncBookmarksAdapter) {

        self.syncService = syncService
        self.syncBookmarksAdapter = syncBookmarksAdapter

        self.favoritesModel = FavoritesDefaultModel(interactionModel: interactionModel)
        let newTabPageView = NewTabPageView(messagesModel: NewTabPageMessagesModel(),
                                            favoritesModel: favoritesModel)

        super.init(rootView: newTabPageView)

        assignFavoriteModelActions()
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
    }

    // MARK: - NewTabPage

    let isDragging: Bool = false

    weak var chromeDelegate: BrowserChromeDelegate?
//    weak var delegate: HomeControllerDelegate?
    weak var delegate: NewTabPageControllerDelegate?

    func launchNewSearch() {

    }

    func openedAsNewTab(allowingKeyboard: Bool) {

    }

    func omniBarCancelPressed() {

    }

    func dismiss() {

    }

    func showNextDaxDialog() {

    }

    func onboardingCompleted() {

    }

    func reloadFavorites() {

    }

    // MARK: -

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

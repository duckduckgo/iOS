//
//  FaviconsFetcherOnboarding.swift
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

import Combine
import Core
import DDGSync
import Foundation
import SwiftUI
import SyncUI

final class FaviconsFetcherOnboarding {

    init(syncService: DDGSyncing, syncBookmarksAdapter: SyncBookmarksAdapter) {
        self.syncService = syncService
        self.syncBookmarksAdapter = syncBookmarksAdapter
        self.viewModel = FaviconsFetcherOnboardingViewModel()
        faviconsFetcherCancellable = viewModel.$isFaviconsFetchingEnabled.sink { [weak self] isEnabled in
            self?.shouldEnableFaviconsFetcherOnDismiss = isEnabled
        }
    }

    @MainActor
    func presentOnboardingIfNeeded(from viewController: UIViewController) {
        let isCurrentlyPresenting = viewController.presentedViewController != nil
        guard shouldPresentOnboarding, !isCurrentlyPresenting else {
            return
        }
        didPresentFaviconsFetchingOnboarding = true

        let controller = UIHostingController(rootView: FaviconsFetcherOnboardingView(model: viewModel))
        if #available(iOS 16.0, *) {
            controller.sheetPresentationController?.detents = [.custom(resolver: { _ in 462 })]
        }

        viewModel.onDismiss = { [weak self, weak viewController] in
            viewController?.dismiss(animated: true)
            if self?.shouldEnableFaviconsFetcherOnDismiss == true {
                self?.syncBookmarksAdapter.isFaviconsFetchingEnabled = true
                self?.syncService.scheduler.notifyDataChanged()
            }
        }

        viewController.present(controller, animated: true)
    }

    private var shouldPresentOnboarding: Bool {
        !didPresentFaviconsFetchingOnboarding
        && !syncBookmarksAdapter.isFaviconsFetchingEnabled
        && syncBookmarksAdapter.isEligibleForFaviconsFetcherOnboarding
    }

    @UserDefaultsWrapper(key: .syncDidPresentFaviconsFetcherOnboarding, defaultValue: false)
    private var didPresentFaviconsFetchingOnboarding: Bool

    private let syncService: DDGSyncing
    private let syncBookmarksAdapter: SyncBookmarksAdapter
    private let viewModel: FaviconsFetcherOnboardingViewModel

    private var shouldEnableFaviconsFetcherOnDismiss: Bool = false
    private var faviconsFetcherCancellable: AnyCancellable?
}

//
//  SyncService.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

import Core
import DDGSync
import Persistence
import Combine
import BrowserServicesKit

final class SyncService {

    let syncDataProviders: SyncDataProviders
    let sync: DDGSync
    let syncErrorHandler: SyncErrorHandler
    private let isSyncInProgressCancellable: AnyCancellable
    private var syncDidFinishCancellable: AnyCancellable?
    private let application: UIApplication

    weak var presenter: SyncAlertsPresenting? {
        didSet {
            syncErrorHandler.alertPresenter = presenter
        }
    }

    init(bookmarksDatabase: CoreDataDatabase,
         privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         application: UIApplication = UIApplication.shared) {
        self.application = application
#if DEBUG
        let defaultEnvironment = ServerEnvironment.development
#else
        let defaultEnvironment = ServerEnvironment.production
#endif

        let environment = ServerEnvironment(
            UserDefaultsWrapper(
                key: .syncEnvironment,
                defaultValue: defaultEnvironment.description
            ).wrappedValue
        ) ?? defaultEnvironment

        syncErrorHandler = SyncErrorHandler()

        syncDataProviders = SyncDataProviders(
            bookmarksDatabase: bookmarksDatabase,
            secureVaultErrorReporter: SecureVaultReporter(),
            settingHandlers: [FavoritesDisplayModeSyncHandler()],
            favoritesDisplayModeStorage: FavoritesDisplayModeStorage(),
            syncErrorHandler: syncErrorHandler,
            faviconStoring: Favicons.shared,
            tld: AppDependencyProvider.shared.storageCache.tld
        )

        sync = DDGSync(
            dataProvidersSource: syncDataProviders,
            errorEvents: SyncErrorHandler(),
            privacyConfigurationManager: privacyConfigurationManager,
            environment: environment
        )
        sync.initializeIfNeeded()
        isSyncInProgressCancellable = sync.isSyncInProgressPublisher
            .filter { $0 }
            .sink { [weak sync] _ in
                DailyPixel.fire(pixel: .syncDaily, includedParameters: [.appVersion])
                sync?.syncDailyStats.sendStatsIfNeeded(handler: { params in
                    Pixel.fire(pixel: .syncSuccessRateDaily,
                               withAdditionalParameters: params,
                               includedParameters: [.appVersion])
                })
            }
    }

    private func suspendSync() {
        if sync.isSyncInProgress {
            Logger.sync.debug("Sync is in progress. Starting background task to allow it to gracefully complete.")

            var taskID: UIBackgroundTaskIdentifier!
            taskID = UIApplication.shared.beginBackgroundTask(withName: "Cancelled Sync Completion Task") {
                Logger.sync.debug("Forcing background task completion")
                UIApplication.shared.endBackgroundTask(taskID)
            }
            syncDidFinishCancellable?.cancel()
            syncDidFinishCancellable = sync.isSyncInProgressPublisher.filter { !$0 }
                .prefix(1)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    Logger.sync.debug("Ending background task")
                    UIApplication.shared.endBackgroundTask(taskID)
                }
        }

        sync.scheduler.cancelSyncAndSuspendSyncQueue()
    }

    private func cancelFaviconsFetching() {
        syncDataProviders.bookmarksAdapter.cancelFaviconsFetching(application)
    }

    func onForeground() {
        sync.scheduler.resumeSyncQueue()
        sync.initializeIfNeeded()
        syncDataProviders.setUpDatabaseCleanersIfNeeded(syncService: sync)
        sync.scheduler.notifyAppLifecycleEvent()
    }

    func onBackground() {
        suspendSync()
        cancelFaviconsFetching()
    }

}

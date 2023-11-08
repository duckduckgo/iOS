//
//  SyncBookmarksAdapter.swift
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

import Bookmarks
import Combine
import Common
import DDGSync
import Foundation
import Persistence
import SyncDataProviders
import WidgetKit

public protocol FavoritesDisplayModeStoring: AnyObject {
    var favoritesDisplayMode: FavoritesDisplayMode { get set }
}

public final class SyncBookmarksAdapter {

    public private(set) var provider: BookmarksProvider?
    public let databaseCleaner: BookmarkDatabaseCleaner
    public let syncDidCompletePublisher: AnyPublisher<Void, Never>
    public var shouldResetBookmarksSyncTimestamp: Bool = false {
        willSet {
            assert(provider == nil, "Setting this value has no effect after provider has been instantiated")
        }
    }

    public static let syncBookmarksPausedStateChanged = Notification.Name("com.duckduckgo.app.SyncPausedStateChanged")

    @UserDefaultsWrapper(key: .syncBookmarksPaused, defaultValue: false)
    static private var isSyncBookmarksPaused: Bool {
        didSet {
            NotificationCenter.default.post(name: syncBookmarksPausedStateChanged, object: nil)
        }
    }

    @Published
    public var isFaviconsFetchingEnabled: Bool = UserDefaultsWrapper(key: .syncAutomaticallyFetchFavicons, defaultValue: false).wrappedValue {
        didSet {
            var udWrapper = UserDefaultsWrapper(key: .syncAutomaticallyFetchFavicons, defaultValue: false)
            udWrapper.wrappedValue = isFaviconsFetchingEnabled
            if isFaviconsFetchingEnabled {
                faviconsFetcher?.initializeFetcherState()
            } else {
                faviconsFetcher?.cancelOngoingFetchingIfNeeded()
            }
        }
    }

    public init(database: CoreDataDatabase, favoritesDisplayModeStorage: FavoritesDisplayModeStoring) {
        self.database = database
        self.favoritesDisplayModeStorage = favoritesDisplayModeStorage
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
        databaseCleaner = BookmarkDatabaseCleaner(
            bookmarkDatabase: database,
            errorEvents: BookmarksCleanupErrorHandling(),
            log: .generalLog
        )
        widgetRefreshCancellable = syncDidCompletePublisher.sink { _ in
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    public func cleanUpDatabaseAndUpdateSchedule(shouldEnable: Bool) {
        databaseCleaner.cleanUpDatabaseNow()
        if shouldEnable {
            databaseCleaner.scheduleRegularCleaning()
            handleFavoritesAfterDisablingSync()
            isFaviconsFetchingEnabled = false
        } else {
            databaseCleaner.cancelCleaningSchedule()
        }
    }

    public func setUpProviderIfNeeded(database: CoreDataDatabase, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }

        let faviconsFetcher = BookmarksFaviconsFetcher(
            database: database,
            stateStore: BookmarkFaviconsFetcherStateStore(
                applicationSupportURL: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            ),
            fetcher: FaviconFetcher(),
            store: Favicons.shared,
            log: .syncLog
        )

        let provider = BookmarksProvider(
            database: database,
            metadataStore: metadataStore,
            syncDidUpdateData: { [weak self] in
                self?.syncDidCompleteSubject.send()
                Self.isSyncBookmarksPaused = false
            },
            syncDidFinish: { [weak self] faviconsFetcherInput in
                if self?.isFaviconsFetchingEnabled == true {
                    if let faviconsFetcherInput {
                        faviconsFetcher.updateBookmarkIDs(
                            modified: faviconsFetcherInput.modifiedBookmarksUUIDs,
                            deleted: faviconsFetcherInput.deletedBookmarksUUIDs
                        )
                    }
                    faviconsFetcher.startFetching()
                }
            }
        )
        if shouldResetBookmarksSyncTimestamp {
            provider.lastSyncTimestamp = nil
        }

        syncErrorCancellable = provider.syncErrorPublisher
            .sink { error in
                switch error {
                case let syncError as SyncError:
                    Pixel.fire(pixel: .syncBookmarksFailed, error: syncError)
                    // If bookmarks count limit has been exceeded
                    if syncError == .unexpectedStatusCode(409) {
                        Self.isSyncBookmarksPaused = true
                        DailyPixel.fire(pixel: .syncBookmarksCountLimitExceededDaily)
                    }
                    // If bookmarks request size limit has been exceeded
                    if syncError == .unexpectedStatusCode(413) {
                        Self.isSyncBookmarksPaused = true
                        DailyPixel.fire(pixel: .syncBookmarksRequestSizeLimitExceededDaily)
                    }
                default:
                    let nsError = error as NSError
                    if nsError.domain != NSURLErrorDomain {
                        let processedErrors = CoreDataErrorsParser.parse(error: error as NSError)
                        let params = processedErrors.errorPixelParameters
                        Pixel.fire(pixel: .syncBookmarksFailed, error: error, withAdditionalParameters: params)
                    }
                }
                os_log(.error, log: OSLog.syncLog, "Bookmarks Sync error: %{public}s", String(reflecting: error))
            }

        self.provider = provider
        self.faviconsFetcher = faviconsFetcher
    }

    private func handleFavoritesAfterDisablingSync() {
        let context = database.makeContext(concurrencyType: .privateQueueConcurrencyType)

        context.performAndWait {
            do {
                if favoritesDisplayModeStorage.favoritesDisplayMode.isDisplayUnified {
                    BookmarkUtils.copyFavorites(from: .unified, to: .mobile, clearingNonNativeFavoritesFolder: .desktop, in: context)
                    favoritesDisplayModeStorage.favoritesDisplayMode = .displayNative(.mobile)
                } else {
                    BookmarkUtils.copyFavorites(from: .mobile, to: .unified, clearingNonNativeFavoritesFolder: .desktop, in: context)
                }
                try context.save()
            } catch {
                let nsError = error as NSError
                let processedErrors = CoreDataErrorsParser.parse(error: nsError)
                let params = processedErrors.errorPixelParameters
                Pixel.fire(pixel: .favoritesCleanupFailed, error: error, withAdditionalParameters: params)
            }
        }
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
    private var widgetRefreshCancellable: AnyCancellable
    private let database: CoreDataDatabase
    private let favoritesDisplayModeStorage: FavoritesDisplayModeStoring
    private var faviconsFetcher: BookmarksFaviconsFetcher?
}

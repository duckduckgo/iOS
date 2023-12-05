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

public class BookmarksFaviconsFetcherErrorHandler: EventMapping<BookmarksFaviconsFetcherError> {

    public init() {
        super.init { event, _, _, _ in
            Pixel.fire(pixel: .bookmarksFaviconsFetcherFailed, error: event.underlyingError)
        }
    }

    override init(mapping: @escaping EventMapping<BookmarksFaviconsFetcherError>.Mapping) {
        fatalError("Use init()")
    }
}

public enum SyncBookmarksAdapterError: CustomNSError {
    case unableToAccessFaviconsFetcherStateStoreDirectory

    public static let errorDomain: String = "SyncBookmarksAdapterError"

    public var errorCode: Int {
        switch self {
        case .unableToAccessFaviconsFetcherStateStoreDirectory:
            return 1
        }
    }
}

public final class SyncBookmarksAdapter {

    public static let syncBookmarksPausedStateChanged = Notification.Name("com.duckduckgo.app.SyncPausedStateChanged")
    public static let bookmarksSyncLimitReached = Notification.Name("com.duckduckgo.app.SyncBookmarksLimitReached")

    public private(set) var provider: BookmarksProvider?
    public let databaseCleaner: BookmarkDatabaseCleaner
    public let syncDidCompletePublisher: AnyPublisher<Void, Never>

    @UserDefaultsWrapper(key: .syncBookmarksPaused, defaultValue: false)
    static public var isSyncBookmarksPaused: Bool {
        didSet {
            NotificationCenter.default.post(name: syncBookmarksPausedStateChanged, object: nil)
        }
    }

    @UserDefaultsWrapper(key: .syncBookmarksPausedErrorDisplayed, defaultValue: false)
    static private var didShowBookmarksSyncPausedError: Bool

    @UserDefaultsWrapper(key: .syncDidMigrateToImprovedListsHandling, defaultValue: false)
    private var didMigrateToImprovedListsHandling: Bool

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

    @UserDefaultsWrapper(key: .syncIsEligibleForFaviconsFetcherOnboarding, defaultValue: false)
    public var isEligibleForFaviconsFetcherOnboarding: Bool

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

        let faviconsFetcher = setUpFaviconsFetcher()

        let provider = BookmarksProvider(
            database: database,
            metadataStore: metadataStore,
            syncDidUpdateData: { [weak self] in
                self?.syncDidCompleteSubject.send()
                Self.isSyncBookmarksPaused = false
                Self.didShowBookmarksSyncPausedError = false
            },
            syncDidFinish: { [weak self] faviconsFetcherInput in
                if let faviconsFetcher, self?.isFaviconsFetchingEnabled == true {
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
        if !didMigrateToImprovedListsHandling {
            didMigrateToImprovedListsHandling = true
            provider.lastSyncTimestamp = nil
        }

        bindSyncErrorPublisher(provider)

        self.provider = provider
        self.faviconsFetcher = faviconsFetcher
    }

    private func setUpFaviconsFetcher() -> BookmarksFaviconsFetcher? {
        let stateStore: BookmarksFaviconsFetcherStateStore
        do {
            guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw SyncBookmarksAdapterError.unableToAccessFaviconsFetcherStateStoreDirectory
            }
            stateStore = try BookmarksFaviconsFetcherStateStore(applicationSupportURL: url)
        } catch {
            Pixel.fire(pixel: .bookmarksFaviconsFetcherStateStoreInitializationFailed, error: error)
            os_log(.error, log: .syncLog, "Failed to initialize BookmarksFaviconsFetcherStateStore: %{public}s", String(reflecting: error))
            return nil
        }

        return BookmarksFaviconsFetcher(
            database: database,
            stateStore: stateStore,
            fetcher: FaviconFetcher(),
            faviconStore: Favicons.shared,
            errorEvents: BookmarksFaviconsFetcherErrorHandler(),
            log: .syncLog
        )
    }

    private func bindSyncErrorPublisher(_ provider: BookmarksProvider) {
        syncErrorCancellable = provider.syncErrorPublisher
            .sink { error in
                switch error {
                case let syncError as SyncError:
                    Pixel.fire(pixel: .syncBookmarksFailed, error: syncError)
                    switch syncError {
                    case .unexpectedStatusCode(409):
                        // If bookmarks count limit has been exceeded
                        Self.isSyncBookmarksPaused = true
                        DailyPixel.fire(pixel: .syncBookmarksCountLimitExceededDaily)
                        Self.notifyBookmarksSyncLimitReached()
                    case .unexpectedStatusCode(413):
                        // If bookmarks request size limit has been exceeded
                        Self.isSyncBookmarksPaused = true
                        DailyPixel.fire(pixel: .syncBookmarksRequestSizeLimitExceededDaily)
                        Self.notifyBookmarksSyncLimitReached()
                    default:
                        break
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
    }

    public func cancelFaviconsFetching(_ application: UIApplication) {
        guard let faviconsFetcher else {
            return
        }
        if faviconsFetcher.isFetchingInProgress == true {
            os_log(.debug, log: .syncLog, "Favicons Fetching is in progress. Starting background task to allow it to gracefully complete.")

            var taskID: UIBackgroundTaskIdentifier!
            taskID = application.beginBackgroundTask(withName: "Cancelled Favicons Fetching Completion Task") {
                os_log(.debug, log: .syncLog, "Forcing background task completion")
                application.endBackgroundTask(taskID)
            }
            faviconsFetchingDidFinishCancellable?.cancel()
            faviconsFetchingDidFinishCancellable = faviconsFetcher.$isFetchingInProgress.dropFirst().filter { !$0 }
                .prefix(1)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    os_log(.debug, log: .syncLog, "Ending background task")
                    application.endBackgroundTask(taskID)
                }
        }

        faviconsFetcher.cancelOngoingFetchingIfNeeded()
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

    static private func notifyBookmarksSyncLimitReached() {
        if !Self.didShowBookmarksSyncPausedError {
            NotificationCenter.default.post(name: Self.bookmarksSyncLimitReached, object: nil)
            Self.didShowBookmarksSyncPausedError = true
        }
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?

    private let database: CoreDataDatabase
    private let favoritesDisplayModeStorage: FavoritesDisplayModeStoring
    private var faviconsFetcher: BookmarksFaviconsFetcher?
    private var faviconsFetchingDidFinishCancellable: AnyCancellable?
    private var widgetRefreshCancellable: AnyCancellable?
}

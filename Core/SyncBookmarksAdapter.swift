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
    public let widgetRefreshCancellable: AnyCancellable

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
        } else {
            databaseCleaner.cancelCleaningSchedule()
        }
    }

    public func handleFavoritesAfterDisablingSync() {
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

    public func setUpProviderIfNeeded(database: CoreDataDatabase, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }

        let provider = BookmarksProvider(
            database: database,
            metadataStore: metadataStore,
            syncDidUpdateData: { [syncDidCompleteSubject] in
                syncDidCompleteSubject.send()
            }
        )

        syncErrorCancellable = provider.syncErrorPublisher
            .sink { error in
                switch error {
                case let syncError as SyncError:
                    Pixel.fire(pixel: .syncBookmarksFailed, error: syncError)
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
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
    private let database: CoreDataDatabase
    private let favoritesDisplayModeStorage: FavoritesDisplayModeStoring
}

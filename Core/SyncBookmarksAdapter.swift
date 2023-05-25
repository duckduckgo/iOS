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

import Combine
import Common
import DDGSync
import Foundation
import Persistence
import SyncDataProviders

public final class SyncBookmarksAdapter {

    public private(set) var provider: BookmarksProvider?

    public let syncDidCompletePublisher: AnyPublisher<Void, Never>

    public init() {
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
    }

    public func setUpProviderIfNeeded(database: CoreDataDatabase, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }
        do {
            let provider = try BookmarksProvider(
                database: database,
                metadataStore: metadataStore,
                reloadBookmarksAfterSync: { [syncDidCompleteSubject] in
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
        } catch let error as NSError {
            let processedErrors = CoreDataErrorsParser.parse(error: error)
            let params = processedErrors.errorPixelParameters
            Pixel.fire(pixel: .syncBookmarksProviderInitializationFailed, error: error, withAdditionalParameters: params)
        }
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
}

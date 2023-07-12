//
//  SyncLoginsAdapter.swift
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

import BrowserServicesKit
import Combine
import Common
import DDGSync
import Persistence
import SyncDataProviders

public final class SyncLoginsAdapter {

    public private(set) var provider: LoginsProvider?

    public func setUpProviderIfNeeded(secureVaultFactory: SecureVaultFactory, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }

        do {
            let provider = try LoginsProvider(
                secureVaultFactory: secureVaultFactory,
                metadataStore: metadataStore,
                reloadLoginsAfterSync: {}
            )

            syncErrorCancellable = provider.syncErrorPublisher
                .sink { error in
                    switch error {
                    case let syncError as SyncError:
                        break
//                        Pixel.fire(.debug(event: .syncLoginsFailed, error: syncError))
                    default:
                        let nsError = error as NSError
                        if nsError.domain != NSURLErrorDomain {
                            let processedErrors = CoreDataErrorsParser.parse(error: error as NSError)
                            let params = processedErrors.errorPixelParameters
//                            Pixel.fire(.debug(event: .syncLoginsFailed, error: error), withAdditionalParameters: params)
                        }
                    }
                    os_log(.error, log: OSLog.syncLog, "Credentials Sync error: %{public}s", String(reflecting: error))
                }

            self.provider = provider

        } catch let error as NSError {
            let processedErrors = CoreDataErrorsParser.parse(error: error)
            let params = processedErrors.errorPixelParameters
//            Pixel.fire(.debug(event: .syncLoginsProviderInitializationFailed, error: error), withAdditionalParameters: params)
        }

    }

    private var syncErrorCancellable: AnyCancellable?
}

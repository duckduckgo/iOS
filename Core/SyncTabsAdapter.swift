//
//  SyncTabsAdapter.swift
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
import Persistence
import SyncDataProviders

public final class SyncTabsAdapter {

    public let syncDidCompletePublisher: AnyPublisher<Void, Never>

    private(set) var provider: TabsProvider?
    private(set) var tabsStore: DeviceTabsStore?

    public init() {
        syncDidCompletePublisher = syncDidCompleteSubject.eraseToAnyPublisher()
    }

    public func setUpProviderIfNeeded(currentDeviceTabsSource: CurrentDeviceTabsSource, metadataStore: SyncMetadataStore) {
        guard provider == nil else {
            return
        }

        let tabsStore = DeviceTabsStore(
            applicationSupportURL: FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!,
            currentDeviceTabsSource: currentDeviceTabsSource
        )

        let provider = TabsProvider(tabsStore: tabsStore, metadataStore: metadataStore, syncDidUpdateData: { [weak self] in
            self?.syncDidCompleteSubject.send()
        })

        syncErrorCancellable = provider.syncErrorPublisher
            .sink { error in
                os_log(.error, log: .syncLog, "Tabs Sync error: %{public}s", String(reflecting: error))
            }

        self.provider = provider
        self.tabsStore = tabsStore
    }

    private var syncDidCompleteSubject = PassthroughSubject<Void, Never>()
    private var syncErrorCancellable: AnyCancellable?
}

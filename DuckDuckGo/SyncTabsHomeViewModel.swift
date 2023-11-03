//
//  SyncTabsHomeViewModel.swift
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
import Foundation
import DDGSync
import SyncDataProviders

extension TabInfo: Identifiable {
    public var id: String {
        UUID().uuidString
    }
}

extension DeviceTabsInfo: Identifiable {
    public var id: String {
        deviceId
    }
}

final class SyncTabsHomeViewModel: ObservableObject {

    @Published var deviceTabs: [DeviceTabsInfo] = []

    var open: (URL) -> Void = { _ in }
    let tabsAdapter: SyncTabsAdapter
    let syncService: DDGSyncing

    init(syncTabsAdapter: SyncTabsAdapter, syncService: DDGSyncing) {
        self.tabsAdapter = syncTabsAdapter
        self.syncService = syncService
        syncDidUpdateTabsCancellable = tabsAdapter.syncDidCompletePublisher
            .sink { [weak self] _ in
                self?.reloadDeviceTabs()
            }

        reloadDeviceTabs()
    }

    func reloadDeviceTabs() {

        Task { @MainActor in
            let deviceTabs = (try? self.tabsAdapter.tabsStore?.getDeviceTabs()) ?? []
            print("loaded \(deviceTabs.count) device tabs")
            let devices = try await self.syncService.fetchDevices()
            self.deviceTabs = deviceTabs
                .filter { !$0.deviceTabs.isEmpty }
                .compactMap { object in
                    guard let deviceName = devices.first(where: { $0.id == object.deviceId })?.name else {
                        return nil
                    }
                    return DeviceTabsInfo(deviceId: deviceName, deviceTabs: object.deviceTabs)
                }
        }
    }

    private var syncDidUpdateTabsCancellable: AnyCancellable?
}

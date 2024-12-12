//
//  WebsiteDataStoreCleaning.swift
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

import WebKit

public protocol WebsiteDataStoreCleaning {

    func countContainers() async -> Int
    func removeAllContainersAfterDelay(previousCount: Int) async

}

public class DefaultWebsiteDataStoreCleaner: WebsiteDataStoreCleaning {

    public init() { }

    @MainActor
    public func countContainers() async -> Int {
        guard #available(iOS 17, *) else { return 0 }
        return await WKWebsiteDataStore.allDataStoreIdentifiers.count
    }

    @MainActor
    public func removeAllContainersAfterDelay(previousCount: Int) async {
        guard #available(iOS 17, *) else { return }

        // Attempt to clean up all previous stores, but wait for a few seconds.
        // If this fails, we are going to still clean them next time as WebKit keeps track of all stores for us.
        Task {
            try? await Task.sleep(interval: 3.0)
            for uuid in await WKWebsiteDataStore.allDataStoreIdentifiers {
                try? await WKWebsiteDataStore.remove(forIdentifier: uuid)
            }

            await checkForLeftBehindDataStores(previousLeftOversCount: previousCount)
        }
    }

    @MainActor
    private func checkForLeftBehindDataStores(previousLeftOversCount: Int) async {
        guard #available(iOS 17, *) else { return }

        let params = [
            "left_overs_count": "\(previousLeftOversCount)"
        ]

        let ids = await WKWebsiteDataStore.allDataStoreIdentifiers
        if ids.count > 1 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedMultiple, withAdditionalParameters: params)
        } else if ids.count > 0 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedOne, withAdditionalParameters: params)
        } else if previousLeftOversCount > 0 {
            Pixel.fire(pixel: .debugWebsiteDataStoresCleared, withAdditionalParameters: params)
        }
    }

}

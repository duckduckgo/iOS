//
//  WebCacheManager.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Common
import WebKit
import os.log

extension WKWebsiteDataStore {

    public static func current(dataStoreIdManager: DataStoreIdManaging = DataStoreIdManager.shared) -> WKWebsiteDataStore {
        if #available(iOS 17, *), let id = dataStoreIdManager.currentId {
            return WKWebsiteDataStore(forIdentifier: id)
        } else {
            return WKWebsiteDataStore.default()
        }
    }

}

extension HTTPCookie {

    func matchesDomain(_ domain: String) -> Bool {
        return self.domain == domain || (self.domain.hasPrefix(".") && domain.hasSuffix(self.domain))
    }

}

public protocol WebsiteDataManaging {

    func removeCookies(forDomains domains: [String], fromDataStore: WKWebsiteDataStore) async
    func consumeCookies(intoHTTPCookieStore httpCookieStore: WKHTTPCookieStore) async
    func clear(dataStore: WKWebsiteDataStore) async

}

@MainActor
public class WebCacheManager: WebsiteDataManaging {

    let cookieStorage: MigratableCookieStorage
    let fireproofing: Fireproofing
    let dataStoreIdManager: DataStoreIdManaging

    public init(cookieStorage: MigratableCookieStorage, fireproofing: Fireproofing, dataStoreIdManager: DataStoreIdManaging) {
        self.cookieStorage = cookieStorage
        self.fireproofing = fireproofing
        self.dataStoreIdManager = dataStoreIdManager
    }

    /// We save cookies from the current container rather than copying them to a new container because
    ///  the container only persists cookies to disk when the web view is used.  If the user presses the fire button
    ///  twice then the fire proofed cookies will be lost and the user will be logged out any sites they're logged in to.
    public func consumeCookies(intoHTTPCookieStore httpCookieStore: WKHTTPCookieStore) async {
        guard !cookieStorage.isConsumed else { return }

        let cookies = cookieStorage.cookies
        var consumedCookiesCount = 0
        for cookie in cookies {
            consumedCookiesCount += 1
            await httpCookieStore.setCookie(cookie)
        }
        cookieStorage.isConsumed = true
    }

    public func removeCookies(forDomains domains: [String],
                              fromDataStore dataStore: WKWebsiteDataStore) async {
        let startTime = CACurrentMediaTime()
        let cookieStore = dataStore.httpCookieStore
        let cookies = await cookieStore.allCookies()
        for cookie in cookies where domains.contains(where: { cookie.matchesDomain($0) }) {
            await cookieStore.deleteCookie(cookie)
        }
        let totalTime = CACurrentMediaTime() - startTime
        Pixel.fire(pixel: .cookieDeletionTime(.init(number: totalTime)))
    }

    public func clear(dataStore: WKWebsiteDataStore) async {

        await performMigrationIfNeeded(dataStoreIdManager: dataStoreIdManager, destinationStore: dataStore)
        await clearData(inDataStore: dataStore, withFireproofing: fireproofing)
        removeContainersIfNeeded()

    }

}

extension WebCacheManager {

    private func performMigrationIfNeeded(dataStoreIdManager: DataStoreIdManaging,
                                          cookieStorage: MigratableCookieStorage = MigratableCookieStorage(),
                                          destinationStore: WKWebsiteDataStore) async {

        // Check version here rather than on function so that we don't need complicated logic related to verison in the calling function
        guard #available(iOS 17, *) else { return }

        // If there's no id, then migration has been done or isn't needed
        guard dataStoreIdManager.currentId != nil else { return }

        // Get all cookies, we'll clean them later to keep all that logic in the same place
        let cookies = cookieStorage.cookies

        // The returned cookies should be kept so move them to the data store
        for cookie in cookies {
            await destinationStore.httpCookieStore.setCookie(cookie)
        }

        cookieStorage.migrationComplete()
        dataStoreIdManager.invalidateCurrentId()
    }

    private func removeContainersIfNeeded() {
        // Check version here rather than on function so that we don't need complicated logic related to verison in the calling function
        guard #available(iOS 17, *) else { return }

        // Attempt to clean up all previous stores, but wait for a few seconds.
        // If this fails, we are going to still clean them next time as WebKit keeps track of all stores for us.
        Task {
            try? await Task.sleep(for: .seconds(3))
            for uuid in await WKWebsiteDataStore.allDataStoreIdentifiers {
                try? await WKWebsiteDataStore.remove(forIdentifier: uuid)
            }

            let count = await WKWebsiteDataStore.allDataStoreIdentifiers.count
            switch count {
            case 0:
                Pixel.fire(pixel: .debugWebsiteDataStoresCleared)

            case 1:
                Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedOne)

            default:
                Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedMultiple)
            }
        }
    }

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

    private func clearData(inDataStore dataStore: WKWebsiteDataStore, withFireproofing fireproofing: Fireproofing) async {
        let startTime = CACurrentMediaTime()

        // Start with all types
        var types = WKWebsiteDataStore.allWebsiteDataTypes()

        // Remove types we want to retain
        types.remove(WKWebsiteDataTypeCookies)
        types.remove(WKWebsiteDataTypeLocalStorage)

        // Add types without an API constant that we also want to clear
        types.insert("_WKWebsiteDataTypeMediaKeys")
        types.insert("_WKWebsiteDataTypeHSTSCache")
        types.insert("_WKWebsiteDataTypeSearchFieldRecentSearches")
        types.insert("_WKWebsiteDataTypeResourceLoadStatistics")
        types.insert("_WKWebsiteDataTypeCredentials")
        types.insert("_WKWebsiteDataTypeAdClickAttributions")
        types.insert("_WKWebsiteDataTypePrivateClickMeasurements")
        types.insert("_WKWebsiteDataTypeAlternativeServices")

        // Get a list of records that are NOT fireproofed
        let removableRecords = await dataStore.dataRecords(ofTypes: types).filter { record in
            !fireproofing.isAllowed(fireproofDomain: record.displayName)
        }

        await dataStore.removeData(ofTypes: types, for: removableRecords)

        self.removeObservationsData()
        let totalTime = CACurrentMediaTime() - startTime
        Pixel.fire(pixel: .clearDataInDefaultPersistence(.init(number: totalTime)))
    }

}

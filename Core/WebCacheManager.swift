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
import GRDB

extension WKWebsiteDataStore {

    public static func current(dataStoreIdManager: DataStoreIdManager = .shared) -> WKWebsiteDataStore {
        if #available(iOS 17, *), let id = dataStoreIdManager.id {
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

@MainActor
public class WebCacheManager {

    public static var shared = WebCacheManager()

    private init() { }

    /// We save cookies from the current container rather than copying them to a new container because
    ///  the container only persists cookies to disk when the web view is used.  If the user presses the fire button
    ///  twice then the fire proofed cookies will be lost and the user will be logged out any sites they're logged in to.
    public func consumeCookies(cookieStorage: CookieStorage = CookieStorage(),
                               httpCookieStore: WKHTTPCookieStore) async {
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
                              dataStore: WKWebsiteDataStore) async {
        let startTime = CACurrentMediaTime()
        let cookieStore = dataStore.httpCookieStore
        let cookies = await cookieStore.allCookies()
        for cookie in cookies where domains.contains(where: { cookie.matchesDomain($0) }) {
            await cookieStore.deleteCookie(cookie)
        }
        let totalTime = CACurrentMediaTime() - startTime
        Pixel.fire(pixel: .cookieDeletionTime(.init(number: totalTime)))
    }

    public func clear(cookieStorage: CookieStorage = CookieStorage(),
                      logins: PreserveLogins = PreserveLogins.shared,
                      dataStoreIdManager: DataStoreIdManager = .shared) async {

        var cookiesToUpdate = [HTTPCookie]()
        if #available(iOS 17, *), dataStoreIdManager.hasId {
            cookiesToUpdate += await containerBasedClearing(storeIdManager: dataStoreIdManager) ?? []
        }

        // Perform legacy clearing to migrate to new container
        cookiesToUpdate += await legacyDataClearing() ?? []

        cookieStorage.updateCookies(cookiesToUpdate, keepingPreservedLogins: logins)
    }

}

extension WebCacheManager {

    @available(iOS 17, *)
    private func checkForLeftBehindDataStores() async {
        let ids = await WKWebsiteDataStore.allDataStoreIdentifiers
        if ids.count > 1 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedMultiple)
        } else if ids.count > 0 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedOne)
        }
    }

    @available(iOS 17, *)
    private func containerBasedClearing(storeIdManager: DataStoreIdManager) async -> [HTTPCookie]? {
        guard let containerId = storeIdManager.id else { return [] }
        var dataStore: WKWebsiteDataStore? = WKWebsiteDataStore(forIdentifier: containerId)
        let cookies = await dataStore?.httpCookieStore.allCookies()
        dataStore = nil

        let uuids = await WKWebsiteDataStore.allDataStoreIdentifiers
        for uuid in uuids {
            try? await WKWebsiteDataStore.remove(forIdentifier: uuid)
        }
        await checkForLeftBehindDataStores()

        storeIdManager.allocateNewContainerId()
        return cookies
    }

    private func legacyDataClearing() async -> [HTTPCookie]? {

        let dataStore = WKWebsiteDataStore.default()
        let startTime = CACurrentMediaTime()

        let cookies = await dataStore.httpCookieStore.allCookies()
        var types = WKWebsiteDataStore.allWebsiteDataTypes()
        types.insert("_WKWebsiteDataTypeMediaKeys")
        types.insert("_WKWebsiteDataTypeHSTSCache")
        types.insert("_WKWebsiteDataTypeSearchFieldRecentSearches")
        types.insert("_WKWebsiteDataTypeResourceLoadStatistics")
        types.insert("_WKWebsiteDataTypeCredentials")
        types.insert("_WKWebsiteDataTypeAdClickAttributions")
        types.insert("_WKWebsiteDataTypePrivateClickMeasurements")
        types.insert("_WKWebsiteDataTypeAlternativeServices")

        await dataStore.removeData(ofTypes: types, modifiedSince: .distantPast)

        self.removeObservationsData()
        let totalTime = CACurrentMediaTime() - startTime
        Pixel.fire(pixel: .legacyDataClearingTime(.init(number: totalTime)))

        return cookies
    }

    private func removeObservationsData() {
        if let pool = getValidDatabasePool() {
            removeObservationsData(from: pool)
        } else {
            os_log("Could not find valid pool to clear observations data", log: .generalLog, type: .debug)
        }
    }

    func getValidDatabasePool() -> DatabasePool? {
        let bundleID = Bundle.main.bundleIdentifier ?? ""

        let databaseURLs = [
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                       .appendingPathComponent("WebKit/WebsiteData/ResourceLoadStatistics/observations.db"),
            FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                       .appendingPathComponent("WebKit/\(bundleID)/WebsiteData/ResourceLoadStatistics/observations.db")
        ]

        guard let validURL = databaseURLs.first(where: { FileManager.default.fileExists(atPath: $0.path) }),
              let pool = try? DatabasePool(path: validURL.absoluteString) else {
            return nil
        }

        return pool
    }

    private func removeObservationsData(from pool: DatabasePool) {
         do {
             try pool.write { database in
                 try database.execute(sql: "PRAGMA wal_checkpoint(TRUNCATE);")

                 let tables = try String.fetchAll(database, sql: "SELECT name FROM sqlite_master WHERE type='table'")

                 for table in tables {
                     try database.execute(sql: "DELETE FROM \(table)")
                 }
             }
         } catch {
             Pixel.fire(pixel: .debugCannotClearObservationsDatabase, error: error)
         }
     }

}

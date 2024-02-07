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

// swiftlint:disable file_length

import Common
import WebKit
import GRDB

//public protocol WebCacheManagerCookieStore {
//    
//    func getAllCookies(_ completionHandler: @escaping ([HTTPCookie]) -> Void)
//
//    func setCookie(_ cookie: HTTPCookie, completionHandler: (() -> Void)?)
//
//    func delete(_ cookie: HTTPCookie, completionHandler: (() -> Void)?)
//    
//}

//public protocol WebCacheManagerDataStore {
//    
//    var cookieStore: WebCacheManagerCookieStore? { get }
//    
//    func legacyClearingRemovingAllDataExceptCookies(completion: @escaping () -> Void)
//    
//    func preservedCookies(_ preservedLogins: PreserveLogins) async -> [HTTPCookie]
//
//}

// extension WebCacheManagerDataStore {
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

public class WebCacheManager {
    
    public static var shared = WebCacheManager()
    
    private init() { }
    
    /// We save cookies from the current container rather than copying them to a new container because
    ///  the container only persists cookies to disk when the web view is used.  If the user presses the fire button
    ///  twice then the fire proofed cookies will be lost and the user will be logged out any sites they're logged in to.
    @MainActor
    public func consumeCookies(cookieStorage: CookieStorage = CookieStorage(),
                               httpCookieStore: WKHTTPCookieStore) async {
        
        let cookies = cookieStorage.cookies
        
        guard !cookies.isEmpty, !cookieStorage.isConsumed else {
            return
        }
        
        var consumedCookiesCount = 0
        for cookie in cookies {
            consumedCookiesCount += 1
            await httpCookieStore.setCookie(cookie)
        }
        cookieStorage.isConsumed = true
        
        if cookieStorage.cookies.count > 0 {
            Task.detached {
                os_log("Error removing cookies: %d cookies left in CookieStorage",
                       log: .generalLog, type: .debug, cookieStorage.cookies.count)
                
                Pixel.fire(pixel: .debugCookieCleanupError, withAdditionalParameters: [
                    PixelParameters.count: "\(cookieStorage.cookies.count)"
                ])
            }
        }
    }
    
    @MainActor
    public func removeCookies(forDomains domains: [String],
                              dataStore: WKWebsiteDataStore) async {
        
        let timeoutTask = Task.detached {
            try? await Task.sleep(interval: 5.0)
        }
        
        _ = Task.detached { @MainActor in
            print("*** removing cookies")
            
            let cookieStore = dataStore.httpCookieStore
            let cookies = await cookieStore.allCookies()
            for cookie in cookies where domains.contains(where: {
                let result = cookie.matchesDomain($0)
                print("***", cookie.domain, $0, result)
                return result
            }) {
                print("*** removing cookie with domain", cookie.domain)
                await cookieStore.deleteCookie(cookie)
            }
            
            print("*** cancelling timeout task")
            timeoutTask.cancel()
        }
        
        await timeoutTask.value
        
        if !timeoutTask.isCancelled {
            print("*** timeout was not cancelled")
            Pixel.fire(pixel: .cookieDeletionTimedOut, withAdditionalParameters: [
                PixelParameters.removeCookiesTimedOut: "1"
            ])
        }
        
    }

    @MainActor
    public func clear(cookieStorage: CookieStorage = CookieStorage(),
                      logins: PreserveLogins = PreserveLogins.shared,
                      tabCountInfo: TabCountInfo? = nil,
                      dataStoreIdManager: DataStoreIdManager = .shared) async {

        if #available(iOS 17, *), dataStoreIdManager.hasId {
            let containerCookies = await containerBasedClearing(storeIdManager: dataStoreIdManager)
            cookieStorage.updateCookies(containerCookies ?? [], keepingPreservedLogins: logins)
        }
        
        // Perform legacy clearing to migrate to new container
        let legacyCookies = await legacyDataClearing()
        cookieStorage.updateCookies(legacyCookies ?? [], keepingPreservedLogins: logins)
    }
    
//    public func clear(cookieStorage: CookieStorage = CookieStorage(),
//                      logins: PreserveLogins = PreserveLogins.shared,
//                      tabCountInfo: TabCountInfo? = nil,
//                      dataStoreIdManager: DataStoreIdManager = .shared,
//                      completion: @escaping () -> Void) {
//
//        if #available(iOS 17, *), dataStoreIdManager.hasId {
//            containerBasedClearing(logins: logins, storeIdManager: dataStoreIdManager) {
//                // Perform legacy clearing anyway, just to be sure
//                self.legacyDataClearing(logins: logins) { _ in completion() }
//            }
//        } else {
//            legacyDataClearing(logins: logins) { cookies in
//                if #available(iOS 17, *) {
//                    // From this point onwards... use containers
//                    dataStoreIdManager.allocateNewContainerId()
//                    Task { @MainActor in
//                        cookieStorage.updateCookies(cookies, keepingPreservedLogins: logins)
//                        completion()
//                    }
//                } else {
//                    completion()
//                }
//            }
//        }
//    }
    
}

extension WebCacheManager {
    
    @available(iOS 17, *)
    func checkForLeftBehindDataStores() async {
        let ids = await WKWebsiteDataStore.allDataStoreIdentifiers
        if ids.count > 1 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedMultiple)
        } else if ids.count > 0 {
            Pixel.fire(pixel: .debugWebsiteDataStoresNotClearedOne)
        }
    }

    @available(iOS 17, *)
    func containerBasedClearing(storeIdManager: DataStoreIdManager) async -> [HTTPCookie]? {
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
    
    @MainActor
    private func legacyDataClearing() async -> [HTTPCookie]? {
        let dataStore = WKWebsiteDataStore.default()
        let cookies = await dataStore.httpCookieStore.allCookies()
        await dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: .distantPast)
        removeObservationsData()
        return cookies
    }
    
    // swiftlint:disable function_body_length
//    private func legacyDataClearing(logins: PreserveLogins,
//                                    tabCountInfo: TabCountInfo? = nil,
//                                    completion: @escaping ([HTTPCookie]) -> Void) {
//
//        func keep(_ cookie: HTTPCookie) -> Bool {
//            return logins.isAllowed(cookieDomain: cookie.domain) ||
//                URL.isDuckDuckGo(domain: cookie.domain)
//        }
//
//        let dataStore = WKWebsiteDataStore.default()
//        dataStore.legacyClearingRemovingAllDataExceptCookies {
//            let cookieStore = dataStore.httpCookieStore
//
//            let cookieClearingSummary = WebStoreCookieClearingSummary()
//
//            cookieStore.getAllCookies { cookies in
//                let group = DispatchGroup()
//                let cookiesToRemove = cookies.filter {
//                    !keep($0)
//                }
//
//                let cookiesToKeep = cookies.filter {
//                    keep($0)
//                }
//
//                let protectedCookiesCount = cookies.count - cookiesToRemove.count
//
//                cookieClearingSummary.storeInitialCount = cookies.count
//                cookieClearingSummary.storeProtectedCount = protectedCookiesCount
//
//                for cookie in cookiesToRemove {
//                    group.enter()
//                    cookieStore.delete(cookie) {
//                        group.leave()
//                    }
//                }
//
//                DispatchQueue.global(qos: .userInitiated).async {
//                    let result = group.wait(timeout: .now() + 5)
//
//                    if result == .timedOut {
//                        cookieClearingSummary.didStoreDeletionTimeOut = true
//                        Pixel.fire(pixel: .cookieDeletionTimedOut, withAdditionalParameters: [
//                            PixelParameters.clearWebDataTimedOut: "1"
//                        ])
//                    }
//
//                    // Remove legacy HTTPCookieStorage cookies
//                    let storageCookies = HTTPCookieStorage.shared.cookies ?? []
//                    let storageCookiesToRemove = storageCookies.filter {
//                        !logins.isAllowed(cookieDomain: $0.domain) && !URL.isDuckDuckGo(domain: $0.domain)
//                    }
//
//                    let protectedStorageCookiesCount = storageCookies.count - storageCookiesToRemove.count
//
//                    cookieClearingSummary.storageInitialCount = storageCookies.count
//                    cookieClearingSummary.storageProtectedCount = protectedStorageCookiesCount
//
//                    for storageCookie in storageCookiesToRemove {
//                        HTTPCookieStorage.shared.deleteCookie(storageCookie)
//                    }
//
//                    self.removeObservationsData()
//
//                    self.validateLegacyClearing(for: cookieStore, summary: cookieClearingSummary, tabCountInfo: tabCountInfo)
//
//                    DispatchQueue.main.async {
//                        completion(cookiesToKeep)
//                    }
//                }
//            }
//        }
//
//    }
    // swiftlint:enable function_body_length

    private func validateLegacyClearing(for cookieStore: WKHTTPCookieStore, summary: WebStoreCookieClearingSummary, tabCountInfo: TabCountInfo?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            cookieStore.getAllCookies { cookiesAfterCleaning in
                let storageCookiesAfterCleaning = HTTPCookieStorage.shared.cookies ?? []
                
                summary.storeAfterDeletionCount = cookiesAfterCleaning.count
                summary.storageAfterDeletionCount = storageCookiesAfterCleaning.count
                
                let cookieStoreDiff = cookiesAfterCleaning.count - summary.storeProtectedCount
                let cookieStorageDiff = storageCookiesAfterCleaning.count - summary.storageProtectedCount
                
                summary.storeAfterDeletionDiffCount = cookieStoreDiff
                summary.storageAfterDeletionDiffCount = cookieStorageDiff
                
                if cookieStoreDiff + cookieStorageDiff > 0 {
                    os_log("Error removing cookies: %d cookies left in WKHTTPCookieStore, %d cookies left in HTTPCookieStorage",
                           log: .generalLog, type: .debug, cookieStoreDiff, cookieStorageDiff)
                    
                    var parameters = summary.makeDictionaryRepresentation()
                    
                    if let tabCountInfo = tabCountInfo {
                        parameters.merge(tabCountInfo.makeDictionaryRepresentation(), uniquingKeysWith: { _, new in new })
                    }
                    
                    Pixel.fire(pixel: .cookieDeletionLeftovers,
                               withAdditionalParameters: parameters)
                }
            }
        }
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

//extension WKHTTPCookieStore: WebCacheManagerCookieStore {
//        
//}

extension WKWebsiteDataStore {

    @MainActor
    public func preservedCookies(_ preservedLogins: PreserveLogins) async -> [HTTPCookie] {
        let allCookies = await self.httpCookieStore.allCookies()
        return allCookies.filter {
            URL.isDuckDuckGo(domain: $0.domain) || preservedLogins.isAllowed(cookieDomain: $0.domain)
        }
    }
//
//    public var cookieStore: WebCacheManagerCookieStore? {
//        return self.httpCookieStore
//    }

    public func legacyClearingRemovingAllDataExceptCookies(completion: @escaping () -> Void) {
        var types = WKWebsiteDataStore.allWebsiteDataTypes()

        // Force the HSTS, Media and Alt services cache to clear when using the Fire button.
        // https://github.com/WebKit/WebKit/blob/0f73b4d4350c707763146ff0501ab62425c902d6/Source/WebKit/UIProcess/API/Cocoa/WKWebsiteDataRecord.mm#L47
        types.insert("_WKWebsiteDataTypeHSTSCache")
        types.insert("_WKWebsiteDataTypeMediaKeys")
        types.insert("_WKWebsiteDataTypeAlternativeServices")
        types.insert("_WKWebsiteDataTypeSearchFieldRecentSearches")
        types.insert("_WKWebsiteDataTypeResourceLoadStatistics")
        types.insert("_WKWebsiteDataTypeCredentials")
        types.insert("_WKWebsiteDataTypeAdClickAttributions")
        types.insert("_WKWebsiteDataTypePrivateClickMeasurements")

        types.remove(WKWebsiteDataTypeCookies)

        removeData(ofTypes: types,
                   modifiedSince: Date.distantPast,
                   completionHandler: completion)
    }
    
}

final class WebStoreCookieClearingSummary {
    var storeInitialCount: Int = 0
    var storeProtectedCount: Int = 0
    var didStoreDeletionTimeOut: Bool = false
    var storageInitialCount: Int = 0
    var storageProtectedCount: Int = 0
    
    var storeAfterDeletionCount: Int = 0
    var storageAfterDeletionCount: Int = 0
    var storeAfterDeletionDiffCount: Int = 0
    var storageAfterDeletionDiffCount: Int = 0
    
    func makeDictionaryRepresentation() -> [String: String] {
        [PixelParameters.storeInitialCount: "\(storeInitialCount)",
         PixelParameters.storeProtectedCount: "\(storeProtectedCount)",
         PixelParameters.didStoreDeletionTimeOut: didStoreDeletionTimeOut ? "true" : "false",
         PixelParameters.storageInitialCount: "\(storageInitialCount)",
         PixelParameters.storageProtectedCount: "\(storageProtectedCount)",
         PixelParameters.storeAfterDeletionCount: "\(storeAfterDeletionCount)",
         PixelParameters.storageAfterDeletionCount: "\(storageAfterDeletionCount)",
         PixelParameters.storeAfterDeletionDiffCount: "\(storeAfterDeletionDiffCount)",
         PixelParameters.storageAfterDeletionDiffCount: "\(storageAfterDeletionDiffCount)"]
    }
}

public final class TabCountInfo {
    var tabsModelCount: Int = 0
    var tabControllerCacheCount: Int = 0
    
    public init() { }
        
    public init(tabsModelCount: Int, tabControllerCacheCount: Int) {
        self.tabsModelCount = tabsModelCount
        self.tabControllerCacheCount = tabControllerCacheCount
    }
    
    func makeDictionaryRepresentation() -> [String: String] {
        [PixelParameters.tabsModelCount: "\(tabsModelCount)",
         PixelParameters.tabControllerCacheCount: "\(tabControllerCacheCount)"]
    }
}

// swiftlint:enable file_length

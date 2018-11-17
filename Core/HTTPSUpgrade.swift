//
//  HTTPSUpgrade.swift
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

import Foundation

public class HTTPSUpgrade {
    
    private struct Constants {
        static let millisecondsPerSecond = 1000.0
    }
    
    public static let shared = HTTPSUpgrade()
    
    private let dataReloadLock = NSLock()
    private let store: HTTPSUpgradeStore
    private var bloomFilter: BloomFilterWrapper?
    
    init(store: HTTPSUpgradeStore = HTTPSUpgradePersistence()) {
        self.store = store
    }
    
    public func upgrade(url: URL) -> URL? {
        
        guard url.scheme == "http" else { return nil }
        
        if !isInUpgradeList(url: url) {
            return nil
        }
        
        let urlString = url.absoluteString
        return URL(string: urlString.replacingOccurrences(of: "http", with: "https", options: .caseInsensitive, range: urlString.range(of: "http")))
    }
    
    public func isInUpgradeList(url: URL) -> Bool {
        
        guard let host = url.host else { return false }

        if store.hasWhitelistedDomain(host) {
            Logger.log(text: "Site \(host) is in whitelist, not upgrading")
            return false
        }
        
        waitForAnyReloadsToComplete()
        
        guard let bloomFilter = bloomFilter else { return false }
        let startTimeMs = Date().timeIntervalSince1970 * Constants.millisecondsPerSecond
        let result = bloomFilter.contains(host)
        let endTimeMs = Date().timeIntervalSince1970 * Constants.millisecondsPerSecond
        Logger.log(text: "Site \(host) \(result ? "can" : "cannot") be upgraded. Lookup took \(endTimeMs - startTimeMs)ms")
        
        return result
    }
    
    private func waitForAnyReloadsToComplete() {
        // wait for lock (by locking and unlocking) before continuing
       dataReloadLock.lock()
       dataReloadLock.unlock()
    }
    
    public func loadDataAsync() {
        DispatchQueue.global(qos: .background).async {
            self.loadData()
        }
    }
    
    public func loadData() {
        if !dataReloadLock.try() {
            Logger.log(text: "Reload already in progress")
            return
        }
        bloomFilter = store.bloomFilter()
        dataReloadLock.unlock()
    
    }
}

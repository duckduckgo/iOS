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
    
    public static let shared = HTTPSUpgrade()
    
    private let dataReloadLock = NSLock()
    private let store: HTTPSUpgradeStore
    private var bloomFilter: BloomFilterWrapper?
    
    init(store: HTTPSUpgradeStore = HTTPSUpgradePersistence()) {
        self.store = store
    }
    
    func upgrade(url: URL) -> URL? {
        
        guard url.scheme == "http" else { return nil }
        guard let host = url.host else { return nil }
        
        if store.hasWhitelistedDomain(host) {
            Logger.log(text: "Site \(host) is in whitelist, not upgrading")
            return nil
        }
        
        waitForAnyReloadsToComplete()
        
        guard let bloomFilter = bloomFilter else { return nil }
        let startTime = Date().timeIntervalSince1970
        let result = bloomFilter.contains(host)
        let endTime = Date().timeIntervalSince1970
        Logger.log(text: "Site \(host) \(result ? "can" : "cannot") be upgraded. Lookup took \(endTime - startTime)ms")
        
        guard result else { return nil }
        let urlString = url.absoluteString
        return URL(string: urlString.replacingOccurrences(of: "http", with: "https", options: .caseInsensitive, range: urlString.range(of: "http")))
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

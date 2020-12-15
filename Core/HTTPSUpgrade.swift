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
import os.log

public class HTTPSUpgrade {

    public typealias UpgradeCheckCompletion = (Bool) -> Void
    public static let shared = HTTPSUpgrade()
    
    private let dataReloadLock = NSLock()
    private let store: HTTPSUpgradeStore
    private let appUrls: AppUrls
    private var bloomFilter: BloomFilterWrapper?
    
    init(store: HTTPSUpgradeStore = HTTPSUpgradePersistence(), appUrls: AppUrls = AppUrls()) {
        self.store = store
        self.appUrls = appUrls
    }

    public func isUgradeable(url: URL, completion: @escaping UpgradeCheckCompletion) {
        
        guard url.scheme == "http" else {
            Pixel.fire(pixel: .httpsNoLookup)
            completion(false)
            return
        }
        
        guard let host = url.host else {
            Pixel.fire(pixel: .httpsNoLookup)
            completion(false)
            return
        }
        
        if store.shouldExcludeDomain(host) {
            Pixel.fire(pixel: .httpsNoLookup)
            completion(false)
            return
        }
        
        waitForAnyReloadsToComplete()
        let isUpgradable = isInUpgradeList(host: host)
        os_log("%s %s upgradable", log: generalLog, type: .debug, host, isUpgradable ? "is" : "is not")
        Pixel.fire(pixel: isUpgradable ? .httpsLocalUpgrade : .httpsNoUpgrade)
        completion(isUpgradable)
           
    }
    
    private func isInUpgradeList(host: String) -> Bool {
        guard let bloomFilter = bloomFilter else { return false }
        return bloomFilter.contains(host)
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
            os_log("Reload already in progress", log: generalLog, type: .debug)
            return
        }
        bloomFilter = store.bloomFilter()
        dataReloadLock.unlock()
    }
}

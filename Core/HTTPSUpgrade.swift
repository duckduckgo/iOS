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
    typealias ServiceCompletion = (ServiceResult) -> Void
    typealias ServiceResult = (isInList: Bool, isCached: Bool)
    
    private struct Constants {
        static let millisecondsPerSecond = 1000.0
    }
    
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
        
        guard store.shouldUpgradeDomain(host) else {
            Pixel.fire(pixel: .httpsNoLookup)
            completion(false)
            return
        }
        
        let isLocallyUpgradable = !isLocalListReloading() && isInLocalUpgradeList(host: host)
        os_log("%s %s locally upgradable", log: generalLog, type: .debug, host, isLocallyUpgradable ? "is" : "is not")
        if  isLocallyUpgradable {
            Pixel.fire(pixel: .httpsLocalUpgrade)
            completion(true)
            return
        }
        
        isInServiceUpgradeList(host: host) { result in
            os_log("%s %s service upgradable", log: generalLog, type: .debug, host, result.isInList ? "is" : "is not")
            if result.isInList {
                Pixel.fire(pixel: result.isCached ? .httpsServiceCacheUpdgrade : .httpsServiceRequestUpgrade)
                completion(true)
            } else {
                Pixel.fire(pixel: result.isCached ? .httpsServiceCacheNoUpdgrade : .httpsServiceRequestNoUpdgrade)
                completion(false)
            }
        }
    }
    
    private func isInLocalUpgradeList(host: String) -> Bool {
        guard let bloomFilter = bloomFilter else { return false }
        return bloomFilter.contains(host)
    }
    
    private func isInServiceUpgradeList(host: String, completion: @escaping ServiceCompletion) {
        let sha1Host = host.sha1
        let partialSha1Host = String(sha1Host.prefix(4))
        let url = appUrls.httpsLookupServiceUrl(forPartialHost: partialSha1Host)
        let serviceRequest = APIRequest.urlRequestFor(url: url, timeoutInterval: 10.0)
        let cachedResponse = URLCache.shared.cachedResponse(for: serviceRequest)?.response as? HTTPURLResponse
        
        APIRequest.request(url: url,
                           timeoutInterval: 10,
                           callBackOnMainThread: true) { (response, _) in
            
            guard let httpResponse = response?.urlResponse as? HTTPURLResponse, let data = response?.data else {
                completion((isInList: false, isCached: false))
                return
            }
            
            let result = try? JSONDecoder().decode([String].self, from: data)
            let isCached = isResponseFromCache(httpResponse, cachedResponse: cachedResponse)
            let isInList = result?.contains(sha1Host) ?? false
            completion((isInList: isInList, isCached: isCached))
        }
    }
    
    private func isLocalListReloading() -> Bool {
        if !dataReloadLock.try() {
            return true
        }
        dataReloadLock.unlock()
        return false
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

private func isResponseFromCache(_ response: HTTPURLResponse?, cachedResponse: HTTPURLResponse?) -> Bool {
    guard let responseHeaders = response?.allHeaderFields as? [String: String] else { return false }
    guard let cachedHeaders = cachedResponse?.allHeaderFields as? [String: String] else { return false }
    return responseHeaders == cachedHeaders
}

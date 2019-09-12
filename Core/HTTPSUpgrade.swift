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
import Alamofire

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
        
        guard !store.hasWhitelistedDomain(host) else {
            Pixel.fire(pixel: .httpsNoLookup)
            completion(false)
            return
        }
        
        let isLocallyUpgradable = !isLocalListReloading() && isInLocalUpgradeList(host: host)
        Logger.log(text: "\(host) \(isLocallyUpgradable ? "is" : "is not") locally upgradable")
        if  isLocallyUpgradable {
            Pixel.fire(pixel: .httpsLocalUpgrade)
            completion(true)
            return
        }
        
        isInServiceUpgradeList(host: host) { result in
            Logger.log(text: "\(host) \(result.isInList ? "is" : "is not") service upgradable")
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
        var serviceRequest = URLRequest(url: appUrls.httpsLookupServiceUrl(forPartialHost: partialSha1Host))
        serviceRequest.allHTTPHeaderFields = APIHeaders().defaultHeaders
        serviceRequest.timeoutInterval = 10

        let cachedResponse = URLCache.shared.cachedResponse(for: serviceRequest)?.response as? HTTPURLResponse
        Alamofire.request(serviceRequest).validate(statusCode: 200..<300).response { response in
            if let data = response.data {
                let result = try? JSONDecoder().decode([String].self, from: data)
                let isCached = isResponseFromCache(response.response, cachedResponse: cachedResponse)
                let isInList = result?.contains(sha1Host) ?? false
                completion((isInList: isInList, isCached: isCached))
            } else {
                completion((isInList: false, isCached: false))
            }
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
            Logger.log(text: "Reload already in progress")
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

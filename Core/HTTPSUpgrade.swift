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
    
    public func upgrade(url: URL) -> URL? {
        
        guard url.scheme == "http" else {
            Pixel.fire(pixel: .httpsNoLookup)
            return nil
        }
        
        guard let host = url.host else {
            Pixel.fire(pixel: .httpsNoLookup)
            return nil
        }
        
        if store.hasWhitelistedDomain(host) {
            Pixel.fire(pixel: .httpsNoLookup)
            return nil
        }
        
        let isLocallyUpgradable = !isLocalListReloading() && isInLocalUpgradeList(host: host)
        Logger.log(text: "\(host) is \(isLocallyUpgradable ? "" : "not") locally upgradable")
        if  isLocallyUpgradable {
            Pixel.fire(pixel: .httpsLocalLookup)
            return url.upgradeToHttps()
        }
        
        let httpsServiceResult = isInServiceUpgradeList(host: host)
        Pixel.fire(pixel: httpsServiceResult.isCached ? .httpsServiceCacheLookup : .httpsServiceRequestLookup)
        Logger.log(text: "\(host) is \(httpsServiceResult.isInList ? "" : "not") service upgradable")
        if httpsServiceResult.isInList {
            return url.upgradeToHttps()
        }
        
        //TODO consider pixel param for hit versus miss
        return nil
    }
    
    private func isInLocalUpgradeList(host: String) -> Bool {
        guard let bloomFilter = bloomFilter else { return false }
        return bloomFilter.contains(host)
    }
    
    private func isInServiceUpgradeList(host: String, completion) -> (isInList: Bool, isCached: Bool) {
    
        let sha1Host = host.sha1
        let partialSha1Host = String(sha1Host.prefix(4))
        var serviceRequest = URLRequest(url: appUrls.httpsLookupServiceUrl(forPartialHost: partialSha1Host))
        serviceRequest.allHTTPHeaderFields = APIHeaders().defaultHeaders
        
        var shouldUpgrade = false
        let isCached = URLCache.shared.cachedResponse(for: serviceRequest) != nil
        
        Alamofire.request(serviceRequest).validate(statusCode: 200..<300).response { response in
            
            if let data = response.data {
                let result = try? JSONDecoder().decode([String].self, from: data)
                shouldUpgrade = result?.contains(sha1Host) ?? false
            }
            
        }
        return (shouldUpgrade, isCached)
    }
    
    private func isLocalListReloading() -> Bool {
        return dataReloadLock.try()
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

extension URL {
    func upgradeToHttps() -> URL? {
        let urlString = absoluteString
        return URL(string: urlString.replacingOccurrences(of: "http", with: "https", options: .caseInsensitive, range: urlString.range(of: "http")))
    }
}

//
//  StorageCache.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

protocol StorageCacheUpdating {
    
    func update(_ configuration: ContentBlockerRequest.Configuration, with data: Any, etag: String?) -> Bool
}

public class StorageCache: StorageCacheUpdating {
    
    public let fileStore = FileStore()
    public let httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()
    
    public let protectionStore: ContentBlockerProtectionStore = ContentBlockerProtectionUserDefaults()
    
    // Read only
    public let tld: TLD
    public let termsOfServiceStore: TermsOfServiceStore
    
    public init() {
        tld = TLD()
        termsOfServiceStore = EmbeddedTermsOfServiceStore()
        
        // Remove legacy data
        _ = fileStore.removeData(forFile: "temporaryUnprotectedSites")
    }
    
    public init(tld: TLD, termsOfServiceStore: TermsOfServiceStore) {
        self.tld = tld
        self.termsOfServiceStore = termsOfServiceStore
        
        // Remove legacy data
        _ = fileStore.removeData(forFile: "temporaryUnprotectedSites")
    }
    
    func update(_ configuration: ContentBlockerRequest.Configuration, with data: Any, etag: String?) -> Bool {
        switch configuration {
        case .httpsExcludedDomains:
            guard let excludedDomains = data as? [String] else { return false }
            return httpsUpgradeStore.persistExcludedDomains(excludedDomains)
            
        case .httpsBloomFilter:
            guard let bloomFilter = data as? (spec: HTTPSBloomFilterSpecification, data: Data) else { return false }
            let result = httpsUpgradeStore.persistBloomFilter(specification: bloomFilter.spec, data: bloomFilter.data)
            HTTPSUpgrade.shared.loadData()
            return result
            
        case .surrogates:
            return fileStore.persist(data as? Data, forConfiguration: configuration)
            
        case .trackerDataSet:
            if fileStore.persist(data as? Data, forConfiguration: configuration),
               TrackerDataManager.shared.reload(etag: etag) == .downloaded {
                return true
            } else {
                Pixel.fire(pixel: .trackerDataReloadFailed)
            }
            return false
            
        case .privacyConfiguration:
            if fileStore.persist(data as? Data, forConfiguration: configuration),
               PrivacyConfigurationManager.shared.reload(etag: etag) == .downloaded {
                return true
            } else {
                Pixel.fire(pixel: .privacyConfigurationReloadFailed)
            }
            return false

        case .httpsBloomFilterSpec:
            return false
            
        }
    }
}

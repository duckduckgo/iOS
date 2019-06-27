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

public class StorageCache {
    
    let easylistStore = EasylistStore()
    let surrogateStore = SurrogateStore()
    
    public let disconnectMeStore = DisconnectMeStore()
    public let httpsUpgradeStore: HTTPSUpgradeStore = HTTPSUpgradePersistence()
    public let entityMappingStore: EntityMappingStore = DownloadedEntityMappingStore()
    public var entityMapping: EntityMapping
    
    public let configuration: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()
    
    // Read only
    public let tld: TLD
    public let termsOfServiceStore: TermsOfServiceStore
    public let prevalenceStore: PrevalenceStore
    
    public init() {
        entityMapping = EntityMapping(store: entityMappingStore)
        tld = TLD()
        termsOfServiceStore = EmbeddedTermsOfServiceStore()
        prevalenceStore = EmbeddedPrevalenceStore()
    }
    
    public init(tld: TLD, termsOfServiceStore: TermsOfServiceStore, prevalenceStore: PrevalenceStore) {
        entityMapping = EntityMapping(store: entityMappingStore)
        self.tld = tld
        self.termsOfServiceStore = termsOfServiceStore
        self.prevalenceStore = prevalenceStore
    }
    
    public var hasData: Bool {
        return disconnectMeStore.hasData && easylistStore.hasData
    }
    
    internal func update(with newData: ContentBlockerLoader.DataStore) {
        for (config, data) in newData {
            update(config, with: data)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func update(_ configuration: ContentBlockerRequest.Configuration, with data: Any) {
        switch configuration {
            
        case .trackersWhitelist:
            guard let data = data as? Data else { return }
            easylistStore.persistEasylistWhitelist(data: data)
            
        case .disconnectMe:
            guard let data = data as? Data else { return }
            try? disconnectMeStore.persist(data: data)
            
        case .httpsWhitelist:
            guard let whitelist = data as? [String] else { return }
            httpsUpgradeStore.persistWhitelist(domains: whitelist)
            
        case .httpsBloomFilter:
            guard let bloomFilter = data as? (spec: HTTPSBloomFilterSpecification, data: Data) else { return }
            _ = httpsUpgradeStore.persistBloomFilter(specification: bloomFilter.spec, data: bloomFilter.data)
            HTTPSUpgrade.shared.loadData()
            
        case .surrogates:
            guard let data = data as? Data else { return }
            surrogateStore.parseAndPersist(data: data)
            
        case .entitylist:
            guard let data = data as? Data else { return }
            entityMappingStore.persist(data: data)
            entityMapping = EntityMapping(store: entityMappingStore)
            
        default:
            return
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

//
//  PrivacyFeatures.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import BrowserServicesKit
import Common

public final class PrivacyFeatures {

    private static var bloomFilterDataURL: URL {
        let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: ContentBlockerStoreConstants.groupName)
        return path!.appendingPathComponent("HttpsBloomFilter.bin")
    }
    private static var embeddedBloomFilterResources: EmbeddedBloomFilterResources {
        EmbeddedBloomFilterResources(bloomSpecification: Bundle.core.url(forResource: "httpsMobileV2BloomSpec", withExtension: "json")!,
                                     bloomFilter: Bundle.core.url(forResource: "httpsMobileV2Bloom", withExtension: "bin")!,
                                     excludedDomains: Bundle.core.url(forResource: "httpsMobileV2FalsePositives", withExtension: "json")!)
    }
    private static let httpsUpgradeDebugEvents = EventMapping<AppHTTPSUpgradeStore.ErrorEvents> { event, error, parameters, onComplete in
        let domainEvent: Pixel.Event
        switch event {
        case .dbSaveBloomFilterError:
            domainEvent = .dbSaveBloomFilterError
        case .dbSaveExcludedHTTPSDomainsError:
            domainEvent = .dbSaveExcludedHTTPSDomainsError
        }

        if let error {
            Pixel.fire(pixel: domainEvent, error: error, withAdditionalParameters: parameters ?? [:], onComplete: onComplete)
        } else {
            Pixel.fire(pixel: domainEvent, withAdditionalParameters: parameters ?? [:], onComplete: onComplete)
        }
    }
    private static var httpsUpgradeStore: AppHTTPSUpgradeStore {
        AppHTTPSUpgradeStore(database: Database.shared,
                             bloomFilterDataURL: bloomFilterDataURL,
                             embeddedResources: embeddedBloomFilterResources,
                             errorEvents: httpsUpgradeDebugEvents)
    }

    public static let httpsUpgrade = HTTPSUpgrade(store: httpsUpgradeStore, privacyManager: ContentBlocking.shared.privacyConfigurationManager)
    
}

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
import os.log

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
        let dailyAndCount: Bool

        switch event {
        case .dbSaveBloomFilterError:
            domainEvent = .dbSaveBloomFilterError
            dailyAndCount = true
        case .dbSaveExcludedHTTPSDomainsError:
            domainEvent = .dbSaveExcludedHTTPSDomainsError
            dailyAndCount = false
        }

        if dailyAndCount {
            DailyPixel.fireDailyAndCount(pixel: domainEvent,
                                         pixelNameSuffixes: DailyPixel.Constant.legacyDailyPixelSuffixes,
                                         error: error,
                                         withAdditionalParameters: parameters ?? [:],
                                         onCountComplete: onComplete)
        } else {
            Pixel.fire(pixel: domainEvent, error: error, withAdditionalParameters: parameters ?? [:], onComplete: onComplete)
        }
    }
    private static var httpsUpgradeStore: AppHTTPSUpgradeStore {
        AppHTTPSUpgradeStore(database: Database.shared,
                             bloomFilterDataURL: bloomFilterDataURL,
                             embeddedResources: embeddedBloomFilterResources,
                             errorEvents: httpsUpgradeDebugEvents,
                             logger: Logger.general)
    }

    public static let httpsUpgrade = HTTPSUpgrade(store: httpsUpgradeStore, privacyManager: ContentBlocking.shared.privacyConfigurationManager,
                                                  logger: Logger.general)

}

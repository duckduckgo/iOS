//
//  WebCacheManager.swift
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


import WebKit

public class WebCacheManager {

    private struct Constants {
        static let internalCache = "duckduckgo.com"
    }
    
    private static var allData: Set<String> {
        return WKWebsiteDataStore.allWebsiteDataTypes()
    }
    
    private static var dataStore: WKWebsiteDataStore {
        return WKWebsiteDataStore.default()
    }
    
    /**
     Provides a summary of the external (non-duckduckgo) cached data
     */
    public static func summary(completionHandler: @escaping (_ summary: WebCacheSummary) -> Void) {
         dataStore.fetchDataRecords(ofTypes: allData, completionHandler: { records in
            let count = records.reduce(0) { (count, record) in
                if record.displayName == Constants.internalCache {
                    return count
                }
                return count + record.dataTypes.count
            }
            Logger.log(text: String(format: "Web cache retrieved, there are %d items in the cache", count))
            completionHandler(WebCacheSummary(count: count))
        })
    }
    
    /**
     Clears the cache of all external (non-duckduckgo) data
     */
    public static func clear(completionHandler: @escaping () -> Void) {
        dataStore.fetchDataRecords(ofTypes: allData) { records in
            let externalRecords = records.filter { $0.displayName != Constants.internalCache }
            dataStore.removeData(ofTypes: allData, for: externalRecords) {
                Logger.log(text: "External cache cleared")
                completionHandler()
            }
        }
    }
}
    

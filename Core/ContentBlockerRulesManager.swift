//
//  ContentBlockerRulesManager.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import WebKit
import os.log

public class ContentBlockerRulesManager {
    
    public static let shared = ContentBlockerRulesManager()
    
    public var blockingRules: WKContentRuleList?

    private init() {}

    public func compileRules(completion: ((WKContentRuleList?) -> Void)?) {
        guard let trackerData = TrackerDataManager.shared.trackerData else {
            completion?(nil)
            return
        }

        let storageCache = StorageCacheProvider().current
        let unprotectedSites = UnprotectedSitesManager().domains
        let tempUnprotectedDomains = storageCache.fileStore.loadAsArray(forConfiguration: .temporaryUnprotectedSites)
            .filter { !$0.trimWhitespace().isEmpty }

        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: unprotectedSites,
                                                                                    andTemporaryUnprotectedDomains: tempUnprotectedDomains)
        
        guard let data = try? JSONEncoder().encode(rules) else {
            os_log("Failed to encode content blocking rules", log: generalLog, type: .error)
            return
        }
        
        if let store = WKContentRuleListStore.default() {
            let ruleList = String(data: data, encoding: .utf8)!
            store.compileContentRuleList(forIdentifier: "tds", encodedContentRuleList: ruleList) { [weak self] ruleList, error in
                self?.blockingRules = ruleList
                completion?(ruleList)
                if let error = error {
                    os_log("Failed to compile rules %{public}s", log: generalLog, type: .error, error.localizedDescription)
                }
            }
        } else {
            os_log("Failed to access the default WKContentRuleListStore for rules compiliation checking", log: generalLog, type: .error)
        }
    }
    
}

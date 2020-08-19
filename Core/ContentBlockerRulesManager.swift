//
//  ContentBlockerRulesBuilder.swift
//  DuckDuckGo Privacy Essentials
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
    
    static let shared = ContentBlockerRulesManager()
    
    private var trackerData: TrackerData!
    
    public var blockingRules: WKContentRuleList?
    
    init() {
        trackerData = TrackerDataManager.shared.trackerData
    }
    
    func compileRules(completion: ((WKContentRuleList?) -> Void)?) {
        let unprotectedSites = UnprotectedSitesManager().domains
        
        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: nil,
                                                                                    andTemporaryUnprotectedDomains: unprotectedSites)
        
        guard let data = try? JSONEncoder().encode(rules) else {
            os_log("Failed to encode content blocking rules", log: generalLog, type: .error)
            return
        }
        
        if let store = WKContentRuleListStore.default() {
            store.compileContentRuleList(forIdentifier: "XXX", encodedContentRuleList: String(data: data, encoding: .utf8)!) { [weak self] ruleList, error in
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

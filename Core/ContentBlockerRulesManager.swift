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
import TrackerRadarKit

public class ContentBlockerRulesManager {

    private static let rulesIdentifier = "tds"

    public static let shared = ContentBlockerRulesManager()

    private init() {}

    private var isCompilingRules: Bool = false

    public func recompile() {
        guard let store = WKContentRuleListStore.default() else {
            fatalError("Failed to access the default WKContentRuleListStore")
        }

        // The `compiledRules` function has this check internally, but it needs to be checked here so that `removeContentRuleList` doesn't get
        // called accidentally.
        guard !isCompilingRules else {
            return
        }

        DispatchQueue.global(qos: .background).async {
            store.removeContentRuleList(forIdentifier: Self.rulesIdentifier) { _ in
                DispatchQueue.global(qos: .background).async {
                    self.compiledRules { _ in
                        NotificationCenter.default.post(name: ContentBlockerProtectionChangedNotification.name, object: nil)
                    }
                }
            }
        }
    }

    /// Return compiled rules for the current content blocking configuration.  This may return a precompiled rule set.
    public func compiledRules(completion: ((WKContentRuleList?) -> Void)?) {
        guard !isCompilingRules else {
            completion?(nil)
            return
        }

        isCompilingRules = true

        guard let store = WKContentRuleListStore.default() else {
            fatalError("Failed to access the default WKContentRuleListStore for rules compiliation checking")
        }

        store.lookUpContentRuleList(forIdentifier: Self.rulesIdentifier) { list, _ in
            guard list == nil else {
                DispatchQueue.main.async {
                    self.isCompilingRules = false
                    completion?(list)
                }

                return
            }

            DispatchQueue.global(qos: .background).async {
                store.compileRules(withIdentifier: Self.rulesIdentifier) { ruleList in
                    self.isCompilingRules = false
                    completion?(ruleList)
                }
            }
        }
    }

}

fileprivate extension WKContentRuleListStore {

    func compileRules(withIdentifier rulesIdentifier: String, completion: ((WKContentRuleList?) -> Void)?) {

        guard let trackerData = TrackerDataManager.shared.trackerData else {
            DispatchQueue.main.async {
                completion?(nil)
            }

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

        let ruleList = String(data: data, encoding: .utf8)!
        compileContentRuleList(forIdentifier: rulesIdentifier, encodedContentRuleList: ruleList) { ruleList, error in
            DispatchQueue.main.async {
                completion?(ruleList)
            }

            if let error = error {
                os_log("Failed to compile rules %{public}s", log: generalLog, type: .error, error.localizedDescription)
            }
        }

    }

}

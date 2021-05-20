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
    
    public typealias CompletionBlock = (WKContentRuleList?) -> Void
    
    enum State {
        case idle
        case recompiling
        case recompilingAndScheduled
    }

    private static let rulesIdentifier = "tds"

    public static let shared = ContentBlockerRulesManager()

    private init() {}
    
    /**
     Variables protected by this lock:
      - state
      - currentRules
     */
    private let lock = NSLock()
    
    private var state = State.idle
    
    private var _currentRules: WKContentRuleList?
    public private(set) var currentRules: WKContentRuleList? {
        get {
            lock.lock(); defer { lock.unlock() }
            return _currentRules
        }
        set {
            lock.lock()
            self._currentRules = newValue
            lock.unlock()
        }
    }

    public func recompile() {
        guard let store = WKContentRuleListStore.default() else {
            fatalError("Failed to access the default WKContentRuleListStore")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            store.removeContentRuleList(forIdentifier: Self.rulesIdentifier) { _ in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.requestCompilation()
                }
            }
        }
    }

    static func generateIdentifier(from cache: StorageCache) -> String {
        // TODO combine:
        //  - TDS etag
        //  - TMP Lists etag
        //  - Add UID to Unprotected Domains state / cosider hashing!
        return rulesIdentifier
    }

    private func requestCompilation() {
        os_log("Requesting compilation...", log: generalLog, type: .default)
        
        lock.lock()
        guard state == .idle else {
            if state == .recompiling {
                // Schedule reload
                state = .recompilingAndScheduled
            }
            lock.unlock()
            return
        }
        
        state = .recompiling
        lock.unlock()
        
        // TODO: refactor it so it always returns either downloaded or built-in list
        guard let trackerData = TrackerDataManager.shared.trackerData else {
            return
        }
        
        compile(trackerData: trackerData)
    }
        
    private func compile(trackerData: TrackerData) {
        os_log("Starting CBR compilation", log: generalLog, type: .default)

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
        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: Self.generateIdentifier(from: storageCache),
                                     encodedContentRuleList: ruleList) { ruleList, error in
            
            if let ruleList = ruleList {
                self.compilationSucceeded(with: ruleList)
            } else if let error = error {
                self.compilationFailed(with: error)
            } else {
                // TODO: assertion
            }
        }

    }
    
    private func compilationFailed(with error: Error) {
        os_log("Failed to compile rules %{public}s", log: generalLog, type: .error, error.localizedDescription)
        
        lock.lock()
                
        if self.state == .recompilingAndScheduled, let trackerData = TrackerDataManager.shared.trackerData {
            // Recompilation is scheduled - it may fix the problem
            DispatchQueue.global(qos: .userInitiated).async {
                self.compile(trackerData: trackerData)
            }
        } else {
            // Fallback to built - in tracker data
            
        }
        
        state = .recompiling
        lock.unlock()
    }
    
    private func compilationSucceeded(with ruleList: WKContentRuleList) {
        os_log("Rules compiled", log: generalLog, type: .default)
        lock.lock()
        
        _currentRules = ruleList
        
        if self.state == .recompilingAndScheduled, let trackerData = TrackerDataManager.shared.trackerData {
            // New work has been scheduled - prepare for execution.
            DispatchQueue.global(qos: .userInitiated).async {
                self.compile(trackerData: trackerData)
            }
            
            state = .recompiling
        } else {
            state = .idle
        }
        
        lock.unlock()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ContentBlockerProtectionChangedNotification.name, object: nil)
        }
    }

}

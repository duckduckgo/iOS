//
//  ContentBlockerRulesUserScript.swift
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

import UIKit
import WebKit
import TrackerRadarKit

public class ContentBlockerRulesUserScript: NSObject, UserScript {
    
    struct ContentBlockerKey {
        static let url = "url"
        static let resourceType = "resourceType"
        static let blocked = "blocked"
        static let pageUrl = "pageUrl"
    }
    
    public var source: String {
        let unprotectedDomains = (UnprotectedSitesManager().domains?.joined(separator: "\n") ?? "")
            + "\n"
            + (storageCache?.fileStore.loadAsString(forConfiguration: .temporaryUnprotectedSites) ?? "")
        
        return loadJS("contentblockerrules", withReplacements: [
            "${unprotectedDomains}": unprotectedDomains
        ])
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "processRule" ]
    
    public weak var delegate: ContentBlockerUserScriptDelegate?
    public weak var storageCache: StorageCache?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let delegate = delegate else { return }
        guard delegate.contentBlockerUserScriptShouldProcessTrackers(self) else { return }
        
        guard let dict = message.body as? [String: Any] else { return }
        guard let blocked = dict[ContentBlockerKey.blocked] as? Bool else { return }
        guard let trackerUrlString = dict[ContentBlockerKey.url] as? String else { return }
        guard let pageUrlStr = dict[ContentBlockerKey.pageUrl] as? String else { return }
        
        if let tracker = trackerFromUrl(trackerUrlString, pageUrlString: pageUrlStr, blockable: blocked) {
            guard let pageUrl = URL(string: pageUrlStr),
               let pageHost = pageUrl.host,
               let pageEntity = TrackerDataManager.shared.findEntity(forHost: pageHost) else {
                delegate.contentBlockerUserScript(self, detectedTracker: tracker)
                return
            }
            
            if pageEntity.displayName != tracker.entity?.displayName {
                delegate.contentBlockerUserScript(self, detectedTracker: tracker)
            }
        }
    }
    
    private func trackerFromUrl(_ trackerUrlString: String, pageUrlString: String, blockable: Bool) -> DetectedTracker? {
        guard let knownTracker = TrackerDataManager.shared.findTracker(forUrl: trackerUrlString) else {
            return nil
        }

        let blocked: Bool

        if knownTracker.hasExemption(for: trackerUrlString, pageUrlString: pageUrlString) {
            blocked = false
        } else {
            blocked = blockable
        }

        if let entity = TrackerDataManager.shared.findEntity(byName: knownTracker.owner?.name ?? "") {
            return DetectedTracker(url: trackerUrlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
        }
        
        return nil
    }
}

fileprivate extension KnownTracker {

    func hasExemption(for trackerUrlString: String, pageUrlString: String) -> Bool {
        let range = NSRange(location: 0, length: trackerUrlString.utf16.count)

        // For each rule, where the rule is set to ignore a pattern:
        //
        // 1. Create a regular expression from the rule string
        // 2. Check if the rule matches the URL string
        // 3. If it matches, check if the rule contains an exemption for the page's host value
        //    3a. If exempt, continue checking rules
        //    3b. If not exempt, return true

        for rule in rules ?? [] where rule.action == .ignore {
            guard let pattern = rule.rule,
                  let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            if regex.firstMatch(in: trackerUrlString, options: [], range: range) != nil {
                if let host = URL(string: pageUrlString)?.host, rule.exceptions?.domains?.contains(host) == true {
                    continue
                } else {
                    return true
                }
            }
        }

        return false
    }

}

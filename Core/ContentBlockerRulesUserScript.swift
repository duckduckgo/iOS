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
import BrowserServicesKit

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
        
        return Self.loadJS("contentblockerrules", from: Bundle.core, withReplacements: [
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
        guard let pageUrlStr = message.webView?.url?.absoluteString ?? dict[ContentBlockerKey.pageUrl] as? String else { return }
        
        if let tracker = trackerFromUrl(trackerUrlString, pageUrlString: pageUrlStr, potentiallyBlocked: blocked) {
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
    
    private func trackerFromUrl(_ trackerUrlString: String, pageUrlString: String, potentiallyBlocked: Bool) -> DetectedTracker? {
        guard let knownTracker = TrackerDataManager.shared.findTracker(forUrl: trackerUrlString) else {
            return nil
        }

        let blocked: Bool
        
        let storageCache = StorageCacheProvider().current
        let unprotectedSites = UnprotectedSitesManager().domains
        let tempUnprotectedDomains = storageCache.fileStore.loadAsArray(forConfiguration: .temporaryUnprotectedSites)
            .filter { !$0.trimWhitespace().isEmpty }

        if knownTracker.hasExemption(for: trackerUrlString, pageUrlString: pageUrlString) {
            blocked = false
        } else if let pageDomain = URL(string: pageUrlString),
                  let pageHost = pageDomain.host,
                  let unprotectedSites = unprotectedSites {
            if unprotectedSites.contains(pageHost) || tempUnprotectedDomains.contains(pageHost) {
                blocked = false
            } else {
                blocked = potentiallyBlocked
            }
        } else {
            blocked = potentiallyBlocked
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

        for rule in rules ?? [] where rule.action == .ignore {
            guard let pattern = rule.rule,
                  let host = URL(string: pageUrlString)?.host,
                  rule.exceptions?.domains?.contains(host) ?? false == false,
                  let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }

            if regex.firstMatch(in: trackerUrlString, options: [], range: range) != nil {
                return true
            }
        }

        return false
    }

}

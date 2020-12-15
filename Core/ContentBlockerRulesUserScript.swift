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
        guard let urlString = dict[ContentBlockerKey.url] as? String else { return }
        guard let pageUrlStr = dict[ContentBlockerKey.pageUrl] as? String else { return }
        
        if let tracker = trackerFromUrl(urlString, blocked: blocked) {
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
    
    private func trackerFromUrl(_ urlString: String, blocked: Bool) -> DetectedTracker? {
        let knownTracker = TrackerDataManager.shared.findTracker(forUrl: urlString)
        if let entity = TrackerDataManager.shared.findEntity(byName: knownTracker?.owner?.name ?? "") {
            return DetectedTracker(url: urlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
        }
        
        return nil
    }
}

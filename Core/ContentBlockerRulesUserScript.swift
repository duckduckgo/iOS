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
        let unprotectedDomains = UnprotectedSitesManager().domains.joined(separator: "\n")
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
    public weak var storageCache: StorageCache? {
        didSet {
            temporaryUnprotectedDomains = storageCache?.fileStore.loadAsArray(forConfiguration: .temporaryUnprotectedSites)
                .filter { !$0.trimWhitespace().isEmpty } ?? []
        }
    }

    var temporaryUnprotectedDomains = [String]()

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let delegate = delegate else { return }
        guard delegate.contentBlockerUserScriptShouldProcessTrackers(self) else { return }
        
        guard let dict = message.body as? [String: Any] else { return }
        
        // False if domain is in unprotected list
        guard let blocked = dict[ContentBlockerKey.blocked] as? Bool else { return }
        guard let trackerUrlString = dict[ContentBlockerKey.url] as? String else { return }
        let resourceType = (dict[ContentBlockerKey.resourceType] as? String) ?? "unknown"
        guard let pageUrlStr = dict[ContentBlockerKey.pageUrl] as? String else { return }
        
        guard let currentTrackerData = ContentBlockerRulesManager.shared.currentRules?.trackerData else {
            return
        }
        
        let resolver = TrackerResolver(tds: currentTrackerData,
                                       unprotectedSites: UnprotectedSitesManager().domains,
                                       tempList: temporaryUnprotectedDomains)
        
        if let tracker = resolver.trackerFromUrl(trackerUrlString,
                                                 pageUrlString: pageUrlStr,
                                                 resourceType: resourceType,
                                                 potentiallyBlocked: blocked) {
            delegate.contentBlockerUserScript(self, detectedTracker: tracker)
        }
    }
}

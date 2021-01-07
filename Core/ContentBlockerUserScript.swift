//
//  ContentBlockerUserScript.swift
//  Core
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

import WebKit
import os

public protocol ContentBlockerUserScriptDelegate: NSObjectProtocol {
    
    func contentBlockerUserScriptShouldProcessTrackers(_ script: UserScript) -> Bool
    func contentBlockerUserScript(_ script: ContentBlockerUserScript, detectedTracker tracker: DetectedTracker, withSurrogate host: String)
    func contentBlockerUserScript(_ script: UserScript, detectedTracker tracker: DetectedTracker)

}

public class ContentBlockerUserScript: NSObject, UserScript {
    
    struct TrackerDetectedKey {
        static let protectionId = "protectionId"
        static let blocked = "blocked"
        static let networkName = "networkName"
        static let url = "url"
        static let isSurrogate = "isSurrogate"
    }

    public var source: String {
        let unprotectedDomains = (UnprotectedSitesManager().domains?.joined(separator: "\n") ?? "")
            + "\n"
            + (storageCache?.fileStore.loadAsString(forConfiguration: .temporaryUnprotectedSites) ?? "")
        let surrogates = storageCache?.fileStore.loadAsString(forConfiguration: .surrogates) ?? ""

        // Encode whatever the tracker data manager is using to ensure it's in sync and because we know it will work
        let trackerData = TrackerDataManager.shared.encodedTrackerData!
        
        return loadJS("contentblocker", withReplacements: [
            "${unprotectedDomains}": unprotectedDomains,
            "${trackerData}": trackerData,
            "${surrogates}": surrogates
        ])
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "trackerDetectedMessage" ]
    
    public weak var storageCache: StorageCache?
    public weak var delegate: ContentBlockerUserScriptDelegate?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        os_log("trackerDetected %s", log: generalLog, type: .debug, String(describing: message.body))

        guard let delegate = delegate else { return }
        guard delegate.contentBlockerUserScriptShouldProcessTrackers(self) else { return }
        
        guard let dict = message.body as? [String: Any] else { return }
        guard let blocked = dict[TrackerDetectedKey.blocked] as? Bool else { return }
        guard let urlString = dict[TrackerDetectedKey.url] as? String else { return }

        let tracker = trackerFromUrl(urlString.trimWhitespace(), blocked)

        os_log("tracker %s %s", log: generalLog, type: .debug, tracker.blocked ? "BLOCKED" : "ignored", tracker.domain ?? "")

        if let isSurrogate = dict[TrackerDetectedKey.isSurrogate] as? Bool, isSurrogate, let host = URL(string: urlString)?.host {
            delegate.contentBlockerUserScript(self, detectedTracker: tracker, withSurrogate: host)
        } else {
            delegate.contentBlockerUserScript(self, detectedTracker: tracker)
        }
    }
            
    private func trackerFromUrl(_ urlString: String, _ blocked: Bool) -> DetectedTracker {
        let knownTracker = TrackerDataManager.shared.findTracker(forUrl: urlString)
        let entity = TrackerDataManager.shared.findEntity(byName: knownTracker?.owner?.name ?? "")
        return DetectedTracker(url: urlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
    }
}

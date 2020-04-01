//
//  ContentBlockerUserScript.swift
//  Core
//
//  Created by Chris Brind on 01/04/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import WebKit
import os

public protocol ContentBlockerUserScriptDelegate: NSObjectProtocol {
    
    func contentBlockerUserScriptShouldProcessTrackers(_ script: ContentBlockerUserScript) -> Bool
    func contentBlockerUserScript(_ script: ContentBlockerUserScript, detectedTracker tracker: DetectedTracker, withSurrogate host: String)
    func contentBlockerUserScript(_ script: ContentBlockerUserScript, detectedTracker tracker: DetectedTracker)

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
        let whitelist = (WhitelistManager().domains?.joined(separator: "\n") ?? "")
            + "\n"
            + (storageCache?.fileStore.loadAsString(forConfiguration: .temporaryWhitelist) ?? "")
        let surrogates = storageCache?.fileStore.loadAsString(forConfiguration: .surrogates) ?? ""

        // Encode whatever the tracker data manager is using to ensure it's in sync and because we know it will work
        let encodedTrackerData = try? JSONEncoder().encode(TrackerDataManager.shared.trackerData)
        let trackerData = String(data: encodedTrackerData!, encoding: .utf8)!
        
        return loadJS("contentblocker", withReplacements: [
            "${whitelist}": whitelist,
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

    deinit {
        print("*** deinit CBS")
    }
}

//
//  ContentBlockerRulesUserScript.swift
//  Core
//
//  Created by Brad Slayter on 8/19/20.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import WebKit

public class ContentBlockerRulesUserScript: NSObject, UserScript {
    
    struct ContentBlockerKey {
        static let url = "url"
        static let resourceType = "resourceType"
    }
    
    public var source: String {
        return loadJS("contentblockerrules")
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "processRule" ]
    
    public weak var delegate: ContentBlockerUserScriptDelegate?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let delegate = delegate else { return }
        guard delegate.contentBlockerUserScriptShouldProcessTrackers(self) else { return }
        
        guard let dict = message.body as? [String: Any] else { return }
//        guard let resourceType = dict[ContentBlockerKey.resourceType] as? String else { return }
        guard let urlString = dict[ContentBlockerKey.url] as? String else { return }
        
        if let tracker = trackerFromUrl(urlString) {
            delegate.contentBlockerUserScript(self, detectedTracker: tracker)
        }
    }
    
    private func trackerFromUrl(_ urlString: String) -> DetectedTracker? {
        let knownTracker = TrackerDataManager.shared.findTracker(forUrl: urlString)
        if let entity = TrackerDataManager.shared.findEntity(byName: knownTracker?.owner?.name ?? "") {
            return DetectedTracker(url: urlString, knownTracker: knownTracker, entity: entity, blocked: true)
        }
        
        return nil
    }
}

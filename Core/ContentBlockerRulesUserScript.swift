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

public protocol ContentBlockerRulesUserScriptDelegate: NSObjectProtocol {

    func contentBlockerUserScriptShouldProcessTrackers(_ script: ContentBlockerRulesUserScript) -> Bool
    func contentBlockerUserScript(_ script: ContentBlockerRulesUserScript,
                                  detectedTracker tracker: DetectedTracker)

}

public protocol ContentBlockerUserScriptConfigSource {

    var privacyConfig: PrivacyConfiguration { get }
    var trackerData: TrackerData? { get }
}

public class DefaultUserScriptConfigSource: ContentBlockerUserScriptConfigSource {

    public var privacyConfig: PrivacyConfiguration {
        return PrivacyConfigurationManager.shared.privacyConfig
    }

    public var trackerData: TrackerData? {
        return ContentBlockerRulesManager.shared.currentRules?.trackerData
    }
}

public class ContentBlockerRulesUserScript: NSObject, UserScript {
    
    struct ContentBlockerKey {
        static let url = "url"
        static let resourceType = "resourceType"
        static let blocked = "blocked"
        static let pageUrl = "pageUrl"
    }

    private let configurationSource: ContentBlockerUserScriptConfigSource

    public init(configurationSource: ContentBlockerUserScriptConfigSource) {
        self.configurationSource = configurationSource

        super.init()
    }

    public override convenience init() {
        self.init(configurationSource: DefaultUserScriptConfigSource())
    }
    
    public var source: String {
        let privacyConfiguration = configurationSource.privacyConfig

        let remoteUnprotectedDomains = (privacyConfiguration.tempUnprotectedDomains.joined(separator: "\n"))
            + "\n"
            + (privacyConfiguration.exceptionsList(forFeature: .contentBlocking).joined(separator: "\n"))
        
        return Self.loadJS("contentblockerrules", from: Bundle.core, withReplacements: [
            "${tempUnprotectedDomains}": remoteUnprotectedDomains,
            "${localUnprotectedDomains}": privacyConfiguration.locallyUnprotectedDomains.joined(separator: "\n")
        ])
    }

    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "processRule" ]
    
    public weak var delegate: ContentBlockerRulesUserScriptDelegate?
    public weak var storageCache: StorageCache? {
        didSet {
            let privacyConfiguration = PrivacyConfigurationManager.shared.privacyConfig
            temporaryUnprotectedDomains = privacyConfiguration.tempUnprotectedDomains.filter { !$0.trimWhitespace().isEmpty }
            temporaryUnprotectedDomains.append(contentsOf: privacyConfiguration.exceptionsList(forFeature: .contentBlocking))
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
        guard let pageUrlStr = message.webView?.url?.absoluteString ?? dict[ContentBlockerKey.pageUrl] as? String else { return }
        
        guard let currentTrackerData = configurationSource.trackerData else {
            return
        }

        let privacyConfiguration = configurationSource.privacyConfig

        let resolver = TrackerResolver(tds: currentTrackerData,
                                       unprotectedSites: privacyConfiguration.locallyUnprotectedDomains,
                                       tempList: temporaryUnprotectedDomains)
        
        if let tracker = resolver.trackerFromUrl(trackerUrlString,
                                                 pageUrlString: pageUrlStr,
                                                 resourceType: resourceType,
                                                 potentiallyBlocked: blocked && privacyConfiguration.isEnabled(featureKey: .contentBlocking)) {
            delegate.contentBlockerUserScript(self, detectedTracker: tracker)
        }
    }
}

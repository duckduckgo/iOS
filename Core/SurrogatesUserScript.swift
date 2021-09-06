//
//  SurrogatesUserScript.swift
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
import TrackerRadarKit
import BrowserServicesKit

public protocol SurrogatesUserScriptDelegate: NSObjectProtocol {
    
    func surrogatesUserScriptShouldProcessTrackers(_ script: SurrogatesUserScript) -> Bool
    func surrogatesUserScript(_ script: SurrogatesUserScript,
                              detectedTracker tracker: DetectedTracker,
                              withSurrogate host: String)

}

public protocol SurrogatesUserScriptConfigSource {

    var privacyConfig: PrivacyConfiguration { get }
    var encodedTrackerData: String? { get }
    var surrogates: String { get }
}

public class DefaultSurrogatesUserScriptConfigSource: SurrogatesUserScriptConfigSource {

    public var privacyConfig: PrivacyConfiguration {
        return PrivacyConfigurationManager.shared.privacyConfig
    }

    public var encodedTrackerData: String? {
        return ContentBlockerRulesManager.shared.currentRules?.encodedTrackerData
    }

    private var cachedSurrogatesETag = ""
    private var cachedSurrogates = ""
    public var surrogates: String {
        let etagStore = UserDefaultsETagStorage()

        let surrogatesETag = etagStore.etag(for: .surrogates) ?? ""

        if cachedSurrogates != surrogatesETag {
            cachedSurrogates = FileStore().loadAsString(forConfiguration: .surrogates) ?? ""
            cachedSurrogatesETag = surrogatesETag
        }

        return cachedSurrogates
    }
}

public class SurrogatesUserScript: NSObject, UserScript {
    
    struct TrackerDetectedKey {
        static let protectionId = "protectionId"
        static let blocked = "blocked"
        static let networkName = "networkName"
        static let url = "url"
        static let isSurrogate = "isSurrogate"
    }

    private let configurationSource: SurrogatesUserScriptConfigSource

    public init(configurationSource: SurrogatesUserScriptConfigSource) {
        self.configurationSource = configurationSource

        super.init()
    }

    public override convenience init() {
        self.init(configurationSource: DefaultSurrogatesUserScriptConfigSource())
    }

    public var source: String {
        let privacyConfiguration = configurationSource.privacyConfig

        let remoteUnprotectedDomains = (privacyConfiguration.tempUnprotectedDomains.joined(separator: "\n"))
            + "\n"
            + (privacyConfiguration.exceptionsList(forFeature: .contentBlocking).joined(separator: "\n"))

        // Encode whatever the tracker data manager is using to ensure it's in sync and because we know it will work
        let trackerData: String
        if let data = configurationSource.encodedTrackerData {
            trackerData = data
        } else {
            let encodedData = try? JSONEncoder().encode(TrackerData(trackers: [:], entities: [:], domains: [:], cnames: [:]))
            trackerData = String(data: encodedData!, encoding: .utf8)!
        }
        
        return Self.loadJS("contentblocker", from: Bundle.core, withReplacements: [
            "${isDebug}": isDebugBuild ? "true" : "false",
            "${tempUnprotectedDomains}": remoteUnprotectedDomains,
            "${userUnprotectedDomains}": privacyConfiguration.userUnprotectedDomains.joined(separator: "\n"),
            "${trackerData}": trackerData,
            "${surrogates}": configurationSource.surrogates,
            "${blockingEnabled}": privacyConfiguration.isEnabled(featureKey: .contentBlocking) ? "true" : "false"
        ])
    }
    
    public var injectionTime: WKUserScriptInjectionTime = .atDocumentStart
    
    public var forMainFrameOnly: Bool = false
    
    public var messageNames: [String] = [ "trackerDetectedMessage" ]

    public weak var delegate: SurrogatesUserScriptDelegate?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        os_log("trackerDetected %s", log: generalLog, type: .debug, String(describing: message.body))

        guard let delegate = delegate else { return }
        guard delegate.surrogatesUserScriptShouldProcessTrackers(self) else { return }
        
        guard let dict = message.body as? [String: Any] else { return }
        guard let blocked = dict[TrackerDetectedKey.blocked] as? Bool else { return }
        guard let urlString = dict[TrackerDetectedKey.url] as? String else { return }

        let tracker = trackerFromUrl(urlString.trimWhitespace(), blocked)

        if let isSurrogate = dict[TrackerDetectedKey.isSurrogate] as? Bool, isSurrogate, let host = URL(string: urlString)?.host {
            delegate.surrogatesUserScript(self, detectedTracker: tracker, withSurrogate: host)
            
            os_log("surrogate for %s Injected", log: generalLog, type: .debug, tracker.domain ?? "")
        }
    }
            
    private func trackerFromUrl(_ urlString: String, _ blocked: Bool) -> DetectedTracker {
        let currentTrackerData = ContentBlockerRulesManager.shared.currentRules?.trackerData
        let knownTracker = currentTrackerData?.findTracker(forUrl: urlString)
        let entity = currentTrackerData?.findEntity(byName: knownTracker?.owner?.name ?? "")
        return DetectedTracker(url: urlString, knownTracker: knownTracker, entity: entity, blocked: blocked)
    }
}

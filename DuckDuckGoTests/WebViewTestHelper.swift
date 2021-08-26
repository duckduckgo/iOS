//
//  ContentBlockerWebViewTestHelpers.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import XCTest
import BrowserServicesKit
import TrackerRadarKit
@testable import Core
@testable import DuckDuckGo

class MockNavigationDelegate: NSObject, WKNavigationDelegate {

    var onDidFinishNavigation: (() -> Void)?

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        XCTFail("Could to navigate to test site")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onDidFinishNavigation?()
    }
}

class MockUserScriptDelegate: NSObject, ContentBlockerUserScriptDelegate {

    var shouldProcessTrackers = true

    var onSurrogateDetected: ((DetectedTracker, String) -> Void)?
    var onTrackerDetected: ((DetectedTracker) -> Void)?

    var detectedSurrogates = Set<DetectedTracker>()
    var detectedTrackers = Set<DetectedTracker>()

    func reset() {
        detectedTrackers.removeAll()
        detectedSurrogates.removeAll()
    }

    func contentBlockerUserScriptShouldProcessTrackers(_ script: UserScript) -> Bool {
        return shouldProcessTrackers
    }

    func contentBlockerUserScript(_ script: ContentBlockerUserScript, detectedTracker tracker: DetectedTracker, withSurrogate host: String) {
        detectedSurrogates.insert(tracker)
        onSurrogateDetected?(tracker, host)
    }

    func contentBlockerUserScript(_ script: UserScript, detectedTracker tracker: DetectedTracker) {
        detectedTrackers.insert(tracker)
        onTrackerDetected?(tracker)
    }
}

class MockUserScriptConfigSource: ContentBlockerUserScriptConfigSource {

    private var _privacyConfig: PrivacyConfiguration?
    public var privacyConfig: PrivacyConfiguration {
        get {
            if let config = _privacyConfig {
                return config
            }
            return PrivacyConfigurationManager.shared.privacyConfig
        }
        set {
            _privacyConfig = newValue
        }
    }

    public var trackerData: TrackerData?
}

class MockDomainsProtectionStore: DomainsProtectionStore {
    var unprotectedDomains = Set<String>()

    func disableProtection(forDomain domain: String) {
        unprotectedDomains.remove(domain)
    }

    func enableProtection(forDomain domain: String) {
        unprotectedDomains.insert(domain)
    }
}

class WebKitTestHelper {

    static func preparePrivacyConfig(locallyUnprotected: [String],
                                     tempUnprotected: [String],
                                     contentBlockingEnabled: Bool,
                                     exceptions: [String]) -> PrivacyConfiguration {
        let contentBlockingExceptions = exceptions.map { PrivacyConfigurationData.ExceptionEntry(domain: $0, reason: nil) }
        let features = [PrivacyFeature.contentBlocking.rawValue: PrivacyConfigurationData.PrivacyFeature(state: contentBlockingEnabled ? "enabled" : "disabled",
                                                                                                         exceptions: contentBlockingExceptions)]
        let unprotectedTemporary = tempUnprotected.map { PrivacyConfigurationData.ExceptionEntry(domain: $0, reason: nil) }
        let privacyData = PrivacyConfigurationData(features: features,
                                                   unprotectedTemporary: unprotectedTemporary)

        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = Set(locallyUnprotected)

        return AppPrivacyConfiguration(data: privacyData,
                                       identifier: "",
                                       localProtection: localProtection)
    }

    static func prepareContentBlockingRules(trackerData: TrackerData,
                                            exceptions: [String],
                                            tempUnprotected: [String],
                                            completion: @escaping (WKContentRuleList?) -> Void) {

        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: exceptions,
                                                                                    andTemporaryUnprotectedDomains: tempUnprotected)

        let data = (try? JSONEncoder().encode(rules))!
        var ruleList = String(data: data, encoding: .utf8)!

        // Replace https scheme regexp with test
        ruleList = ruleList.replacingOccurrences(of: "https", with: "test", options: [], range: nil)

        WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "test", encodedContentRuleList: ruleList) { list, _ in

            DispatchQueue.main.async {
                completion(list)
            }
        }
    }
}


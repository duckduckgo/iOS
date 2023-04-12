//
//  WebViewTestHelper.swift
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
import ContentBlocking
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

class MockSurrogatesUserScriptDelegate: NSObject, SurrogatesUserScriptDelegate {

    var shouldProcessTrackers = true

    var onSurrogateDetected: ((DetectedRequest, String) -> Void)?
    var detectedSurrogates = Set<DetectedRequest>()

    func reset() {
        detectedSurrogates.removeAll()
    }

    func surrogatesUserScriptShouldProcessTrackers(_ script: SurrogatesUserScript) -> Bool {
        return shouldProcessTrackers
    }

    func surrogatesUserScript(_ script: SurrogatesUserScript,
                              detectedTracker tracker: DetectedRequest,
                              withSurrogate host: String) {
        detectedSurrogates.insert(tracker)
        onSurrogateDetected?(tracker, host)
    }
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

class CustomSurrogatesUserScript: SurrogatesUserScript {

    var onSourceInjection: (String) -> String = { $0 }

    override var source: String {
        return onSourceInjection(super.source)
    }
}

class WebKitTestHelper {

    static func preparePrivacyConfig(locallyUnprotected: [String],
                                     tempUnprotected: [String],
                                     trackerAllowlist: [String: [PrivacyConfigurationData.TrackerAllowlist.Entry]],
                                     contentBlockingEnabled: Bool,
                                     exceptions: [String],
                                     httpsUpgradesEnabled: Bool = false) -> PrivacyConfiguration {
        let contentBlockingExceptions = exceptions.map { PrivacyConfigurationData.ExceptionEntry(domain: $0, reason: nil) }
        let contentBlockingStatus = contentBlockingEnabled ? "enabled" : "disabled"
        let httpsStatus = httpsUpgradesEnabled ? "enabled" : "disabled"
        let features = [PrivacyFeature.contentBlocking.rawValue: PrivacyConfigurationData.PrivacyFeature(state: contentBlockingStatus,
                                                                                                         exceptions: contentBlockingExceptions),
                        PrivacyFeature.httpsUpgrade.rawValue: PrivacyConfigurationData.PrivacyFeature(state: httpsStatus, exceptions: [])]
        let unprotectedTemporary = tempUnprotected.map { PrivacyConfigurationData.ExceptionEntry(domain: $0, reason: nil) }
        let privacyData = PrivacyConfigurationData(features: features,
                                                   unprotectedTemporary: unprotectedTemporary,
                                                   trackerAllowlist: trackerAllowlist)

        let localProtection = MockDomainsProtectionStore()
        localProtection.unprotectedDomains = Set(locallyUnprotected)

        return AppPrivacyConfiguration(data: privacyData,
                                       identifier: "",
                                       localProtection: localProtection,
                                       internalUserDecider: DefaultInternalUserDecider())
    }

    static func prepareContentBlockingRules(trackerData: TrackerData,
                                            exceptions: [String],
                                            tempUnprotected: [String],
                                            trackerExceptions: [TrackerException],
                                            completion: @escaping (WKContentRuleList?) -> Void) {

        let rules = ContentBlockerRulesBuilder(trackerData: trackerData).buildRules(withExceptions: exceptions,
                                                                                    andTemporaryUnprotectedDomains: tempUnprotected,
                                                                                    andTrackerAllowlist: trackerExceptions)

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

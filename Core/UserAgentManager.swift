//
//  UserAgentManager.swift
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

import Foundation
import WebKit
import BrowserServicesKit
import Common

public protocol UserAgentManager {

    func update(request: inout URLRequest, isDesktop: Bool)

    func update(webView: WKWebView, isDesktop: Bool, url: URL?)

    func userAgent(isDesktop: Bool) -> String
    
}

public class DefaultUserAgentManager: UserAgentManager {
    
    public static let shared: UserAgentManager = DefaultUserAgentManager()

    private var userAgent = UserAgent()
    
    init() {
        prepareUserAgent()
    }
    
    private func prepareUserAgent() {
        let webview = WKWebView()
        webview.load(URLRequest.developerInitiated(URL(string: "about:blank")!))
        
        getDefaultAgent(webView: webview) { [weak self] agent in
            // Reference webview instance to keep it in scope and allow UA to be returned
            _ = webview
            
            guard let defaultAgent = agent else { return }
            self?.userAgent = UserAgent(defaultAgent: defaultAgent)
        }
    }
    
    public func userAgent(isDesktop: Bool) -> String {
        return userAgent.agent(forUrl: nil, isDesktop: isDesktop)
    }

    public func update(request: inout URLRequest, isDesktop: Bool) {
        request.addValue(userAgent.agent(forUrl: nil, isDesktop: isDesktop), forHTTPHeaderField: "User-Agent")
    }

    public func update(webView: WKWebView, isDesktop: Bool, url: URL?) {
        let agent = userAgent.agent(forUrl: url, isDesktop: isDesktop)
        webView.customUserAgent = agent
    }
    
    private func getDefaultAgent(webView: WKWebView, completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("navigator.userAgent") { (result, _) in
            let agent = result as? String
            completion(agent)
        }
    }
    
    public static var duckDuckGoUserAgent: String { duckduckGoUserAgent(for: AppVersion.shared) }
    
    public static func duckduckGoUserAgent(for appVersion: AppVersion) -> String {
        let osVersion = UIDevice.current.systemVersion
        return "ddg_ios/\(appVersion.versionAndBuildNumber) (\(appVersion.identifier); iOS \(osVersion))"
    }
    
}

struct UserAgent {

    private enum DefaultPolicy: String {

        case ddg
        case ddgFixed
        case closest

    }
    
    private enum Constants {
        // swiftlint:disable line_length
        static let fallbackWekKitVersion = "605.1.15"
        static let fallbackSafariComponent = "Safari/\(fallbackWekKitVersion)"
        static let fallbackDefaultAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/\(fallbackWekKitVersion) (KHTML, like Gecko) Mobile/15E148"
        static let desktopPrefixComponent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15)"
        static let fallbackVersionComponent = "Version/13.1.1"
        
        static let uaOmitSitesConfigKey = "omitApplicationSites"
        static let uaOmitDomainConfigKey = "domain"

        static let defaultPolicyConfigKey = "defaultPolicy"
        static let ddgDefaultSitesConfigKey = "ddgDefaultSites"
        static let ddgFixedSitesConfigKey = "ddgFixedSites"

        static let closestUserAgentConfigKey = "closestUserAgent"
        static let ddgFixedUserAgentConfigKey = "ddgFixedUserAgent"

        static let uaVersionsKey = "versions"
        static let uaStateKey = "state"
        // swiftlint:enable line_length
    }
    
    private struct Regex {
        static let suffix = "(AppleWebKit/.*) Mobile"
        static let webKitVersion = "AppleWebKit/([^ ]+) "
        static let osVersion = " OS ([0-9_]+)"
    }
    
    private let baseAgent: String
    private let baseDesktopAgent: String
    private let versionComponent: String
    private let safariComponent: String
    private let applicationComponent = "DuckDuckGo/\(AppVersion.shared.majorVersionNumber)"
    private let statistics: StatisticsStore
    private let isTesting: Bool = ProcessInfo().arguments.contains("testing")

    init(defaultAgent: String = Constants.fallbackDefaultAgent, statistics: StatisticsStore = StatisticsUserDefaults()) {
        versionComponent = UserAgent.createVersionComponent(fromAgent: defaultAgent)
        baseAgent = UserAgent.createBaseAgent(fromAgent: defaultAgent, versionComponent: versionComponent)
        baseDesktopAgent = UserAgent.createBaseDesktopAgent(fromAgent: defaultAgent, versionComponent: versionComponent)
        safariComponent = UserAgent.createSafariComponent(fromAgent: baseAgent)
        self.statistics = statistics
    }
    
    private func omitApplicationSites(forConfig config: PrivacyConfiguration) -> [String] {
        let uaSettings = config.settings(for: .customUserAgent)
        let omitApplicationObjs = uaSettings[Constants.uaOmitSitesConfigKey] as? [[String: String]] ?? []
        
        return omitApplicationObjs.map { $0[Constants.uaOmitDomainConfigKey] ?? "" }
    }

    private func defaultPolicy(forConfig config: PrivacyConfiguration) -> DefaultPolicy {
        let uaSettings = config.settings(for: .customUserAgent)
        guard let policy = uaSettings[Constants.defaultPolicyConfigKey] as? String else { return .ddg }

        return DefaultPolicy(rawValue: policy) ?? .ddg
    }

    private func ddgDefaultSites(forConfig config: PrivacyConfiguration) -> [String] {
        let uaSettings = config.settings(for: .customUserAgent)
        let defaultSitesObjs = uaSettings[Constants.ddgDefaultSitesConfigKey] as? [[String: String]] ?? []

        return defaultSitesObjs.map { $0[Constants.uaOmitDomainConfigKey] ?? "" }
    }

    private func ddgFixedSites(forConfig config: PrivacyConfiguration) -> [String] {
        let uaSettings = config.settings(for: .customUserAgent)
        let fixedSitesObjs = uaSettings[Constants.ddgFixedSitesConfigKey] as? [[String: String]] ?? []

        return fixedSitesObjs.map { $0[Constants.uaOmitDomainConfigKey] ?? "" }
    }

    private func closestUserAgentVersions(forConfig config: PrivacyConfiguration) -> [String] {
        let uaSettings = config.settings(for: .customUserAgent)
        let closestUserAgent = uaSettings[Constants.closestUserAgentConfigKey] as? [String: Any] ?? [:]
        let versions = closestUserAgent[Constants.uaVersionsKey] as? [String] ?? []
        return versions
    }

    private func ddgFixedUserAgentVersions(forConfig config: PrivacyConfiguration) -> [String] {
        let uaSettings = config.settings(for: .customUserAgent)
        let fixedUserAgent = uaSettings[Constants.ddgFixedUserAgentConfigKey] as? [String: Any] ?? [:]
        let versions = fixedUserAgent[Constants.uaVersionsKey] as? [String] ?? []
        return versions
    }

    // swiftlint:disable:next cyclomatic_complexity
    public func agent(forUrl url: URL?,
                      isDesktop: Bool,
                      privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig) -> String {

        guard privacyConfig.isEnabled(featureKey: .customUserAgent) else { return oldLogic(forUrl: url,
                                                                                           isDesktop: isDesktop,
                                                                                           privacyConfig: privacyConfig) }

        if ddgDefaultSites(forConfig: privacyConfig).contains(where: { domain in
            url?.isPart(ofDomain: domain) ?? false
        }) { return oldLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig) }

        if ddgFixedSites(forConfig: privacyConfig).contains(where: { domain in
            url?.isPart(ofDomain: domain) ?? false
        }) { return ddgFixedLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig) }

        if closestUserAgentVersions(forConfig: privacyConfig).contains(statistics.atbWeek ?? "") {
            if canUseClosestLogic {
                return closestLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
            } else {
                return oldLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
            }
        }

        if ddgFixedUserAgentVersions(forConfig: privacyConfig).contains(statistics.atbWeek ?? "") {
            return ddgFixedLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        }

        if DefaultVariantManager().isSupported(feature: .fixedUserAgent) {
            return ddgFixedLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        } else if DefaultVariantManager().isSupported(feature: .closestUserAgent) {
            return closestLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        }

        switch defaultPolicy(forConfig: privacyConfig) {
        case .ddg: return oldLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        case .ddgFixed: return ddgFixedLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        case .closest:
            if canUseClosestLogic {
                return closestLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
            } else {
                return oldLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
            }
        }
    }

    private func oldLogic(forUrl url: URL?,
                          isDesktop: Bool,
                          privacyConfig: PrivacyConfiguration) -> String {
        let omittedSites = omitApplicationSites(forConfig: privacyConfig)
        let customUAEnabled = privacyConfig.isEnabled(featureKey: .customUserAgent)

        let omitApplicationComponent = !customUAEnabled || omittedSites.contains { domain in
            url?.isPart(ofDomain: domain) ?? false
        }

        let resolvedApplicationComponent = !omitApplicationComponent ? applicationComponent : nil

        if isDesktop {
            return concatWithSpaces(baseDesktopAgent, resolvedApplicationComponent, safariComponent)
        } else {
            return concatWithSpaces(baseAgent, resolvedApplicationComponent, safariComponent)
        }
    }

    private func ddgFixedLogic(forUrl url: URL?,
                               isDesktop: Bool,
                               privacyConfig: PrivacyConfiguration) -> String {
        let omittedSites = omitApplicationSites(forConfig: privacyConfig)
        let omitApplicationComponent = omittedSites.contains { domain in
            url?.isPart(ofDomain: domain) ?? false
        }
        let resolvedApplicationComponent = !omitApplicationComponent ? applicationComponent : nil

        if canUseClosestLogic {
            var defaultSafari = closestLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
            // If the UA should have DuckDuckGo append it prior to Safari
            if let resolvedApplicationComponent {
                if let index = defaultSafari.range(of: "Safari")?.lowerBound {
                    defaultSafari.insert(contentsOf: resolvedApplicationComponent + " ", at: index)
                }
            }
            return defaultSafari
        } else {
            return oldLogic(forUrl: url, isDesktop: isDesktop, privacyConfig: privacyConfig)
        }
    }

    private func closestLogic(forUrl url: URL?,
                              isDesktop: Bool,
                              privacyConfig: PrivacyConfiguration) -> String {
        if isDesktop {
            return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Safari/605.1.15"
        }
        return "Mozilla/5.0 (" + deviceProfile + ") AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1"
    }

    private var canUseClosestLogic: Bool {
        guard let webKitVersion else { return false }
        return webKitVersion.versionCompare("605.1.15") != .orderedAscending
    }

    private var webKitVersion: String? {
        let components = baseAgent.components(separatedBy: "AppleWebKit/")

        if components.count > 1 {
            let versionComponents = components[1].components(separatedBy: " ")
            return versionComponents.first
        }

        return nil
    }

    var deviceProfile: String {
        let regex = try? NSRegularExpression(pattern: "\\((.*?)\\)")
        if let match = regex?.firstMatch(in: baseAgent, range: NSRange(baseAgent.startIndex..., in: baseAgent)) {
            let range = Range(match.range(at: 1), in: baseAgent)
            if let range = range {
                return String(baseAgent[range])
            }
        }
        return "iPhone; CPU iPhone OS 16_6 like Mac OS X"
    }

    private func concatWithSpaces(_ elements: String?...) -> String {
        return elements
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    private static func createVersionComponent(fromAgent agent: String) -> String {
        let regex = try? NSRegularExpression(pattern: Regex.osVersion)
        let match = regex?.firstMatch(in: agent, options: [], range: NSRange(location: 0, length: agent.count))
        
        guard let range = match?.range(at: 1) else {
            return Constants.fallbackVersionComponent
        }
        
        let version = (agent as NSString).substring(with: range)
        let versionComponents = version.split(separator: "_").prefix(2)
        
        guard versionComponents.count > 1 else {
            return Constants.fallbackVersionComponent
        }
        
        return "Version/\(versionComponents.joined(separator: "."))"
    }
    
    private static func createSafariComponent(fromAgent agent: String) -> String {
        let regex = try? NSRegularExpression(pattern: Regex.webKitVersion)
        let match = regex?.firstMatch(in: agent, options: [], range: NSRange(location: 0, length: agent.count))
        
        guard let range = match?.range(at: 1) else {
            return Constants.fallbackSafariComponent
        }
        
        let version = (agent as NSString).substring(with: range)
        return "Safari/\(version)"
    }
    
    private static func createBaseAgent(fromAgent agent: String,
                                        versionComponent: String) -> String {
        var agentComponents = agent.split(separator: " ")
        
        guard !agentComponents.isEmpty else {
            return agent
        }
        
        agentComponents.insert(.init(versionComponent), at: agentComponents.endIndex - 1)
        return agentComponents.joined(separator: " ")
    }
    
    private static func createBaseDesktopAgent(fromAgent agent: String,
                                               versionComponent: String) -> String {
        let regex = try? NSRegularExpression(pattern: Regex.suffix)
        let match = regex?.firstMatch(in: agent, options: [], range: NSRange(location: 0, length: agent.count))
        
        guard let range = match?.range(at: 1) else {
            return createBaseDesktopAgent(fromAgent: Constants.fallbackDefaultAgent,
                                          versionComponent: versionComponent)
        }
        
        let suffix = (agent as NSString).substring(with: range)
        return "\(Constants.desktopPrefixComponent) \(suffix) \(versionComponent)"
    }
    
}

private extension StatisticsStore {

    var atbWeek: String? {
        guard let atb else { return nil }
        let trimmed = String(atb.dropFirst())

        if let hyphenIndex = trimmed.firstIndex(of: "-") {
            return String(trimmed.prefix(upTo: hyphenIndex))
        } else {
            return trimmed
        }
    }

}

private extension String {

    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        compare(otherVersion, options: .numeric)
    }

}

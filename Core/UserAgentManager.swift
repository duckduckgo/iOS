//
//  UserAgentConfiguration.swift
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

public class UserAgentManager {
    
    public static let shared = UserAgentManager()

    private var userAgent = UserAgent()
    
    init() {
        prepareUserAgent()
    }
    
    private func prepareUserAgent() {
        let webview = WKWebView()
        webview.load(URLRequest(url: URL(string: "about:blank")!))
        
        getDefaultAgent(webView: webview) { [weak self] agent in
            // Reference webview instance to keep it in scope and allow UA to be returned
            _ = webview
            
            guard let defaultAgent = agent else { return }
            self?.userAgent = UserAgent(defaultAgent: defaultAgent)
        }
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
}

struct UserAgent {
    
    private struct Constants {
        // swiftlint:disable line_length
        static let fallbackWekKitVersion = "605.1.15"
        static let fallbackSafariComponent = "Safari/\(fallbackWekKitVersion)"
        static let fallbackDefaultAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/\(fallbackWekKitVersion) (KHTML, like Gecko) Mobile/15E148"
        static let desktopPrefixComponent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15)"
        static let fallbackVersionComponent = "Version/13.1.1"
        // swiftlint:enable line_length
    }
    
    private struct Regex {
        static let suffix = "(AppleWebKit/.*) Mobile"
        static let webKitVersion = "AppleWebKit/([^ ]+) "
        static let osVersion = " OS ([0-9_]+)"
    }
    
    private static let sitesThatOmitApplication = [
        "cvs.com",
        "sovietgames.su",
        "accounts.google.com",
        "facebook.com"
    ]
    
    private let baseAgent: String
    private let baseDesktopAgent: String
    private let versionComponent: String
    private let safariComponent: String
    private let applicationComponent = "DuckDuckGo/\(AppVersion.shared.majorVersionNumber)"
    
    init(defaultAgent: String = Constants.fallbackDefaultAgent) {
        versionComponent = UserAgent.createVersionComponent(fromAgent: defaultAgent)
        baseAgent = UserAgent.createBaseAgent(fromAgent: defaultAgent, versionComponent: versionComponent)
        baseDesktopAgent = UserAgent.createBaseDesktopAgent(fromAgent: defaultAgent, versionComponent: versionComponent)
        safariComponent = UserAgent.createSafariComponent(fromAgent: baseAgent)
    }
    
    public func agent(forUrl url: URL?, isDesktop: Bool) -> String {
        let omitApplicationComponent = UserAgent.sitesThatOmitApplication.contains { domain in
            url?.isPart(ofDomain: domain) ?? false
        }
        
        let resolvedApplicationComponent = !omitApplicationComponent ? applicationComponent : nil
        if isDesktop {
            return concatWithSpaces(baseDesktopAgent, resolvedApplicationComponent, safariComponent)
        } else {
            return concatWithSpaces(baseAgent, resolvedApplicationComponent, safariComponent)
        }
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

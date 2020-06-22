//
//  UserAgentConfiguration.swift
//  Core
//
//  Created by DuckDuckGo on 27/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import Foundation
import WebKit

public class UserAgentManager {
    
    public static let shared = UserAgentManager()
    
    private var defaultAgentRetreived = false
    private var userAgent: UserAgent
    
    init() {
        let webview = WKWebView()
        webview.load(URLRequest(url: URL(string: "https://duckduckgo.com")!))
        
        guard let defaultAgent = UserAgentManager.getDefaultAgent(webView: webview) else {
            userAgent = UserAgent()
            return
        }
        
        userAgent = UserAgent(defaultAgent: defaultAgent)
    }
    
    public func update(forWebView webView: WKWebView, isDesktop: Bool, url: URL?) {
        let agent = userAgent.agent(forHost: url?.host, isDesktop: isDesktop)
        webView.customUserAgent = agent
    }
    
    public static func getDefaultAgent(webView: WKWebView) -> String? {
        var agent: String?
        var complete = false

        webView.evaluateJavaScript("navigator.userAgent") { (result, _) in
            agent = result as? String
            complete = true
        }

        let limit = Date().addingTimeInterval(TimeInterval(3.0))
        while !complete {
            RunLoop.current.run(mode: .default, before: .distantFuture)
            let now = Date()
            if now > limit {
                complete = true
            }
        }

        return agent
    }
}

struct UserAgent {
    
    private struct Constants {
        // swiftlint:disable line_length
        static let fallbackWekKitVersion = "605.1.15"
        static let fallbackSafariComponent = "Safari/\(fallbackWekKitVersion)"
        static let fallbackDefaultAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/\(fallbackWekKitVersion) (KHTML, like Gecko) Mobile/15E148"
        static let desktopPrefixComponent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15)"
        static let desktopVersionComponent = "Version/13.1.1"
        // swiftlint:enable line_length
    }
    
    private struct Regex {
        static let suffix = "(AppleWebKit/.*) Mobile"
        static let webKitVersion = "AppleWebKit/([^ ]+) "
    }
    
    private static let sitesThatOmitApplication = [
        "cvs.com"
    ]
    
    private let baseAgent: String
    private let baseDesktopAgent: String
    private let safariComponent: String
    private let applicationComponent = "DuckDuckGo/\(AppVersion.shared.majorVersionNumber)"
    
    init(defaultAgent: String = Constants.fallbackDefaultAgent) {
        baseAgent = defaultAgent
        baseDesktopAgent = UserAgent.createBaseDesktopAgent(fromAgent: baseAgent)
        safariComponent = UserAgent.createSafariComponent(fromAgent: baseAgent)
    }
    
    public func agent(forHost host: String?, isDesktop: Bool) -> String {
        var omitApplicationComponent = false
        if let host = host {
            omitApplicationComponent = UserAgent.sitesThatOmitApplication.contains { parentHost in
                isSameOrSubdomain(child: host, parent: parentHost)
            }
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
    
    private static func createSafariComponent(fromAgent agent: String) -> String {
        let regex = try? NSRegularExpression(pattern: Regex.webKitVersion)
        let match = regex?.firstMatch(in: agent, options: [], range: NSRange(location: 0, length: agent.count))
        
        guard let range = match?.range(at: 1) else {
            return Constants.fallbackSafariComponent
        }
        
        let version = (agent as NSString).substring(with: range)
        return "Safari/\(version)"
    }
    
    private static func createBaseDesktopAgent(fromAgent agent: String) -> String {
        let regex = try? NSRegularExpression(pattern: Regex.suffix)
        let match = regex?.firstMatch(in: agent, options: [], range: NSRange(location: 0, length: agent.count))
        
        guard let range = match?.range(at: 1) else {
            return createBaseDesktopAgent(fromAgent: Constants.fallbackDefaultAgent)
        }
        
        let suffix = (agent as NSString).substring(with: range)
        return "\(Constants.desktopPrefixComponent) \(suffix) \(Constants.desktopVersionComponent)"
    }
    
    private func isSameOrSubdomain(child: String, parent: String) -> Bool {
        return child == parent || child.hasSuffix(".\(parent)")
    }
}

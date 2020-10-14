//
//  URLExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import JavaScriptCore

extension URL {

    public enum URLProtocol: String {
        case http
        case https

        public var scheme: String {
            return "\(rawValue)://"
        }
    }

    enum Host: String {
        case localhost
    }
    
    public var hostVariations: [String]? {
        guard var parts = host?.components(separatedBy: ".") else { return nil }
        var domains = [String]()
        while parts.count > 1 {
            let domain = parts.joined(separator: ".")
            domains.append(domain)
            parts.removeFirst()
        }
        return domains
    }
    
    public func toHttps() -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard components.scheme == URLProtocol.http.rawValue else { return self }
        components.scheme = URLProtocol.https.rawValue
        return components.url
    }

    public func toDesktopUrl() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        components.host = components.host?.dropPrefix(prefix: "m.")
        components.host = components.host?.dropPrefix(prefix: "mobile.")
        return components.url ?? self
    }

    public func getParam(name: String) -> String? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let encodedQuery = components.percentEncodedQuery else { return nil }
        components.percentEncodedQuery = switchWebSpacesToSystemEncoding(text: encodedQuery)
        guard let query = components.queryItems else { return nil }
        return query.filter({ (item) in item.name == name }).first?.value
    }

    public func addParam(name: String, value: String?) -> URL {
        let clearedUrl = removeParam(name: name)
        guard var components = URLComponents(url: clearedUrl, resolvingAgainstBaseURL: false) else { return self }
        var query = components.queryItems ?? [URLQueryItem]()
        query.append(URLQueryItem(name: name, value: value))
        components.queryItems = query
        components.percentEncodedQuery = encodePluses(text: components.percentEncodedQuery!)
        return components.url ?? self
    }

    public func addParams(_ params: [String: String?]) -> URL {
        var url = self
        for param in params {
            url = url.addParam(name: param.key, value: param.value)
        }
        return url
    }

    public func removeParam(name: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard let encodedQuery = components.percentEncodedQuery else { return self }
        components.percentEncodedQuery = switchWebSpacesToSystemEncoding(text: encodedQuery)
        guard var query = components.queryItems else { return self }
        
        for (index, param) in query.enumerated() where param.name == name {
            query.remove(at: index)
        }
        components.queryItems = query
        return components.url ?? self
    }

    public func isHttps() -> Bool {
        return absoluteString.hasPrefix(URLProtocol.https.scheme)
    }

    // Encodes plus symbols in a string. iOS does not automatically encode plus symbols so it
    // is often necessary to do so manually to avoid them being treated as spaces on the web
    private func encodePluses(text: String) -> String {
        return text.replacingOccurrences(of: "+", with: "%2B")
    }

    // iOS does not recognise plus symbols in an encoded web string as spaces. This method converts
    // them to %20 which iOS does support and can thus subsequently decode correctly
    private func switchWebSpacesToSystemEncoding(text: String) -> String {
        return text.replacingOccurrences(of: "+", with: "%20")
    }

    public func isCustomURLScheme() -> Bool {
        return scheme != nil && !absoluteString.hasPrefix(URLProtocol.http.scheme) && !absoluteString.hasPrefix(URLProtocol.https.scheme)
    }

    public func isBookmarklet() -> Bool {
        return absoluteString.isBookmarklet()
    }

    public func toDecodedBookmarklet() -> String? {
        return absoluteString.toDecodedBookmarklet()
    }
    
    // MARK: static

    public static func webUrl(fromText text: String) -> URL? {
        guard isWebUrl(text: text) else {
            return nil
        }
        let urlText = appendScheme(path: text)
        return URL(string: urlText)
    }

    public static func isWebUrl(text: String) -> Bool {
        guard let url = URL(string: text) else { return false }
        guard let scheme = url.scheme else { return isWebUrl(text: appendScheme(path: text)) }
        guard scheme == URLProtocol.http.rawValue || scheme == URLProtocol.https.rawValue else { return false }
        guard url.user == nil else { return false }
        guard let host = url.host else { return false }
        guard isValidHost(host) else { return false }
        return true
    }

    public static func decode(query: String) -> String? {
        return query.removingPercentEncoding
    }

    public static func appendScheme(path: String) -> String {
        if path.hasPrefix(URLProtocol.http.scheme) || path.hasPrefix(URLProtocol.https.scheme) {
            return path
        }
        return "\(URLProtocol.http.scheme)\(path)"
    }

    private static func isValidHost(_ host: String) -> Bool {
        return isValidHostname(host) || isValidIpHost(host)
    }

    public static func isValidHostname(_ host: String) -> Bool {
        if host == Host.localhost.rawValue {
            return true
        }

        // from https://stackoverflow.com/a/25717506/73479
        let hostNameRegex = "^(((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z0-9-]{2,63})$"
        return host.matches(pattern: hostNameRegex)
    }

    public static func isValidIpHost(_ host: String) -> Bool {
        // from https://stackoverflow.com/a/30023010/73479
        let ipRegex = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        return host.matches(pattern: ipRegex)
    }

    /// Uses JavaScriptCore to determine if the bookmarklet is valid JavaScript
    public static func isValidBookmarklet(url: URL?) -> Bool {
        guard let url = url,
              let bookmarklet = url.toDecodedBookmarklet(),
              let context = JSContext() else { return false }

        context.evaluateScript(bookmarklet)
        if let exception = context.exception {
            // Allow ReferenceErrors since the bookmarklet will likely want to access
            // document or other variables which don't exist in this JSContext.  Consider
            // this bookmarklet invalid for all other exceptions.
            return exception.description.contains("ReferenceError")
        }
        return true
    }
    
    public func isPart(ofDomain domain: String) -> Bool {
        guard let host = host else { return false }
        return host == domain || host.hasSuffix(".\(domain)")
    }
}

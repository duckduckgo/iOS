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
import BrowserServicesKit

extension URL {

    enum Host: String {
        case localhost
    }

    public func toDesktopUrl() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        components.host = components.host?.dropping(prefix: "m.")
        components.host = components.host?.dropping(prefix: "mobile.")
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
        return self.removeParams(named: [name])
    }

    public func removeParams(named parametersToRemove: Set<String>) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard let encodedQuery = components.percentEncodedQuery else { return self }
        components.percentEncodedQuery = switchWebSpacesToSystemEncoding(text: encodedQuery)
        guard var query = components.queryItems else { return self }

        query.removeAll { parametersToRemove.contains($0.name) }

        components.queryItems = query
        return components.url ?? self
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

    public static func webUrl(from text: String) -> URL? {
        guard var url = URL(string: text) else { return nil }

        switch url.scheme {
        case URLProtocol.http.rawValue, URLProtocol.https.rawValue:
            break
        case .none:
            // assume http by default
            guard let urlWithScheme = URL(string: URLProtocol.http.scheme + text),
                  // only allow 2nd+ level domains or "localhost" without scheme
                  urlWithScheme.host?.contains(".") == true || urlWithScheme.host == .localhost
            else { return nil }
            url = urlWithScheme

        default:
            return nil
        }

        guard url.host?.isValidHost == true, url.user == nil else { return nil }

        return url
    }

    public static func decode(query: String) -> String? {
        return query.removingPercentEncoding
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

    public func normalized() -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = nil
        components?.fragment = nil

        return components?.url
    }

}

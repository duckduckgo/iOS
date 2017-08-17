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



extension URL {
    
    enum URLProtocol: String {
        case http
        case https
    }
    
    private static let webUrlRegex = "^(https?:\\/\\/)?([\\da-z\\.-]+\\.[a-z\\.]{2,6}|(([\\d]+[.]){3}[\\d]+))([\\/]?[\\/:?=&#]{1}[\\%\\da-zA-Z_\\.-]+)*[\\/\\?]?$"
    
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
    
    public func addParams(_ params: [URLQueryItem]) -> URL {
        var url = self
        for param in params {
            url = url.addParam(name: param.name, value: param.value)
        }
        return url
    }
    
    public func removeParam(name: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard var query = components.queryItems else { return self }
        for (index, param) in query.enumerated() {
            if param.name == name {
                query.remove(at: index)
            }
        }
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
    
    public static func webUrl(fromText text: String) -> URL? {
        guard isWebUrl(text: text) else {
            return nil
        }
        let urlText = text.hasPrefix("http") ? text : appendScheme(path: text)
        return URL(string: urlText)
    }
    
    public static func isWebUrl(text: String) -> Bool {
        let pattern = webUrlRegex
        let webRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = webRegex.matches(in: text, options: .anchored, range:NSMakeRange(0, text.characters.count))
        return matches.count == 1
    }
    
    public func isHttps() -> Bool {
        return absoluteString.hasPrefix(URLProtocol.https.rawValue)
    }
    
    private static func appendScheme(path: String) -> String {
        return "\(URLProtocol.http.rawValue)://\(path)"
    }
    
    public static func decode(query: String) -> String? {
        return query.removingPercentEncoding
    }
}

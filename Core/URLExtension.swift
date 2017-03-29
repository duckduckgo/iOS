//
//  URLExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension URL {
    
    private static let webUrlRegex = "^(https?:\\/\\/)?([\\da-z\\.-]+\\.[a-z\\.]{2,6}|[\\d\\.]+)([\\/:?=&#]{1}[\\da-z\\.-]+)*[\\/\\?]?$"
    
    public func getParam(name: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let query = components.queryItems else { return nil }
        return query.filter({ (item) in item.name == name }).first?.value
    }
    
    public func addParam(name: String, value: String?) -> URL {
        let clearedUrl = removeParam(name: name)
        guard var components = URLComponents(url: clearedUrl, resolvingAgainstBaseURL: false) else { return self }
        var query = components.queryItems ?? [URLQueryItem]()
        query.append(URLQueryItem(name: name, value: value))
        components.queryItems = query
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
    
    private static func appendScheme(path: String) -> String {
        return "http://\(path)"
    }
    
    public static func encode(queryText: String) -> String? {
        return queryText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    public static func decode(query: String) -> String? {
        return query.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
    }
}

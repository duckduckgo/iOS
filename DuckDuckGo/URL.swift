//
//  URL.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

extension URL {

    private static let webUrlRegex = "^(https?:\\/\\/)?([\\da-z\\.-]+\\.[a-z\\.]{2,6}|[\\d\\.]+)([\\/:?=&#]{1}[\\da-z\\.-]+)*[\\/\\?]?$"
    
    static func webUrl(fromText text: String) -> URL? {
        guard isWebUrl(text: text) else {
            return nil
        }
        let urlText = text.hasPrefix("http") ? text : appendScheme(path: text)
        return URL(string: urlText)
    }
    
    static func isWebUrl(text: String) -> Bool {
        let pattern = webUrlRegex
        let webRegex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = webRegex.matches(in: text, options: .anchored, range:NSMakeRange(0, text.characters.count))
        return matches.count == 1
    }
    
    private static func appendScheme(path: String) -> String {
        return "http://\(path)"
    }

    static func encode(queryText: String) -> String? {
        return queryText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}

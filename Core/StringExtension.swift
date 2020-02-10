//
//  StringExtension.swift
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
import Punycode

extension String {

    public func trimWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func length() -> Int {
        return count
    }

    public func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let matches = regex.matches(in: self, options: .anchored, range: NSRange(location: 0, length: count))
        return matches.count == 1
    }

    /// Useful if loaded from UserText, for example
    public func format(arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
    }

    public func dropPrefix(prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }

    /// URL and URLComponents can't cope with emojis and international characters so this routine does some manual processing while trying to
    ///  retain the input as much as possible.
    public var punycodedUrl: URL? {
        if let url = URL(string: self) {
            return url
        }
        
        if contains(" ") {
            return nil
        }
        
        var originalScheme = ""
        var s = self
        
        if hasPrefix(URL.URLProtocol.http.scheme) {
            originalScheme = URL.URLProtocol.http.scheme
        } else if hasPrefix(URL.URLProtocol.https.scheme) {
            originalScheme = URL.URLProtocol.https.scheme
        } else if !contains(".") {
            // could be a local domain but user needs to use the protocol to specify that
            return nil
        } else {
            s = URL.URLProtocol.https.scheme + s
        }
        
        let urlAndQuery = s.split(separator: "?")
        guard urlAndQuery.count > 0 else {
            return nil
        }
        
        let query = urlAndQuery.count > 1 ? "?" + urlAndQuery[1] : ""
        let componentsWithoutQuery = [String](urlAndQuery[0].split(separator: "/").map { String($0) }.dropFirst())
        guard componentsWithoutQuery.count > 0 else {
            return nil
        }
        
        let host = componentsWithoutQuery[0].punycodeEncodedHostname
        let encodedPath = componentsWithoutQuery
            .dropFirst()
            .map { $0.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlPathAllowed) ?? $0 }
            .joined(separator: "/")
        
        let hostPathSeparator = !encodedPath.isEmpty || hasSuffix("/") ? "/" : ""
        let url = originalScheme + host + hostPathSeparator + encodedPath + query
        return URL(string: url)
    }
    
    public var punycodeEncodedHostname: String {
        return self.split(separator: ".")
            .map { String($0) }
            .map { $0.idnaEncoded ?? $0 }
            .joined(separator: ".")
    }
    
}

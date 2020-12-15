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
    
    public var fullRange: NSRange {
        return NSRange(location: 0, length: count)
    }

    public func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let matches = regex.matches(in: self, options: .anchored, range: fullRange)
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

    public func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256
        }
        return ""
    }

    public func attributedString(withPlaceholder placeholder: String,
                                 replacedByImage image: UIImage,
                                 horizontalPadding: CGFloat = 0.0,
                                 verticalOffset: CGFloat = 0.0) -> NSAttributedString? {
        let components = self.components(separatedBy: placeholder)
        guard components.count > 1 else { return nil }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: verticalOffset, width: image.size.width, height: image.size.height)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        let paddingAttachment = NSTextAttachment()
        paddingAttachment.bounds = CGRect(x: 0, y: 0, width: horizontalPadding, height: 0)
        let startPadding = NSAttributedString(attachment: paddingAttachment)
        let endPadding = NSAttributedString(attachment: paddingAttachment)
        
        let firstString = NSMutableAttributedString(string: components[0])
        for component in components.dropFirst() {
            let endString = NSMutableAttributedString(string: component)
            firstString.append(startPadding)
            firstString.append(attachmentString)
            firstString.append(endPadding)
            firstString.append(endString)
        }
        return firstString
    }
}

// MARK: - Bookmarklet

extension String {
    public func isBookmarklet() -> Bool {
        return self.lowercased().hasPrefix("javascript:")
    }

    public func toDecodedBookmarklet() -> String? {
        guard self.isBookmarklet(),
              let result = self.dropPrefix(prefix: "javascript:").removingPercentEncoding,
              !result.isEmpty else { return nil }
        return result
    }

    public func toEncodedBookmarklet() -> URL? {
        let allowedCharacters = CharacterSet.alphanumerics.union(.urlQueryAllowed)
        guard self.isBookmarklet(),
              let encoded = self.dropPrefix(prefix: "javascript:")
                // Avoid double encoding by removing any encoding first
                .removingPercentEncoding?
                .addingPercentEncoding(withAllowedCharacters: allowedCharacters) else { return nil }
        return URL(string: "javascript:\(encoded)")
    }
}

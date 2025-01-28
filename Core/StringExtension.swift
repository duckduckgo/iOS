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
import BrowserServicesKit

extension String {

    public func truncated(length: Int, trailing: String = "…") -> String {
      return (self.count > length) ? self.prefix(length) + trailing : self
    }

    /// Useful if loaded from UserText, for example
    public func format(arguments: CVarArg...) -> String {
        return String(format: self, arguments: arguments)
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

    public func width(for font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }

}

// MARK: - URL

extension String {
    public var toTrimmedURL: URL? {
        return URL(trimmedAddressBarString: self)
    }
}

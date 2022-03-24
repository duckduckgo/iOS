//
//  DownloadActionMessageViewHelper.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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

import UIKit

struct DownloadActionMessageViewHelper {
    
    static func makeDownloadStartedMessage(for download: Download) -> NSAttributedString {
        let downloadStartedMessage = UserText.messageDownloadStarted(for: download.filename)
        return Self.boldDownloadFilenameInMessage(downloadStartedMessage, filename: download.filename)
    }
    
    static func makeDownloadFinishedMessage(for download: Download) -> NSAttributedString {
        let downloadStartedMessage = UserText.messageDownloadComplete(for: download.filename)
        return Self.boldDownloadFilenameInMessage(downloadStartedMessage, filename: download.filename)
    }
    
    private static func boldDownloadFilenameInMessage(_ message: String, filename: String) -> NSAttributedString {
        let attributedMessage = NSMutableAttributedString(string: message)
        guard let filenameRange = message.range(of: filename) else {
            return NSAttributedString(string: message)
        }
        
        let fontSize: CGFloat = 16
        
        let regularAttributes = [
            NSAttributedString.Key.font: UIFont.appFont(ofSize: fontSize)
        ]
        
        let boldAttributes = [
            NSAttributedString.Key.font: UIFont.semiBoldAppFont(ofSize: fontSize)
        ]
        
        let range = NSRange(filenameRange, in: message)
        attributedMessage.addAttributes(regularAttributes, range: NSRange(location: 0, length: attributedMessage.length))
        attributedMessage.addAttributes(boldAttributes, range: range)
        
        return attributedMessage
    }
}

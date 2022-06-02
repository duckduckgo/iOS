//
//  BackForwardMenuHistoryItem.swift
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

import Foundation
import WebKit

struct BackForwardMenuHistoryItem {
    let backForwardItem: WKBackForwardListItem
    var title: String {
        backForwardItem.title ?? ""
    }
    
    var url: URL {
        backForwardItem.initialURL
    }
    
    var sanitizedURLForDisplay: String {
        BackForwardMenuHistoryItemURLSanitizer.sanitizedURLForDisplay(backForwardItem.initialURL)
    }
}

struct BackForwardMenuHistoryItemURLSanitizer {
    
    static func sanitizedURLForDisplay(_ url: URL) -> String {
        guard let components = URLComponents(string: url.absoluteString) else {
            return "\(url)"
        }
        
        var displayURL = url.absoluteString

        if let scheme = components.scheme {
            displayURL = displayURL.replacingOccurrences(of: scheme, with: "")
        }
        
        displayURL = displayURL.dropPrefix(prefix: "://")
        displayURL = displayURL.dropPrefix(prefix: "www.")
        displayURL = displayURL.drop(suffix: "/")
        
        let maxSize = 25
        if displayURL.count > maxSize {
            displayURL = "\(String(displayURL.dropLast(displayURL.count - maxSize)))..."
        }

        return displayURL
    }
}

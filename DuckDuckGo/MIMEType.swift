//
//  MIMEType.swift
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

enum MIMEType: String {
    case passbook = "application/vnd.apple.pkpass"
    case multipass = "application/vnd.apple.pkpasses"
    case usdz = "model/vnd.usdz+zip"
    case reality = "model/vnd.reality"
    case octetStream = "application/octet-stream"
    case xhtml = "application/xhtml+xml"
    case html = "text/html"
    case calendar = "text/calendar"
    case unknown
    
    init(from string: String?) {
        self = MIMEType(rawValue: string ?? "") ?? .unknown
    }

    init(from string: String?, fileExtension: String?) {
        let initialMIMEType = MIMEType(from: string)

        switch (initialMIMEType, fileExtension) {
        case (.octetStream, "pkpass"): self = .passbook
        case (.octetStream, "pkpasses"): self = .multipass
        default: self = initialMIMEType
        }
    }

    var isHTML: Bool {
        switch self {
        case .html, .xhtml:
            return true
        default:
            return false
        }
    }
}

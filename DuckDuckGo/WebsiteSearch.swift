//
//  WebsiteSearch.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import UIKit

struct WebPageSearchResultValue: Identifiable, Hashable {
    let id: String
    let name: String
    let displayUrl: String
    let url: URL
    let icon: UIImage?

    init(id: String, name: String, displayUrl: String, url: URL, icon: UIImage? = nil) {
        self.id = id
        self.name = name
        self.displayUrl = displayUrl
        self.url = url
        self.icon = icon
    }
}

protocol WebsiteSearch {
    func search(term: String) async throws -> [WebPageSearchResultValue]
}

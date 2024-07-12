//
//  Favorite.swift
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

import Bookmarks
import SwiftUI

struct Favorite: Identifiable, Equatable {
    let id: String
    let title: String
    let domain: String

    let urlObject: URL?

    init(id: String, title: String, domain: String, urlObject: URL? = nil) {
        self.id = id
        self.title = title
        self.domain = domain
        self.urlObject = urlObject
    }
}

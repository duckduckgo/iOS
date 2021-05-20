//
//  Suggestion.swift
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
import Core

struct Suggestion {

    enum Source {
        case remote
        case local
    }
    
    let source: Source
    let suggestion: String
    let url: URL?
    
    init(source: Source, suggestion: String, url: URL?) {
        self.source = source
        self.suggestion = suggestion
        self.url = url
    }
}

struct AutocompleteEntry: Decodable {

    let phrase: String?
    let isNav: Bool?

}

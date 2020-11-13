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

struct Suggestion: Decodable {

    enum Source {
        case remote
        case local
    }
    
    let source: Source
    let type: String
    let suggestion: String
    let url: URL?
    
    init(source: Source = .local, type: String, suggestion: String, url: URL?) {
        self.source = source
        self.type = type
        self.suggestion = suggestion
        self.url = url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String: String].self)

        if let element = dictionary.first {
            self.source = .remote
            self.type = element.key
            self.suggestion = element.value
            self.url = nil
        } else {
            throw JsonError.invalidJson
        }
    }
}

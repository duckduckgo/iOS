//
//  AutocompleteParser.swift
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

class AutocompleteParser {

    func convert(fromJsonData data: Data) throws -> [Suggestion] {

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            throw JsonError.invalidJson
        }

        guard let jsonArray = json as? [[String: String]] else {
            throw JsonError.typeMismatch
        }

        var suggestions = [Suggestion]()
        for element in jsonArray {
            if let type = element.keys.first, let suggestion = element[type] {
                suggestions.append(Suggestion(type: type, suggestion: suggestion))
            }
        }

        return suggestions
    }
}

//
//  AutocompleteParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

//
//  AutocompleteParser.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 09/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

class AutocompleteParser {
    
    enum ParsingError: Error {
        case noData
        case invalidJson
    }
    
    func parse(data: Data?) throws -> [Suggestion] {
        
        guard let data = data else {
            throw ParsingError.noData
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            throw ParsingError.invalidJson
        }
        
        var suggestions = [Suggestion]()
        for element in json {
            if let type = element.keys.first, let suggestion = element[type] {
                NSLog("\(type): \(suggestion)")
                suggestions.append(Suggestion(type: type, suggestion: suggestion))
            }
        }
        return suggestions
    }
}

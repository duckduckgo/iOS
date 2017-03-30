//
//  DateFilter.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 29/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public enum DateFilter: String {
    
    case any = ""
    case day = "d"
    case week = "w"
    case month = "m"
    
    public static func all() -> [DateFilter] {
        return [any, day, week, month]
    }
    
    public static func forKey(_ key: String?) -> DateFilter {
        guard let key = key else { return .any }
        return DateFilter.init(rawValue: key) ?? .any
    }
}

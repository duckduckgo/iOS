//
//  ContentBlockerEntries.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//


typealias CategorizedContentBlockerEntries = [String: [ContentBlockerEntry]]

public enum ContentBlockerCategory: String {
    case none = "None"
    case advertising = "Advertising"
    case analytics = "Analytics"
    case content = "Content"
    case social = "Social"
    
    public static func forKey(_ key: String?) -> ContentBlockerCategory {
        guard let key = key else { return .none }
        return ContentBlockerCategory.init(rawValue: key) ?? .none
    }
}

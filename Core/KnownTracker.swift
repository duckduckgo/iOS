//
//  KnownTracker.swift
//  Core
//
//  Created by Chris Brind on 25/11/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

public struct KnownTracker {
    
    public struct Owner {
        public let name: String?
    }
    
    public var category: String {
        guard let categories = categories else { return "" }
        return categories.isEmpty ? "" : categories[0]
    }
    
    public let domain: String?
    public let owner: Owner?
    public let categories: [String]?
    
}

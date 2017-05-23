//
//  ContentBlockerEntry.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 18/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Foundation

public struct ContentBlockerEntry {
    public let domain: String
    public let url: String
}

extension ContentBlockerEntry: Equatable {}

public func ==(first: ContentBlockerEntry, second: ContentBlockerEntry) -> Bool {
    return first.domain == second.domain && first.url == second.url
}

//
//  ContentBlockerMonitor.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 22/06/2017.
//  Copyright (c) 2015 Edinburgh International Science Festival. All rights reserved.
//

import Foundation


public class ContentBlockerMonitor {
    
    private let configuration = ContentBlockerConfigurationUserDefaults()

    private var blockedEntries = [ContentBlockerEntry]()
    
    public init() {}
    
    public var blockingEnabled: Bool {
        return configuration.blockingEnabled
    }
    
    public var totalAdvertising: Int {
        return blockedEntries.filter({ $0.category == .advertising }).count
    }

    public var totalAnalytics: Int {
        return blockedEntries.filter({ $0.category == .analytics }).count
    }

    public var totalSocial: Int {
        return blockedEntries.filter({ $0.category == .social }).count
    }
    
    public var total: Int {
        return blockedEntries.count
    }
    
    public func blocked(entry: ContentBlockerEntry) {
        blockedEntries.append(entry)
    }

}

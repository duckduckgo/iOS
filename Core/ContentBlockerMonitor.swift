//
//  ContentBlockerMonitor.swift
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

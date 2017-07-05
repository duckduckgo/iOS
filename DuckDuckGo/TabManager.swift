//
//  TabManager.swift
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


import Core

class TabManager:  NSObject, NSCoding {
    
    private struct NSCodingKeys {
        static let current = "current"
        static let tabs = "tabs"
    }
    
    private(set) var current: Tab?
    private var tabs: [Tab]
    
    override init() {
        tabs = [Tab]()
    }
    
    init(tabs: [Tab], current: Tab?) {
        self.tabs = tabs
        self.current = current
    }
    
    var tabDetails: [Link] {
        return buildTabDetails()
    }
    
    var isEmpty: Bool {
        return tabs.isEmpty
    }
    
    var count: Int {
        return tabs.count
    }
    
    var lastIndex: Int? {
        return isEmpty ? nil : tabs.count-1
    }
    
    var currentIndex: Int? {
        guard let current = current else { return nil }
        return indexOf(tab: current)
    }
    
    private func buildTabDetails() -> [Link] {
        var links = [Link]()
        for tab in tabs {
            if let link = tab.link {
                links.append(link)
            }
        }
        return links
    }
    
    func clearSelection() {
        current?.dismiss()
        current = nil
    }
    
    func select(tabAt index: Int) -> Tab {
        current?.dismiss()
        let tab = tabs[index]
        current = tab
        return tab
    }
    
    func add(tab: Tab) {
        current?.dismiss()
        tabs.append(tab)
        current = tab
    }
    
    func remove(at index: Int) {
        let tab = tabs.remove(at: index)
        tab.destroy()
    }
    
    func remove(tab: Tab) {
        if let index = indexOf(tab: tab) {
            remove(at: index)
        }
    }
    
    func indexOf(tab: Tab) -> Int? {
        for (index, current) in tabs.enumerated() {
            if current === tab {
                return index
            }
        }
        return nil
    }
    
    func clearAll() {
        for tab in tabs {
            remove(tab: tab)
        }
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        guard let tabs = aDecoder.decodeObject(forKey: NSCodingKeys.tabs) as? [Tab] else { return nil }
        let current = aDecoder.decodeObject(forKey: NSCodingKeys.current) as? Tab
        self.init(tabs: tabs, current: current)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(tabs, forKey: NSCodingKeys.tabs)
        aCoder.encode(current, forKey: NSCodingKeys.current)
    }
}


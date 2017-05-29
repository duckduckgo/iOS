//
//  TabManager.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core

struct TabManager {
    
    private(set) var current: Tab?
    
    private var tabs = [Tab]()
    
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
            links.append(tab.link)
        }
        return links
    }
    
    mutating func select(tabAt index: Int) -> Tab {
        current?.dismiss()
        let tab = tabs[index]
        current = tab
        return tab
    }
    
    mutating func add(tab: Tab) {
        current?.dismiss()
        tabs.append(tab)
        current = tab
    }
    
    mutating func remove(at index: Int) {
        let tab = tabs.remove(at: index)
        tab.destroy()
    }
    
    mutating func remove(tab: Tab) {
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
    
    mutating func clearAll() {
        for tab in tabs {
            remove(tab: tab)
        }
    }
}


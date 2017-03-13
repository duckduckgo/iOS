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
        for (index, current) in tabs.enumerated() {
            if current === tab {
                remove(at: index)
                return
            }
        }
    }
    
    mutating func clearAll() {
        for tab in tabs {
            remove(tab: tab)
         }
    }
}


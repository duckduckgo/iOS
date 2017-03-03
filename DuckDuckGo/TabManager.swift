//
//  TabManager.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import Core
import WebKit

struct TabManager {
    
    private var tabs = [WKWebView]()
    
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
            let link = Link(title: tab.title ?? "", url: tab.url ?? URL(string: "")!)
            links.append(link)
        }
        return links
    }
    
    func get(at index: Int) -> WKWebView {
        return tabs[index]
    }
    
    mutating func add(tab: WKWebView) {
        tabs.append(tab)
    }
    
    mutating func remove(at index: Int) {
        tabs.remove(at: index)
    }
    
    mutating func remove(webView: WKWebView) {
        for (index, tab) in tabs.enumerated() {
            if tab == webView {
                remove(at: index)
                webView.clearCache(completionHandler: {})
                return
            }
        }
    }
    
    mutating func clearAll() {
        for tab in tabs {
            remove(webView: tab)
            tab.clearCache(completionHandler: {})
        }
    }
}


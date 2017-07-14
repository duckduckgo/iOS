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

struct TabManager {
    
    private(set) var model: TabsModel
    
    private var tabs = [TabViewController]()
    
    init(model: TabsModel, contentBlocker: ContentBlocker, delegate: TabDelegate) {
        self.model = model
        for element in model.tabs {
            let url = element.link?.url
            let controller = buildController(contentBlocker: contentBlocker, delegate: delegate, url: url)
            tabs.append(controller)
        }
    }
    
    public func buildController(contentBlocker: ContentBlocker, delegate: TabDelegate, url: URL?) -> TabViewController {
        let controller = TabViewController.loadFromStoryboard(contentBlocker: contentBlocker)
        controller.attachNewWebView(persistsData: true)
        if let url = url {
            controller.load(url: url)
        }
        controller.delegate = delegate
        return controller
    }
    
    var current: TabViewController? {
        guard let index = model.currentIndex else { return nil }
        return tabs[index]
    }
    
    var currentIndex: Int? {
        return model.currentIndex
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
    
    mutating func clearSelection() {
        current?.dismiss()
        model.clearSelection()
        save()
    }
    
    mutating func select(tabAt index: Int) -> TabViewController {
        current?.dismiss()
        model.currentIndex = index
        save()
        return current!
    }
    
    mutating func add(tab: TabViewController) {
        current?.dismiss()
        tabs.append(tab)
        model.add(tab: Tab(link: tab.link))
        save()
    }
    
    mutating func remove(at index: Int) {
        if index == model.currentIndex {
            clearSelection()
        }
        
        let tab = tabs.remove(at: index)
        tab.destroy()
        model.remove(at: index)
        
        if index < tabs.count {
            model.currentIndex = index
        } else if let lastIndex = lastIndex {
            model.currentIndex = lastIndex
        }
        save()
    }
    
    mutating func remove(tab: TabViewController) {
        guard let index = indexOf(tab: tab) else { return }
        remove(at: index)
    }
    
    func indexOf(tab: TabViewController) -> Int? {
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
        save()
    }
    
    func updateModelFromTab(tab: TabViewController) {
        if let index = indexOf(tab: tab) {
            model.get(tabAt: index).link = tab.link
        }
        save()
    }
    
    func save() {
        model.save()
    }
}


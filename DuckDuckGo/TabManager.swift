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
    
    private weak var delegate: TabDelegate?
    
    init(model: TabsModel, delegate: TabDelegate) {
        self.model = model
        self.delegate = delegate
        for tabEntity in model.tabs {
            let url = tabEntity.link?.url
            let controller = buildTabController(url: url)
            tabs.append(controller)
        }
    }
 
    private func buildTabController(url: URL?) -> TabViewController {
        let request = url == nil ? nil : URLRequest(url: url!)
        return buildTabController(request: request)
    }
    
    private func buildTabController(request: URLRequest?) -> TabViewController {
        let contentBlocker = ContentBlocker()
        let controller = TabViewController.loadFromStoryboard(contentBlocker: contentBlocker)
        controller.attachWebView(persistsData: true)
        controller.delegate = delegate
        if let request = request {
            controller.load(urlRequest: request)
        }
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
    
    mutating func clearSelection() {
        current?.dismiss()
        model.clearSelection()
        save()
    }
    
    mutating func select(tabAt index: Int) -> TabViewController {
        current?.dismiss()
        model.select(tabAt: index)
        save()
        return current!
    }

    mutating func add(url: URL?) -> TabViewController {
        let request = url == nil ? nil : URLRequest(url: url!)
        return add(request: request)
    }
    
    mutating func add(request: URLRequest?) -> TabViewController {
        current?.dismiss()
        let tab = buildTabController(request: request)
        tabs.append(tab)
        model.add(tab: Tab(link: tab.link))
        save()
        return tab
    }

    mutating func remove(at index: Int) {
        let tab = tabs.remove(at: index)
        tab.destroy()
        model.remove(at: index)
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


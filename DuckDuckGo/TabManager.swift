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
import WebKit
import os.log

class TabManager {

    private(set) var model: TabsModel
    
    private var tabControllerCache = [TabViewController]()

    private weak var delegate: TabDelegate?

    init(model: TabsModel, delegate: TabDelegate) {
        self.model = model
        self.delegate = delegate
        let index = model.currentIndex
        let tab = model.tabs[index]
        if tab.link != nil {
            let controller = buildController(forTab: tab)
            tabControllerCache.append(controller)
        }
    }

    private func buildController(forTab tab: Tab) -> TabViewController {
        let url = tab.link?.url
        return buildController(forTab: tab, url: url)
    }

    private func buildController(forTab tab: Tab, url: URL?) -> TabViewController {
        let configuration =  WKWebViewConfiguration.persistent()
        let controller = TabViewController.loadFromStoryboard(model: tab)
        controller.attachWebView(configuration: configuration, andLoadUrl: url, consumeCookies: !model.hasActiveTabs)
        controller.delegate = delegate
        controller.loadViewIfNeeded()
        return controller
    }

    var current: TabViewController? {

        let index = model.currentIndex
        let tab = model.tabs[index]

        if let controller = controller(for: tab) {
            return controller
        } else {
            os_log("Tab not in cache, creating", log: generalLog, type: .debug)
            let controller = buildController(forTab: tab)
            tabControllerCache.append(controller)
            return controller
        }
    }
    
    private func controller(for tab: Tab) -> TabViewController? {
        return tabControllerCache.first { $0.tabModel === tab }
    }

    var isEmpty: Bool {
        return tabControllerCache.isEmpty
    }
    
    var hasUnread: Bool {
        return model.hasUnread
    }

    var count: Int {
        return model.count
    }

    func select(tabAt index: Int) -> TabViewController {
        current?.dismiss()
        model.select(tabAt: index)

        save()
        return current!
    }

    func addHomeTab() {
        model.add(tab: Tab())
        model.select(tabAt: model.count - 1)
    }
    
    func loadUrlInCurrentTab(_ url: URL) -> TabViewController {
        guard let tab = model.currentTab else {
            fatalError("No current tab")

        }
        let controller = buildController(forTab: tab, url: url)
        tabControllerCache.append(controller)
        
        save()
        return controller
    }
    
    func add(url: URL?, inBackground: Bool = false) -> TabViewController {

        if !inBackground {
            current?.dismiss()
        }

        let link = url == nil ? nil : Link(title: nil, url: url!)
        let tab = Tab(link: link)
        tab.viewed = !inBackground
        let controller = buildController(forTab: tab, url: url)
        tabControllerCache.append(controller)

        let index = model.currentIndex
        model.insert(tab: tab, at: index + 1)

        if !inBackground {
            model.select(tabAt: index + 1)
        }

        save()
        return controller
    }

    func remove(at index: Int) {
        let tab = model.get(tabAt: index)
        model.remove(tab: tab)
        if let controller = controller(for: tab) {
            removeFromCache(controller)
        }
        save()
    }

    func remove(tabController: TabViewController) {
        model.remove(tab: tabController.tabModel)
        removeFromCache(tabController)
        save()
    }

    private func removeFromCache(_ controller: TabViewController) {
        if let index = tabControllerCache.firstIndex(of: controller) {
            tabControllerCache.remove(at: index)
        }
        controller.destroy()
    }

    func removeAll() {
        model.clearAll()
        for controller in tabControllerCache {
            removeFromCache(controller)
        }
        save()
    }

    func invalidateCache(forController controller: TabViewController) {
        if current === controller {
            current?.reload(scripts: false)
        } else {
            removeFromCache(controller)
        }
    }

    func save() {
        model.save()
    }
}

extension TabManager: Themable {
    
    func decorate(with theme: Theme) {
        for tabController in tabControllerCache {
            tabController.decorate(with: theme)
        }
    }
    
}

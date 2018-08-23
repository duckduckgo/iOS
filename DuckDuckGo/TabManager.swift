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

class TabManager {

    private(set) var model: TabsModel
    private var disconnectMeStore = DisconnectMeStore()
    private var tabControllerCache = [TabViewController]()

    private weak var delegate: TabDelegate?

    init(model: TabsModel, delegate: TabDelegate) {
        self.model = model
        self.delegate = delegate
        if let index = model.currentIndex {
            let tab = model.tabs[index]
            let controller = buildController(forTab: tab)
            tabControllerCache.append(controller)
        }
    }

    private func buildController(forTab tab: Tab) -> TabViewController {
        let url = tab.link?.url
        return buildController(forTab: tab, url: url)
    }

    private func buildController(forTab tab: Tab, url: URL?) -> TabViewController {
        let contentBlocker = ContentBlockerConfigurationUserDefaults()
        let configuration =  WKWebViewConfiguration.persistent()
        let controller = TabViewController.loadFromStoryboard(model: tab, contentBlocker: contentBlocker)
        controller.attachWebView(configuration: configuration, andLoadUrl: url)
        controller.delegate = delegate
        return controller
    }

    var current: TabViewController? {

        guard let index = model.currentIndex else { return nil }
        let tab = model.tabs[index]

        if let controller = cachedController(forTab: tab) {
            return controller
        } else {
            Logger.log(text: "Tab not in cache, creating")
            let controller = buildController(forTab: tab)
            tabControllerCache.append(controller)
            return controller
        }
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

    func clearSelection() {
        current?.dismiss()
        model.clearSelection()
        save()
    }

    func select(tabAt index: Int) -> TabViewController {
        current?.dismiss()
        model.select(tabAt: index)

        save()
        return current!
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

        if let index = model.currentIndex, inBackground {
            model.insert(tab: tab, at: index + 1)
        } else {
            model.add(tab: tab)
        }

        save()
        return controller
    }

    func remove(at index: Int) {
        let tab = model.get(tabAt: index)
        model.remove(tab: tab)
        if let controller = cachedController(forTab: tab) {
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
        if let index = tabControllerCache.index(of: controller) {
            tabControllerCache.remove(at: index)
        }
        controller.destroy()
    }

    private func cachedController(forTab tab: Tab) -> TabViewController? {
        let controller = tabControllerCache.filter({ $0.tabModel === tab }).first
        if let link = controller?.link {
            tab.link = link
            save()
        }
        return controller
    }

    func removeAll() {
        for controller in tabControllerCache {
            removeFromCache(controller)
        }
        model.clearAll()
        save()
    }

    func invalidateCache(forController controller: TabViewController) {
        if current === controller {
            current?.reload()
        } else {
            removeFromCache(controller)
        }
    }

    func save() {
        model.save()
    }
}

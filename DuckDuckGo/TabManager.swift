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

import Common
import Core
import DDGSync
import WebKit
import BrowserServicesKit
import Persistence

class TabManager {

    private(set) var model: TabsModel
    
    private var tabControllerCache = [TabViewController]()

    private let bookmarksDatabase: CoreDataDatabase
    private let syncService: DDGSyncing
    private var previewsSource: TabPreviewsSource
    weak var delegate: TabDelegate?

    @UserDefaultsWrapper(key: .faviconTabsCacheNeedsCleanup, defaultValue: true)
    var tabsCacheNeedsCleanup: Bool

    init(model: TabsModel,
         previewsSource: TabPreviewsSource,
         bookmarksDatabase: CoreDataDatabase,
         syncService: DDGSyncing,
         delegate: TabDelegate) {
        self.model = model
        self.previewsSource = previewsSource
        self.bookmarksDatabase = bookmarksDatabase
        self.syncService = syncService
        self.delegate = delegate
        let index = model.currentIndex
        let tab = model.tabs[index]
        if tab.link != nil {
            let controller = buildController(forTab: tab, inheritedAttribution: nil)
            tabControllerCache.append(controller)
        }

        registerForNotifications()
    }

    private func buildController(forTab tab: Tab, inheritedAttribution: AdClickAttributionLogic.State?) -> TabViewController {
        let url = tab.link?.url
        return buildController(forTab: tab, url: url, inheritedAttribution: inheritedAttribution)
    }

    private func buildController(forTab tab: Tab, url: URL?, inheritedAttribution: AdClickAttributionLogic.State?) -> TabViewController {
        let configuration =  WKWebViewConfiguration.persistent()
        let controller = TabViewController.loadFromStoryboard(model: tab, bookmarksDatabase: bookmarksDatabase, syncService: syncService)
        controller.applyInheritedAttribution(inheritedAttribution)
        controller.attachWebView(configuration: configuration,
                                 andLoadRequest: url == nil ? nil : URLRequest.userInitiated(url!),
                                 consumeCookies: !model.hasActiveTabs)
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
            os_log("Tab not in cache, creating", log: .generalLog, type: .debug)
            let controller = buildController(forTab: tab, inheritedAttribution: nil)
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

    func addURLRequest(_ request: URLRequest,
                       with configuration: WKWebViewConfiguration,
                       inheritedAttribution: AdClickAttributionLogic.State?) -> TabViewController {

        guard let configCopy = configuration.copy() as? WKWebViewConfiguration else {
            fatalError("Failed to copy configuration")
        }

        let tab = Tab(link: request.url == nil ? nil : Link(title: nil, url: request.url!))
        model.insert(tab: tab, at: model.currentIndex + 1)
        model.select(tabAt: model.currentIndex + 1)

        let controller = TabViewController.loadFromStoryboard(model: tab, bookmarksDatabase: bookmarksDatabase, syncService: syncService)
        controller.attachWebView(configuration: configCopy,
                                 andLoadRequest: request,
                                 consumeCookies: !model.hasActiveTabs,
                                 loadingInitiatedByParentTab: true)
        controller.delegate = delegate
        controller.loadViewIfNeeded()
        controller.applyInheritedAttribution(inheritedAttribution)
        tabControllerCache.append(controller)

        save()
        return controller
    }

    func addHomeTab() {
        model.add(tab: Tab())
        model.select(tabAt: model.count - 1)
        save()
    }

    func firstHomeTab() -> Tab? {
        return model.tabs.first(where: { $0.link == nil })
    }

    func first(withUrl url: URL) -> Tab? {
        return model.tabs.first(where: {
            guard let linkUrl = $0.link?.url else { return false }

            if linkUrl == url {
                return true
            }

            if linkUrl.scheme == "https" && url.scheme == "http" {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.scheme = "https"
                return components?.url == linkUrl
            }

            return false
        })
    }

    func selectTab(_ tab: Tab) {
        guard let index = model.indexOf(tab: tab) else { return }
        model.select(tabAt: index)
        save()
    }

    func add(url: URL?, inBackground: Bool = false, inheritedAttribution: AdClickAttributionLogic.State?) -> TabViewController {

        if !inBackground {
            current?.dismiss()
        }

        let link = url == nil ? nil : Link(title: nil, url: url!)
        let tab = Tab(link: link)
        let controller = buildController(forTab: tab, url: url, inheritedAttribution: inheritedAttribution)
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
        previewsSource.removePreview(forTab: tab)
        model.remove(tab: tab)
        if let controller = controller(for: tab) {
            removeFromCache(controller)
        }
        save()
    }

    private func removeFromCache(_ controller: TabViewController) {
        if let index = tabControllerCache.firstIndex(of: controller) {
            tabControllerCache.remove(at: index)
        }
        controller.dismiss()
    }

    func removeAll() {
        previewsSource.removeAllPreviews()
        model.clearAll()
        for controller in tabControllerCache {
            removeFromCache(controller)
        }
        save()
    }

    func invalidateCache(forController controller: TabViewController) {
        if current === controller {
            Pixel.fire(pixel: .webKitTerminationDidReloadCurrentTab)
            current?.reload()
        } else {
            removeFromCache(controller)
        }
    }

    func save() {
        model.save()
    }
    
    func prepareAllTabsExceptCurrentForDataClearing() {
        tabControllerCache.filter { $0 != current }.forEach { $0.prepareForDataClearing() }
    }
    
    func prepareCurrentTabForDataClearing() {
        current?.prepareForDataClearing()
    }

    func cleanupTabsFaviconCache() {
        guard tabsCacheNeedsCleanup else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                  let tabsCacheUrl = Favicons.CacheType.tabs.cacheLocation()?.appendingPathComponent(Favicons.Constants.tabsCachePath),
                  let contents = try? FileManager.default.contentsOfDirectory(at: tabsCacheUrl, includingPropertiesForKeys: nil, options: []),
                    !contents.isEmpty else { return }

            let imageDomainURLs = contents.compactMap({ $0.filename })

            // create a Set of all unique hosts in case there are hundreds of tabs with many duplicate hosts
            let tabLink = Set(self.model.tabs.compactMap { tab in
                if let host = tab.link?.url.host {
                    return host
                }

                return nil
            })

            // hash the unique tab hosts
            let tabLinksHashed = tabLink.map { Favicons.createHash(ofDomain: $0) }

            // filter images that don't have a corresponding tab
            let toDelete = imageDomainURLs.filter { !tabLinksHashed.contains($0) }
            toDelete.forEach {
                Favicons.shared.removeTabFavicon(forCacheKey: $0)
            }

            self.tabsCacheNeedsCleanup = false
        }
    }
}

extension TabManager: Themable {
    
    func decorate(with theme: Theme) {
        for tabController in tabControllerCache {
            tabController.decorate(with: theme)
        }
    }
    
}

// MARK: - Debugging Pixels

extension TabManager {

    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationBecameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc
    private func onApplicationBecameActive(_ notification: NSNotification) {
        assertTabPreviewCount()
    }

    private func assertTabPreviewCount() {
        let totalStoredPreviews = previewsSource.totalStoredPreviews()
        let totalTabs = model.tabs.count

        if let storedPreviews = totalStoredPreviews, storedPreviews > totalTabs {
            Pixel.fire(pixel: .cachedTabPreviewsExceedsTabCount, withAdditionalParameters: [
                PixelParameters.tabPreviewCountDelta: "\(storedPreviews - totalTabs)"
            ])
            TabPreviewsCleanup.shared.startCleanup(with: model, source: previewsSource)
        }
    }
}

extension TabManager {
 
    func makeTabCountInfo() -> TabCountInfo {
        TabCountInfo(tabsModelCount: model.count,
                     tabControllerCacheCount: tabControllerCache.count)
    }
}

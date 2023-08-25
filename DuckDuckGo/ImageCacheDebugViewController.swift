//
//  ImageCacheDebugViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import WidgetKit
import Bookmarks
import CoreData
import Persistence
import BrowserServicesKit
import Common
import Kingfisher

class ImageCacheDebugViewController: UITableViewController {

    private let titles = [
        Sections.fireproof: "Fireproof (Fireproof Cache)",
        Sections.tabs: "Tabs (Tabs Cache)"
    ]

    private enum Sections: Int, CaseIterable {
        case fireproof
        case tabs
    }

    private enum Constants {
        static let cellIdentifier = "ImageCacheDebugCell"
        static let fireproofCachePath = "com.onevcat.Kingfisher.ImageCache.fireproof"
        static let tabsCachePath = "com.onevcat.Kingfisher.ImageCache.tabs"
    }

    private let tabsModel = TabsModel.get() ?? TabsModel(desktop: false)

    private let bookmarksContext: NSManagedObjectContext

    private var fireproofFavicons = [String: UIImage]()
    private var tabFavicons = [String: UIImage]()

    private var bookmarks = [String: String]()
    private var logins = [String: String]()
    private var fireproofSites = [String: String]()
    private var tabs = [String: String]()

    init?(coder: NSCoder,
          bookmarksDatabase: CoreDataDatabase) {

        bookmarksContext = bookmarksDatabase.makeContext(concurrencyType: .mainQueueConcurrencyType)
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let clearCacheItem = UIBarButtonItem(image: UIImage(systemName: "trash")!,
                                             style: .done,
                                             target: self,
                                             action: #selector(presentClearCachePrompt(_:)))
        clearCacheItem.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearCacheItem

        loadAllFireproofFavicons()
        loadAllTabFavicons()

        loadAllBookmarks()
        loadAllLogins()
        loadAllFireproofSites()
        loadAllTabs()
    }

    private func loadAllFireproofFavicons() {
        guard let cacheUrl = Favicons.CacheType.fireproof.cacheLocation() else { return }
        let fireproofCacheUrl = cacheUrl.appendingPathComponent(Constants.fireproofCachePath)
        fireproofFavicons = loadFaviconImages(from: fireproofCacheUrl)
    }

    private func loadAllTabFavicons() {
        guard let cacheUrl = Favicons.CacheType.tabs.cacheLocation() else { return }
        let tabCacheUrl = cacheUrl.appendingPathComponent(Constants.tabsCachePath)
        tabFavicons = loadFaviconImages(from: tabCacheUrl)
    }

    private func loadFaviconImages(from cacheUrl: URL) -> [String: UIImage] {
        let contents = try? FileManager.default.contentsOfDirectory(at: cacheUrl, includingPropertiesForKeys: nil, options: [])

        var favicons = [String: UIImage]()
        for imageUrl in contents ?? [] {
            if let data = (try? Data(contentsOf: imageUrl)) {
                favicons[imageUrl.lastPathComponent] = UIImage(data: data)
            }
        }
        return favicons
    }

    // Access core data directly because this is just a debug view
    private func loadAllBookmarks() {
        let request = BookmarkEntity.fetchRequest()
        request.sortDescriptors = [ .init(keyPath: \BookmarkEntity.title, ascending: true) ]
        request.predicate = .init(format: "isFolder == false")
        request.returnsObjectsAsFaults = false
        let bookmarksAndFavorites = (try? bookmarksContext.fetch(request)) ?? []
        for bookmark in bookmarksAndFavorites {
            if let url = bookmark.urlObject, let imageResource = Favicons.shared.defaultResource(forDomain: url.host) {
                bookmarks[imageResource.cacheKey] = url.host
            }
        }
    }

    private func loadAllLogins() {
        do {
            let secureVault = try AutofillSecureVaultFactory.makeVault(errorReporter: SecureVaultErrorReporter.shared)
            let accounts = try secureVault.accounts()
            for account in accounts {
                if let imageResource = Favicons.shared.defaultResource(forDomain: account.domain) {
                    logins[imageResource.cacheKey] = account.domain
                }
            }
        } catch {
            os_log("Failed to fetch accounts")
        }
    }

    private func loadAllFireproofSites() {
        let preservedLoginSites = PreserveLogins.shared.allowedDomains
        for site in preservedLoginSites {
            if let imageResource = Favicons.shared.defaultResource(forDomain: site) {
                fireproofSites[imageResource.cacheKey] = site
            }
        }
    }

    private func loadAllTabs() {
        for tab in tabsModel.tabs {
            if let link = tab.link?.url.host, let imageResource = Favicons.shared.defaultResource(forDomain: link) {
                tabs[imageResource.cacheKey] = link
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImageDebugFaviconTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? ImageDebugFaviconTableViewCell else {
            fatalError("Could not dequeue cell")
        }

        var detailText: String = ""

        switch Sections(rawValue: indexPath.section) {

        case .fireproof:
            let fireproofFaviconKey = fireproofFavicons.keys.sorted()[indexPath.row]
            cell.faviconImageView.image = fireproofFavicons[fireproofFaviconKey]
            cell.cacheKey.text = "Cache key: \(fireproofFaviconKey)"

            if let bookmark = bookmarks[fireproofFaviconKey] {
                detailText = "*Bookmark:* \(bookmark)\n"
            }
            if let login = logins[fireproofFaviconKey] {
                detailText.append("*Login:* \(login)\n")
            }
            if let fireproofSite = fireproofSites[fireproofFaviconKey] {
                detailText.append("*Fireproof:* \(fireproofSite)\n")
            }

            if detailText.isEmpty {
                detailText = "‼️ Orphaned fireproof favicon\n"
                detailText.append(describe(fireproofFavicons[fireproofFaviconKey]))
                cell.details.attributedText = detailText.attributedStringFromMarkdown(color: .red, lineHeightMultiple: 1.1, fontSize: 14.0)
            } else {
                detailText.append(describe(fireproofFavicons[fireproofFaviconKey]))
                cell.details.attributedText = detailText.attributedStringFromMarkdown(color: .label, lineHeightMultiple: 1.1, fontSize: 14.0)
            }
        case .tabs:
            let tabFaviconKey = tabFavicons.keys.sorted()[indexPath.row]
            cell.faviconImageView.image = tabFavicons[tabFaviconKey]
            cell.cacheKey.text = "Cache key: \(tabFaviconKey)"

            if let tab = tabs[tabFaviconKey] {
                detailText = "*Tab:* \(tab)\n"
                detailText.append(describe(tabFavicons[tabFaviconKey]))
                cell.details.attributedText = detailText.attributedStringFromMarkdown(color: .label, lineHeightMultiple: 1.1, fontSize: 14.0)
            } else {
                detailText = "‼️ Orphaned tab favicon\n"
                detailText.append(describe(tabFavicons[tabFaviconKey]))
                cell.details.attributedText = detailText.attributedStringFromMarkdown(color: .red, lineHeightMultiple: 1.1, fontSize: 14.0)
            }

        default: break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .fireproof: return fireproofFavicons.count
        case .tabs: return tabFavicons.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ImageDebugFaviconTableViewCell else { return }
        share(image: cell.faviconImageView.image, withDetails: cell.details.text ?? "", fromView: cell)
    }

    private func share(image: UIImage?, withDetails details: String, fromView view: UIView) {
        guard let image = image else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.title = details
        if let popover = controller.popoverPresentationController {
            popover.sourceView = view
        }
        present(controller, animated: true)
    }

    private func describe(_ image: UIImage?) -> String {
        guard let image = image else { return "No image" }
        let size = image.size
        return "\(size.width) x \(size.height)"
    }

    @objc
    private func presentClearCachePrompt(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Clear Image Cache?", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.clearCacheAndReload()
            WidgetCenter.shared.reloadAllTimelines()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    private func clearCacheAndReload() {
        let caches = Favicons.Constants.caches

        caches.values.forEach {
            $0.clearMemoryCache()
            $0.clearDiskCache()
        }

        loadAllFireproofFavicons()
        loadAllTabFavicons()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}

class ImageDebugFaviconTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ImageDebugFaviconTableViewCell"

    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var cacheKey: UILabel!

}

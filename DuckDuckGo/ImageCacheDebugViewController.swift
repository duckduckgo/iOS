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

class ImageCacheDebugViewController: UITableViewController {

    private let titles = [
        Sections.bookmarks: "Bookmarks (Bookmark Cache)",
        Sections.tabs: "Tabs (Tabs Cache)"
    ]

    enum Sections: Int, CaseIterable {

        case bookmarks
        case tabs

    }

    let imageNotFound = UIImage(systemName: "exclamationmark.circle")
    let imageError = UIImage(systemName: "exclamationmark.triangle")
    let tabsModel = TabsModel.get() ?? TabsModel(desktop: false)

    private let bookmarksContext = BookmarksDatabase.globalReferenceForDebug!.makeContext(concurrencyType: .mainQueueConcurrencyType)

    private var bookmarksAndFavorites = [BookmarkEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let clearCacheItem = UIBarButtonItem(image: UIImage(systemName: "trash")!,
                                             style: .done,
                                             target: self,
                                             action: #selector(presentClearCachePrompt(_:)))
        clearCacheItem.tintColor = .systemRed
        navigationItem.rightBarButtonItem = clearCacheItem

        loadAllBookmarks()
    }

    // Access core data directly because this is just a debug view
    private func loadAllBookmarks() {
        let request = BookmarkEntity.fetchRequest()
        request.sortDescriptors = [ .init(keyPath: \BookmarkEntity.title, ascending: true) ]
        request.predicate = .init(format: "isFolder == false")
        request.returnsObjectsAsFaults = false
        bookmarksAndFavorites = (try? bookmarksContext.fetch(request)) ?? []
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { return nil }
        return titles[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch Sections(rawValue: indexPath.section) {

        case .bookmarks:
            let bookmark = bookmarksAndFavorites[indexPath.row]
            cell.textLabel?.text = bookmark.urlObject?.host
            cell.imageView?.loadFavicon(forDomain: bookmark.urlObject?.host, usingCache: .bookmarks) {
                cell.imageView?.image = $1 ? self.imageNotFound : $0 ?? self.imageError
                cell.detailTextLabel?.text = self.describe($1 ? nil : $0)
            }

        case .tabs:
            if let link = tabsModel.get(tabAt: indexPath.row).link {
                cell.textLabel?.text = link.url.host
                cell.imageView?.loadFavicon(forDomain: tabsModel.get(tabAt: indexPath.row).link?.url.host, usingCache: .tabs) {
                    cell.imageView?.image = $1 ? self.imageNotFound : $0 ?? self.imageError
                    cell.detailTextLabel?.text = self.describe($1 ? nil : $0)
                }
            } else {
                cell.imageView?.image = UIImage(named: "Logo")
                cell.textLabel?.text = "<Home Screen>"
                cell.detailTextLabel?.text = ""
            }

        default: break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .bookmarks: return bookmarksAndFavorites.count
        case .tabs: return tabsModel.count
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let host: String?
        switch Sections(rawValue: indexPath.section) {
        case .bookmarks: host = bookmarksAndFavorites[indexPath.row].urlObject?.host
        case .tabs: host = tabsModel.get(tabAt: indexPath.row).link?.url.host
        default: host = nil
        }
        guard let domain = host, let cell = tableView.cellForRow(at: indexPath) else { return }
        share(image: cell.imageView?.image, forDomain: domain, fromView: cell)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func share(image: UIImage?, forDomain domain: String, fromView view: UIView) {
        guard let image = image else { return }
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.title = domain
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

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}

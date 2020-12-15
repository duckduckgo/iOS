//
//  TodayViewController.swift
//  TodayExtension
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

import UIKit
import Core
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    struct Constants {
        static let maxCompactModeBookmarks = 3
    }
    
    private var bookmarks = [Link]()
    private var bookmarkStore = BookmarkUserDefaults()

    @IBOutlet weak var tableView: UITableView!

    private var preferredHeight: CGFloat {
        return tableView.contentSize.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        configureWidgetSize()
    }

    private func configureWidgetSize() {
        guard let context = extensionContext else { return }
        let compactModeOverflow = bookmarks.count > Constants.maxCompactModeBookmarks
        let mode = compactModeOverflow ? NCWidgetDisplayMode.expanded : NCWidgetDisplayMode.compact
        context.widgetLargestAvailableDisplayMode = mode

        let maxSize = context.widgetMaximumSize(for: mode)
        let width = tableView.contentSize.width
        let height = preferredHeight > maxSize.height ? maxSize.height : preferredHeight
        preferredContentSize = CGSize(width: width, height: height)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let dataChanged = refresh()
        completionHandler(dataChanged ? NCUpdateResult.newData : NCUpdateResult.noData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == NCWidgetDisplayMode.expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: preferredHeight)
        } else {
            preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        }
    }

    @discardableResult private func refresh() -> Bool {
        let newBookmarks = getData()
        if newBookmarks != bookmarks {
            bookmarks = newBookmarks
            tableView.reloadData()
            refreshViews()
            return true
        }
        return false
    }

    private func refreshViews() {
        configureWidgetSize()
    }

    private func getData() -> [Link] {
        return bookmarkStore.bookmarks
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.isEmpty ? 1 : bookmarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookmarks.isEmpty {
            return noBookmarksCell(for: indexPath)
        }
        let bookmark = bookmarks[bookmarkIndex(forTableIndex: indexPath)!]
        return bookmarkCell(for: indexPath, bookmark: bookmark)
    }
    
    func noBookmarksCell(for indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "NoBookmarks", for: indexPath)
    }

    func bookmarkCell(for indexPath: IndexPath, bookmark: Link) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Bookmark", for: indexPath) as? BookmarkCell else {
            fatalError("Bookmark table view identifier should be type BookmarkCell")
        }
        cell.update(withBookmark: bookmark)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmarkIndex = bookmarkIndex(forTableIndex: indexPath) else { return }
        launchBookmark(at: bookmarkIndex)
    }
    
    private func launchBookmark(at index: Int) {
        let selection = bookmarks[index].url
        if let url = URL(string: "\(AppDeepLinks.quickLink)\(selection)") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
    
    private func bookmarkIndex(forTableIndex indexPath: IndexPath) -> Int? {
        let bookmarkIndex = indexPath.row
        guard bookmarkIndex >= 0, bookmarkIndex < bookmarks.count else {
            return nil
        }
        return bookmarkIndex
    }
}

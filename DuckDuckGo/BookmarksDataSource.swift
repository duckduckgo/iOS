//
//  BookmarksDataSource.swift
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

import UIKit
import Bookmarks
import Core

protocol BookmarksDataSourceDelegate: NSObjectProtocol {

    func viewControllerForAlert(_: BookmarksDataSource) -> UIViewController
    func bookmarkDeleted(_: BookmarksDataSource)

}

class BookmarksDataSource: NSObject, UITableViewDataSource {

    weak var delegate: BookmarksDataSourceDelegate?

    let viewModel: BookmarkListViewModel

    var isEmpty: Bool {
        viewModel.bookmarks.isEmpty
    }

    init(viewModel: BookmarkListViewModel) {
        self.viewModel = viewModel
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, viewModel.bookmarks.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !viewModel.bookmarks.isEmpty else {
            return BookmarkCellCreator.createEmptyCell(tableView, forIndexPath: indexPath, inFolder: viewModel.currentFolder != nil)
        }

        guard let bookmark = viewModel.bookmarkAt(indexPath.row) else {
            fatalError("No bookmark at index \(indexPath.row)")
        }

        let cell = BookmarkCellCreator.bookmarkCell(tableView, forIndexPath: indexPath)
        cell.bookmark = bookmark
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.bookmarks.isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let bookmark = viewModel.bookmarkAt(indexPath.row) else { return }

        func delete() {
            let oldCount = viewModel.bookmarks.count
            viewModel.deleteBookmark(bookmark)
            let newCount = viewModel.bookmarks.count
            
            // Make sure we are animating only single removal
            if newCount + 1 == oldCount {
                tableView.deleteRows(at: [indexPath], with: .fade)
            } else {
                tableView.reloadSections([0], with: .automatic)
            }
            delegate?.bookmarkDeleted(self)
        }

        if let delegate = delegate,
           bookmark.isFolder,
           bookmark.children?.count ?? 0 > 0 {

            let title = String(format: UserText.deleteBookmarkFolderAlertTitle, bookmark.title ?? "")
#warning("original code recursively counted the children")
            let count = bookmark.children?.count ?? 0
            let message = UserText.deleteBookmarkFolderAlertMessage(numberOfChildren: count)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(title: UserText.deleteBookmarkFolderAlertDeleteButton, style: .default) {
                delete()
            }
            alertController.addAction(title: UserText.actionCancel, style: .cancel)
            let viewController = delegate.viewControllerForAlert(self)
            viewController.present(alertController, animated: true)

        } else {
            delete()
        }

    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.bookmarks.isEmpty
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let bookmark = viewModel.bookmarkAt(sourceIndexPath.row) else { return }
        viewModel.moveBookmark(bookmark, fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }

}

class SearchBookmarksDataSource: NSObject, UITableViewDataSource {

    let searchEngine: BookmarksCachingSearch

    var results = [BookmarksCachingSearch.ScoredBookmark]()

    init(searchEngine: BookmarksCachingSearch) {
        self.searchEngine = searchEngine
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BookmarkCellCreator.bookmarkCell(tableView, forIndexPath: indexPath)
        cell.scoredBookmark = results[indexPath.row]
        return cell
    }

    func performSearch(_ text: String) async {
        results = await searchEngine.search(query: text)
    }

}

class BookmarkCellCreator {

    static func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath, inFolder: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier, for: indexPath)
                as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        let theme = ThemeManager.shared.currentTheme
        cell.label.textColor = theme.tableCellTextColor
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        return cell
    }

    static func bookmarkCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> BookmarkCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier, for: indexPath) as? BookmarkCell else {
            fatalError("Failed to dequeue bookmark item")
        }

        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        return cell
    }

}

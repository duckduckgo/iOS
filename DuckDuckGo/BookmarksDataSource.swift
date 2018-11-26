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
import Core

class BookmarksDataSource: NSObject, UITableViewDataSource {

    private lazy var bookmarksManager: BookmarksManager = BookmarksManager()

    var isEmpty: Bool {
        return bookmarksManager.bookmarksCount == 0
    }

    func bookmark(at indexPath: IndexPath) -> Link {        
        return bookmarksManager.bookmark(atIndex: indexPath.row)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmpty { return 1 }
        return bookmarksManager.bookmarksCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmpty {
            return createEmptyCell(tableView)
        }
        return createBookmarkCell(tableView, forIndexPath: indexPath)
    }

    private func createEmptyCell(_ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier) as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.contentView.backgroundColor = theme.tableCellBackgroundColor
        cell.label.textColor = theme.tableCellTintColor
        
        return cell
    }

    private func createBookmarkCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        let bookmark = self.bookmark(at: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }
        cell.update(withBookmark: bookmark)
        
        let theme = ThemeManager.shared.currentTheme
        cell.contentView.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTintColor
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarksManager.deleteBookmark(at: indexPath.row)
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.moveBookmark(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, updateBookmark updatedBookmark: Link, at indexPath: IndexPath) {
        bookmarksManager.updateBookmark(at: indexPath.row, with: updatedBookmark)
        tableView.reloadData()
    }
    
}

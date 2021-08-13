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
    
    func link(at indexPath: IndexPath) -> Link? {
        return nil
    }
    
    typealias VisibleBookmarkItem = (item: BookmarkItem, depth: Int)
    
    func item(at indexPath: IndexPath) -> VisibleBookmarkItem? {
        return nil
    }
    
    func expand(folder: Folder) {
    }
    
    func collapse(folder: Folder) {
    }
    
    var isEmpty: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if link(at: indexPath) != nil {
            return createBookmarkCell(tableView, forIndexPath: indexPath)
        } else {
            return createEmptyCell(tableView, forIndexPath: indexPath)
        }
    }
    
    fileprivate func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> NoBookmarksCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier) as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.label.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)

        return cell
    }
    
    //TOdo we need to a representation for folders. I guess just the image is different?
    //oh they also have the arrow and number of items on the right.
    //probably worthy or a new cell type?
    fileprivate func createBookmarkCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }

        //TODO handle folders
        cell.bookmark = item(at: indexPath) as! Bookmark
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
}

class DefaultBookmarksDataSource: BookmarksDataSource {

    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    //TODO I question if this is necessary. Could just use the visible object to track this
    private var expandedFolders = Set<Folder>()

    override var isEmpty: Bool {
        return bookmarksManager.favoritesCount == 0 && bookmarksManager.bookmarksCount == 0
    }

    override func link(at indexPath: IndexPath) -> Link? {
        if indexPath.section == 0 {
            return bookmarksManager.favorite(atIndex: indexPath.row)
        } else {
            return bookmarksManager.bookmark(atIndex: indexPath.row)
        }
    }
    
    private lazy var visibleBookmarkItems: [VisibleBookmarkItem] = {
        return bookmarksManager.topLevelBookmarkItems.map {
            VisibleBookmarkItem($0, 0)
        }
    }()
    
    override func expand(folder: Folder) {
        expandedFolders.insert(folder)
        guard let children = folder.children?.array as? [BookmarkItem],
              let index = visibleBookmarkItems.firstIndex(where: { $0.item == folder }) else {
            return //TOdo fatal error if firstIndex fails?
        }
        let newDepth = visibleBookmarkItems[index].depth + 1
        let visibleChildren = children.map {
            VisibleBookmarkItem($0, newDepth)
        }
        visibleBookmarkItems.insert(contentsOf: visibleChildren, at: index + 1)
        //TODO reload
    }
    
    override func collapse(folder: Folder) {
        expandedFolders.remove(folder)
        visibleBookmarkItems.removeAll(where: { $0.item.parent == folder })
        //TODO reload
    }
    
    override func item(at indexPath: IndexPath) -> VisibleBookmarkItem? {
        if indexPath.section == 0 {
            return nil //TODO
        } else {
            return visibleBookmarkItems[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, section == 0 ? bookmarksManager.favoritesCount : visibleBookmarkItems.count)
    }
    
    override func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> NoBookmarksCell {
        let cell = super.createEmptyCell(tableView, forIndexPath: indexPath)
        
        cell.label.text = indexPath.section == 0 ? UserText.emptyFavorites : UserText.emptyBookmarks
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? UserText.sectionTitleFavorites : UserText.sectionTitleBookmarks
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return link(at: indexPath) != nil
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        var reload = false
        
        if indexPath.section == 0 {
            bookmarksManager.deleteFavorite(at: indexPath.row)
            reload = bookmarksManager.favoritesCount == 0
        } else {
            bookmarksManager.deleteBookmark(at: indexPath.row)
            reload = bookmarksManager.bookmarksCount == 0
        }
        
        if reload {
            // because we're replacing this cell with a place holder that says "no whatever yet"
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        var reload = false
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
            bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
            bookmarksManager.moveFavorite(at: sourceIndexPath.row, toBookmark: destinationIndexPath.row)
            reload = bookmarksManager.favoritesCount == 0 || bookmarksManager.bookmarksCount == 1
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 1 {
            bookmarksManager.moveBookmark(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
            bookmarksManager.moveBookmark(at: sourceIndexPath.row, toFavorite: destinationIndexPath.row)
            reload = bookmarksManager.bookmarksCount == 0 || bookmarksManager.favoritesCount == 1
        }

        if reload {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, updateBookmark updatedBookmark: Link, at indexPath: IndexPath) {
        if indexPath.section == 0 {
            bookmarksManager.updateFavorite(at: indexPath.row, with: updatedBookmark)
        } else {
            bookmarksManager.updateBookmark(at: indexPath.row, with: updatedBookmark)
        }
        
        tableView.reloadData()
    }
}

class SearchBookmarksDataSource: BookmarksDataSource {
    
    var searchResults = [Link]()
    private let searchEngine = BookmarksSearch()
    
    func performSearch(query: String) {
        let query = query.lowercased()
        searchResults = searchEngine.search(query: query, sortByRelevance: false)
    }

    override var isEmpty: Bool {
        return searchResults.isEmpty
    }

    override func link(at indexPath: IndexPath) -> Link? {
        guard indexPath.row < searchResults.count else {
            return nil
        }
        
        return searchResults[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return link(at: indexPath) != nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, searchResults.count)
    }
    
    override func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> NoBookmarksCell {
        let cell = super.createEmptyCell(tableView, forIndexPath: indexPath)
        
        cell.label.text = UserText.noMatchesFound
        
        return cell
    }
}

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
    
    typealias VisibleBookmarkItem = (item: BookmarkItem, depth: Int)
    
    func item(at indexPath: IndexPath) -> VisibleBookmarkItem? {
        return nil
    }
    
    var isEmpty: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if item(at: indexPath) != nil {
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

        let visibleItem = item(at: indexPath)
        cell.bookmarkItem = visibleItem?.item
        cell.depth = visibleItem?.depth ?? 0
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        //TODO folder tint
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
}

class DefaultBookmarksDataSource: BookmarksDataSource {

    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    //TODO variable parent
    
    //I'm really not sure we need this visible bookmark item idea...
    //don't know how we're goign to integrate with the folder screen...
    
    private lazy var visibleBookmarkItems: [VisibleBookmarkItem] = {
        return bookmarksManager.topLevelBookmarkItems.map {
            VisibleBookmarkItem($0, 0)
        }
    }()

    override var isEmpty: Bool {
        return bookmarksManager.favoritesCount == 0 && bookmarksManager.topLevelBookmarkItemsCount == 0
    }
    
    override func item(at indexPath: IndexPath) -> VisibleBookmarkItem? {
        if indexPath.section == 0 {
            guard let favorite = bookmarksManager.favorite(atIndex: indexPath.row) else { return nil }
            return VisibleBookmarkItem(favorite, 0)
        } else {
            if visibleBookmarkItems.count <= indexPath.row {
                return nil
            }
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
        return item(at: indexPath) != nil
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        var reload = false
        
        guard let item = item(at: indexPath)?.item else { return }
        bookmarksManager.delete(item: item)
        if indexPath.section == 0 {
            reload = bookmarksManager.favoritesCount == 0
        } else {
            reload = bookmarksManager.topLevelBookmarkItemsCount == 0
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
        // TODO lets do edit screen first cos moving is gonna be interesting
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
            //bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
            //bookmarksManager.moveFavorite(at: sourceIndexPath.row, toBookmark: destinationIndexPath.row)
            reload = bookmarksManager.favoritesCount == 0 || bookmarksManager.topLevelBookmarkItemsCount == 1
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 1 {
            //bookmarksManager.moveBookmark(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
            guard item(at: sourceIndexPath)?.item is Bookmark else {
                // Folders aren't allowed in favourites
                return
            }
            //bookmarksManager.moveBookmark(at: sourceIndexPath.row, toFavorite: destinationIndexPath.row)
            reload = bookmarksManager.topLevelBookmarkItemsCount == 0 || bookmarksManager.favoritesCount == 1
        }

        if reload {
            tableView.reloadData()
        }
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

//    override func link(at indexPath: IndexPath) -> Link? {
//        guard indexPath.row < searchResults.count else {
//            return nil
//        }
//        
//        return searchResults[indexPath.row]
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //return link(at: indexPath) != nil
        return false
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


/*
 //TODO I don't think we actually need this cos things can't actually expand
 //sigh, assumptions be wrong :(
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
 */

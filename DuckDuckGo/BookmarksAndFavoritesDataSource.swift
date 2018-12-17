//
//  BookmarksAndFavoritesDataSource.swift
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

class BookmarksAndFavoritesDataSource: BookmarksDataSource {
    
    private lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let emptyCell = cell as? NoBookmarksCell {
            emptyCell.label.text = indexPath.section == 0 ? UserText.emptyFavorites : UserText.emptyBookmarks
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? UserText.sectionTitleFavorites : UserText.sectionTitleBookmarks
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, section == 0 ? bookmarksManager.favoritesCount : bookmarksManager.bookmarksCount)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
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
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
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

    override func tableView(_ tableView: UITableView, updateBookmark updatedBookmark: Link, at indexPath: IndexPath) {
        let bookmarksManager = BookmarksManager()
        
        if indexPath.section == 0 {
            bookmarksManager.updateFavorite(at: indexPath.row, with: updatedBookmark)
        } else {
            bookmarksManager.updateBookmark(at: indexPath.row, with: updatedBookmark)
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return link(at: indexPath) != nil
    }

}

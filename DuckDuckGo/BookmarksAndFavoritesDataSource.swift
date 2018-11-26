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
    
    override func bookmark(at indexPath: IndexPath) -> Link {
        if indexPath.section == 0 {
            return bookmarksManager.favorite(atIndex: indexPath.row)
        } else {
            return bookmarksManager.bookmark(atIndex: indexPath.row)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isEmpty { return 1 }
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isEmpty else { return nil }
        return section == 0 ? UserText.sectionTitleFavorites : UserText.sectionTitleBookmarks
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmpty { return 1 }
        return section == 0 ? bookmarksManager.favoritesCount : bookmarksManager.bookmarksCount
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                bookmarksManager.deleteFavorite(at: indexPath.row)
            } else {
                bookmarksManager.deleteBookmark(at: indexPath.row)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
            bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
            bookmarksManager.moveFavorite(at: sourceIndexPath.row, toBookmark: destinationIndexPath.row)
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 1 {
            bookmarksManager.moveBookmark(at: sourceIndexPath.row, to: destinationIndexPath.row)
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
            bookmarksManager.moveBookmark(at: sourceIndexPath.row, toFavorite: destinationIndexPath.row)
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

}

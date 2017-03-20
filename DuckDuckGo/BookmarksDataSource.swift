//
//  BookmarksDataSource.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 17/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class BookmarksDataSource: NSObject, UITableViewDataSource {
    
    private lazy var bookmarksManager = BookmarksManager()
    
    var isEmpty: Bool {
        return bookmarksManager.isEmpty
    }
    
    func bookmark(atIndex index: Int) -> Link {
        return bookmarksManager.bookmark(atIndex: index)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEmpty { return 1 }
        return bookmarksManager.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if bookmarksManager.isEmpty {
            return createEmptyCell(tableView)
        }
        return createBookmarkCell(tableView, forIndex: indexPath.row)
    }
    
    private func createEmptyCell(_ tableView: UITableView) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier)!
    }
    
    private func createBookmarkCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        let bookmark = bookmarksManager.bookmark(atIndex: index)
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as! BookmarkCell
        cell.update(withBookmark: bookmark)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarksManager.delete(itemAtIndex: indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.move(itemAtIndex: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

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
    
    fileprivate lazy var groupData = GroupData()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let bookmarks = groupData.quickLinks, !isEmpty() else {
            return 1
        }
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmpty() {
            return createEmptyCell(tableView)
        }
        return createBookmarkCell(tableView, forIndex: indexPath.row)
    }
    
    private func createEmptyCell(_ tableView: UITableView) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier)!
    }
    
    private func createBookmarkCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        let data = groupData.quickLinks![index]
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as! BookmarkCell
        cell.title.text = data.title
        cell.showsReorderControl = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !isEmpty()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(itemAtIndex: indexPath.row)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        move(itemAtIndex: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    public func getData(atIndex index: Int) -> Link {
        return groupData.quickLinks![index]
    }
    
    private func delete(itemAtIndex index: Int) {
        if var newLinks = groupData.quickLinks {
            newLinks.remove(at: index)
            groupData.quickLinks = newLinks
        }
    }
    
    private func move(itemAtIndex oldIndex: Int, to newIndex: Int) {
        if var newLinks = groupData.quickLinks {
            let link = newLinks.remove(at: oldIndex)
            newLinks.insert(link, at: newIndex)
            groupData.quickLinks = newLinks
        }
    }
    
    func isEmpty() -> Bool {
        return groupData.quickLinks?.isEmpty ?? true
    }
}

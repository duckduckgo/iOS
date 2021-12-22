//
//  BookmarkSectionDataSources.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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
import CoreData

protocol BookmarkItemsSectionDataSource {
    
    var numberOfRows: Int { get }
    var isEmpty: Bool { get }
    
    func bookmarkItem(at index: Int) -> BookmarkItem?
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell
    func title() -> String?
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool
    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int)
}

extension BookmarkItemsSectionDataSource {
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if isEmpty {
            return createEmptyCell(tableView, forIndex: index)
        } else {
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func title() -> String? {
        return nil
    }
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool {
        return bookmarkItem(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !isEmpty
    }
    
    func createCell(_ tableView: UITableView, withItem item: BookmarkItem?) -> UITableViewCell {
        BookmarkCellCreator.createCell(tableView, withItem: item)
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        BookmarkCellCreator.createEmptyCell(tableView, forIndex: index)
    }
}

class FavoritesSectionDataSource: BookmarkItemsSectionDataSource {
    
    private let bookmarksManager: BookmarksManager
    
    var numberOfRows: Int {
        return max(1, bookmarksManager.favoritesCount)
    }
    
    var isEmpty: Bool {
        bookmarksManager.favoritesCount == 0
    }
    
    init(bookmarksManager: BookmarksManager) {
        self.bookmarksManager = bookmarksManager
    }
    
    func bookmarkItem(at index: Int) -> BookmarkItem? {
        bookmarksManager.favorite(atIndex: index)
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if isEmpty {
            return createEmptyCell(tableView, forIndex: index)
        } else {
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
 
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        let cell = (self as BookmarkItemsSectionDataSource).createEmptyCell(tableView, forIndex: index)
        cell.label.text =  UserText.emptyFavorites
        return cell
    }

    func title() -> String? {
        return UserText.sectionTitleFavorites
    }

    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        
        guard editingStyle == .delete else { return }

        guard let item = bookmarkItem(at: index) else { return }
        bookmarksManager.delete(item)
    }

}

protocol BookmarksSectionDataSourceDelegate: AnyObject {
    func bookmarksSectionDataSourceDidRequestViewControllerForDeleteAlert(_ bookmarksSectionDataSource: BookmarksSectionDataSource) ->
    UIViewController
}

class BookmarksSectionDataSource: BookmarkItemsSectionDataSource {
    
    private let bookmarksManager: BookmarksManager
    
    private let parentFolder: BookmarkFolder?
    weak var delegate: BookmarksSectionDataSourceDelegate?
    
    private func bookmarkItems() -> [BookmarkItem] {
        if let folder = parentFolder {
            return folder.children?.array as? [BookmarkItem] ?? []
        } else {
            return bookmarksManager.topLevelBookmarkItems
        }
    }
    
    var numberOfRows: Int {
        return max(1, bookmarkItems().count)
    }
    
    var isEmpty: Bool {
        bookmarkItems().count == 0
    }
    
    init(parentFolder: BookmarkFolder?, delegate: BookmarksSectionDataSourceDelegate?, bookmarksManager: BookmarksManager) {
        self.parentFolder = parentFolder
        self.delegate = delegate
        self.bookmarksManager = bookmarksManager
    }
    
    func bookmarkItem(at index: Int) -> BookmarkItem? {
        let items = bookmarkItems()
        if items.count <= index {
            return nil
        }
        return items[index]
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if isEmpty {
            tableView.separatorColor = parentFolder != nil  ? .clear : UIColor(named: "BookmarksCellSeperatorColor")
            return createEmptyCell(tableView, forIndex: index)
        } else {
            tableView.separatorColor = UIColor(named: "BookmarksCellSeperatorColor")
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func navigationTitle() -> String? {
        return parentFolder?.title
    }

    func title() -> String? {
        return parentFolder == nil ? UserText.sectionTitleBookmarks : nil
    }
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        guard editingStyle == .delete else { return }

        guard let item = bookmarkItem(at: index) else { return }
        if let delegate = delegate,
            let folder = item as? BookmarkFolder,
            (folder.children?.count ?? 0) > 0 {
            
            let title = String(format: UserText.deleteBookmarkFolderAlertTitle, folder.title ?? "")
            let count = folder.numberOfChildrenDeep
            let messageString: String
            if count == 1 {
                messageString = UserText.deleteBookmarkFolderAlertMessageSingular
            } else {
                messageString = UserText.deleteBookmarkFolderAlertMessagePlural
            }
            let message = String(format: messageString, count)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(title: UserText.deleteBookmarkFolderAlertDeleteButton, style: .default) {
                self.bookmarksManager.delete(item)
            }
            alertController.addAction(title: UserText.actionCancel, style: .cancel)
            let viewController = delegate.bookmarksSectionDataSourceDidRequestViewControllerForDeleteAlert(self)
            viewController.present(alertController, animated: true)
            
        } else {
            bookmarksManager.delete(item)
        }
    }

    private func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if parentFolder != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksInSubfolderCell.reuseIdentifier)
                    as? NoBookmarksInSubfolderCell else {
                        
                fatalError("Failed to dequeue \(NoBookmarksInSubfolderCell.reuseIdentifier) as NoBookmarksInSubfolderCell")
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
            return cell
        } else {
            return (self as BookmarkItemsSectionDataSource).createEmptyCell(tableView, forIndex: index)
        }
    }
}

class BookmarkCellCreator {
    
    static func createCell(_ tableView: UITableView, withItem item: BookmarkItem?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }

        cell.bookmarkItem = item
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
    
    static func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier) as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.label.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)

        return cell
    }
}

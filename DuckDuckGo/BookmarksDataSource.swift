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
import CoreData

//TODO I think this would have been waaaay easier if I'd made any none UITableViewDataSource methods part of a seperate protocol.
//let's do it

//I think that will allow is to break this down too, into the mainBookmarksviewDataSource
//and then the general concept of a sections manager

/*
 okay, so what does a hypotehtical mainBookmarksviewDataSource actually need?
 Needs to return bookmark items
 isEmpty
 showSearch
 navigation title?
 */

protocol MainBookmarksViewDataSource: UITableViewDataSource {
    var isEmpty: Bool { get }
    var showSearch: Bool { get }
    var favoritesSectionIndex: Int? { get }
    var navigationTitle: String? { get }
    var folder: BookmarkFolder? { get }
    var bookmarksManager: BookmarksManager { get }
    
    func item(at indexPath: IndexPath) -> BookmarkItem?
}

extension MainBookmarksViewDataSource {
    var folder: BookmarkFolder? {
        return nil
    }
}

//Todo I should just not have this? It's sort of stupid...
//yeah, only the actual bookmark data source (favourites, bookmarks, folders) should share a common source and maybe some kind of view controller mechanism (but even then probably get rid of the shared view controller at least for now?)
//e.g. edit folder view should defo have a different view controller chain
class BookmarksDataSource: NSObject, UITableViewDataSource {
    
    //TODO should inject bookmarksManager properly
    fileprivate var dataSources: [BookmarksSectionDataSource] = []
    
    fileprivate var sections: [BookmarksSection] = [] {
        didSet {
            dataSources = sections.map { $0.dataSource }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].numberOfRows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSources[section].title()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = dataSources[indexPath.section]
        return dataSource.cell(tableView, forIndex: indexPath.row)
    }
}

//TODO how would search fit into this?
enum BookmarksSection {
    case favourites
    case bookmarksShallow(parentFolder: BookmarkFolder?, delegate: BookmarksShallowSectionDataSourceDelegate?)
    
    var dataSource: BookmarksSectionDataSource {
        switch self {
        case .favourites:
            return FavoritesSectionDataSource()
        case .bookmarksShallow(let parentFolder, let delegate):
            return BookmarksShallowSectionDataSource(parentFolder: parentFolder, delegate: delegate)
        }
    }
}

//Okay, lets just ditch this whole thing :(
protocol BookmarksSectionDataSource {
    
    var numberOfRows: Int { get }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell
    func title() -> String?
        
}

extension BookmarksSectionDataSource {
    
    func title() -> String? {
        return nil
    }
    
}

typealias PresentableBookmarkItem = (item: BookmarkItem, depth: Int)

//maybe keep this one? idk...
protocol BookmarkItemsSectionDataSource: BookmarksSectionDataSource {
        
    var isEmpty: Bool { get }
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem?
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool
    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int)
    
}

//TODO none of this needs this visible bookmark thing...
extension BookmarkItemsSectionDataSource {
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool {
        return bookmarkItem(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !isEmpty
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if isEmpty {
            return createEmptyCell(tableView, forIndex: index)
        } else {
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func createCell(_ tableView: UITableView, withItem item: PresentableBookmarkItem?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }

        cell.bookmarkItem = item?.item
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
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

class FavoritesSectionDataSource: BookmarkItemsSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem? {
        guard let favorite = bookmarksManager.favorite(atIndex: index) else { return nil }
        return PresentableBookmarkItem(favorite, 0)
    }
    
    var isEmpty: Bool {
        bookmarksManager.favoritesCount == 0
    }
    
    var numberOfRows: Int {
        return max(1, bookmarksManager.favoritesCount)
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

        guard let item = bookmarkItem(at: index)?.item else { return }
        bookmarksManager.delete(item)
    }

}

//todo should be passing self into these delegate methods
protocol BookmarksShallowSectionDataSourceDelegate: AnyObject {
    func bookmarksShallowSectionDataSourceDidRequestViewControllerForDeleteAlert() ->
    UIViewController
}

class BookmarksShallowSectionDataSource: BookmarkItemsSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    private let parentFolder: BookmarkFolder?
    weak var delegate: BookmarksShallowSectionDataSourceDelegate?
    
    private func bookmarkItems() -> [PresentableBookmarkItem] {
        if let folder = parentFolder {
            let array = folder.children?.array as? [BookmarkItem] ?? []
            return array.map {
                PresentableBookmarkItem($0, 0)
            }
        } else {
            return bookmarksManager.topLevelBookmarkItems.map {
                PresentableBookmarkItem($0, 0)
            }
        }
    }
    
    var isEmpty: Bool {
        bookmarkItems().count == 0
    }
    
    init(parentFolder: BookmarkFolder?, delegate: BookmarksShallowSectionDataSourceDelegate?) {
        self.parentFolder = parentFolder
        self.delegate = delegate
    }
    
    //TODO some duplicaton here
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if isEmpty {
            tableView.separatorColor = parentFolder != nil  ? .clear : UIColor(named: "BookmarksCellSeperatorColor")
            return createEmptyCell(tableView, forIndex: index)
        } else {
            tableView.separatorColor = UIColor(named: "BookmarksCellSeperatorColor")
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if parentFolder != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksInSubfolderCell.reuseIdentifier) as? NoBookmarksInSubfolderCell else {
                fatalError("Failed to dequeue \(NoBookmarksInSubfolderCell.reuseIdentifier) as NoBookmarksInSubfolderCell")
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
            return cell
        } else {
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
    
    func navigationTitle() -> String? {
        return parentFolder?.title
    }
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem? {
        let items = bookmarkItems()
        if items.count <= index {
            return nil
        }
        return items[index]
    }
    
    var numberOfRows: Int {
        return max(1, bookmarkItems().count)
    }

    func title() -> String? {
        return parentFolder == nil ? UserText.sectionTitleBookmarks : nil
    }
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        guard editingStyle == .delete else { return }

        guard let item = bookmarkItem(at: index)?.item else { return }
        if let delegate = delegate,
            let folder = item as? BookmarkFolder,
            (folder.children?.count ?? 0) > 0 {
            let title = String(format: UserText.deleteBookmarkFolderAlertTitle, folder.title ?? "")
            let count = folder.children?.count ?? 0
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
            let viewController = delegate.bookmarksShallowSectionDataSourceDidRequestViewControllerForDeleteAlert()
            viewController.present(alertController, animated: true)
            
        } else {
            bookmarksManager.delete(item)
        }
    }

}

class DefaultBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    
    var favoritesSectionIndex: Int? {
        return parentFolder == nil ? 0 : nil
    }
    
    
    //TODO proper injection
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    var parentFolder: BookmarkFolder?
    
    private var itemsDataSources: [BookmarkItemsSectionDataSource] {
        //TODO I hate it
        return dataSources as! [BookmarkItemsSectionDataSource]
    }
        
    init(alertDelegate: BookmarksShallowSectionDataSourceDelegate?, parentFolder: BookmarkFolder? = nil) {
        self.parentFolder = parentFolder
        super.init()
        if parentFolder != nil {
            self.sections = [.bookmarksShallow(parentFolder: parentFolder, delegate: alertDelegate)]
        } else {
            self.sections = [.favourites, .bookmarksShallow(parentFolder: nil, delegate: alertDelegate)]
        }
    }
    
    var folder: BookmarkFolder? {
        return parentFolder
    }
    
    var isEmpty: Bool {
        let isSectionsEmpty = itemsDataSources.map { $0.isEmpty }
        return !isSectionsEmpty.contains(where: { !$0 })
    }
    
    var showSearch: Bool {
        return sections.count > 1
    }
    
    var navigationTitle: String? {
        let bookmarksDataSource = dataSources.first {
            $0.self is BookmarksShallowSectionDataSource
        } as? BookmarksShallowSectionDataSource
        return bookmarksDataSource?.navigationTitle()
    }
    
    func item(at indexPath: IndexPath) -> BookmarkItem? {
        if dataSources.count <= indexPath.section {
            return nil
        }
        return itemsDataSources[indexPath.section].bookmarkItem(at: indexPath.row)?.item
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !itemsDataSources[indexPath.section].isEmpty
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !itemsDataSources[indexPath.section].isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        itemsDataSources[indexPath.section].commit(tableView, editingStyle: editingStyle, forRowAt: indexPath.row, section: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        guard let item = item(at: sourceIndexPath) else {
            assertionFailure("Item does not exist")
            return
        }
        
        if sourceIndexPath.section == destinationIndexPath.section {
            bookmarksManager.updateIndex(of: item.objectID, newIndex: destinationIndexPath.row)
        } else if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
            bookmarksManager.convertFavoriteToBookmark(item.objectID, newIndex: destinationIndexPath.row)
        } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
            guard let bookmark = item as? Bookmark else {
                // Folders aren't allowed in favourites. We shouldn't be able to get here
                fatalError()
            }
            bookmarksManager.convertBookmarkToFavorite(bookmark.objectID, newIndex: destinationIndexPath.row)
        }
    }
}


//TODO integrate this into the whole sections data srouce thing
class SearchBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    var favoritesSectionIndex: Int? {
        return nil
    }
    
    
    //TODO injection here
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    var searchResults = [Bookmark]()
    private let searchEngine = BookmarksSearch()
    
    func performSearch(query: String, completion: @escaping () -> Void) {
        let query = query.lowercased()
        searchEngine.search(query: query, sortByRelevance: false) { results in
            self.searchResults = results
            completion()
        }
    }
    
    var isEmpty: Bool {
        return searchResults.isEmpty
    }
    
    var showSearch: Bool {
        sections.count > 1
    }
    
    var navigationTitle: String?
    
    func item(at indexPath: IndexPath) -> BookmarkItem? {
        return item(at: indexPath.row)
    }
    
    func item(at index: Int) -> Bookmark? {
        guard index < searchResults.count else {
            return nil
        }
        return searchResults[index]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return item(at: indexPath.row) != nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, searchResults.count)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isEmpty {
            return createEmptyCell(tableView, forIndex: indexPath.row)
        } else {
            let item = item(at: indexPath.row)
            return createCell(tableView, withItem: item)
        }
    }
    
    //TODO copied from section data source, should make this use section datasource.
    func createCell(_ tableView: UITableView, withItem item: Bookmark?) -> UITableViewCell {
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
    
    //TODO copied from section data source, should make this use section datasource.
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier) as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.label.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)

        cell.label.text = UserText.noMatchesFound
        return cell
    }
}

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

//todo fileprivate?
typealias PresentableBookmarkItem = (item: BookmarkItem, depth: Int)

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

protocol MainBookmarksViewDataSource {
    var isEmpty: Bool { get }
    
    func item(
}



//also, no function should be emmiting PresentableBookmarkItems outside of this file, no one else needs to know about the depth
class BookmarksDataSource: NSObject, UITableViewDataSource {
    
    fileprivate var dataSources: [BookmarksSectionDataSource] = []
    
    fileprivate var sections: [BookmarksSection] = [] {
        didSet {
            dataSources = sections.map { $0.dataSource }
        }
    }
    
    func item(at indexPath: IndexPath) -> PresentableBookmarkItem? {
        if dataSources.count <= indexPath.section {
            return nil
        }
        return dataSources[indexPath.section].bookmarkItem(at: indexPath.row)
    }
    
    var isEmpty: Bool {
        let isSectionsEmpty = dataSources.map { $0.containsBookmarkItems() }
        return !isSectionsEmpty.contains(where: { !$0 })
    }
    
    var showSearch: Bool {
        return false
    }
    
    func navigationTitle() -> String? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSources[section].title()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = dataSources[indexPath.section]
        return dataSource.cell(tableView, forIndex: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSources[indexPath.section].containsBookmarkItems()
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !dataSources[indexPath.section].containsBookmarkItems()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        dataSources[indexPath.section].commit(tableView, editingStyle: editingStyle, forRowAt: indexPath.row, section: indexPath.section)
    }
    
        func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            
            //original logic is, if both sections equal, don't need to reload, otherwise do
            //I have no idea what we'll need...
            
            //folders can't move to favorites
            
            //perhaps we should figure out what this will look like at the data layer first
            //sections will need to know about this, cos they'll need to update their own models
            
            //perhaps something like moverow(at, to: ) where to is optional, and if nil it's moving out of the section.
            //hmmm
    
//            var reload = false
//            if sourceIndexPath.section == 0 && destinationIndexPath.section == 0 {
//                //bookmarksManager.moveFavorite(at: sourceIndexPath.row, to: destinationIndexPath.row)
//            } else if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 {
//                //bookmarksManager.moveFavorite(at: sourceIndexPath.row, toBookmark: destinationIndexPath.row)
//                reload = bookmarksManager.favoritesCount == 0 || bookmarksManager.topLevelBookmarkItemsCount == 1
//            } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 1 {
//                //bookmarksManager.moveBookmark(at: sourceIndexPath.row, to: destinationIndexPath.row)
//            } else if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 {
//                guard item(at: sourceIndexPath)?.item is Bookmark else {
//                    // Folders aren't allowed in favourites
//                    return
//                }
//                //bookmarksManager.moveBookmark(at: sourceIndexPath.row, toFavorite: destinationIndexPath.row)
//                reload = bookmarksManager.topLevelBookmarkItemsCount == 0 || bookmarksManager.favoritesCount == 1
//            }
//
//            if reload {
//                tableView.reloadData()
//            }
        }
}

//TODO how would search fit into this?
enum BookmarksSection {
    case favourites
    case bookmarksShallow(parentFolder: Folder?)
    case folders
    case folderDetails(_ folder: Folder?)
    
    var dataSource: BookmarksSectionDataSource {
        switch self {
        case .favourites:
            return FavoritesSectionDataSource()
        case .bookmarksShallow(let parentFolder):
            return BookmarksShallowSectionDataSource(parentFolder: parentFolder)
        case .folders:
            return BookmarkFoldersSectionDataSource()
        case .folderDetails(let folder):
            return BookmarksFolderDetailsSectionDataSource(existingFolder: folder)
        }
    }
}

protocol BookmarksSectionDataSource {
    
    typealias PresentableBookmarkItem = (item: BookmarkItem, depth: Int)
    
    func title() -> String?
    
    func containsBookmarkItems() -> Bool
    
    func numberOfRows() -> Int
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem?
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell
            
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int)
        
}

extension BookmarksSectionDataSource {
    
    func title() -> String? {
        return nil
    }
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem? {
        return nil
    }
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool {
        return false
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return false
    }
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
    }
    
    func createCell(_ tableView: UITableView, withItem item: PresentableBookmarkItem?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }

        cell.bookmarkItem = item?.item
        cell.depth = item?.depth ?? 0
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        //TODO folder tint
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

class FavoritesSectionDataSource: BookmarksSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem? {
        guard let favorite = bookmarksManager.favorite(atIndex: index) else { return nil }
        return PresentableBookmarkItem(favorite, 0)
    }
    
    func containsBookmarkItems() -> Bool {
        bookmarksManager.favoritesCount == 0
    }
    
    func numberOfRows() -> Int {
        return max(1, bookmarksManager.favoritesCount)
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if containsBookmarkItems() {
            return createEmptyCell(tableView, forIndex: index)
        } else {
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        let cell = (self as BookmarksSectionDataSource).createEmptyCell(tableView, forIndex: index)
        cell.label.text =  UserText.emptyFavorites
        return cell
    }

    func title() -> String? {
        return UserText.sectionTitleFavorites
    }
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool {
        return bookmarkItem(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !containsBookmarkItems()
    }

    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        
        guard editingStyle == .delete else { return }

        guard let item = bookmarkItem(at: index)?.item else { return }
        //TODO actual deletion
        bookmarksManager.delete(item: item)
        
        let indexPath = IndexPath(row: index, section: section)
        if bookmarksManager.favoritesCount == 0 {
            // because we're replacing this cell with a place holder that says "no whatever yet"
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}

//why did I do any of this? we're never gonna mix and match...

class BookmarksShallowSectionDataSource: BookmarksSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    private let parentFolder: Folder?
    
    private lazy var presentableBookmarkItems: [PresentableBookmarkItem] = {
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
    }()
    
    init(parentFolder: Folder?) {
        self.parentFolder = parentFolder
    }
    
    func navigationTitle() -> String? {
        return parentFolder?.title
    }
    
    func bookmarkItem(at index: Int) -> PresentableBookmarkItem? {
        if presentableBookmarkItems.count <= index {
            return nil
        }
        return presentableBookmarkItems[index]
    }

    func containsBookmarkItems() -> Bool {
        presentableBookmarkItems.count == 0
    }
    
    func numberOfRows() -> Int {
        return max(1, presentableBookmarkItems.count)
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        if containsBookmarkItems() {
            return createEmptyCell(tableView, forIndex: index)
        } else {
            return createCell(tableView, withItem: bookmarkItem(at: index))
        }
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        let cell = (self as BookmarksSectionDataSource).createEmptyCell(tableView, forIndex: index)
        cell.label.text =  UserText.emptyBookmarks
        return cell
    }

    func title() -> String? {
        return UserText.sectionTitleBookmarks
    }
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool {
        return bookmarkItem(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !containsBookmarkItems()
    }
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        guard editingStyle == .delete else { return }

        guard let item = bookmarkItem(at: index)?.item else { return }
        //TODO actual deletion
        //gonna have to refresh presentablebookmarkitems too
        bookmarksManager.delete(item: item)

        let indexPath = IndexPath(row: index, section: section)
        //TODO this needs to take into account variable parent folder
        if bookmarksManager.topLevelBookmarkItemsCount == 0 {
            // because we're replacing this cell with a place holder that says "no whatever yet"
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}

class BookmarkFoldersSectionDataSource: BookmarksSectionDataSource {

    lazy var bookmarksManager: BookmarksManager = BookmarksManager()

    //TODO this really should just use folders internally if we can?
    private lazy var presentableBookmarkItems: [PresentableBookmarkItem] = {
        return visibleFolders(for: bookmarksManager.topLevelBookmarksFolder, depthOfFolder: 0)
    }()
    
    private var selectedRow = 0
    
    //TODO should this actually be optional?
    func item(at index: Int) -> PresentableBookmarkItem? {
        if presentableBookmarkItems.count <= index {
            return nil
        }
        return presentableBookmarkItems[index]
    }
    
    func containsBookmarkItems() -> Bool {
        // Don't count the top level item
        presentableBookmarkItems.count > 0
    }
    
    func numberOfRows() -> Int {
        return presentableBookmarkItems.count
    }
    
    func title() -> String? {
        NSLocalizedString("Location", comment: "Header for folder selection for bookmarks")
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier) as? BookmarkFolderCell else {
            fatalError("Failed to dequeue \(BookmarkFolderCell.reuseIdentifier) as BookmarkFolderCell")
        }
        
        let item = item(at: index)
        cell.folder = item?.item as? Folder
        cell.depth = item?.depth ?? 0
        cell.isSelected = index == selectedRow
        
        return cell
    }
    
    func select(_ tableView: UITableView, row: Int, section: Int) {
        let previousSelected = selectedRow
        selectedRow = row
        
        let indexesToReload = [IndexPath(row: row, section: section), IndexPath(row: previousSelected, section: section)]
        tableView.reloadRows(at: indexesToReload, with: .none)
    }
    
    func selected() -> BookmarkItem? {
        return item(at: selectedRow)?.item
    }
    
    private func visibleFolders(for folder: Folder, depthOfFolder: Int) -> [PresentableBookmarkItem] {
        let array = folder.children?.array as? [BookmarkItem] ?? []
        let folders = array.compactMap { $0 as? Folder }

        var visibleItems = [PresentableBookmarkItem(folder, depthOfFolder)]

        visibleItems.append(contentsOf: folders.map { folder -> [PresentableBookmarkItem] in
            return visibleFolders(for: folder, depthOfFolder: depthOfFolder + 1)
        }.flatMap { $0 })

        return visibleItems
    }
}

class BookmarksFolderDetailsSectionDataSource: BookmarksSectionDataSource {
    
    let existingFolder: Folder?

    init(existingFolder: Folder?) {
        self.existingFolder = existingFolder
    }
    
    func containsBookmarkItems() -> Bool {
        false
    }
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarksTextFieldCell.reuseIdentifier) as? BookmarksTextFieldCell else {
            fatalError("Failed to dequeue \(BookmarksTextFieldCell.reuseIdentifier) as BookmarksTextFieldCell")
        }
        
        cell.textField.text = existingFolder?.title
        return cell
    }
}

class DefaultBookmarksDataSource: BookmarksDataSource {

    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    init(parentFolder: Folder? = nil) {
        super.init()
        if parentFolder != nil {
            self.sections = [.bookmarksShallow(parentFolder: parentFolder)]
        } else {
            self.sections = [.favourites, .bookmarksShallow(parentFolder: nil)]
        }
    }
    
    override var showSearch: Bool {
        return sections.count > 1
    }
    
    override func navigationTitle() -> String? {
        let bookmarksDataSource = dataSources.first {
            $0.self is BookmarksShallowSectionDataSource
        } as? BookmarksShallowSectionDataSource
        return bookmarksDataSource?.navigationTitle()
    }
    
}

class BookmarksFolderDetailsDataSource: BookmarksDataSource {
    
    init(existingFolder: Folder? = nil) {
        super.init()
        self.sections = [.folderDetails(existingFolder), .folders]
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        guard let dataSource = dataSources[indexPath.section] as? BookmarkFoldersSectionDataSource else {
            return
        }
        
        dataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func save() {
        // TODO
        //need selected location, and the title. How get title?
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
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        //return link(at: indexPath) != nil
//        return false
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, searchResults.count)
    }
    
//    override func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> NoBookmarksCell {
//        let cell = super.createEmptyCell(tableView, forIndexPath: indexPath)
//
//        cell.label.text = UserText.noMatchesFound
//
//        return cell
//    }
}

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
    var navigationTitle: String? { get }
    
    func item(at indexPath: IndexPath) -> BookmarkItem?
}

protocol BookmarkItemDetailsDataSource: UITableViewDataSource {
    func select(_ tableView: UITableView, indexPath: IndexPath)
    func save(_ tableView: UITableView)
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
    case bookmarksShallow(parentFolder: BookmarkFolder?)
    case folders(_ item: BookmarkItem?)
    case folderDetails(_ folder: BookmarkFolder?)
    case bookmarkDetails(_ bookmark: Bookmark?)
    
    var dataSource: BookmarksSectionDataSource {
        switch self {
        case .favourites:
            return FavoritesSectionDataSource()
        case .bookmarksShallow(let parentFolder):
            return BookmarksShallowSectionDataSource(parentFolder: parentFolder)
        case .folders(let item):
            return BookmarkFoldersSectionDataSource(existingItem: item)
        case .folderDetails(let folder):
            return BookmarksFolderDetailsSectionDataSource(existingFolder: folder)
        case .bookmarkDetails(let bookmark):
            return BookmarkDetailsSectionDataSource(existingBookmark: bookmark)
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

class BookmarksShallowSectionDataSource: BookmarkItemsSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    private let parentFolder: BookmarkFolder?
    
    private lazy var presentableBookmarkItems: [PresentableBookmarkItem] = {
        if let folder = parentFolder {
            let array = folder.children.array as? [BookmarkItem] ?? []
            return array.map {
                PresentableBookmarkItem($0, 0)
            }
        } else {
            return bookmarksManager.topLevelBookmarkItems.map {
                PresentableBookmarkItem($0, 0)
            }
        }
    }()
    
    var isEmpty: Bool {
        presentableBookmarkItems.count == 0
    }
    
    init(parentFolder: BookmarkFolder?) {
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
    
    var numberOfRows: Int {
        return max(1, presentableBookmarkItems.count)
    }

    func title() -> String? {
        return UserText.sectionTitleBookmarks
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
    
    //TODO If a folder has subfolders and we edit the location, hide the subfolders in the folder structure"
    init(existingItem: BookmarkItem?) {
        if let item = existingItem, let parent = item.parent {
            let parentIndex = presentableBookmarkItems.firstIndex {
                $0.item.objectID == parent.objectID
            }
            selectedRow = parentIndex ?? 0
        }
    }
    
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
    
    var numberOfRows: Int {
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
        cell.folder = item?.item as? BookmarkFolder
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
    
    private func visibleFolders(for folder: BookmarkFolder, depthOfFolder: Int) -> [PresentableBookmarkItem] {
        let array = folder.children.array as? [BookmarkItem] ?? []
        let folders = array.compactMap { $0 as? BookmarkFolder }

        var visibleItems = [PresentableBookmarkItem(folder, depthOfFolder)]

        visibleItems.append(contentsOf: folders.map { folder -> [PresentableBookmarkItem] in
            return visibleFolders(for: folder, depthOfFolder: depthOfFolder + 1)
        }.flatMap { $0 })

        return visibleItems
    }
}

// TODO can currently select the cell in screwy way if you press the right bit
class BookmarksFolderDetailsSectionDataSource: BookmarksSectionDataSource {
    
    let initialTitle: String?

    init(existingFolder: BookmarkFolder?) {
        self.initialTitle = existingFolder?.title
    }
    
    func containsBookmarkItems() -> Bool {
        false
    }
    
    var numberOfRows: Int {
        return 1
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarksTextFieldCell.reuseIdentifier) as? BookmarksTextFieldCell else {
            fatalError("Failed to dequeue \(BookmarksTextFieldCell.reuseIdentifier) as BookmarksTextFieldCell")
        }
        
        cell.title = initialTitle
        return cell
    }
    
    func folderTitle(_ tableView: UITableView, section: Int) -> String? {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? BookmarksTextFieldCell else {
            assertionFailure("Could not get folder details cell")
            return nil
        }
        return cell.title
    }
}

class BookmarkDetailsSectionDataSource: BookmarksSectionDataSource {
    
    let initialTitle: String?
    let initialUrl: URL?

    init(existingBookmark: Bookmark?) {
        self.initialTitle = existingBookmark?.title
        self.initialUrl = existingBookmark?.url
    }
    
    func containsBookmarkItems() -> Bool {
        false
    }
    
    var numberOfRows: Int {
        return 1
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkDetailsCell.reuseIdentifier) as? BookmarkDetailsCell else {
            fatalError("Failed to dequeue \(BookmarkDetailsCell.reuseIdentifier) as BookmarkDetailsCell")
        }
        
        cell.title = initialTitle
        cell.urlString = initialUrl?.absoluteString
        //todo favicon
        return cell
    }
    
    func bookmarkTitle(_ tableView: UITableView, section: Int) -> String? {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? BookmarkDetailsCell else {
            assertionFailure("Could not get bookmark details cell")
            return nil
        }
        return cell.title
    }
    
    func bookmarkUrlString(_ tableView: UITableView, section: Int) -> String? {
       guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? BookmarkDetailsCell else {
           assertionFailure("Could not get bookmark details cell")
           return nil
       }
       return cell.urlString
   }
}

class DefaultBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    
    private var itemsDataSources: [BookmarkItemsSectionDataSource] {
        //TODO I hate it
        return dataSources as! [BookmarkItemsSectionDataSource]
    }
        
    init(parentFolder: BookmarkFolder? = nil) {
        super.init()
        if parentFolder != nil {
            self.sections = [.bookmarksShallow(parentFolder: parentFolder)]
        } else {
            self.sections = [.favourites, .bookmarksShallow(parentFolder: nil)]
        }
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

class BookmarkFolderDetailsDataSource: BookmarksDataSource, BookmarkItemDetailsDataSource {
        
    private let existingFolder: BookmarkFolder?
    
    init(existingFolder: BookmarkFolder? = nil) {
        self.existingFolder = existingFolder
        super.init()
        self.sections = [.folderDetails(existingFolder), .folders(existingFolder)]
        //TODO seriously need to get rid of this sections stuff
        //I like having the seperate data sources, but we should at least keep references to the individual data sources
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        guard let dataSource = dataSources[indexPath.section] as? BookmarkFoldersSectionDataSource else {
            return
        }
        
        dataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func save(_ tableView: UITableView) {
        let dataSource = dataSources[1] as! BookmarkFoldersSectionDataSource
        //TODO if this is nil, something has gone really wrong
        guard let selectedParent = dataSource.selected() as? BookmarkFolder else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }
        let detailsDataSource = dataSources[0] as! BookmarksFolderDetailsSectionDataSource
        let title = detailsDataSource.folderTitle(tableView, section: 0)
        // TODO inject bookmarks manager properly
        let manager = BookmarksManager()
        
        if let folder = existingFolder {
            manager.update(folderID: folder.objectID, newTitle: title, newParent: selectedParent)
        } else {
            manager.saveNewFolder(withTitle: title, parent: selectedParent)
        }
        
        //TODO on save, any number of views might have to change...
        //hmmm, we gonna have to audit that...
        //any instance of main bookmark view will need to
        //For this particular one, I don't think anything else will have to?
    }
}

class BookmarkDetailsDataSource: BookmarksDataSource, BookmarkItemDetailsDataSource {
        
    private let existingBookmark: Bookmark?
    private let isFavorite: Bool
    
    init(isFavorite: Bool, existingBookmark: Bookmark? = nil) {
        self.isFavorite = isFavorite
        self.existingBookmark = existingBookmark
        super.init()
        //TODO I think we should use the same one for favs
        if isFavorite {
            self.sections = [.bookmarkDetails(existingBookmark)]
        } else {
            self.sections = [.bookmarkDetails(existingBookmark), .folders(existingBookmark)]
        }
        //TODO seriously need to get rid of this sections stuff
        //I like having the seperate data sources, but we should at least keep references to the individual data sources
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        guard let dataSource = dataSources[indexPath.section] as? BookmarkFoldersSectionDataSource else {
            return
        }
        
        dataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func save(_ tableView: UITableView) {
        let dataSource = dataSources[1] as! BookmarkFoldersSectionDataSource
        //TODO if this is nil, something has gone really wrong
        guard let selectedParent = dataSource.selected() as? BookmarkFolder else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }
        let detailsDataSource = dataSources[0] as! BookmarkDetailsSectionDataSource
        let title = detailsDataSource.bookmarkTitle(tableView, section: 0)
        let urlString = detailsDataSource.bookmarkUrlString(tableView, section: 0)
        //TODO what should we do if the url is invalid
        // TODO inject bookmarks manager properly
        let manager = BookmarksManager()
        
        if let bookmark = existingBookmark {
            //TODO
        } else {
            //TODO
        }
        
        //TODO on save, any number of views might have to change...
        //hmmm, we gonna have to audit that...
        //any instance of main bookmark view will need to
        //For this particular one, I don't think anything else will have to?
    }
}

class SearchBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    
    var searchResults = [Link]()
    private let searchEngine = BookmarksSearch()
    
    func performSearch(query: String) {
        let query = query.lowercased()
        searchResults = searchEngine.search(query: query, sortByRelevance: false)
    }
    
    var isEmpty: Bool {
        return searchResults.isEmpty
    }
    
    var showSearch: Bool {
        sections.count > 1
    }
    
    var navigationTitle: String?
    
    func item(at indexPath: IndexPath) -> BookmarkItem? {
        guard indexPath.row < searchResults.count else {
            return nil
        }
        return nil
        //return searchResults[indexPath.row]
    }

//    override var isEmpty: Bool {
//        return searchResults.isEmpty
//    }

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

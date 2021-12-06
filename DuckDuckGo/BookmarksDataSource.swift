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

protocol BookmarkItemDetailsDataSource: UITableViewDataSource {
    func select(_ tableView: UITableView, indexPath: IndexPath)
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?)
}

protocol BookmarkItemDetailsDataSourceDidSaveDelegate: AnyObject {
    func bookmarkItemDetailsDataSource(_ bookmarkItemDetailsDataSource: BookmarkItemDetailsDataSource, createdNewFolderWithObjectID objectID: NSManagedObjectID)
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
    case folders(_ item: BookmarkItem?, parentFolder: BookmarkFolder?, delegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?)
    case folderDetails(_ folder: BookmarkFolder?, delegate: BookmarksFolderDetailsSectionDataSourceDelegate)
    case bookmarkDetails(_ bookmark: Bookmark?, delegate: BookmarkDetailsSectionDataSourceDelegate)
    
    var dataSource: BookmarksSectionDataSource {
        switch self {
        case .favourites:
            return FavoritesSectionDataSource()
        case .bookmarksShallow(let parentFolder, let delegate):
            return BookmarksShallowSectionDataSource(parentFolder: parentFolder, delegate: delegate)
        case .folders(let item, let parentFolder, let delegate):
            return BookmarkFoldersSectionDataSource(existingItem: item, initialParentFolder: parentFolder, delegate: delegate)
        case .folderDetails(let folder, let delegate):
            return BookmarksFolderDetailsSectionDataSource(existingFolder: folder, delegate: delegate)
        case .bookmarkDetails(let bookmark, let delegate):
            return BookmarkDetailsSectionDataSource(existingBookmark: bookmark, delegate: delegate)
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
            let title = String(format: NSLocalizedString("Delete %@?", comment: "Delete bookmark folder alert title"), folder.title ?? "")
            let count = folder.children?.count ?? 0
            let messageString: String
            if count == 1 {
                messageString = NSLocalizedString("Are you sure you want to delete this folder and %i item?", comment: "Delete bookmark folder alert message")
            } else {
                messageString = NSLocalizedString("Are you sure you want to delete this folder and %i items?", comment: "Delete bookmark folder alert message plural")
            }
            let message = String(format: messageString, count)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(title: NSLocalizedString("Delete", comment: "Delete bookmark folder alert delete button"), style: .default) {
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

protocol BookmarkFoldersSectionDataSourceAddFolderDelegate: AnyObject {
    func bookmarkFoldersSectionDataSourceDidRequestAddNewFolder(_ bookmarkFoldersSectionDataSource: BookmarkFoldersSectionDataSource)
}

class BookmarkFoldersSectionDataSource: BookmarksSectionDataSource {
    
    weak var delegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?

    lazy var bookmarksManager: BookmarksManager = BookmarksManager()

    //TODO this really should just use folders internally if we can?
    private lazy var presentableBookmarkItems: [PresentableBookmarkItem] = {
        guard let folder = bookmarksManager.topLevelBookmarksFolder else {
            return []
        }
        return visibleFolders(for: folder, depthOfFolder: 0)
    }()
    
    private var selectedRow = 0
    private let existingItem: BookmarkItem?
    private let shouldShowAddFolderCell: Bool
    
    init(existingItem: BookmarkItem?, initialParentFolder: BookmarkFolder?, delegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?) {
        self.existingItem = existingItem
        self.delegate = delegate
        self.shouldShowAddFolderCell = delegate != nil
                
        if let parent = existingItem?.parentFolder ?? initialParentFolder {
            let parentIndex = presentableBookmarkItems.firstIndex {
                $0.item.objectID == parent.objectID
            }
            selectedRow = parentIndex ?? 0
        }

    }
    
    func refreshFolders(_ tableView: UITableView, section: Int, andSelectFolderWithObjectID objectID: NSManagedObjectID) {
        
        guard let folder = bookmarksManager.topLevelBookmarksFolder else {
            return
        }
        presentableBookmarkItems = visibleFolders(for: folder, depthOfFolder: 0)
        let newIndex = presentableBookmarkItems.firstIndex {
            $0.item.objectID == objectID
        }
        if let index = newIndex {
            selectedRow = index
        }
        
        tableView.reloadData()
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
        return presentableBookmarkItems.count + (shouldShowAddFolderCell ? 1 : 0)
    }
    
    func title() -> String? {
        NSLocalizedString("Location", comment: "Header for folder selection for bookmarks")
    }
    
    func cell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier) as? BookmarkFolderCell else {
            fatalError("Failed to dequeue \(BookmarkFolderCell.reuseIdentifier) as BookmarkFolderCell")
        }
        
        if let item = item(at: index) {
            cell.folder = item.item as? BookmarkFolder
            cell.depth = item.depth
            cell.isSelected = index == selectedRow
            
            if index == 0 {
                cell.titleString = NSLocalizedString("Bookmarks", comment: "Top level bookmarks folder title")

            }
        } else {
            cell.setUpAddFolderCell()
            cell.isSelected = false
        }
        
        return cell
    }
    
    func select(_ tableView: UITableView, row: Int, section: Int) {
        if shouldShowAddFolderCell && row == numberOfRows - 1 {
            tableView.deselectRow(at: IndexPath(row: row, section: section), animated: true)
            delegate?.bookmarkFoldersSectionDataSourceDidRequestAddNewFolder(self)
        } else {
            let previousSelected = selectedRow
            selectedRow = row
            
            let indexesToReload = [IndexPath(row: row, section: section), IndexPath(row: previousSelected, section: section)]
            tableView.reloadRows(at: indexesToReload, with: .none)
        }
    }
    
    func selected() -> BookmarkItem? {
        return item(at: selectedRow)?.item
    }
    
    private func visibleFolders(for folder: BookmarkFolder, depthOfFolder: Int) -> [PresentableBookmarkItem] {
        let array = folder.children?.array as? [BookmarkItem] ?? []
        let folders: [BookmarkFolder] = array.compactMap {
            // If a folder has subfolders and we edit the location, hide the subfolders in the folder structure (so you can't insert a folder into itself
            if let folder = existingItem as? BookmarkFolder,
               folder.objectID == $0.objectID {
                return nil
            } else {
                return $0 as? BookmarkFolder
            }
        }

        var visibleItems = [PresentableBookmarkItem(folder, depthOfFolder)]

        visibleItems.append(contentsOf: folders.map { folder -> [PresentableBookmarkItem] in
            return visibleFolders(for: folder, depthOfFolder: depthOfFolder + 1)
        }.flatMap { $0 })

        return visibleItems
    }
}

protocol BookmarksFolderDetailsSectionDataSourceDelegate: AnyObject {
    func bookmarksFolderDetailsSectionDataSource(_ dataSource: BookmarksFolderDetailsSectionDataSource, titleTextFieldDidChange textField: UITextField)
    func bookmarksFolderDetailsSectionDataSourceTextFieldDidReturn(dataSource: BookmarksFolderDetailsSectionDataSource)
}

// TODO can currently select the cell in screwy way if you press the right bit
class BookmarksFolderDetailsSectionDataSource: BookmarksSectionDataSource {
    
    var currentTitle: String?
    weak var delegate: BookmarksFolderDetailsSectionDataSourceDelegate?

    init(existingFolder: BookmarkFolder?, delegate: BookmarksFolderDetailsSectionDataSourceDelegate) {
        self.delegate = delegate
        self.currentTitle = existingFolder?.title
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
        cell.textField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)

        
        cell.title = currentTitle
        cell.textField.becomeFirstResponder()
        cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        cell.selectionStyle = .none

        return cell
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        currentTitle = textField.text
        delegate?.bookmarksFolderDetailsSectionDataSource(self, titleTextFieldDidChange: textField)
    }
    
    @objc func textFieldDidReturn() {
        delegate?.bookmarksFolderDetailsSectionDataSourceTextFieldDidReturn(dataSource: self)
    }
    
    func folderTitle() -> String? {
        return currentTitle
    }
}

protocol BookmarkDetailsSectionDataSourceDelegate: AnyObject {
    func bookmarkDetailsSectionDataSource(_ dataSource: BookmarkDetailsSectionDataSource, textFieldDidChangeWithTitleText titleText: String?, urlText: String?)
    func bookmarkDetailsSectionDataSourceTextFieldDidReturn(dataSource: BookmarkDetailsSectionDataSource)
}

class BookmarkDetailsSectionDataSource: BookmarksSectionDataSource {
    
    var currentTitle: String?
    var currentURLString: String?
    weak var delegate: BookmarkDetailsSectionDataSourceDelegate?

    init(existingBookmark: Bookmark?, delegate: BookmarkDetailsSectionDataSourceDelegate) {
        self.currentTitle = existingBookmark?.title
        self.currentURLString = existingBookmark?.url?.absoluteString
        self.delegate = delegate
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
        
        cell.title = currentTitle
        cell.setUrlString(currentURLString)
        cell.setUp()
        cell.delegate = self
        return cell
    }
    
    func bookmarkTitle() -> String? {
        return currentTitle
    }
    
    func bookmarkUrlString() -> String? {
       return currentURLString
   }
}

extension BookmarkDetailsSectionDataSource: BookmarkDetailsCellDelegate {
    
    func bookmarkDetailsCellDelegate(_ cell: BookmarkDetailsCell, textFieldDidChangeWithTitleText titleText: String?, urlText: String?) {
        currentTitle = titleText
        currentURLString = urlText
        delegate?.bookmarkDetailsSectionDataSource(self, textFieldDidChangeWithTitleText: titleText, urlText: urlText)
    }
    
    func bookmarkDetailsCellDelegateTextFieldDidReturn(cell: BookmarkDetailsCell) {
        delegate?.bookmarkDetailsSectionDataSourceTextFieldDidReturn(dataSource: self)
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

class BookmarkFolderDetailsDataSource: BookmarksDataSource, BookmarkItemDetailsDataSource {
        
    private let existingFolder: BookmarkFolder?
    
    init(delegate: BookmarksFolderDetailsSectionDataSourceDelegate, addFolderDelegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?, existingFolder: BookmarkFolder? = nil, initialParentFolder: BookmarkFolder? = nil) {
        self.existingFolder = existingFolder
        super.init()
        self.sections = [.folderDetails(existingFolder, delegate: delegate), .folders(existingFolder, parentFolder: initialParentFolder, delegate: addFolderDelegate)]
        //TODO seriously need to get rid of this sections stuff
        //I like having the seperate data sources, but we should at least keep references to the individual data sources
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        guard let dataSource = dataSources[indexPath.section] as? BookmarkFoldersSectionDataSource else {
            return
        }
        
        dataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {
        
        let dataSource = dataSources[1] as! BookmarkFoldersSectionDataSource
        //TODO if this is nil, something has gone really wrong
        guard let selectedParent = dataSource.selected() as? BookmarkFolder else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }
        let detailsDataSource = dataSources[0] as! BookmarksFolderDetailsSectionDataSource
        let title = detailsDataSource.folderTitle() ?? ""
        // TODO inject bookmarks manager properly
        let manager = BookmarksManager()
        
        if let folder = existingFolder {
            manager.update(folderID: folder.objectID, newTitle: title, newParentID: selectedParent.objectID)
        } else {
            manager.saveNewFolder(withTitle: title, parentID: selectedParent.objectID) { folderID in
                DispatchQueue.main.async {
                    delegate?.bookmarkItemDetailsDataSource(self, createdNewFolderWithObjectID: folderID)
                }
            }
        }
    }
}

class BookmarkDetailsDataSource: BookmarksDataSource, BookmarkItemDetailsDataSource {
        
    private let existingBookmark: Bookmark?
    
    init(delegate: BookmarkDetailsSectionDataSourceDelegate, addFolderDelegate: BookmarkFoldersSectionDataSourceAddFolderDelegate, existingBookmark: Bookmark? = nil, initialParentFolder: BookmarkFolder? = nil) {
        self.existingBookmark = existingBookmark
        super.init()

        self.sections = [.bookmarkDetails(existingBookmark, delegate: delegate), .folders(existingBookmark, parentFolder: initialParentFolder, delegate: addFolderDelegate)]
    }
    
    func refreshFolders(_ tableView: UITableView, section: Int, andSelectFolderWithObjectID objectID: NSManagedObjectID) {
        let dataSource = dataSources[1] as! BookmarkFoldersSectionDataSource
        dataSource.refreshFolders(tableView, section: section, andSelectFolderWithObjectID: objectID)
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        guard let dataSource = dataSources[indexPath.section] as? BookmarkFoldersSectionDataSource else {
            return
        }
        
        dataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    //TODO some logic here is duplicated
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {
        let dataSource = dataSources[1] as! BookmarkFoldersSectionDataSource
        //TODO if this is nil, something has gone really wrong
        guard let selectedParent = dataSource.selected() as? BookmarkFolder else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }
        let detailsDataSource = dataSources[0] as! BookmarkDetailsSectionDataSource
        let title = detailsDataSource.bookmarkTitle() ?? ""
        var urlString = detailsDataSource.bookmarkUrlString() ?? ""
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") && !urlString.isBookmarklet() {
            urlString = "http://\(urlString)"
        }

        let optionalURL: URL?
        if urlString.isBookmarklet() {
            optionalURL = urlString.toEncodedBookmarklet()
            guard URL.isValidBookmarklet(url: optionalURL) else { return }
        } else {
            optionalURL = urlString.punycodedUrl
        }
        
        guard let url = optionalURL else { return }
        
        // TODO inject bookmarks manager properly
        let manager = BookmarksManager()
        
        if let bookmark = existingBookmark {
            manager.update(bookmark: bookmark, newTitle: title, newURL: url, newParentID: selectedParent.objectID)
        } else {
            manager.saveNewBookmark(withTitle: title, url: url, parentID: selectedParent.objectID)
        }
    }
}

class FavoriteDetailsDataSource: BookmarksDataSource, BookmarkItemDetailsDataSource {
    private let existingBookmark: Bookmark?
    
    init(delegate: BookmarkDetailsSectionDataSourceDelegate, existingBookmark: Bookmark? = nil) {
        self.existingBookmark = existingBookmark
        super.init()

        self.sections = [.bookmarkDetails(existingBookmark, delegate: delegate)]
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        
    }
    
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {
        let detailsDataSource = dataSources[0] as! BookmarkDetailsSectionDataSource
        let title = detailsDataSource.bookmarkTitle() ?? ""
        var urlString = detailsDataSource.bookmarkUrlString() ?? ""
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") && !urlString.isBookmarklet() {
            urlString = "http://\(urlString)"
        }

        let optionalURL: URL?
        if urlString.isBookmarklet() {
            optionalURL = urlString.toEncodedBookmarklet()
            guard URL.isValidBookmarklet(url: optionalURL) else { return }
        } else {
            optionalURL = urlString.punycodedUrl
        }
        
        guard let url = optionalURL else { return }
        
        // TODO inject bookmarks manager properly
        let manager = BookmarksManager()
        
        if let bookmark = existingBookmark {
            manager.update(favorite: bookmark, newTitle: title, newURL: url)
        } else {
            manager.saveNewFavorite(withTitle: title, url: url)
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

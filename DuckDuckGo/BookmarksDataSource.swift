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

class BookmarksDataSource: NSObject, UITableViewDataSource {
    
    fileprivate var dataSources: [BookmarksSectionDataSource] = []
    
    fileprivate var sections: [BookmarksSection] = [] {
        didSet {
            dataSources = sections.map { $0.dataSource! }
        }
    }
    
    func item(at indexPath: IndexPath) -> PresentableBookmarkItem? {
        if dataSources.count <= indexPath.section {
            return nil
        }
        return dataSources[indexPath.section].item(at: indexPath.row)
    }
    
    var isEmpty: Bool {
        let isSectionsEmpty = dataSources.map { $0.isEmpty() }
        return !isSectionsEmpty.contains(where: { !$0 })
    }
    
    var showSearch: Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func navigationTitle() -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSources[section].title()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = dataSources[indexPath.section]
        if item(at: indexPath) != nil {
            return dataSource.createCell(tableView, forIndex: indexPath.row)
        } else {
            return dataSource.createEmptyCell(tableView, forIndex: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSources[indexPath.section].item(at: indexPath.row) != nil
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !dataSources[indexPath.section].isEmpty()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        dataSources[indexPath.section].commit(tableView, editingStyle: editingStyle, forRowAt: indexPath.row, section: indexPath.section)
    }
}

//TODO how would search fit into this?
enum BookmarksSection {
    case favourites
    case bookmarksShallow(parentFolder: Folder?)
    case folders(parentFolder: Folder?)
    
    var dataSource: BookmarksSectionDataSource? {
        switch self {
        case .favourites:
            return FavoritesSectionDataSource()
        case .bookmarksShallow(let parentFolder):
            return BookmarksShallowSectionDataSource(parentFolder: parentFolder)
        case .folders(let parentFolder):
            return BookmarkFoldersSectionDataSource(parentFolder: parentFolder)
        }
    }
}

protocol BookmarksSectionDataSource {
    
    typealias PresentableBookmarkItem = (item: BookmarkItem, depth: Int)
    
    func title() -> String?
    
    func isEmpty() -> Bool
    
    func numberOfRows() -> Int
    
    func item(at index: Int) -> PresentableBookmarkItem?
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell
    
    func createCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell
    
    func canEditRow(_ tableView: UITableView, at index: Int) -> Bool

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int)
    
}

extension BookmarksSectionDataSource {
    
    func isEmpty() -> Bool {
        numberOfRows() == 0
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
    
    func createCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier) as? BookmarkCell else {
            fatalError("Failed to dequeue \(BookmarkCell.reuseIdentifier) as BookmarkCell")
        }

        let visibleItem = item(at: index)
        cell.bookmarkItem = visibleItem?.item
        cell.depth = visibleItem?.depth ?? 0
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.title.textColor = theme.tableCellTextColor
        //TODO folder tint
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
    
    func title() -> String? {
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
}

class FavoritesSectionDataSource: BookmarksSectionDataSource {
    
    lazy var bookmarksManager: BookmarksManager = BookmarksManager()
    
    func item(at index: Int) -> PresentableBookmarkItem? {
        guard let favorite = bookmarksManager.favorite(atIndex: index) else { return nil }
        return PresentableBookmarkItem(favorite, 0)
    }
    
    func isEmpty() -> Bool {
        bookmarksManager.favoritesCount == 0
    }
    
    func numberOfRows() -> Int {
        return max(1, bookmarksManager.favoritesCount)
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
        return item(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !isEmpty()
    }

    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        
        guard editingStyle == .delete else { return }

        guard let item = item(at: index)?.item else { return }
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
    
    func item(at index: Int) -> PresentableBookmarkItem? {
        if presentableBookmarkItems.count <= index {
            return nil
        }
        return presentableBookmarkItems[index]
    }
    
    func isEmpty() -> Bool {
        presentableBookmarkItems.count == 0
    }
    
    func numberOfRows() -> Int {
        return max(1, presentableBookmarkItems.count)
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
        return item(at: index) != nil
    }

    func canMoveRow(_ tableView: UITableView, at index: Int) -> Bool {
        return !isEmpty()
    }
    
    func commit(_ tableView: UITableView, editingStyle: UITableViewCell.EditingStyle, forRowAt index: Int, section: Int) {
        guard editingStyle == .delete else { return }

        guard let item = item(at: index)?.item else { return }
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
    private let parentFolder: Folder?

    init(parentFolder: Folder?) {
        self.parentFolder = parentFolder
    }

    private lazy var presentableBookmarkItems: [PresentableBookmarkItem] = {
        let folder = parentFolder ?? bookmarksManager.topLevelBookmarksFolder
        return visibleFolders(for: folder, depthOfFolder: 0)
    }()
    
    func item(at index: Int) -> PresentableBookmarkItem? {
        if presentableBookmarkItems.count <= index {
            return nil
        }
        return presentableBookmarkItems[index]
    }
    
    func isEmpty() -> Bool {
        presentableBookmarkItems.count == 0
    }
    
    func numberOfRows() -> Int {
        return presentableBookmarkItems.count
    }
    
    func createCell(_ tableView: UITableView, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier) as? BookmarkFolderCell else {
            fatalError("Failed to dequeue \(BookmarkFolderCell.reuseIdentifier) as BookmarkFolderCell")
        }
        
        let item = item(at: index)
        cell.folder = item?.item as? Folder
        cell.depth = item?.depth ?? 0
        
        return cell
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

class BookmarkFoldersDataSource: BookmarksDataSource {

    init(parentFolder: Folder? = nil) {
        super.init()
        self.sections = [.folders(parentFolder: parentFolder)]
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
    
//    override func createEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> NoBookmarksCell {
//        let cell = super.createEmptyCell(tableView, forIndexPath: indexPath)
//
//        cell.label.text = UserText.noMatchesFound
//
//        return cell
//    }
}

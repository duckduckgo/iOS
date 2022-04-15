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

class BookmarksDataSource: NSObject, UITableViewDataSource {
    
    fileprivate var sectionDataSources: [BookmarkItemsSectionDataSource] = []
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionDataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionDataSources[section].numberOfRows
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionDataSources[section].title()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = sectionDataSources[indexPath.section]
        return dataSource.cell(tableView, forIndex: indexPath.row)
    }
}

class DefaultBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    
    let bookmarksManager: BookmarksManager

    var parentFolder: BookmarkFolder?
        
    init(alertDelegate: BookmarksSectionDataSourceDelegate?,
         parentFolder: BookmarkFolder? = nil,
         bookmarksManager: BookmarksManager = BookmarksManager()) {
        
        self.parentFolder = parentFolder
        self.bookmarksManager = bookmarksManager
        super.init()
        let bookmarksDataSource = BookmarksSectionDataSource(parentFolder: parentFolder, delegate: alertDelegate, bookmarksManager: bookmarksManager)
        if parentFolder != nil {
            self.sectionDataSources = [bookmarksDataSource]
        } else {
            let favoritesDataSource = FavoritesSectionDataSource(bookmarksManager: bookmarksManager)
            self.sectionDataSources = [favoritesDataSource, bookmarksDataSource]
        }
    }
    
    var favoritesSectionIndex: Int? {
        return parentFolder == nil ? 0 : nil
    }
    
    var folder: BookmarkFolder? {
        return parentFolder
    }
    
    var isEmpty: Bool {
        let isSectionsEmpty = sectionDataSources.map { $0.isEmpty }
        return !isSectionsEmpty.contains(where: { !$0 })
    }
    
    var showSearch: Bool {
        return sectionDataSources.count > 1
    }
    
    var navigationTitle: String? {
        let bookmarksDataSource = sectionDataSources.first {
            $0.self is BookmarksSectionDataSource
        } as? BookmarksSectionDataSource
        return bookmarksDataSource?.navigationTitle()
    }
    
    func item(at indexPath: IndexPath) -> BookmarkItem? {
        if sectionDataSources.count <= indexPath.section {
            return nil
        }
        return sectionDataSources[indexPath.section].bookmarkItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !sectionDataSources[indexPath.section].isEmpty
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !sectionDataSources[indexPath.section].isEmpty
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        sectionDataSources[indexPath.section].commit(tableView, editingStyle: editingStyle, forRowAt: indexPath.row, section: indexPath.section)
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
                fatalError("Folders aren't allowed in favorites. We shouldn't be able to get here")
            }
            bookmarksManager.convertBookmarkToFavorite(bookmark.objectID, newIndex: destinationIndexPath.row)
        }
    }
}

class SearchBookmarksDataSource: BookmarksDataSource, MainBookmarksViewDataSource {
    
    let bookmarksManager: BookmarksManager
    
    init(bookmarksManager: BookmarksManager = BookmarksManager()) {
        self.bookmarksManager = bookmarksManager
    }
    
    var searchResults = [Bookmark]()
    
    var favoritesSectionIndex: Int? {
        return nil
    }
    
    var isEmpty: Bool {
        return searchResults.isEmpty
    }
    
    var showSearch: Bool {
        sectionDataSources.count > 1
    }
    
    var navigationTitle: String?
    
    func performSearch(query: String, searchEngine: BookmarksCachingSearch, completion: @escaping () -> Void) {
        let query = query.lowercased()
        searchEngine.search(query: query, sortByRelevance: false) { results in
            self.searchResults = results
            completion()
        }
    }
    
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
    
    func createCell(_ tableView: UITableView, withItem item: Bookmark?) -> UITableViewCell {
        BookmarkCellCreator.createCell(tableView, withItem: item)
    }
    
    func createEmptyCell(_ tableView: UITableView, forIndex index: Int) -> NoBookmarksCell {
        let cell = BookmarkCellCreator.createEmptyCell(tableView, forIndex: index)
        cell.label.text = UserText.noMatchesFound
        return cell
    }
}

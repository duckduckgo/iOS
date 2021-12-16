//
//  BookmarkItemDetailsDataSource.swift
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

protocol BookmarkItemDetailsDataSource: UITableViewDataSource {
    func select(_ tableView: UITableView, indexPath: IndexPath)
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?)
}

protocol BookmarkItemDetailsDataSourceDidSaveDelegate: AnyObject {
    func bookmarkItemDetailsDataSource(
        _ bookmarkItemDetailsDataSource: BookmarkItemDetailsDataSource,
        createdNewFolderWithObjectID objectID: NSManagedObjectID)
}

protocol BookmarkFolderDetailsDataSourceDelegate: AnyObject {
    func bookmarkFolderDetailsDataSource(_ dataSource: BookmarkFolderDetailsDataSource, titleTextFieldDidChange textField: UITextField)
    func bookmarkFolderDetailsDataSourceTextFieldDidReturn(dataSource: BookmarkFolderDetailsDataSource)
}

class BookmarkFolderDetailsDataSource: NSObject, BookmarkItemDetailsDataSource {
    
    weak var delegate: BookmarkFolderDetailsDataSourceDelegate?
    
    private let bookmarksManager: BookmarksManager
        
    private let existingFolder: BookmarkFolder?
    private let bookmarkFoldersSectionDataSource: BookmarkFoldersSectionDataSource

    private var currentTitle: String?
    
    init(delegate: BookmarkFolderDetailsDataSourceDelegate,
         addFolderDelegate: BookmarkFoldersSectionDataSourceAddFolderDelegate?,
         bookmarksManager: BookmarksManager = BookmarksManager(),
         existingFolder: BookmarkFolder? = nil,
         initialParentFolder: BookmarkFolder? = nil) {
        self.delegate = delegate
        self.bookmarksManager = bookmarksManager
        self.existingFolder = existingFolder
        self.currentTitle = existingFolder?.title
        self.bookmarkFoldersSectionDataSource = BookmarkFoldersSectionDataSource(
            existingItem: existingFolder,
            initialParentFolder: initialParentFolder,
            delegate: addFolderDelegate,
            bookmarksManager: bookmarksManager)
        super.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : bookmarkFoldersSectionDataSource.numberOfRows
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? bookmarkFoldersSectionDataSource.title() : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0 ? detailsCell(tableView) : bookmarkFoldersSectionDataSource.cell(tableView, forIndex: indexPath.row)
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        
        bookmarkFoldersSectionDataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {
        
        guard let selectedParent = bookmarkFoldersSectionDataSource.selected() else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }
        let title = currentTitle ?? ""
        
        if let folder = existingFolder {
            bookmarksManager.update(folderID: folder.objectID, newTitle: title, newParentID: selectedParent.objectID)
        } else {
            bookmarksManager.saveNewFolder(withTitle: title, parentID: selectedParent.objectID) { folderID, _ in
                guard let folderID = folderID else { return }
                delegate?.bookmarkItemDetailsDataSource(self, createdNewFolderWithObjectID: folderID)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        currentTitle = textField.text
        delegate?.bookmarkFolderDetailsDataSource(self, titleTextFieldDidChange: textField)
    }
    
    @objc func textFieldDidReturn() {
        delegate?.bookmarkFolderDetailsDataSourceTextFieldDidReturn(dataSource: self)
    }
}

private extension BookmarkFolderDetailsDataSource {
    
    func detailsCell(_ tableView: UITableView) -> BookmarksTextFieldCell {
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
}

protocol BookmarkOrFavoriteDetailsDataSourceDelegate: AnyObject {
    func bookmarkOrFavoriteDetailsDataSource(_ dataSource: BookmarkOrFavoriteDetailsDataSource,
                                             textFieldDidChangeWithTitleText titleText: String?,
                                             urlText: String?)
    func bookmarkOrFavoriteDetailsDataSourceTextFieldDidReturn(dataSource: BookmarkOrFavoriteDetailsDataSource)
}

class BookmarkOrFavoriteDetailsDataSource: NSObject, BookmarkDetailsCellDelegate {
    
    weak var delegate: BookmarkOrFavoriteDetailsDataSourceDelegate?
    
    var existingBookmark: Bookmark? {
        didSet {
            currentTitle = existingBookmark?.title
            currentURLString = existingBookmark?.url?.absoluteString
        }
    }
    
    var currentTitle: String?
    var currentURLString: String?
    
    func bookmarkDetailsCellDelegate(_ cell: BookmarkDetailsCell, textFieldDidChangeWithTitleText titleText: String?, urlText: String?) {
        currentTitle = titleText
        currentURLString = urlText
        delegate?.bookmarkOrFavoriteDetailsDataSource(self, textFieldDidChangeWithTitleText: titleText, urlText: urlText)
    }
    
    func bookmarkDetailsCellDelegateTextFieldDidReturn(cell: BookmarkDetailsCell) {
        delegate?.bookmarkOrFavoriteDetailsDataSourceTextFieldDidReturn(dataSource: self)
    }
    
    func detailsCell(_ tableView: UITableView) -> BookmarkDetailsCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkDetailsCell.reuseIdentifier) as? BookmarkDetailsCell else {
            fatalError("Failed to dequeue \(BookmarkDetailsCell.reuseIdentifier) as BookmarkDetailsCell")
        }
        
        cell.title = currentTitle
        cell.setUrlString(currentURLString)
        cell.setUp()
        cell.delegate = self
        return cell
    }
    
    func url() -> URL? {
        var urlString = currentURLString ?? ""
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") && !urlString.isBookmarklet() {
            urlString = "http://\(urlString)"
        }

        let optionalURL: URL?
        if urlString.isBookmarklet() {
            optionalURL = urlString.toEncodedBookmarklet()
            guard URL.isValidBookmarklet(url: optionalURL) else { return nil }
        } else {
            optionalURL = urlString.punycodedUrl
        }
        
        return optionalURL
    }
}

class BookmarkDetailsDataSource: BookmarkOrFavoriteDetailsDataSource, BookmarkItemDetailsDataSource {
        
    private let bookmarksManager: BookmarksManager
        
    private let bookmarkFoldersSectionDataSource: BookmarkFoldersSectionDataSource
        
    init(delegate: BookmarkOrFavoriteDetailsDataSourceDelegate,
         addFolderDelegate: BookmarkFoldersSectionDataSourceAddFolderDelegate,
         bookmarksManager: BookmarksManager = BookmarksManager(),
         existingBookmark: Bookmark? = nil,
         initialParentFolder: BookmarkFolder? = nil) {
        
        self.bookmarksManager = bookmarksManager
        self.bookmarkFoldersSectionDataSource = BookmarkFoldersSectionDataSource(
            existingItem: existingBookmark,
            initialParentFolder: initialParentFolder,
            delegate: addFolderDelegate,
            bookmarksManager: bookmarksManager)
        super.init()
        self.existingBookmark = existingBookmark
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : bookmarkFoldersSectionDataSource.numberOfRows
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? bookmarkFoldersSectionDataSource.title() : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0 ? detailsCell(tableView) : bookmarkFoldersSectionDataSource.cell(tableView, forIndex: indexPath.row)
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        if indexPath.section != 1 { return }
        
        bookmarkFoldersSectionDataSource.select(tableView, row: indexPath.row, section: indexPath.section)
    }
    
    func refreshFolders(_ tableView: UITableView, section: Int, andSelectFolderWithObjectID objectID: NSManagedObjectID) {
        bookmarkFoldersSectionDataSource.refreshFolders(tableView, section: section, andSelectFolderWithObjectID: objectID)
    }
    
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {

        guard let selectedParent = bookmarkFoldersSectionDataSource.selected() else {
            assertionFailure("BookmarkFoldersSectionDataSource selected folder nil, this shouldn't be possible. Folder will not be saved")
            return
        }

        let title = currentTitle ?? ""
        
        guard let url = url() else { return }
        
        if let bookmark = existingBookmark {
            bookmarksManager.update(bookmark: bookmark, newTitle: title, newURL: url, newParentID: selectedParent.objectID)
        } else {
            bookmarksManager.saveNewBookmark(withTitle: title, url: url, parentID: selectedParent.objectID)
        }
    }
}

class FavoriteDetailsDataSource: BookmarkOrFavoriteDetailsDataSource, BookmarkItemDetailsDataSource {
    
    private let bookmarksManager: BookmarksManager
    
    init(delegate: BookmarkOrFavoriteDetailsDataSourceDelegate,
         bookmarksManager: BookmarksManager = BookmarksManager(),
         existingBookmark: Bookmark? = nil) {
        self.bookmarksManager = bookmarksManager
        super.init()
        self.existingBookmark = existingBookmark
        self.delegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return detailsCell(tableView)
    }
    
    func select(_ tableView: UITableView, indexPath: IndexPath) {
        
    }
    
    func save(_ tableView: UITableView, delegate: BookmarkItemDetailsDataSourceDidSaveDelegate?) {

        let title = currentTitle ?? ""
        
        guard let url = url() else { return }
        
        if let bookmark = existingBookmark {
            bookmarksManager.update(favorite: bookmark, newTitle: title, newURL: url)
        } else {
            bookmarksManager.saveNewFavorite(withTitle: title, url: url)
        }
    }
    
}

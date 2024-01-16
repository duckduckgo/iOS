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
import Bookmarks
import Core

class BookmarksDataSource: NSObject, UITableViewDataSource {

    let viewModel: BookmarkListInteracting
    var onFaviconMissing: ((String) -> Void)?

    var isEmpty: Bool {
        viewModel.bookmarks.isEmpty
    }

    init(viewModel: BookmarkListInteracting) {
        self.viewModel = viewModel
        super.init()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let bookmark = viewModel.bookmark(at: indexPath.row) else {
            fatalError("No bookmark at index \(indexPath.row)")
        }

        if bookmark.isFolder {
            let cell = BookmarksViewControllerCellFactory.makeFolderCell(tableView, forIndexPath: indexPath)
            cell.titleLabel.text = bookmark.title
            cell.childrenCountLabel.text = "\(bookmark.childrenArray.count)"
            return cell
        } else {
            let cell = BookmarksViewControllerCellFactory.makeBookmarkCell(tableView, forIndexPath: indexPath)
            cell.faviconImageView.loadFavicon(forDomain: bookmark.urlObject?.host, usingCache: .fireproof) { [weak self] _, isFake in
                if isFake, let host = bookmark.urlObject?.host {
                    self?.onFaviconMissing?(host)
                }
            }
            cell.titleLabel.text = bookmark.title
            cell.favoriteImageViewContainer.isHidden = !bookmark.isFavorite(on: viewModel.favoritesDisplayMode.displayedFolder)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.bookmarks.isEmpty
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return !viewModel.bookmarks.isEmpty
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let bookmark = viewModel.bookmark(at: sourceIndexPath.row) else { return }
        viewModel.moveBookmark(bookmark, fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }

}

class SearchBookmarksDataSource: NSObject, UITableViewDataSource {

    let searchEngine: BookmarksStringSearch
    var results = [BookmarksStringSearchResult]()

    init(searchEngine: BookmarksStringSearch) {
        self.searchEngine = searchEngine
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(1, results.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if results.isEmpty {
            return BookmarksViewControllerCellFactory.makeNoResultsCell(tableView)
        }

        let cell = BookmarksViewControllerCellFactory.makeBookmarkCell(tableView, forIndexPath: indexPath)
        cell.faviconImageView.loadFavicon(forDomain: results[indexPath.row].url.host, usingCache: .fireproof)
        cell.titleLabel.text = results[indexPath.row].title
        cell.favoriteImageViewContainer.isHidden = !results[indexPath.row].isFavorite
        return cell
    }

    func performSearch(_ text: String) {
        results = searchEngine.search(query: text)
    }

    func toggleFavorite(at index: Int) {
        results[index] = results[index].togglingFavorite()
    }

}

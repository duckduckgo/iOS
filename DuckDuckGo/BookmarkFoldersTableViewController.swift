//
//  BookmarkFoldersTableViewController.swift
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
import Bookmarks

protocol BookmarkFoldersViewControllerDelegate: AnyObject {

    func textDidChange(_ controller: BookmarkFoldersViewController)
    func textDidReturn(_ controller: BookmarkFoldersViewController)
    func addFolder(_ controller: BookmarkFoldersViewController)

}

class BookmarkFoldersViewController: UITableViewController {

    weak var delegate: BookmarkFoldersViewControllerDelegate?

    var viewModel: BookmarkEditorViewModel?
    var selected: IndexPath?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0 else { return }
        guard let viewModel = viewModel else {
            assertionFailure("No view model")
            return
        }

        if indexPath.row >= viewModel.locations.count {
            delegate?.addFolder(self)
        } else {
            viewModel.selectLocationAtIndex(indexPath.row)
            if let selected = selected {
                tableView.reloadRows(at: [
                    selected,
                    indexPath
                ], with: .automatic)
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return viewModel?.bookmark.isFolder == true ?
                detailCellForFolder(tableView) :
                detailCellForBookmark(tableView)
        } else if indexPath.row >= viewModel?.locations.count ?? 0 {
            return tableView.dequeueReusableCell(withIdentifier: "AddFolderCell")!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier)
            if let viewModel = viewModel, let folderCell = cell as? BookmarkFolderCell {
                folderCell.folder = viewModel.locations[indexPath.row].bookmark
                folderCell.depth = viewModel.locations[indexPath.row].depth
                folderCell.isSelected = viewModel.isSelected(viewModel.locations[indexPath.row].bookmark)
                if folderCell.isSelected {
                    selected = indexPath
                }
            }
            return cell!
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return section == 0 ? 1 : viewModel.locations.count + (viewModel.canAddNew ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? UserText.bookmarkFolderSelectTitle : nil
    }

    func detailCellForBookmark(_ tableView: UITableView) -> BookmarkDetailsCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkDetailsCell.reuseIdentifier) as? BookmarkDetailsCell else {
            fatalError("Failed to dequeue \(BookmarkDetailsCell.reuseIdentifier) as BookmarkDetailsCell")
        }
        cell.titleTextField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.titleTextField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        cell.titleTextField.becomeFirstResponder()
        cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.titleTextField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)

        cell.urlTextField.removeTarget(self, action: #selector(urlTextFieldDidChange(_:)), for: .editingChanged)
        cell.urlTextField.removeTarget(self, action: #selector(urlTextFieldDidReturn), for: .editingDidEndOnExit)
        cell.urlTextField.becomeFirstResponder()
        cell.urlTextField.addTarget(self, action: #selector(urlTextFieldDidChange(_:)), for: .editingChanged)
        cell.urlTextField.addTarget(self, action: #selector(urlTextFieldDidReturn), for: .editingDidEndOnExit)

        cell.faviconImageView.loadFavicon(forDomain: viewModel?.bookmark.urlObject?.host?.droppingWwwPrefix(),
                                          usingCache: .bookmarks)

        cell.selectionStyle = .none
        cell.title = viewModel?.bookmark.title
        cell.urlString = viewModel?.bookmark.url
        return cell
    }

    func detailCellForFolder(_ tableView: UITableView) -> BookmarksTextFieldCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarksTextFieldCell.reuseIdentifier) as? BookmarksTextFieldCell else {
            fatalError("Failed to dequeue \(BookmarksTextFieldCell.reuseIdentifier) as BookmarksTextFieldCell")
        }
        cell.textField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        cell.textField.becomeFirstResponder()
        cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)

        cell.selectionStyle = .none
        cell.title = viewModel?.bookmark.title
        return cell
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        viewModel?.bookmark.title = textField.text?.trimmingWhitespace()
        delegate?.textDidChange(self)
    }

    @objc func textFieldDidReturn() {
        if viewModel?.bookmark.isFolder == true {
            delegate?.textDidReturn(self)
        }
    }

    @objc func urlTextFieldDidChange(_ textField: UITextField) {
        viewModel?.bookmark.url = textField.text?.trimmingWhitespace()
        delegate?.textDidChange(self)
    }

    @objc func urlTextFieldDidReturn() {
        delegate?.textDidReturn(self)
    }

}

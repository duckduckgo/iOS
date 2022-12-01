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

    var locationCount: Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.locations.count
    }

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

        if viewModel?.bookmark.isFolder == true {
            switch indexPath.section {
            case 0:
                return detailCellForFolder(tableView)

            case 1:
                return folderSelectorCell(tableView, forIndexPath: indexPath)

            default:
                fatalError("Unexpected section")
            }
        } else {
            switch indexPath.section {
            case 0:
                return titleAndUrlCellForBookmark(tableView)

            case 1:
                return favoriteCellForBookmark(tableView)

            case 2:
                return indexPath.row >= locationCount ?
                    tableView.dequeueReusableCell(withIdentifier: "AddFolderCell")! :
                    folderSelectorCell(tableView, forIndexPath: indexPath)

            default:
                fatalError("Unexpected section")
            }
        }
    }

    func folderSelectorCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier) else {
            fatalError("Failed to dequeue cell for BookmarkFolder")
        }
        if let viewModel = viewModel, let folderCell = cell as? BookmarkFolderCell {
            folderCell.folder = viewModel.locations[indexPath.row].bookmark
            folderCell.depth = viewModel.locations[indexPath.row].depth
            folderCell.isSelected = viewModel.isSelected(viewModel.locations[indexPath.row].bookmark)
            if folderCell.isSelected {
                selected = indexPath
            }
        }
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.bookmark.isFolder == true ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            assertionFailure()
            return 0
        }

        let locationCount = self.locationCount + (viewModel.canAddNewFolder ? 1 : 0)
        if viewModel.bookmark.isFolder {
            switch section {
            case 0: return 1
            case 1: return locationCount
            default: fatalError("Unexpected section")
            }
        } else {
            switch section {
            case 0: return 1
            case 1: return 1
            case 2: return locationCount
            default: fatalError("Unexpected section")
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel?.bookmark.isFolder == true {
            return section == 1 ? UserText.bookmarkFolderSelectTitle : nil
        } else {
            return section == 2 ? UserText.bookmarkFolderSelectTitle : nil
        }
    }

    func favoriteCellForBookmark(_ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseIdentifier) as? FavoriteCell else {
            fatalError("Failed to dequeue \(FavoriteCell.reuseIdentifier) as FavoriteCell")
        }

        cell.favoriteToggle.isOn = viewModel?.bookmark.isFavorite == true
        cell.favoriteToggle.removeTarget(self, action: #selector(favoriteToggleDidChange(_:)), for: .valueChanged)
        cell.favoriteToggle.addTarget(self, action: #selector(favoriteToggleDidChange(_:)), for: .valueChanged)
        cell.favoriteToggle.onTintColor = ThemeManager.shared.currentTheme.buttonTintColor

        return cell
    }

    func titleAndUrlCellForBookmark(_ tableView: UITableView) -> UITableViewCell {
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

        cell.faviconImageView.loadFavicon(forDomain: viewModel?.bookmark.urlObject?.host, usingCache: .bookmarks)

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

    @objc func favoriteToggleDidChange(_ toggle: UISwitch) {
        if toggle.isOn {
            viewModel?.addToFavorites()
        } else {
            viewModel?.removeFromFavorites()
        }
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

    func refresh() {
        viewModel?.refresh()
        tableView.reloadData()
    }

}

class FavoriteCell: UITableViewCell {

    static let reuseIdentifier = "FavoriteCell"

    @IBOutlet var favoriteToggle: UISwitch!

}

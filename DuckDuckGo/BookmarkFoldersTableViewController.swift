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

}

class BookmarkFoldersViewController: UITableViewController {

    weak var delegate: BookmarkFoldersViewControllerDelegate?

    var editingFolder: BookmarkEntity?
    var parentFolder: BookmarkEntity?
    var folderList = [BookmarkEntity]()

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        #warning("Allow selecting an item in the list")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return detailsCell(tableView)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkFolderCell.reuseIdentifier, for: indexPath)
            if let folderCell = cell as? BookmarkFolderCell {
                folderCell.folder = folderList[indexPath.row]
                folderCell.isSelected = parentFolder?.objectID == folderCell.folder?.objectID
            }
            return cell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : folderList.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? UserText.bookmarkFolderSelectTitle : nil
    }

    func detailsCell(_ tableView: UITableView) -> BookmarksTextFieldCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarksTextFieldCell.reuseIdentifier) as? BookmarksTextFieldCell else {
            fatalError("Failed to dequeue \(BookmarksTextFieldCell.reuseIdentifier) as BookmarksTextFieldCell")
        }
        cell.textField.removeTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.removeTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)

        cell.title = self.editingFolder?.title
        cell.textField.becomeFirstResponder()
        cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        cell.selectionStyle = .none

        return cell
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        editingFolder?.title = textField.text
        delegate?.textDidChange(self)
    }

    @objc func textFieldDidReturn() {
        delegate?.textDidReturn(self)
    }

}

//
//  BookmarksViewControllerCells.swift
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
import DesignResourcesKit

class BookmarkCell: UITableViewCell {

    static let reuseIdentifier = "BookmarkCell"

    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteImageViewContainer: UIView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    
}

class FolderCell: UITableViewCell {

    static let reuseIdentifier = "FolderCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var childrenCountLabel: UILabel!

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        childrenCountLabel.isHidden = editing
    }

}

class NoResultsCell: UITableViewCell {

    @IBOutlet var label: UILabel!

    static let reuseIdentifier = "NoResultsCell"
}

class BookmarksViewControllerCellFactory {

    static func makeNoResultsCell(_ tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.reuseIdentifier) as? NoResultsCell else {
            fatalError("Failed to dequeue no results cell")
        }

        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.label.textColor = theme.tableCellTextColor

        return cell
    }

    static func makeBookmarkCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> BookmarkCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier, for: indexPath) as? BookmarkCell else {
            fatalError("Failed to dequeue bookmark item")
        }

        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.titleLabel.textColor = theme.tableCellTextColor
        cell.favoriteImageView.tintColor = UIColor(designSystemColor: .icons)
        cell.editingAccessoryType = .disclosureIndicator
        return cell
    }

    static func makeFolderCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> FolderCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FolderCell.reuseIdentifier, for: indexPath) as? FolderCell else {
            fatalError("Failed to dequeue folder cell")
        }

        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.titleLabel.textColor = theme.tableCellTextColor
        cell.childrenCountLabel.textColor = theme.tableCellTextColor
        cell.editingAccessoryType = .disclosureIndicator
        return cell
    }

}

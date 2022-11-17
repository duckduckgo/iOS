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

class BookmarkCell: UITableViewCell {

    static let reuseIdentifier = "BookmarkCell"

    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

}

class FolderCell: UITableViewCell {

    static let reuseIdentifier = "FolderCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var childrenCountLabel: UILabel!

}

class NoBookmarksCell: UITableViewCell {

    @IBOutlet var label: UILabel!

    static let reuseIdentifier = "NoBookmarksCell"
}

class BookmarksViewControllerCellFactory {

    static func makeEmptyCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath, inFolder: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoBookmarksCell.reuseIdentifier, for: indexPath)
                as? NoBookmarksCell else {
            fatalError("Failed to dequeue \(NoBookmarksCell.reuseIdentifier) as NoBookmarksCell")
        }
        let theme = ThemeManager.shared.currentTheme
        cell.label.textColor = theme.tableCellTextColor
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        return cell
    }

    static func makeBookmarkCell(_ tableView: UITableView, forIndexPath indexPath: IndexPath) -> BookmarkCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkCell.reuseIdentifier, for: indexPath) as? BookmarkCell else {
            fatalError("Failed to dequeue bookmark item")
        }

        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.titleLabel.textColor = theme.tableCellTextColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
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
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        return cell
    }

}

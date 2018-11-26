//
//  BookmarksViewController.swift
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

class BookmarksViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!

    weak var delegate: BookmarksDelegate?

    // TODO variant
    fileprivate lazy var dataSource = BookmarksAndFavoritesDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        addAplicationActiveObserver()
        configureTableView()
        refreshEditButton()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            showEditBookmarkAlert(for: indexPath)
        } else {
            selectBookmark(dataSource.bookmark(at: indexPath))
        }
    }

    private func addAplicationActiveObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationBecameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func configureTableView() {
        tableView.dataSource = dataSource
    }

    @objc func onApplicationBecameActive(notification: NSNotification) {
        tableView.reloadData()
    }

    private func refreshEditButton() {
        if dataSource.isEmpty {
            disableEditButton()
        } else {
            enableEditButton()
        }
    }

    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        startEditing()
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing && !dataSource.isEmpty {
            finishEditing()
        } else {
            dismiss()
        }
    }

    private func startEditing() {
        tableView.isEditing = true
        disableEditButton()
    }

    private func finishEditing() {
        tableView.isEditing = false
        refreshEditButton()
    }

    private func enableEditButton() {
        editButton.title = UserText.navigationTitleEdit
        editButton.isEnabled = true
    }

    private func disableEditButton() {
        editButton.title = ""
        editButton.isEnabled = false
    }

    fileprivate func showEditBookmarkAlert(for indexPath: IndexPath) {
        let title = UserText.alertEditBookmark
        let link = dataSource.bookmark(at: indexPath)
        let alert = EditBookmarkAlert.buildAlert(
            title: title,
            bookmark: link,
            saveCompletion: { [weak self] (updatedBookmark) in
                self?.dataSource.tableView(self!.tableView, updateBookmark: updatedBookmark, at: indexPath)
            },
            cancelCompletion: {}
        )
        present(alert, animated: true)
    }

    fileprivate func selectBookmark(_ bookmark: Link) {
        dismiss()
        delegate?.bookmarksDidSelect(link: bookmark)
    }

    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}

extension BookmarksViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        tableView.reloadData()
    }
}

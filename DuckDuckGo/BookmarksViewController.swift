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
import os.log

class BookmarksViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!

    weak var delegate: BookmarksDelegate?
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    fileprivate lazy var dataSource: BookmarksDataSource = {
        return BookmarksDataSource()
    }()
    
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
        } else if let link = dataSource.link(at: indexPath) {
            selectLink(link)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let shareContextualAction = UIContextualAction(style: .normal, title: UserText.actionShare) { (_, _, completionHandler) in
            self.showShareSheet(for: indexPath)
            completionHandler(true)
        }
        shareContextualAction.backgroundColor = UIColor.cornflowerBlue
        return UISwipeActionsConfiguration(actions: [shareContextualAction])
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
        let link = dataSource.link(at: indexPath)
        let alert = EditBookmarkAlert.buildAlert(
            title: title,
            bookmark: link,
            saveCompletion: { [weak self] (updatedBookmark) in
                self?.dataSource.tableView(self!.tableView, updateBookmark: updatedBookmark, at: indexPath)
            }
        )
        present(alert, animated: true)
    }
    
    fileprivate func showShareSheet(for indexPath: IndexPath) {

        if let link = dataSource.link(at: indexPath) {
            let appUrls: AppUrls = AppUrls()
            let url = appUrls.removeATBAndSource(fromUrl: link.url)
            presentShareSheet(withItems: [ url, link ], fromView: self.view)
        } else {
            os_log("Invalid share link found", log: generalLog, type: .debug)
        }
    }

    fileprivate func selectLink(_ link: Link) {
        dismiss()
        delegate?.bookmarksDidSelect(link: link)
    }

    private func dismiss() {
        delegate?.bookmarksUpdated()
        dismiss(animated: true, completion: nil)
    }

}

extension BookmarksViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        if #available(iOS 13.0, *) {
            overrideSystemTheme(with: theme)
        }
        
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        tableView.reloadData()
    }
}

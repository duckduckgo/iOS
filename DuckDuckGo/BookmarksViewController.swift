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

class BookmarksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    weak var delegate: BookmarksDelegate?
    
    fileprivate lazy var dataSource = BookmarksDataSource()
    
    static func loadFromStoryboard(delegate: BookmarksDelegate) -> BookmarksViewController {
        let controller = UIStoryboard(name: "Bookmarks", bundle: nil).instantiateInitialViewController() as! BookmarksViewController
        controller.delegate = delegate
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAplicationActiveObserver()
        tableView.dataSource = dataSource
        refreshEditButton()
    }
    
    deinit {
        removeApplicationActiveObserver()
    }
    
    private func addAplicationActiveObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onApplicationBecameActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    private func removeApplicationActiveObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    func onApplicationBecameActive(notification: NSNotification) {
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
    
    fileprivate func showEditBookmarkAlert(forIndex index: Int) {
        let title = UserText.alertEditBookmark
        let bookmark = dataSource.bookmark(atIndex: index)
        let alert = EditBookmarkAlert.buildAlert(
            title: title,
            bookmark: bookmark,
            saveCompletion: { [weak self] (updatedBookmark) in self?.updateBookmark(updatedBookmark, atIndex: index) },
            cancelCompletion: {}
        )
        present(alert, animated: true)
    }
    
    private func updateBookmark(_ updatedBookmark: Link, atIndex index: Int) {
        let bookmarksManager = BookmarksManager()
        bookmarksManager.update(index: index, withBookmark: updatedBookmark)
        tableView.reloadData()
    }
    
    fileprivate func selectBookmark(_ bookmark: Link) {
        delegate?.bookmarksDidSelect(link:  bookmark)
        dismiss()
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension BookmarksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            showEditBookmarkAlert(forIndex: indexPath.row)
        } else {
            selectBookmark(dataSource.bookmark(atIndex: indexPath.row))
        }
    }
}

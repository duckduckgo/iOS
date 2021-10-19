//
//  AddOrEditBookmarkViewController.swift
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

class AddOrEditBookmarkViewController: UIViewController {
    
    private var foldersViewController: BookmarkFoldersViewController?
    
    var isFavorite = false
    var isAlertController = false
    
    private var existingBookmark: Bookmark?
    private var initialParentFolder: BookmarkFolder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpDoneButton()
    }
    
    private func setUpTitle() {
        if let bookmark = existingBookmark {
            if bookmark.isFavorite {
                title = NSLocalizedString("Edit Favorite", comment: "Edit favorite screen title")
            } else {
                title = NSLocalizedString("Edit Bookmark", comment: "Edit bookmark screen title")
            }
        } else {
            if isFavorite {
                title = NSLocalizedString("Add Favorite", comment: "Add favorite screen title")
            } else {
                title = NSLocalizedString("Add Bookmark", comment: "Add bookmark screen title")
            }
        }
    }
    
    func setUpDoneButton() {
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        if let bookmark = existingBookmark,
           let title = bookmark.title,
           title.trimWhitespace().count > 0,
           let url = bookmark.url,
           url.absoluteString.count > 0 {
            
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func setExistingBookmark(_ existingBookmark: Bookmark?, initialParentFolder: BookmarkFolder?) {
        self.existingBookmark = existingBookmark
        self.initialParentFolder = initialParentFolder
        setUpTitle()
        setUpDataSource()
    }
    
    private func setUpDataSource() {
        if existingBookmark?.isFavorite ?? isFavorite {
            foldersViewController?.dataSource = FavoriteDetailsDataSource(delegate: self, existingBookmark: existingBookmark)
        } else {
            foldersViewController?.dataSource = BookmarkDetailsDataSource(delegate: self, existingBookmark: existingBookmark)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFoldersTableViewControllerSegue" {
            foldersViewController = segue.destination as? BookmarkFoldersViewController
            setUpDataSource()
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        foldersViewController?.save()
        if isAlertController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension AddOrEditBookmarkViewController: BookmarkDetailsSectionDataSourceDelegate {
    
    func bookmarkDetailsSectionDataSource(_ dataSource: BookmarkDetailsSectionDataSource, textFieldDidChangeWithTitleText titleText: String?, urlText: String?) {
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        let title = titleText?.trimWhitespace() ?? ""
        let url = urlText?.trimWhitespace() ?? ""
        
        doneButton.isEnabled = !title.isEmpty && !url.isEmpty
    }
    
    func bookmarkDetailsSectionDataSourceTextFieldDidReturn(dataSource: BookmarkDetailsSectionDataSource) {
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        if doneButton.isEnabled {
            onDonePressed(self)
        }
        
    }
}

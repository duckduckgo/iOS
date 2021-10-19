//
//  AddBookmarksFolderViewController.swift
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

class AddOrEditBookmarkFolderViewController: UIViewController {
        
    private var foldersViewController: BookmarkFoldersViewController?
    
    private var existingFolder: BookmarkFolder?
    private var initialParentFolder: BookmarkFolder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpDoneButton()
    }
    
    func setUpTitle() {
        if existingFolder != nil {
            title = NSLocalizedString("Edit Folder", comment: "Edit folder screen title")
        } else {
            title = NSLocalizedString("Add Folder", comment: "Add folder screen title")
        }
    }
    
    func setUpDoneButton() {
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        if let title = existingFolder?.title, title.trimWhitespace().count > 0 {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func setExistingFolder(_ existingFolder: BookmarkFolder?, initialParentFolder: BookmarkFolder?) {
        self.existingFolder = existingFolder
        self.initialParentFolder = initialParentFolder
        foldersViewController?.dataSource = BookmarkFolderDetailsDataSource(delegate: self, existingFolder: existingFolder, initialParentFolder: initialParentFolder)
        setUpTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFoldersTableViewControllerSegue" {
            foldersViewController = segue.destination as? BookmarkFoldersViewController
            foldersViewController?.dataSource = BookmarkFolderDetailsDataSource(delegate: self, existingFolder: existingFolder, initialParentFolder: initialParentFolder)
        }
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        foldersViewController?.save()
        navigationController?.popViewController(animated: true)
    }
}

extension AddOrEditBookmarkFolderViewController: BookmarksFolderDetailsSectionDataSourceDelegate {
    
    func bookmarksFolderDetailsSectionDataSource(_ dataSource: BookmarksFolderDetailsSectionDataSource, titleTextFieldDidChange textField: UITextField) {
        
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        let title = textField.text?.trimWhitespace() ?? ""
        doneButton.isEnabled = !title.isEmpty
    }
    
    func bookmarksFolderDetailsSectionDataSourceTextFieldDidReturn(dataSource: BookmarksFolderDetailsSectionDataSource) {
        
        guard let doneButton = navigationItem.rightBarButtonItem else { return }
        if doneButton.isEnabled {
            onDonePressed(self)
        }
    }
}

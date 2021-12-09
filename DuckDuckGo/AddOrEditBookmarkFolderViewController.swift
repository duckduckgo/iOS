//
//  AddOrEditBookmarkFolderViewController.swift
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
    
    weak var createdNewFolderDelegate: BookmarkItemDetailsDataSourceDidSaveDelegate?
        
    private var foldersViewController: BookmarkFoldersViewController?
    
    private var existingFolder: BookmarkFolder?
    private var initialParentFolder: BookmarkFolder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpSaveButton()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    func setUpTitle() {
        if existingFolder != nil {
            title = UserText.editFolderScreenTitle
        } else {
            title = UserText.addFolderScreenTitle
        }
    }
    
    func setUpSaveButton() {
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        if let title = existingFolder?.title, title.trimWhitespace().count > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func setExistingFolder(_ existingFolder: BookmarkFolder?, initialParentFolder: BookmarkFolder?) {
        self.existingFolder = existingFolder
        self.initialParentFolder = initialParentFolder
        foldersViewController?.dataSource = BookmarkFolderDetailsDataSource(delegate: self, addFolderDelegate: nil, existingFolder: existingFolder, initialParentFolder: initialParentFolder)
        setUpTitle()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedFoldersTableViewControllerSegue" {
            foldersViewController = segue.destination as? BookmarkFoldersViewController
            foldersViewController?.dataSource = BookmarkFolderDetailsDataSource(delegate: self, addFolderDelegate: nil, existingFolder: existingFolder, initialParentFolder: initialParentFolder)
        }
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        foldersViewController?.save(delegate: createdNewFolderDelegate)
        dismiss(animated: true, completion: nil)
    }
}

extension AddOrEditBookmarkFolderViewController: BookmarkFolderDetailsDataSourceDelegate {
    
    func bookmarkFolderDetailsDataSource(_ dataSource: BookmarkFolderDetailsDataSource, titleTextFieldDidChange textField: UITextField) {
        
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        let title = textField.text?.trimWhitespace() ?? ""
        saveButton.isEnabled = !title.isEmpty
    }
    
    func bookmarkFolderDetailsDataSourceTextFieldDidReturn(dataSource: BookmarkFolderDetailsDataSource) {
        
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        if saveButton.isEnabled {
            DispatchQueue.main.async {
                self.onSavePressed(self)
            }
        }
    }
}

extension AddOrEditBookmarkFolderViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        decorateToolbar(with: theme)
        
        overrideSystemTheme(with: theme)
    }
}

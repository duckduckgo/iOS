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
import CoreData
import Bookmarks

protocol AddOrEditBookmarkFolderViewControllerDelegate: AnyObject {

    func folderFinishedEditing(_: AddOrEditBookmarkFolderViewController)

}

class AddOrEditBookmarkFolderViewController: UIViewController {

    weak var delegate: AddOrEditBookmarkFolderViewControllerDelegate?

    private var foldersViewController: BookmarkFoldersViewController?

    private var isNew = true
    private var editingFolder: BookmarkEntity?
    private var parentFolder: BookmarkEntity?

    let context = BookmarksDatabase.shared.makeContext(concurrencyType: .mainQueueConcurrencyType)

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle()
        updateSaveButton()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    func updateTitle() {
        if isNew {
            title = UserText.addFolderScreenTitle
        } else {
            title = UserText.editFolderScreenTitle
        }
    }

    var canSave: Bool {
        editingFolder?.title?.trimmingWhitespace().count ?? 0 > 0
    }
    
    func updateSaveButton() {
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        if canSave {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    func setExistingID(_ id: NSManagedObjectID?, withParentID parentID: NSManagedObjectID?) {
        if let parentID = parentID {
            parentFolder = context.object(with: parentID) as? BookmarkEntity
        } else {
            parentFolder = BookmarkUtils.fetchRootFolder(context)
        }

        if let id = id {
            isNew = false
            editingFolder = context.object(with: id) as? BookmarkEntity
            assert(editingFolder != nil)
        } else {
            isNew = true
            let newFolder = BookmarkEntity(context: context)
            newFolder.uuid = UUID().uuidString
            newFolder.isFolder = true
            newFolder.isFavorite = false
            newFolder.parent = parentFolder
            editingFolder = newFolder
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let folderVC = segue.destination as? BookmarkFoldersViewController {
            foldersViewController = folderVC
            foldersViewController?.delegate = self
            foldersViewController?.viewModel = locationSelectorViewModel()
        }
    }

    private func locationSelectorViewModel() -> BookmarkEditorViewModel {
        let storage = CoreDataBookmarksLogic(context: context)
        return BookmarkEditorViewModel(storage: storage, bookmark: editingFolder!)
    }

    private func folderList(parent: BookmarkEntity) -> [BookmarkEntity] {
        return [parent]
    }

    @IBAction func onCancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        saveAndDismiss()
    }

    func saveAndDismiss() {
        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            assertionFailure("\(error)")
        }
        self.delegate?.folderFinishedEditing(self)
        dismiss(animated: true, completion: nil)
    }
}

extension AddOrEditBookmarkFolderViewController: BookmarkFoldersViewControllerDelegate {

    func textDidChange(_ controller: BookmarkFoldersViewController) {
        updateSaveButton()
    }

    func textDidReturn(_ controller: BookmarkFoldersViewController) {
        if canSave {
            saveAndDismiss()
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

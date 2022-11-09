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
import CoreData
import Bookmarks

protocol AddOrEditBookmarkViewControllerDelegate: AnyObject {

    func finishedEditing(_: AddOrEditBookmarkViewController)

}

class AddOrEditBookmarkViewController: UIViewController {

    weak var delegate: AddOrEditBookmarkViewControllerDelegate?

    private var foldersViewController: BookmarkFoldersViewController?

    let context: NSManagedObjectContext
    let viewModel: BookmarkEditorViewModel

    init?(coder: NSCoder, editingEntityID: NSManagedObjectID?, parentFolderID: NSManagedObjectID?) {
//    init(editingEntityID: NSManagedObjectID?, parentFolderID: NSManagedObjectID?) {
        context = BookmarksDatabase.shared.makeContext(concurrencyType: .mainQueueConcurrencyType)

        let isNew: Bool
        let editingEntity: BookmarkEntity
        if let editingEntityID = editingEntityID {
            guard let entity = context.object(with: editingEntityID) as? BookmarkEntity else {
                fatalError("Failed to load entity when expected")
            }
            isNew = false
            editingEntity = entity
        } else {

            let parent: BookmarkEntity?
            if let parentFolderID = parentFolderID {
                parent = context.object(with: parentFolderID) as? BookmarkEntity
            } else {
                parent = BookmarkUtils.fetchRootFolder(context)
            }
            assert(parent != nil)

            editingEntity = BookmarkEntity(context: context)
            editingEntity.uuid = UUID().uuidString
            editingEntity.parent = parent

            // We don't support creating bookmarks from scratch at this time, so it must be a folder
            editingEntity.isFolder = true
            editingEntity.isFavorite = false

            isNew = true
        }

        viewModel = BookmarkEditorViewModel(storage: CoreDataBookmarksLogic(context: context),
                                            bookmark: editingEntity,
                                            isNew: isNew)

        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle()
        updateSaveButton()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    func updateTitle() {
        if viewModel.isNew {
            title = UserText.addFolderScreenTitle
        } else {
            title = UserText.editFolderScreenTitle
        }
    }
    
    func updateSaveButton() {
        guard let saveButton = navigationItem.rightBarButtonItem else { return }
        if viewModel.canSave {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BookmarkFoldersViewController {
            controller.delegate = self
            controller.viewModel = viewModel
            foldersViewController = controller
        }
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
        self.delegate?.finishedEditing(self)
        dismiss(animated: true, completion: nil)
    }

    @IBSegueAction func onCreateEditor(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> AddOrEditBookmarkViewController? {
        guard let controller = AddOrEditBookmarkViewController(coder: coder,
                                                               editingEntityID: nil,
                                                               parentFolderID: viewModel.bookmark.parent?.objectID) else {
            fatalError("Failed to create controller")
        }
        controller.delegate = self
        return controller
    }
}

extension AddOrEditBookmarkViewController: BookmarkFoldersViewControllerDelegate {

    func textDidChange(_ controller: BookmarkFoldersViewController) {
        updateSaveButton()
    }

    func textDidReturn(_ controller: BookmarkFoldersViewController) {
        if viewModel.canSave {
            saveAndDismiss()
        }
    }

    func addFolder(_ controller: BookmarkFoldersViewController) {
        performSegue(withIdentifier: "AddFolder", sender: nil)
    }

}

extension AddOrEditBookmarkViewController: AddOrEditBookmarkViewControllerDelegate {

    func finishedEditing(_ controller: AddOrEditBookmarkViewController) {
        #warning("if this was saved, set the parent to the new folder")
        foldersViewController?.refresh()
    }

}

extension AddOrEditBookmarkViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        decorateToolbar(with: theme)
        
        overrideSystemTheme(with: theme)
    }
}

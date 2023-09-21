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
import Persistence
import Combine
import DDGSync
import WidgetKit

protocol AddOrEditBookmarkViewControllerDelegate: AnyObject {

    func finishedEditing(_: AddOrEditBookmarkViewController, entityID: NSManagedObjectID)
    func deleteBookmark(_: AddOrEditBookmarkViewController, entityID: NSManagedObjectID)

}

class AddOrEditBookmarkViewController: UIViewController {

    weak var delegate: AddOrEditBookmarkViewControllerDelegate?

    private var foldersViewController: BookmarkFoldersViewController?
    private let viewModel: BookmarkEditorViewModel
    private let bookmarksDatabase: CoreDataDatabase
    private let syncService: DDGSyncing
    private let appSettings: AppSettings

    private var viewModelCancellable: AnyCancellable?

    init?(coder: NSCoder,
          editingEntityID: NSManagedObjectID,
          bookmarksDatabase: CoreDataDatabase,
          syncService: DDGSyncing,
          appSettings: AppSettings) {
        
        self.bookmarksDatabase = bookmarksDatabase
        self.viewModel = BookmarkEditorViewModel(editingEntityID: editingEntityID,
                                                 bookmarksDatabase: bookmarksDatabase,
                                                 favoritesDisplayMode: appSettings.favoritesDisplayMode,
                                                 syncService: syncService)
        self.syncService = syncService
        self.appSettings = appSettings

        super.init(coder: coder)
    }
    
    init?(coder: NSCoder,
          parentFolderID: NSManagedObjectID?,
          bookmarksDatabase: CoreDataDatabase,
          syncService: DDGSyncing,
          appSettings: AppSettings) {

        self.bookmarksDatabase = bookmarksDatabase
        self.viewModel = BookmarkEditorViewModel(creatingFolderWithParentID: parentFolderID,
                                                 bookmarksDatabase: bookmarksDatabase,
                                                 favoritesDisplayMode: appSettings.favoritesDisplayMode,
                                                 syncService: syncService)
        self.syncService = syncService
        self.appSettings = appSettings

        super.init(coder: coder)
    }

    // If you hit this constructor you probably decided to try and instanciate this VC directly.
    //  However, if it is part of a navigation controller stack this construct gets called.
    //  Check the segue actions defined in the storyboard. 
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle()
        updateSaveButton()

        applyTheme(ThemeManager.shared.currentTheme)

        viewModelCancellable = viewModel.externalUpdates.sink { [weak self] _ in
            self?.foldersViewController?.refresh()
        }
    }

    func updateTitle() {
        if viewModel.isNew {
            title = UserText.addFolderScreenTitle
        } else {
            title = viewModel.bookmark.isFolder ? UserText.editFolderScreenTitle : UserText.editBookmarkScreenTitle
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
        viewModel.save()
        WidgetCenter.shared.reloadAllTimelines()
        self.delegate?.finishedEditing(self, entityID: viewModel.bookmark.objectID)
        dismiss(animated: true, completion: nil)
        syncService.scheduler.notifyDataChanged()
    }

    @IBSegueAction func onCreateEditor(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> AddOrEditBookmarkViewController? {
        guard let controller = AddOrEditBookmarkViewController(
            coder: coder,
            parentFolderID: viewModel.bookmark.parent?.objectID,
            bookmarksDatabase: bookmarksDatabase,
            syncService: syncService,
            appSettings: appSettings
        ) else {
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

    func deleteBookmark(_ controller: BookmarkFoldersViewController) {
        self.delegate?.deleteBookmark(self, entityID: viewModel.bookmark.objectID)
        dismiss(animated: true, completion: nil)
    }

}

extension AddOrEditBookmarkViewController: AddOrEditBookmarkViewControllerDelegate {

    func finishedEditing(_ controller: AddOrEditBookmarkViewController, entityID: NSManagedObjectID) {
        viewModel.setParentWithID(entityID)
        foldersViewController?.refresh()
    }

    func deleteBookmark(_: AddOrEditBookmarkViewController, entityID: NSManagedObjectID) {
        self.delegate?.deleteBookmark(self, entityID: entityID)
    }

}

extension AddOrEditBookmarkViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        decorateToolbar(with: theme)
        
        overrideSystemTheme(with: theme)
    }
}

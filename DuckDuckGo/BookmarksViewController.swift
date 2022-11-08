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
import MobileCoreServices
import os.log
import UniformTypeIdentifiers
import Bookmarks
import CoreData

// swiftlint:disable file_length
// swiftlint:disable type_body_length

class BookmarksViewController: UIViewController, UITableViewDelegate {

    private enum Constants {
        static var saveToFiles = "com.apple.DocumentManagerUICore.SaveToFiles"
        static var bookmarksFileName = "DuckDuckGo Bookmarks.html"
        static var importBookmarkImage = "BookmarksImport"
        static var exportBookmarkImage = "BookmarksExport"
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var importFooterButton: UIButton!
    @IBOutlet weak var favoritesContainer: UIView!
    @IBOutlet weak var selectorContainer: UIView!
    @IBOutlet weak var selectorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectorControl: UISegmentedControl!

    /// Creating left and right toolbar UIBarButtonItems with customView so that 'Edit' button is centered
    private lazy var addFolderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(UserText.addbookmarkFolderButton, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.sizeToFit()
        button.addTarget(self, action: #selector(onAddFolderPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var addFolderBarButtonItem = UIBarButtonItem(customView: addFolderButton)

    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(UserText.moreBookmarkButton, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.sizeToFit()
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private lazy var moreBarButtonItem = UIBarButtonItem(customView: moreButton)

    private var bookmarksMenu: UIMenu {
        return UIMenu(title: UserText.importExportBookmarksTitle,
                      children: [exportAction(), importAction()])
    }

    private var searchController: UISearchController?
    weak var delegate: BookmarksDelegate?

    fileprivate lazy var viewModel: BookmarkListViewModel = {
        let context = BookmarksDatabase.shared.makeContext(concurrencyType: .mainQueueConcurrencyType)
        let storage = CoreDataBookmarksLogic(context: context)
        return BookmarkListViewModel(storage: storage, currentFolder: nil)
    }() {
        didSet {
            dataSource = BookmarksDataSource(viewModel: viewModel)
        }
    }

    fileprivate lazy var dataSource: BookmarksDataSource = {
        let dataSource = BookmarksDataSource(viewModel: viewModel)
        dataSource.delegate = self
        return dataSource
    }()

    fileprivate var searchDataSource = SearchBookmarksDataSource()
    private lazy var bookmarksCachingSearch: BookmarksCachingSearch = CoreDependencyProvider.shared.bookmarksCachingSearch

    var isNested: Bool {
        viewModel.currentFolder != nil
    }

    var favoritesController: FavoritesViewController?

    fileprivate var onDidAppearAction: () -> Void = {}

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        registerForNotifications()
        configureSelector()
        configureTableView()
        configureBars()

        applyTheme(ThemeManager.shared.currentTheme)

        selectorContainer.isHidden = isNested
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onDidAppearAction()
        onDidAppearAction = {}

    }
    
    @objc func dataDidChange(notification: Notification) {
        tableView.reloadData()
        if currentDataSource.isEmpty && isEditingBookmarks {
            finishEditing()
        }
        refreshEditButton()
        refreshFooterView()
        refreshMoreButton()
    }

    @IBAction func onViewSelectorChanged(_ segment: UISegmentedControl) {
        switch selectorControl.selectedSegmentIndex {
        case 0:
            showBookmarksView()

        case 1:
            showFavoritesView()

        default: assertionFailure("Invalid selected segment index")
        }
    }

    private func showBookmarksView() {
        tableView.isHidden = false
        favoritesContainer.isHidden = true
        addFolderButton.isHidden = false
        moreButton.isHidden = false
        navigationItem.title = UserText.sectionTitleBookmarks
        refreshEditButton()
    }

    private func showFavoritesView() {
        tableView.isHidden = true
        favoritesContainer.isHidden = false
        addFolderButton.isHidden = true
        moreButton.isHidden = true
        navigationItem.title = UserText.sectionTitleFavorites
        refreshEditButton()
    }

    func openEditFormWhenPresented(bookmark: BookmarkEntity) {
        onDidAppearAction = { [weak self] in
            self?.performSegue(withIdentifier: "AddOrEditBookmark", sender: bookmark)
        }
    }
    
    func openEditFormWhenPresented(link: Link) {
//        onDidAppearAction = { [weak self] in
//            if let bookmark = viewModel.bookmarkForURL(link.url) {
//                self?.performSegue(withIdentifier: "AddOrEditBookmark", sender: bookmark)
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmark = viewModel.bookmarkAt(indexPath.row) else { return }

        if isEditingBookmarks {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: bookmark.isFolder ? "AddOrEditBookmarkFolder" : "AddOrEditBookmark", sender: bookmark.objectID)
        } else if bookmark.isFolder {
            drillIntoFolder(bookmark)
            onDidAppearAction = { [weak self] in
                self?.viewModel.refresh()
            }
        } else {
            select(bookmark: bookmark)
        }
    }

    private func drillIntoFolder(_ parent: BookmarkEntity) {
        let storyboard = UIStoryboard(name: "Bookmarks", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "BookmarksViewController", creator: { coder in
            let controller = BookmarksViewController(coder: coder)
            controller?.viewModel = self.viewModel.viewModelForFolder(parent)
            controller?.delegate = self.delegate
            return controller
        })

        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = viewModel.bookmarkAt(indexPath.row),
                !item.isFolder else {
            return nil
        }
     
        let shareContextualAction = UIContextualAction(style: .normal, title: UserText.actionShare) { (_, _, completionHandler) in
            self.showShareSheet(for: indexPath)
            completionHandler(true)
        }
        shareContextualAction.backgroundColor = UIColor.cornflowerBlue
        return UISwipeActionsConfiguration(actions: [shareContextualAction])
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onApplicationBecameActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector:
                                                #selector(dataDidChange),
                                               name: BookmarksManager.Notifications.bookmarksDidChange,
                                               object: nil)
    }

    private func configureSelector() {
        favoritesContainer.backgroundColor = tableView.backgroundColor
        selectorContainer.backgroundColor = tableView.backgroundColor
        selectorContainer.isHidden = isNested
        selectorHeightConstraint.constant = isNested ? 0 : selectorHeightConstraint.constant
    }

    private func configureTableView() {
        tableView.contentInset = .init(top: isNested ? -12 : -1, left: 0,
                                       bottom: isNested ? 0 : -24, right: 0)

        if isNested {
            tableView.tableHeaderView = nil
        }

        tableView.dataSource = dataSource
        importFooterButton.setTitle(UserText.importBookmarksFooterButton, for: .normal)
        importFooterButton.setTitleColor(UIColor.cornflowerBlue, for: .normal)
        importFooterButton.titleLabel?.textAlignment = .center
        
        importFooterButton.addAction(UIAction { [weak self] _ in
            self?.presentDocumentPicker()
        }, for: .touchUpInside)
        
        refreshFooterView()
    }

#warning("should return correct datasource")
    private var currentDataSource: BookmarksDataSource {
        return dataSource

//        if tableView.dataSource === dataSource {
//            return dataSource
//        }
//        return searchDataSource
    }

    @objc func onApplicationBecameActive(notification: NSNotification) {
        tableView.reloadData()
    }

    func configureBars() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        toolbarItems?.insert(addFolderBarButtonItem, at: 0)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbarItems?.insert(flexibleSpace, at: 1)
        // Edit button is at position 2
        configureToolbarMoreItem()

        if let title = viewModel.currentFolder?.title {
            self.title = title
        }
        refreshEditButton()
    }

    private func configureToolbarMoreItem() {
        #warning("Edit button needs to stay in the middle if the more button dissapears")

        if isEditingBookmarks || isNested {
            if toolbarItems?.count ?? 0 >= 5 {
                toolbarItems?.remove(at: 4)
                toolbarItems?.remove(at: 3)
            }
        } else {
            if toolbarItems?.contains(moreBarButtonItem) == false {
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
                toolbarItems?.insert(flexibleSpace, at: 3)
                toolbarItems?.insert(moreBarButtonItem, at: 4)
            }
            refreshMoreButton()
        }
    }

    private func refreshEditButton() {
        if !favoritesContainer.isHidden {
            #warning("refer to favorites view model")
//            editButton.isEnabled = dataSource.bookmarksManager.favoritesCount > 0
//            editButton.title = UserText.actionGenericEdit
        } else if (currentDataSource.isEmpty && !isEditingBookmarks) || currentDataSource === searchDataSource {
            disableEditButton()
        } else if !isEditingBookmarks {
            enableEditButton()
        }
    }
    
    private func refreshAddFolderButton() {
        if currentDataSource === searchDataSource {
            disableAddFolderButton()
        } else {
            enableAddFolderButton()
        }
    }

    private func refreshMoreButton() {
        if isEditingBookmarks || currentDataSource === searchDataSource  || viewModel.currentFolder != nil {
            disableMoreButton()
        } else {
            enableMoreButton()
        }
    }
    
    private func refreshFooterView() {
        if !isNested && dataSource.isEmpty && currentDataSource !== searchDataSource {
            enableFooterView()
        } else {
            disableFooterView()
        }
    }

    @IBAction func onAddFolderPressed(_ sender: Any) {
        performSegue(withIdentifier: "AddOrEditBookmarkFolder", sender: nil)
    }
    
    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        if isEditingBookmarks {
            finishEditing()
        } else {
            startEditing()
        }
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        dismiss()
    }

    // MARK: Import bookmarks

    func importAction() -> UIAction {
        return UIAction(title: UserText.importBookmarksActionTitle,
                        image: UIImage(named: Constants.importBookmarkImage)
        ) { [weak self] _ in
            self?.presentDocumentPicker()
        }
    }

    func presentDocumentPicker() {
        let docTypes = [UTType.html]
        let docPicker = UIDocumentPickerViewController(forOpeningContentTypes: docTypes, asCopy: true)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true)
    }

    func importBookmarks(fromHtml html: String) {
        fatalError("Not implemented")
//        Task {
//            let bookmarkCountBeforeImport = await dataSource.bookmarksManager.allBookmarksAndFavoritesFlat().count
//
//            let result = await BookmarksImporter().parseAndSave(html: html)
//            switch result {
//            case .success:
//                dataSource.bookmarksManager.reloadWidgets()
//
//                let bookmarkCountAfterImport = await dataSource.bookmarksManager.allBookmarksAndFavoritesFlat().count
//                let bookmarksImported = bookmarkCountAfterImport - bookmarkCountBeforeImport
//                Pixel.fire(pixel: .bookmarkImportSuccess,
//                           withAdditionalParameters: [PixelParameters.bookmarkCount: "\(bookmarksImported)"])
//                DispatchQueue.main.async {
//                    ActionMessageView.present(message: UserText.importBookmarksSuccessMessage)
//                }
//            case .failure(let bookmarksImportError):
//                os_log("Bookmarks import error %s", type: .debug, bookmarksImportError.localizedDescription)
//                Pixel.fire(pixel: .bookmarkImportFailure)
//                DispatchQueue.main.async {
//                    ActionMessageView.present(message: UserText.importBookmarksFailedMessage)
//                }
//            }
//        }
    }

    // MARK: Export bookmarks

    func exportAction() -> UIAction {
        return UIAction(title: UserText.exportBookmarksActionTitle,
                image: UIImage(named: Constants.exportBookmarkImage),
                attributes: currentDataSource.isEmpty ? .disabled : []) { [weak self] _ in
            self?.exportHtmlFile()
        }
    }

    func exportHtmlFile() {
        // create file to export
        let tempFileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(Constants.bookmarksFileName)
        do {
            try BookmarksExporter().exportBookmarksTo(url: tempFileUrl)
        } catch {
            os_log("bookmarks failed to export %s", type: .debug, error.localizedDescription)
            ActionMessageView.present(message: UserText.exportBookmarksFailedMessage)
            return
        }

        // create activityViewController with exported file
        let activity = UIActivityViewController(activityItems: [tempFileUrl], applicationActivities: nil)
        activity.completionWithItemsHandler = {[weak self] (activityType: UIActivity.ActivityType?, completed: Bool, _: [Any]?, error: Error?) in
            guard error == nil else {
                // this trips if user cancelled Save to Files but they are still in the UIActivityViewController so
                // can still choose to share to another app so in this case we don't want to delete the bookmarks file yet
                if let error = error as NSError?, error.code == NSUserCancelledError {
                    return
                }

                Pixel.fire(pixel: .bookmarkExportFailure)
                self?.presentActionMessageView(withMessage: UserText.exportBookmarksFailedMessage)
                self?.cleanupTempFile(tempFileUrl)
                return
            }

            if completed && activityType != nil {
                if let activityTypeStr = activityType?.rawValue, activityTypeStr == Constants.saveToFiles {
                    self?.presentActionMessageView(withMessage: UserText.exportBookmarksFilesSuccessMessage)
                } else {
                    self?.presentActionMessageView(withMessage: UserText.exportBookmarksShareSuccessMessage)
                }
                Pixel.fire(pixel: .bookmarkExportSuccess)
            }

            self?.cleanupTempFile(tempFileUrl)
        }

        if let popover = activity.popoverPresentationController {
            popover.sourceView = moreBarButtonItem.customView
        }
        present(activity, animated: true, completion: nil)
    }

    func cleanupTempFile(_ tempFileUrl: URL) {
        try? FileManager.default.removeItem(at: tempFileUrl)
    }

    func presentActionMessageView(withMessage message: String) {
        DispatchQueue.main.async {
            ActionMessageView.present(message: message)
        }
    }

    // when swipe-to-delete control is shown tableView.isEditing is true
    private var isEditingBookmarks: Bool = false
    private func startEditing() {
        assert(!isEditingBookmarks)

        // necessary in case a cell is swiped (which would mean isEditing is already true, and setting it again wouldn't do anything)
        tableView.isEditing = false
        
        tableView.isEditing = true
        favoritesController?.isEditing = true

        self.isEditingBookmarks = true
        changeEditButtonToDone()
        configureToolbarMoreItem()
        refreshFooterView()
    }

    private func finishEditing() {
        favoritesController?.isEditing = false

        guard tableView.isEditing else {
            return
        }

        tableView.isEditing = false
        self.isEditingBookmarks = false
        refreshEditButton()
        enableDoneButton()
        configureToolbarMoreItem()
        refreshFooterView()
    }

    private func enableEditButton() {
        editButton.title = UserText.navigationTitleEdit
        editButton.isEnabled = true
    }

    private func disableEditButton() {
        editButton.title = UserText.navigationTitleEdit
        editButton.isEnabled = false
    }
    
    private func enableAddFolderButton() {
        addFolderBarButtonItem.title = UserText.addbookmarkFolderButton
        addFolderBarButtonItem.isEnabled = true
    }
    
    private func disableAddFolderButton() {
        addFolderBarButtonItem.isEnabled = false
    }
    
    private func changeEditButtonToDone() {
        editButton.title = UserText.navigationTitleDone
        doneButton.title = ""
        doneButton.isEnabled = false
    }
    
    private func enableDoneButton() {
        doneButton.title = UserText.navigationTitleDone
        doneButton.isEnabled = true
    }
    
    private func enableMoreButton() {
        moreButton.menu = bookmarksMenu
        moreButton.isEnabled = true
    }

    private func disableMoreButton() {
        moreButton.isEnabled = false
    }

    private func enableFooterView() {
        importFooterButton.isHidden = false
        importFooterButton.isEnabled = true
    }

    private func disableFooterView() {
        importFooterButton.isHidden = true
        importFooterButton.isEnabled = false
    }

    private func prepareForSearching() {
        print("***", #function, "TODO")
        finishEditing()
        disableEditButton()
        disableAddFolderButton()
    }
    
    private func finishSearching() {
        tableView.dataSource = dataSource
        tableView.reloadData()
        
        enableEditButton()
        enableAddFolderButton()
    }

    fileprivate func showShareSheet(for indexPath: IndexPath) {

        if let bookmark = viewModel.bookmarkAt(indexPath.row) {
            presentShareSheet(withItems: [bookmark], fromView: self.view)
        } else {
            os_log("Invalid share link found", log: generalLog, type: .debug)
        }
    }

    fileprivate func select(bookmark: BookmarkEntity) {
        dismiss()
        delegate?.bookmarksDidSelect(bookmark: bookmark)
    }

    private func dismiss() {
        delegate?.bookmarksUpdated()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let viewController = segue.destination.children.first as? AddOrEditBookmarkFolderViewController {
//            viewController.hidesBottomBarWhenPushed = true
//            viewController.setExistingFolder(sender as? BookmarkFolder, initialParentFolder: dataSource.folder)
//        } else
//        if let viewController = segue.destination.children.first as? AddOrEditBookmarkViewController {
//            viewController.hidesBottomBarWhenPushed = true
//            viewController.setExistingBookmark(sender as? Bookmark, initialParentFolder: dataSource.folder)
//        } else

        if let viewController = segue.destination.children.first as? AddOrEditBookmarkFolderViewController {
            viewController.hidesBottomBarWhenPushed = true
            viewController.setExistingID(sender as? NSManagedObjectID,
                                         withParentID: viewModel.currentFolder?.objectID)
            viewController.delegate = self
        } else
        if let viewController = segue.destination as? FavoritesViewController {
            viewController.delegate = self
            favoritesController = viewController
        }
    }

}

extension BookmarksViewController: AddOrEditBookmarkFolderViewControllerDelegate {

    func folderFinishedEditing(_: AddOrEditBookmarkFolderViewController) {
        viewModel.refresh()
        tableView.reloadData()
    }

}

extension BookmarksViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            if tableView.dataSource !== dataSource {
                finishSearching()
            }
            return
        }
        
        if currentDataSource !== searchDataSource {
            prepareForSearching()
            tableView.dataSource = searchDataSource
        }

        fatalError("Not implemented")
//        searchDataSource.performSearch(query: searchText, searchEngine: bookmarksCachingSearch) {
//            self.tableView.reloadData()
//        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        finishSearching()
    }
}

extension BookmarksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        finishEditing()
    }
}

extension BookmarksViewController: BookmarksDataSourceDelegate {

    func viewControllerForAlert(_: BookmarksDataSource) -> UIViewController {
        return self
    }

    func bookmarkDeleted(_: BookmarksDataSource) {
        refreshFooterView()
    }

}

extension BookmarksViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        decorateToolbar(with: theme)
        
        overrideSystemTheme(with: theme)
        searchController?.searchBar.searchTextField.textColor = theme.searchBarTextColor
                
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        navigationController?.view.backgroundColor = tableView.backgroundColor
        
        tableView.reloadData()
    }
}

extension BookmarksViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, let data = try? Data(contentsOf: url), let contents = String(data: data, encoding: .utf8) else {
            ActionMessageView.present(message: UserText.importBookmarksFailedMessage)
            return
        }
        importBookmarks(fromHtml: contents)
    }
}

extension BookmarksViewController: FavoritesViewControllerDelegate {

    func favoritesViewController(_ controller: FavoritesViewController, didSelectFavorite favorite: BookmarkEntity) {
        select(bookmark: favorite)
    }

    func favoritesViewController(_ controller: FavoritesViewController, didRequestEditFavorite favorite: BookmarkEntity) {
        performSegue(withIdentifier: "AddOrEditBookmark", sender: favorite)
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length

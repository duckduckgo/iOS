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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

class BookmarksViewController: UITableViewController {

    private enum Constants {
        static var saveToFiles = "com.apple.DocumentManagerUICore.SaveToFiles"
        static var bookmarksFileName = "DuckDuckGo Bookmarks.html"
        static var importBookmarkImage = "BookmarksImport"
        static var exportBookmarkImage = "BookmarksExport"
    }

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var importFooterButton: UIButton!

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

    @available(iOS 14.0, *)
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(UserText.moreBookmarkButton, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.sizeToFit()
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    @available(iOS 14.0, *)
    private lazy var moreBarButtonItem = UIBarButtonItem(customView: moreButton)

    private var bookmarksMenu: UIMenu {
        return UIMenu(title: UserText.importExportBookmarksTitle,
                      children: [exportAction(), importAction()])
    }

    private var searchController: UISearchController?
    weak var delegate: BookmarksDelegate?
    
    fileprivate lazy var dataSource: MainBookmarksViewDataSource = DefaultBookmarksDataSource(alertDelegate: self)
    fileprivate var searchDataSource = SearchBookmarksDataSource()
    private var bookmarksCachingSearch: BookmarksCachingSearch?
    
    fileprivate var onDidAppearAction: () -> Void = {}
        
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        configureTableView()
        configureSearchIfNeeded()
        configureBars()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onDidAppearAction()
        onDidAppearAction = {}
    }
    
    @objc func dataDidChange(notification: Notification) {
        tableView.reloadData()
        if currentDataSource.isEmpty && tableView.isEditing {
            finishEditing()
        }
        refreshEditButton()
        refreshFooterView()
        if #available(iOS 14.0, *) {
            refreshMoreButton()
        }
    }
    
    func openEditFormWhenPresented(bookmark: Bookmark) {
        onDidAppearAction = { [weak self] in
            self?.performSegue(withIdentifier: "AddOrEditBookmark", sender: bookmark)
        }
    }
    
    func openEditFormWhenPresented(link: Link) {
        onDidAppearAction = { [weak self] in
            self?.dataSource.bookmarksManager.bookmark(forURL: link.url) { bookmark in
                if let bookmark = bookmark {
                    self?.performSegue(withIdentifier: "AddOrEditBookmark", sender: bookmark)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = currentDataSource.item(at: indexPath) else { return }
        
        if tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
            if let bookmark = item as? Bookmark {
                performSegue(withIdentifier: "AddOrEditBookmark", sender: bookmark)
            } else if let folder = item as? BookmarkFolder {
                performSegue(withIdentifier: "AddOrEditBookmarkFolder", sender: folder)
            }
        } else {
            if let bookmark = item as? Bookmark {
                select(bookmark: bookmark)
            } else if let folder = item as? BookmarkFolder {
                let storyboard = UIStoryboard(name: "Bookmarks", bundle: nil)
                guard let viewController = storyboard.instantiateViewController(withIdentifier: "BookmarksViewController")
                        as? BookmarksViewController else {
                            
                    return
                }
                viewController.dataSource = DefaultBookmarksDataSource(alertDelegate: viewController, parentFolder: folder)
                viewController.delegate = delegate
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = currentDataSource.item(at: indexPath),
              item as? BookmarkFolder == nil else {
            return nil
        }
     
        let shareContextualAction = UIContextualAction(style: .normal, title: UserText.actionShare) { (_, _, completionHandler) in
            self.showShareSheet(for: indexPath)
            completionHandler(true)
        }
        shareContextualAction.backgroundColor = UIColor.cornflowerBlue
        return UISwipeActionsConfiguration(actions: [shareContextualAction])
    }
    
    override func tableView(_ tableView: UITableView,
                            targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                            toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        // Can't move folders into favorites
        if let item = currentDataSource.item(at: sourceIndexPath),
           item as? BookmarkFolder != nil &&
            proposedDestinationIndexPath.section == currentDataSource.favoritesSectionIndex {
            return sourceIndexPath
        }
        
        // Check if the proposed section is empty, if so we need to make sure the proposed row is 0, not 1
        let sectionIndexPath = IndexPath(row: 0, section: proposedDestinationIndexPath.section)
        if currentDataSource.item(at: sectionIndexPath) == nil {
            return sectionIndexPath
        }
        
        return proposedDestinationIndexPath
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

    private func configureTableView() {
        tableView.dataSource = dataSource
        if dataSource.folder != nil {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: CGFloat.leastNormalMagnitude))
        }

        if #available(iOS 14, *) {
            importFooterButton.setTitle(UserText.importBookmarksFooterButton, for: .normal)
            importFooterButton.setTitleColor(UIColor.cornflowerBlue, for: .normal)

            importFooterButton.addAction(UIAction { [weak self] _ in
                self?.presentDocumentPicker()
            }, for: .touchUpInside)
        }

        refreshFooterView()
    }
    
    private func configureSearchIfNeeded() {
        guard dataSource.showSearch else {
            // Don't show search for sub folders
            return
        }
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsScopeBar = false
        searchController.searchBar.searchTextField.font = UIFont.semiBoldAppFont(ofSize: 16.0)
        
        // Add separator
        if let nv = navigationController?.navigationBar {
            let separator = UIView()
            separator.backgroundColor = .greyish
            nv.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.widthAnchor.constraint(equalTo: nv.widthAnchor).isActive = true
            separator.leadingAnchor.constraint(equalTo: nv.leadingAnchor).isActive = true
            separator.bottomAnchor.constraint(equalTo: nv.bottomAnchor, constant: 1.0 / UIScreen.main.scale).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        }
        self.searchController = searchController
        
        // Initially puling down the table to reveal search bar will result in a glitch if content offset is 0 and we are using `isModalInPresentation` set to true
        tableView.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
    }
    
    private var currentDataSource: MainBookmarksViewDataSource {
        if tableView.dataSource === dataSource {
            return dataSource
        }
        return searchDataSource
    }

    @objc func onApplicationBecameActive(notification: NSNotification) {
        tableView.reloadData()
    }

    private func configureBars() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        toolbarItems?.insert(addFolderBarButtonItem, at: 0)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbarItems?.insert(flexibleSpace, at: 1)
        // Edit button is at position 2
        configureToolbarMoreItem()

        if let dataSourceTitle = dataSource.navigationTitle {
            title = dataSourceTitle
        }
        refreshEditButton()
    }

    private func configureToolbarMoreItem() {
        if #available(iOS 14, *) {
            if tableView.isEditing {
                if toolbarItems?.count ?? 0 >= 5 {
                    toolbarItems?.remove(at: 4)
                    toolbarItems?.remove(at: 3)
                }
            } else {
                let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
                toolbarItems?.insert(flexibleSpace, at: 3)
                toolbarItems?.insert(moreBarButtonItem, at: 4)
                refreshMoreButton()
            }
        }
    }

    private func refreshEditButton() {
        if (currentDataSource.isEmpty && !tableView.isEditing) || currentDataSource === searchDataSource {
            disableEditButton()
        } else if !tableView.isEditing {
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

    @available(iOS 14.0, *)
    private func refreshMoreButton() {
        if tableView.isEditing || currentDataSource === searchDataSource  || dataSource.folder != nil {
            disableMoreButton()
        } else {
            enableMoreButton()
        }
    }

    private func refreshFooterView() {
        if #available(iOS 14, *) {
            if dataSource.folder == nil && dataSource.isEmpty && currentDataSource !== searchDataSource {
                enableFooterView()
            } else {
                disableFooterView()
            }
        } else {
            disableFooterView()
        }
    }

    @IBAction func onAddFolderPressed(_ sender: Any) {
        performSegue(withIdentifier: "AddOrEditBookmarkFolder", sender: nil)
    }
    
    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
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
        let docTypes = [String(kUTTypeHTML)]
        let docPicker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true)
    }

    func importBookmarks(fromHtml html: String) {
        Task {
            let bookmarkCountBeforeImport = await dataSource.bookmarksManager.allBookmarksAndFavoritesFlat().count

            let result = await BookmarksImporter().parseAndSave(html: html)
            switch result {
            case .success:
                dataSource.bookmarksManager.reloadWidgets()

                let bookmarkCountAfterImport = await dataSource.bookmarksManager.allBookmarksAndFavoritesFlat().count
                let bookmarksImported = bookmarkCountAfterImport - bookmarkCountBeforeImport
                Pixel.fire(pixel: .bookmarkImportSuccess,
                           withAdditionalParameters: [PixelParameters.bookmarkCount: "\(bookmarksImported)"])
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.importBookmarksSuccessMessage)
                }
            case .failure(let bookmarksImportError):
                os_log("Bookmarks import error %s", type: .debug, bookmarksImportError.localizedDescription)
                Pixel.fire(pixel: .bookmarkImportFailure)
                DispatchQueue.main.async {
                    ActionMessageView.present(message: UserText.importBookmarksFailedMessage)
                }
            }
        }
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
            if #available(iOS 14, *) {
                popover.sourceView = moreBarButtonItem.customView
            }
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

    private func startEditing() {
        // necessary in case a cell is swiped (which would mean isEditing is already true, and setting it again wouldn't do anything)
        tableView.isEditing = false
        
        tableView.isEditing = true
        changeEditButtonToDone()
        if #available(iOS 14, *) {
            configureToolbarMoreItem()
            refreshFooterView()
        }
    }

    private func finishEditing() {
        tableView.isEditing = false
        refreshEditButton()
        enableDoneButton()
        if #available(iOS 14, *) {
            configureToolbarMoreItem()
            refreshFooterView()
        }
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
    
    @available(iOS 14.0, *)
    private func enableMoreButton() {
        moreButton.menu = bookmarksMenu
        moreButton.isEnabled = true
    }

    @available(iOS 14.0, *)
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

        if let item = currentDataSource.item(at: indexPath),
            let bookmark = item as? Bookmark {
            presentShareSheet(withItems: [bookmark], fromView: self.view)
        } else {
            os_log("Invalid share link found", log: generalLog, type: .debug)
        }
    }

    fileprivate func select(bookmark: Bookmark) {
        dismiss()
        delegate?.bookmarksDidSelect(bookmark: bookmark)
    }

    private func dismiss() {
        delegate?.bookmarksUpdated()
        
        if let searchController = searchController, searchController.isActive {
            searchController.dismiss(animated: false) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination.children.first as? AddOrEditBookmarkFolderViewController {
            viewController.hidesBottomBarWhenPushed = true
            viewController.setExistingFolder(sender as? BookmarkFolder, initialParentFolder: dataSource.folder)
        } else if let viewController = segue.destination.children.first as? AddOrEditBookmarkViewController {
            viewController.hidesBottomBarWhenPushed = true
            viewController.setExistingBookmark(sender as? Bookmark, initialParentFolder: dataSource.folder)
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (searchController?.searchBar.bounds.height ?? 0) == 0 {
            // Disable drag-to-dismiss if we start scrolling and search bar is still hidden
            isModalInPresentation = true
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let searchController = searchController else {
            return
        }

        if isModalInPresentation, searchController.searchBar.bounds.height > 0 {
            // Re-enable drag-to-dismiss if needed
            isModalInPresentation = false
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let searchController = searchController else {
            return
        }
        
        if isModalInPresentation, searchController.searchBar.bounds.height > 0 {
            // Re-enable drag-to-dismiss if needed
            isModalInPresentation = false
        }
    }
}

extension BookmarksViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        bookmarksCachingSearch = BookmarksCachingSearch()
    }
    
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

        let bookmarksSearch = bookmarksCachingSearch ?? BookmarksCachingSearch()
        searchDataSource.performSearch(query: searchText, searchEngine: bookmarksSearch) {
            self.tableView.reloadData()
        }
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

extension BookmarksViewController: BookmarksSectionDataSourceDelegate {
    func bookmarksSectionDataSourceDidRequestViewControllerForDeleteAlert(
        _ bookmarksSectionDataSource: BookmarksSectionDataSource) -> UIViewController {
       
        return self
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

// swiftlint:enable type_body_length
// swiftlint:enable file_length

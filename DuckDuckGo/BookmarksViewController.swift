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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

class BookmarksViewController: UITableViewController {

    @IBOutlet weak var addFolderButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
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
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        toolbarItems?.insert(flexibleSpace, at: 1)
        if let dataSourceTitle = dataSource.navigationTitle {
            title = dataSourceTitle
        }
        refreshEditButton()
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

    private func startEditing() {
        // necessary in case a cell is swiped (which would mean isEditing is already true, and setting it again wouldn't do anything)
        tableView.isEditing = false
        
        tableView.isEditing = true
        changeEditButtonToDone()
    }

    private func finishEditing() {
        tableView.isEditing = false
        refreshEditButton()
        enableDoneButton()
    }

    private func enableEditButton() {
        editButton.title = UserText.navigationTitleEdit
        editButton.isEnabled = true
    }

    private func disableEditButton() {
        editButton.title = ""
        editButton.isEnabled = false
    }
    
    private func enableAddFolderButton() {
        addFolderButton.title = UserText.addbookmarkFolderButton
        addFolderButton.isEnabled = true
    }
    
    private func disableAddFolderButton() {
        addFolderButton.title = ""
        addFolderButton.isEnabled = false
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

// swiftlint:enable type_body_length
// swiftlint:enable file_length

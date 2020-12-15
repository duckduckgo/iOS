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

class BookmarksViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!

    private var searchController: UISearchController!
    weak var delegate: BookmarksDelegate?
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    fileprivate var dataSource = DefaultBookmarksDataSource()
    fileprivate var searchDataSource = SearchBookmarksDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        configureTableView()
        configureSearch()
        refreshEditButton()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            showEditBookmarkAlert(for: indexPath)
        } else if let link = currentDataSource.link(at: indexPath) {
            selectLink(link)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onExternalDataChange),
                                               name: BookmarkUserDefaults.Notifications.bookmarkStoreDidChange,
                                               object: nil)
    }

    private func configureTableView() {
        tableView.dataSource = dataSource
    }
    
    private func configureSearch() {
        // Do not use UISearchController() as it causes iOS 12 to miss search bar.
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        if #available(iOS 13.0, *) {
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
        }
        
        // Initially puling down the table to reveal search bar will result in a glitch if content offset is 0 and we are using `isModalInPresentation` set to true
        tableView.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
    }
    
    private var currentDataSource: BookmarksDataSource {
        if tableView.dataSource === dataSource {
            return dataSource
        }
        return searchDataSource
    }

    @objc func onApplicationBecameActive(notification: NSNotification) {
        tableView.reloadData()
    }
    
    @objc func onExternalDataChange(notification: NSNotification) {
        guard let source = notification.object as? BookmarkUserDefaults,
              dataSource.bookmarksManager.dataStore !== source else { return }
        
        tableView.reloadData()
    }

    private func refreshEditButton() {
        if currentDataSource.isEmpty {
            disableEditButton()
        } else {
            enableEditButton()
        }
    }

    @IBAction func onEditPressed(_ sender: UIBarButtonItem) {
        startEditing()
    }

    @IBAction func onDonePressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing && !currentDataSource.isEmpty {
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
    
    private func prepareForSearching() {
        finishEditing()
        disableEditButton()
    }
    
    private func finishSearching() {
        tableView.dataSource = dataSource
        tableView.reloadData()
        
        enableEditButton()
    }

    fileprivate func showEditBookmarkAlert(for indexPath: IndexPath) {
        let title = UserText.alertEditBookmark
        let link = dataSource.link(at: indexPath)
        let alert = EditBookmarkAlert.buildAlert(
            title: title,
            bookmark: link,
            saveCompletion: { [weak self] (updatedBookmark) in
                self?.dataSource.tableView(self!.tableView, updateBookmark: updatedBookmark, at: indexPath)
            }
        )
        present(alert, animated: true)
    }
    
    fileprivate func showShareSheet(for indexPath: IndexPath) {

        if let link = currentDataSource.link(at: indexPath) {
            let appUrls: AppUrls = AppUrls()
            let url = appUrls.removeATBAndSource(fromUrl: link.url)
            presentShareSheet(withItems: [ url, link ], fromView: self.view)
        } else {
            os_log("Invalid share link found", log: generalLog, type: .debug)
        }
    }

    fileprivate func selectLink(_ link: Link) {
        dismiss()
        delegate?.bookmarksDidSelect(link: link)
    }

    private func dismiss() {
        delegate?.bookmarksUpdated()
        
        if searchController.isActive {
            searchController.dismiss(animated: false) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if #available(iOS 13.0, *), searchController.searchBar.bounds.height == 0 {
            // Disable drag-to-dismiss if we start scrolling and search bar is still hidden
            isModalInPresentation = true
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if #available(iOS 13.0, *), isModalInPresentation, searchController.searchBar.bounds.height > 0 {
            // Re-enable drag-to-dismiss if needed
            isModalInPresentation = false
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if #available(iOS 13.0, *), isModalInPresentation, searchController.searchBar.bounds.height > 0 {
            // Re-enable drag-to-dismiss if needed
            isModalInPresentation = false
        }
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
        
        searchDataSource.performSearch(query: searchText)
        tableView.reloadData()
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

extension BookmarksViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        if #available(iOS 13.0, *) {
            overrideSystemTheme(with: theme)
            searchController.searchBar.searchTextField.textColor = theme.searchBarTextColor
        } else {
            
            switch theme.currentImageSet {
            case .dark:
                searchController.searchBar.barStyle = .black
            case .light:
                searchController.searchBar.barStyle = .default
            }
            
            searchController.searchBar.tintColor = theme.searchBarTextColor
            if let searchField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                searchField.layer.backgroundColor = theme.searchBarBackgroundColor.cgColor
                searchField.layer.cornerRadius = 8
                
                // Hide default background view.
                for view in searchField.subviews {
                    // Background has same size as search field
                    guard view.bounds == searchField.bounds else {
                        continue
                    }

                    view.alpha = 0.0
                    break
                }
            }
        }
        
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        tableView.reloadData()
    }
}

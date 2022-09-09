//
//  AutofillLoginSettingsListViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Combine
import Core
import BrowserServicesKit

// swiftlint:disable file_length

protocol AutofillLoginSettingsListViewControllerDelegate: AnyObject {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController)
}

final class AutofillLoginSettingsListViewController: UIViewController {
    weak var delegate: AutofillLoginSettingsListViewControllerDelegate?
    private let viewModel: AutofillLoginListViewModel
    private let emptyView = AutofillItemsEmptyView()
    private let lockedView = AutofillItemsLockedView()
    private let emptySearchView = AutofillEmptySearchView()
    
    private lazy var addBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UserText.autofillLoginListSearchPlaceholder
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        return searchController
    }()


    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.registerCell(ofType: AutofillListItemTableViewCell.self)
        tableView.registerCell(ofType: EnableAutofillSettingsTableViewCell.self)
        // Have to set tableHeaderView height otherwise tableView content willl jump when adding / removing searchController due to tableView insetGrouped style
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        return tableView
    }()
    
    init(appSettings: AppSettings) {
        self.viewModel = AutofillLoginListViewModel(appSettings: appSettings)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = UserText.autofillLoginListTitle
        setupCancellables()
        installSubviews()
        installConstraints()
        applyTheme(ThemeManager.shared.currentTheme)
        updateViewState()
        configureNotification()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Pixel.fire(pixel: .autofillSettingsOpened)
        authenticate()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

        updateNavigationBarButtons()
        updateSearchController()
    }
    
    @objc
    func addButtonPressed() {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator)
        detailsController.delegate = self
        navigationController?.pushViewController(detailsController, animated: true)
    }
    
    func showAccountDetails(_ account: SecureVaultModels.WebsiteAccount, animated: Bool = true) {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator, account: account)
        detailsController.delegate = self
        navigationController?.pushViewController(detailsController, animated: animated)
    }
    
    private func setupCancellables() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateViewState()
            }
            .store(in: &cancellables)
        
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func configureNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appWillMoveToForegroundCallback),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(appWillMoveToBackgroundCallback),
                                       name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func appWillMoveToForegroundCallback() {
        authenticate()
    }
    
    @objc private func appWillMoveToBackgroundCallback() {
        viewModel.lockUI()
    }
    
    private func authenticate() {
        viewModel.authenticate {[weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.delegate?.autofillLoginSettingsListViewControllerDidFinish(self)
            }
        }
    }
    
    // MARK: Subviews Setup
    
    private func updateViewState() {
        
        switch viewModel.viewState {
        case .showItems :
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = true
        case .authLocked:
            emptyView.isHidden = true
            tableView.isHidden = true
            lockedView.isHidden = false
            emptySearchView.isHidden = true
        case .empty:
            emptyView.viewState = viewModel.isAutofillEnabled ? .autofillEnabled : .autofillDisabled
            emptyView.isHidden = false
            tableView.isHidden = false
            setEditing(false, animated: false)
            lockedView.isHidden = true
            emptySearchView.isHidden = true
        case .searching:
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = true
        case .searchingNoResults:
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = false
        }
        updateNavigationBarButtons()
        updateSearchController()
        tableView.reloadData()
    }
    
    private func updateNavigationBarButtons() {
        switch viewModel.viewState {
        case .showItems:
            if tableView.isEditing {
                navigationItem.rightBarButtonItems = [editButtonItem]
            } else {
                if viewModel.isAutofillEnabled {
                    navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
                } else {
                    navigationItem.rightBarButtonItems = [addBarButtonItem]
                }
                addBarButtonItem.isEnabled = true
            }
            editButtonItem.isEnabled = true
        case .authLocked:
            navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
            addBarButtonItem.isEnabled = false
            editButtonItem.isEnabled = false
        case .empty:
            if viewModel.isAutofillEnabled {
                navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
                editButtonItem.isEnabled = false
            } else {
                navigationItem.rightBarButtonItems = [addBarButtonItem]
            }
            addBarButtonItem.isEnabled = true
        case .searching, .searchingNoResults:
            navigationItem.rightBarButtonItems = []
        }
    }

    private func updateSearchController() {
        switch viewModel.viewState {
        case .showItems:
            if tableView.isEditing {
                navigationItem.searchController = nil
            } else {
                navigationItem.searchController = searchController
            }
        case .searching, .searchingNoResults:
            navigationItem.searchController = searchController
        case .empty, .authLocked:
            navigationItem.searchController = nil
        }
    }

    private func installSubviews() {
        view.addSubview(tableView)
        tableView.addSubview(emptySearchView)
        view.addSubview(lockedView)
    }
    
    private func installConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptySearchView.translatesAutoresizingMaskIntoConstraints = false
        lockedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptySearchView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptySearchView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 160),
            emptySearchView.widthAnchor.constraint(equalToConstant: 225),

            lockedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            lockedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            lockedView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    
    // MARK: Cell Methods
    
    private func credentialCell(for tableView: UITableView, item: AutofillLoginListItemViewModel, indexPath: IndexPath) -> AutofillListItemTableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillListItemTableViewCell.self, for: indexPath)
        cell.viewModel = item
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func enableAutofillCell(for tableView: UITableView, indexPath: IndexPath) -> EnableAutofillSettingsTableViewCell {
        let cell = tableView.dequeueCell(ofType: EnableAutofillSettingsTableViewCell.self, for: indexPath)
        cell.delegate = self
        cell.isToggleOn = viewModel.isAutofillEnabled
        cell.theme = ThemeManager.shared.currentTheme
        return cell
    }
}

// MARK: UITableViewDelegate

extension AutofillLoginSettingsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            return 44
        case .credentials:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewModel.sections[indexPath.section] {
        case .credentials(_, let items):
            let item = items[indexPath.row]
            showAccountDetails(item.account)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch viewModel.viewState {
        case .empty:
            return emptyView
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        switch viewModel.viewState {
        case .empty:
            return 255
        default:
            return 0
        }
    }
}

// MARK: UITableViewDataSource

extension AutofillLoginSettingsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsInSection(section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            return enableAutofillCell(for: tableView, indexPath: indexPath)
        case .credentials(_, let items):
            return credentialCell(for: tableView, item: items[indexPath.row], indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .credentials(_, let items):
            if editingStyle == .delete {
                let shouldDeleteSection = items.count == 1
                let title = items[indexPath.row].title
                let deletedSuccessfully = viewModel.delete(at: indexPath)
                
                if shouldDeleteSection {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                
                if deletedSuccessfully {
                    ActionMessageView.present(message: UserText.autofillLoginLisLoginDeletedToastMessage(for: title),
                                              actionTitle: UserText.actionGenericUndo,
                                              presentationLocation: .withoutBottomBar,
                                              onAction: {
                        self.viewModel.undoLastDelete()
                    }, onDidDismiss: {
                        self.viewModel.clearUndoCache()
                    })
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sections[section] {
        case .enableAutofill:
            return nil
        case .credentials(let title, _):
            return title
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        viewModel.viewState == .showItems ? UILocalizedIndexedCollation.current().sectionIndexTitles : []
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewModel.sections[indexPath.section] {
        case .credentials:
            return true
        default :
            return false
        }
    }
}

// MARK: AutofillLoginDetailsViewControllerDelegate

extension AutofillLoginSettingsListViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController) {
        viewModel.updateData()
        tableView.reloadData()
    }
}

// MARK: EnableAutofillSettingsTableViewCellDelegate

extension AutofillLoginSettingsListViewController: EnableAutofillSettingsTableViewCellDelegate {
    func enableAutofillSettingsTableViewCell(_ cell: EnableAutofillSettingsTableViewCell, didChangeSettings value: Bool) {
        viewModel.isAutofillEnabled = value
        updateViewState()
    }
}

// MARK: Themable

extension AutofillLoginSettingsListViewController: Themable {

    func decorate(with theme: Theme) {
        lockedView.decorate(with: theme)
        emptyView.decorate(with: theme)
        emptySearchView.decorate(with: theme)

        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.sectionIndexColor = theme.buttonTintColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor
        
        tableView.reloadData()
    }
}

// MARK: UISearchControllerDelegate

extension AutofillLoginSettingsListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.isSearching = searchController.isActive
        if let query = searchController.searchBar.text {
            viewModel.filterData(with: query)
            emptySearchView.query = query
        }
    }
}

// swiftlint:enable file_length

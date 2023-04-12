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
import Common
import os.log

// swiftlint:disable file_length type_body_length

protocol AutofillLoginSettingsListViewControllerDelegate: AnyObject {
    func autofillLoginSettingsListViewControllerDidFinish(_ controller: AutofillLoginSettingsListViewController)
}

final class AutofillLoginSettingsListViewController: UIViewController {

    private enum Constants {
        static let padding: CGFloat = 16
    }

    weak var delegate: AutofillLoginSettingsListViewControllerDelegate?
    private let viewModel: AutofillLoginListViewModel
    private let emptyView = AutofillItemsEmptyView()
    private let lockedView = AutofillItemsLockedView()
    private let emptySearchView = AutofillEmptySearchView()
    private let noAuthAvailableView = AutofillNoAuthAvailableView()
    private let tld: TLD = AppDependencyProvider.shared.storageCache.tld

    private lazy var addBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UserText.autofillLoginListSearchPlaceholder
        navigationItem.hidesSearchBarWhenScrolling = false
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
        // Have to set tableHeaderView height otherwise tableView content will jump when adding / removing searchController due to tableView insetGrouped style
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        return tableView
    }()

    private lazy var lockedViewBottomConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: tableView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: lockedView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 144)
    }()

    private lazy var emptySearchViewCenterYConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: emptySearchView,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: tableView,
                           attribute: .top,
                           multiplier: 1,
                           constant: (tableView.frame.height / 2))
    }()

    init(appSettings: AppSettings, currentTabUrl: URL? = nil) {
        let secureVault = try? SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
        if secureVault == nil {
            os_log("Failed to make vault")
        }
        self.viewModel = AutofillLoginListViewModel(appSettings: appSettings, tld: tld, secureVault: secureVault, currentTabUrl: currentTabUrl)
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
        registerForKeyboardNotifications()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if viewModel.authenticator.canAuthenticate() {
            AppDependencyProvider.shared.autofillLoginSession.startSession()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.updateConstraintConstants()
            self.emptyView.refreshConstraints()
            if self.view.subviews.contains(self.noAuthAvailableView) {
                self.noAuthAvailableView.refreshConstraints()
            }
            if !self.searchController.isActive {
                self.navigationItem.searchController = nil
            }
        }, completion: { _ in
            self.updateSearchController()
        })
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)

        updateNavigationBarButtons()
        updateSearchController()
    }
    
    @objc
    func addButtonPressed() {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator,
                                                                   tld: tld,
                                                                   authenticationNotRequired: viewModel.authenticationNotRequired)
        detailsController.delegate = self
        let detailsNavigationController = UINavigationController(rootViewController: detailsController)
        navigationController?.present(detailsNavigationController, animated: true)
    }
    
    func showAccountDetails(_ account: SecureVaultModels.WebsiteAccount, animated: Bool = true) {
        let detailsController = AutofillLoginDetailsViewController(authenticator: viewModel.authenticator,
                                                                   account: account,
                                                                   tld: tld,
                                                                   authenticationNotRequired: viewModel.authenticationNotRequired)
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

        notificationCenter.addObserver(self,
                                       selector: #selector(authenticatorInvalidateContext),
                                       name: AutofillLoginListAuthenticator.Notifications.invalidateContext, object: nil)
    }
    
    @objc private func appWillMoveToForegroundCallback() {
        // AutofillLoginDetailsViewController will handle calling authenticate() if it is the top view controller
        guard navigationController?.topViewController is AutofillLoginDetailsViewController else {
            authenticate()
            return
        }
    }
    
    @objc private func appWillMoveToBackgroundCallback() {
        viewModel.lockUI()
    }

    @objc private func authenticatorInvalidateContext() {
        viewModel.authenticateInvalidateContext()
    }
    
    private func authenticate() {
        viewModel.authenticate {[weak self] error in
            guard let self = self else { return }
            if error != nil {
                if error != .noAuthAvailable {
                    self.delegate?.autofillLoginSettingsListViewControllerDidFinish(self)
                }
            }
        }
    }

    private func presentDeleteConfirmation(for title: String) {
        let message = title.isEmpty ? UserText.autofillLoginListLoginDeletedToastMessageNoTitle
                                    : UserText.autofillLoginListLoginDeletedToastMessage(for: title)

        ActionMessageView.present(message: message,
                                  actionTitle: UserText.actionGenericUndo,
                                  presentationLocation: .withoutBottomBar,
                                  onAction: {
            self.viewModel.undoLastDelete()
        }, onDidDismiss: {
            self.viewModel.clearUndoCache()
        })
    }
    
    // MARK: Subviews Setup

    private func updateViewState() {
        
        switch viewModel.viewState {
        case .showItems:
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .noAuthAvailable:
            emptyView.isHidden = true
            tableView.isHidden = true
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = false
            emptySearchView.isHidden = true
        case .authLocked:
            emptyView.isHidden = true
            tableView.isHidden = true
            lockedView.isHidden = false
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .empty:
            emptyView.viewState = viewModel.isAutofillEnabledInSettings ? .autofillEnabled : .autofillDisabled
            emptyView.isHidden = false
            tableView.isHidden = false
            setEditing(false, animated: false)
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .searching:
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
            emptySearchView.isHidden = true
        case .searchingNoResults:
            emptyView.isHidden = true
            tableView.isHidden = false
            lockedView.isHidden = true
            noAuthAvailableView.isHidden = true
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
                if viewModel.isAutofillEnabledInSettings || (!viewModel.isAutofillEnabledInSettings && viewModel.hasAccountsSaved) {
                    navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
                } else {
                    navigationItem.rightBarButtonItems = [addBarButtonItem]
                }
                addBarButtonItem.isEnabled = true
            }
            editButtonItem.isEnabled = true
        case .noAuthAvailable:
            navigationItem.rightBarButtonItems = [addBarButtonItem]
            addBarButtonItem.isEnabled = false
        case .authLocked:
            navigationItem.rightBarButtonItems = [editButtonItem, addBarButtonItem]
            addBarButtonItem.isEnabled = false
            editButtonItem.isEnabled = false
        case .empty:
            if viewModel.isAutofillEnabledInSettings {
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
        case .empty, .authLocked, .noAuthAvailable:
            navigationItem.searchController = nil
        }
    }

    private func installSubviews() {
        view.addSubview(tableView)
        tableView.addSubview(emptySearchView)
        view.addSubview(lockedView)
        view.addSubview(noAuthAvailableView)
    }
    
    private func installConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptySearchView.translatesAutoresizingMaskIntoConstraints = false
        lockedView.translatesAutoresizingMaskIntoConstraints = false
        noAuthAvailableView.translatesAutoresizingMaskIntoConstraints = false

        updateConstraintConstants()

        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptySearchView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptySearchViewCenterYConstraint,
            emptySearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            emptySearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),

            lockedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            lockedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            lockedViewBottomConstraint,

            noAuthAvailableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAuthAvailableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noAuthAvailableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            noAuthAvailableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding)
        ])
    }

    private func updateConstraintConstants() {
        let isIPhoneLandscape = traitCollection.containsTraits(in: UITraitCollection(verticalSizeClass: .compact))
        if isIPhoneLandscape {
            lockedViewBottomConstraint.constant = (view.frame.height / 2 - max(lockedView.frame.height, 120.0) / 2)
        } else {
            lockedViewBottomConstraint.constant = view.frame.height * 0.15
        }
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
        cell.isToggleOn = viewModel.isAutofillEnabledInSettings
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

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch viewModel.viewState {
        case .empty:
            return max(tableView.bounds.height - tableView.contentSize.height, 250)
        case .showItems:
            return viewModel.sections[section] == .enableAutofill ? 10 : 0
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
                let title = items[indexPath.row].title
                let accountId = items[indexPath.row].account.id

                let tableContentToDelete = viewModel.tableContentsToDelete(accountId: accountId)

                let deletedSuccessfully = viewModel.delete(at: indexPath)

                if deletedSuccessfully {
                    tableView.beginUpdates()
                    if !tableContentToDelete.sectionsToDelete.isEmpty {
                        tableView.deleteSections(IndexSet(tableContentToDelete.sectionsToDelete), with: .automatic)
                    }
                    if !tableContentToDelete.rowsToDelete.isEmpty {
                        tableView.deleteRows(at: tableContentToDelete.rowsToDelete, with: .automatic)
                    }
                    tableView.endUpdates()

                    presentDeleteConfirmation(for: title)
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
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var closestSoFar = 0
        var exactMatchIndex: Int?
        for (index, section) in viewModel.sections.enumerated() {
            if case .credentials(let sectionTitle, _) = section {
                
                if let first = title.first, !first.isLetter {
                    return viewModel.sections.count - 1
                }
                
                let result = sectionTitle.localizedCaseInsensitiveCompare(title)
                if result == .orderedSame {
                    exactMatchIndex = index
                    break
                } else if result == .orderedDescending {
                    break
                }
            }
            closestSoFar = index
        }
        return exactMatchIndex ?? closestSoFar
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewModel.sections[indexPath.section] {
        case .credentials:
            return true
        default:
            return false
        }
    }
}

// MARK: AutofillLoginDetailsViewControllerDelegate

extension AutofillLoginSettingsListViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController, account: SecureVaultModels.WebsiteAccount?) {
        viewModel.updateData()
        tableView.reloadData()

        if let account = account {
            showAccountDetails(account)
        }
    }

    func autofillLoginDetailsViewControllerDelete(account: SecureVaultModels.WebsiteAccount, title: String) {
        let deletedSuccessfully = viewModel.delete(account)

        if deletedSuccessfully {
            viewModel.updateData()
            tableView.reloadData()
            presentDeleteConfirmation(for: title)
        }
    }
}

// MARK: EnableAutofillSettingsTableViewCellDelegate

extension AutofillLoginSettingsListViewController: EnableAutofillSettingsTableViewCellDelegate {
    func enableAutofillSettingsTableViewCell(_ cell: EnableAutofillSettingsTableViewCell, didChangeSettings value: Bool) {
        if value {
            Pixel.fire(pixel: .autofillLoginsSettingsEnabled)
        } else {
            Pixel.fire(pixel: .autofillLoginsSettingsDisabled)
        }
        
        viewModel.isAutofillEnabledInSettings = value
        updateViewState()
    }
}

// MARK: Themable

extension AutofillLoginSettingsListViewController: Themable {

    func decorate(with theme: Theme) {
        lockedView.decorate(with: theme)
        emptyView.decorate(with: theme)
        emptySearchView.decorate(with: theme)
        noAuthAvailableView.decorate(with: theme)

        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.sectionIndexColor = theme.buttonTintColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowColor = .clear
            appearance.backgroundColor = theme.backgroundColor

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

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

// MARK: Keyboard

extension AutofillLoginSettingsListViewController {

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustForKeyboard),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    @objc private func adjustForKeyboard(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        emptySearchViewCenterYConstraint.constant = min(
            (keyboardViewEndFrame.minY + emptySearchView.frame.height) / 2 - searchController.searchBar.frame.height,
            (tableView.frame.height / 2) - searchController.searchBar.frame.height
        )
    }
}
// swiftlint:enable file_length type_body_length

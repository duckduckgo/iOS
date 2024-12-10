//
//  CredentialProviderListViewController.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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
import AuthenticationServices
import BrowserServicesKit
import Combine
import Common
import Core
import SwiftUI

final class CredentialProviderListViewController: UIViewController {

    private let viewModel: CredentialProviderListViewModel
    private let shouldProvideTextToInsert: Bool
    private let tld: TLD
    private let onRowSelected: (AutofillLoginItem) -> Void
    private let onTextProvided: (String) -> Void
    private let onDismiss: () -> Void
    private var cancellables: Set<AnyCancellable> = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 60
        tableView.register(CredentialProviderListItemTableViewCell.self, forCellReuseIdentifier: CredentialProviderListItemTableViewCell.reuseIdentifier)
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = UserText.credentialProviderListSearchPlaceholder
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        return searchController
    }()

    private lazy var lockedView = { [weak self] in
        let view = LockScreenView()
        let hostingController = UIHostingController(rootView: view)
        self?.installChildViewController(hostingController)
        return hostingController.view ?? UIView()
    }()

    private let emptySearchView = EmptySearchView()

    private lazy var emptyView: UIView = { [weak self] in
        let emptyView = EmptyView()

        let hostingController = UIHostingController(rootView: emptyView)
        self?.installChildViewController(hostingController)
        hostingController.view.backgroundColor = .clear
        return hostingController.view
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

    init(serviceIdentifiers: [ASCredentialServiceIdentifier],
         secureVault: (any AutofillSecureVault)?,
         credentialIdentityStoreManager: AutofillCredentialIdentityStoreManaging,
         shouldProvideTextToInsert: Bool,
         tld: TLD,
         onRowSelected: @escaping (AutofillLoginItem) -> Void,
         onTextProvided: @escaping (String) -> Void,
         onDismiss: @escaping () -> Void) {
        self.viewModel = CredentialProviderListViewModel(serviceIdentifiers: serviceIdentifiers,
                                                         secureVault: secureVault,
                                                         credentialIdentityStoreManager: credentialIdentityStoreManager,
                                                         tld: tld)
        self.shouldProvideTextToInsert = shouldProvideTextToInsert
        self.tld = tld
        self.onRowSelected = onRowSelected
        self.onTextProvided = onTextProvided
        self.onDismiss = onDismiss

        super.init(nibName: nil, bundle: nil)

        if #available(iOS 18.0, *) {
            authenticate()
        } else {
            // pre-iOS 18.0 authentication can fail silently if extension is loaded twice in quick succession
            // if authenticate is called without a slight delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.authenticate()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = UserText.credentialProviderListTitle

        if let itemPrompt = viewModel.serviceIdentifierPromptLabel {
            navigationItem.prompt = itemPrompt
        }

        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneItem

        setupCancellables()
        installSubviews()
        installConstraints()
        decorate()
        updateViewState()
        registerForKeyboardNotifications()

        navigationItem.searchController = searchController

        Pixel.fire(pixel: .autofillExtensionPasswordsOpened)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.authenticateInvalidateContext()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            if !self.searchController.isActive {
                self.navigationItem.searchController = nil
            }
        }, completion: { _ in
            self.updateSearchController()
        })
    }

    private func decorate() {
        view.backgroundColor = UIColor(designSystemColor: .background)
        tableView.backgroundColor = UIColor(designSystemColor: .background)
        tableView.separatorColor = UIColor(designSystemColor: .lines)
        tableView.sectionIndexColor = UIColor(designSystemColor: .accent)

        navigationController?.navigationBar.barTintColor = UIColor(designSystemColor: .panel)
        navigationController?.navigationBar.tintColor = UIColor(designSystemColor: .textPrimary)

        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(designSystemColor: .background)

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tableView.reloadData()
    }

    private func authenticate() {
        viewModel.authenticate {[weak self] error in
            guard let self = self else { return }

            if error != nil {
                if error != .noAuthAvailable {
                    self.onDismiss()
                } else {
                    let alert = UIAlertController.makeDeviceAuthenticationAlert { [weak self] in
                        self?.onDismiss()
                    }
                    present(alert, animated: true)
                }
            }
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

        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptySearchView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptySearchViewCenterYConstraint,
            emptySearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptySearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
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

    private func updateViewState() {

        switch viewModel.viewState {
        case .showItems:
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = true
            emptyView.isHidden = true
        case .noAuthAvailable:
            tableView.isHidden = true
            lockedView.isHidden = true
            emptySearchView.isHidden = true
            emptyView.isHidden = true
        case .authLocked:
            tableView.isHidden = true
            lockedView.isHidden = false
            emptySearchView.isHidden = true
            emptyView.isHidden = true
        case .empty:
            tableView.isHidden = true
            lockedView.isHidden = true
            emptySearchView.isHidden = true
            emptyView.isHidden = false
        case .searching:
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = true
            emptyView.isHidden = true
        case .searchingNoResults:
            tableView.isHidden = false
            lockedView.isHidden = true
            emptySearchView.isHidden = false
            emptyView.isHidden = true
        }
        updateSearchController()
        tableView.reloadData()
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
        case .authLocked:
            navigationItem.searchController = viewModel.hasAccountsSaved ? searchController : nil
        case .empty, .noAuthAvailable:
            navigationItem.searchController = nil
        }
    }

    @objc private func doneTapped() {
        onDismiss()
        Pixel.fire(pixel: .autofillExtensionPasswordsDismissed)
    }

}

extension CredentialProviderListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .suggestions(_, items: let items), .credentials(_, let items):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CredentialProviderListItemTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? CredentialProviderListItemTableViewCell else {
                fatalError("Could not dequeue cell")
            }
            cell.item = items[indexPath.row]
            cell.backgroundColor = UIColor(designSystemColor: .surface)

            cell.disclosureButtonTapped = { [weak self] in
                let item = items[indexPath.row]
                self?.presentDetailsForCredentials(item: item)
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sections[section] {
        case .suggestions(let title, _), .credentials(let title, _):
            return title
        default:
            return nil
        }
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        viewModel.viewState == .showItems ? UILocalizedIndexedCollation.current().sectionIndexTitles : []
    }

    private func presentDetailsForCredentials(item: AutofillLoginItem) {
        let detailViewController = CredentialProviderListDetailsViewController(account: item.account,
                                                                               tld: tld,
                                                                               shouldProvideTextToInsert: self.shouldProvideTextToInsert)
        detailViewController.delegate = self

        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension CredentialProviderListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch viewModel.sections[indexPath.section] {
        case .suggestions(_, items: let items), .credentials(_, let items):
            let item = items[indexPath.row]
            if shouldProvideTextToInsert {
                presentDetailsForCredentials(item: item)
            } else {
                onRowSelected(item)
                Pixel.fire(pixel: .autofillExtensionPasswordSelected)
            }
        default:
            return
        }
    }

}

extension CredentialProviderListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.isSearching = searchController.isActive

        if let query = searchController.searchBar.text {
            viewModel.filterData(with: query)
            emptySearchView.query = query
            tableView.reloadData()
        }
    }

}

extension CredentialProviderListViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.isSearching = false

        viewModel.filterData(with: "")
        tableView.reloadData()
    }

}

// MARK: Keyboard

extension CredentialProviderListViewController {

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

extension CredentialProviderListViewController: CredentialProviderListDetailsViewControllerDelegate {

    func credentialProviderListDetailsViewControllerDidProvideText(_ controller: CredentialProviderListDetailsViewController, text: String) {
        onTextProvided(text)
    }

}

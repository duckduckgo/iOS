//
//  AutofillLoginDetailsViewController.swift
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
import SwiftUI
import BrowserServicesKit
import Common
import Combine

protocol AutofillLoginDetailsViewControllerDelegate: AnyObject {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController)
    func autofillLoginDetailsViewControllerDelete(account: SecureVaultModels.WebsiteAccount)
}

class AutofillLoginDetailsViewController: UIViewController {
    
    weak var delegate: AutofillLoginDetailsViewControllerDelegate?
    private let viewModel: AutofillLoginDetailsViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var authenticator = AutofillLoginListAuthenticator()
    private let lockedView = AutofillItemsLockedView()
    private var contentView: UIView?

    private lazy var saveBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        let attributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        barButtonItem.setTitleTextAttributes(attributes, for: .normal)
        return barButtonItem
    }()

    private lazy var editBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
        let attributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        barButtonItem.setTitleTextAttributes(attributes, for: .normal)
        return barButtonItem
    }()

    init(authenticator: AutofillLoginListAuthenticator, account: SecureVaultModels.WebsiteAccount? = nil, tld: TLD) {
        self.viewModel = AutofillLoginDetailsViewModel(account: account, tld: tld)
        self.authenticator = authenticator
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installSubviews()
        setupNavigationBar()
        setupCancellables()
        setupTableViewAppearance()
        applyTheme(ThemeManager.shared.currentTheme)
        installConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticator.authenticate()
    }
    
    private func installSubviews() {
        installContentView()
        view.addSubview(lockedView)
    }

    private func installConstraints() {
        lockedView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lockedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lockedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            lockedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            lockedView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    
    private func setupTableViewAppearance() {
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [AutofillLoginDetailsViewController.self])
        appearance.backgroundColor = UIColor(named: "ListBackground")
    }
    
    private func setupCancellables() {
        viewModel.$viewMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupNavigationBar()
            }
            .store(in: &cancellables)
        
        Publishers.MergeMany(
            viewModel.$title,
            viewModel.$username,
            viewModel.$password,
            viewModel.$address)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setupNavigationBar()
            }
            .store(in: &cancellables)
        
        authenticator.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAuthViews()
            }
            .store(in: &cancellables)
    }
    
    private func updateAuthViews() {
        switch authenticator.state {
        case .loggedOut:
            lockedView.isHidden = false
            self.contentView?.isHidden = true
        case .loggedIn:
            lockedView.isHidden = true
            self.contentView?.isHidden = false
        }
    }
    
    private func installContentView() {
        let contentView = AutofillLoginDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: contentView)
        installChildViewController(hostingController)
        self.contentView = hostingController.view
    }
    
    private func setupNavigationBar() {
        title = viewModel.navigationTitle
        switch viewModel.viewMode {
        case .edit:
            navigationItem.rightBarButtonItem = saveBarButtonItem
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        case .view:
            navigationItem.rightBarButtonItem = editBarButtonItem
            navigationItem.leftBarButtonItem = nil
        
        case .new:
            if viewModel.shouldShowSaveButton {
                navigationItem.rightBarButtonItem = saveBarButtonItem
            } else {
                navigationItem.rightBarButtonItem = nil
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        }
    }
    
    
    @objc private func toggleEditMode() {
        viewModel.toggleEditMode()
    }
    
    @objc private func save() {
        viewModel.save()
        delegate?.autofillLoginDetailsViewControllerDidSave(self)
    }
    
    @objc private func cancel() {
        if viewModel.viewMode == .new {
            navigationController?.popViewController(animated: true)
        } else {
            toggleEditMode()
        }
    }
}

extension AutofillLoginDetailsViewController: AutofillLoginDetailsViewModelDelegate {
    func autofillLoginDetailsViewModelDidSave() {
        
    }
    
    func autofillLoginDetailsViewModelDidAttemptToSaveDuplicateLogin() {
        let alert = UIAlertController(title: UserText.autofillLoginDetailsSaveDuplicateLoginAlertTitle,
                                      message: UserText.autofillLoginDetailsSaveDuplicateLoginAlertMessage,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: UserText.autofillLoginDetailsSaveDuplicateLoginAlertAction, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    func autofillLoginDetailsViewModelDelete(account: SecureVaultModels.WebsiteAccount) {
        delegate?.autofillLoginDetailsViewControllerDelete(account: account)
        navigationController?.popViewController(animated: true)
    }

    func autofillLoginDetailsViewModelDismiss() {
        navigationController?.dismiss(animated: true)
    }
}

// MARK: Themable

extension AutofillLoginDetailsViewController: Themable {

    func decorate(with theme: Theme) {
        lockedView.decorate(with: theme)
        lockedView.backgroundColor = theme.backgroundColor
        
        view.backgroundColor = theme.backgroundColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor

        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.shadowColor = .clear
            appearance.backgroundColor = theme.backgroundColor

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
}

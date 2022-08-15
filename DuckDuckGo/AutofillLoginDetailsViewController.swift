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
import Combine

protocol AutofillLoginDetailsViewControllerDelegate: AnyObject {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController)
}

class AutofillLoginDetailsViewController: UIViewController {
    
    weak var delegate: AutofillLoginDetailsViewControllerDelegate?
    private let viewModel: AutofillLoginDetailsViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var authenticator = AutofillLoginListAuthenticator()
    private let lockedView = AutofillItemsLockedView()
    private var contentView: UIView?

    init(authenticator: AutofillLoginListAuthenticator, account: SecureVaultModels.WebsiteAccount? = nil) {
        self.viewModel = AutofillLoginDetailsViewModel(account: account)
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
        //TODo why was this shit not in the view model? Tsk...
        switch viewModel.viewMode {
        case .edit:
            title = UserText.autofillLoginDetailsEditTitle
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))

        case .view:
            title = UserText.autofillLoginDetailsDefaultTitle
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
        
        case .new:
            title = UserText.autofillLoginDetailsNewTitle
            //TODO hide save if everything empty
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
            
        }
    }
    
    
    @objc private func toggleEditMode() {
        viewModel.toggleEditMode()
    }
    
    @objc private func save() {
        viewModel.save()
        viewModel.toggleEditMode()
        delegate?.autofillLoginDetailsViewControllerDidSave(self)
    }
}

extension AutofillLoginDetailsViewController: AutofillLoginDetailsViewModelDelegate {
    func autofillLoginDetailsViewModelDidSave() {
        
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

    }
}

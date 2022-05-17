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

@available(iOS 14.0, *)
protocol AutofillLoginDetailsViewControllerDelegate: AnyObject {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController)
}

@available(iOS 14.0, *)
class AutofillLoginDetailsViewController: UIViewController {
    weak var delegate: AutofillLoginDetailsViewControllerDelegate?
    private let viewModel: AutofillLoginDetailsViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(account: SecureVaultModels.WebsiteAccount) {
        self.viewModel = AutofillLoginDetailsViewModel(account: account)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installContentView()
        setupNavigationBar()
        setupCancellables()
        setupTableViewAppearance()
    }
    
    deinit {
        print("DEINIT DETAILS")
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
    }
    
    private func installContentView() {
        let contentView = AutofillLoginDetailsView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: contentView)
        installChildViewController(hostingController)
    }
    
    private func setupNavigationBar() {
        switch viewModel.viewMode {
        case .edit:
            title = "Edit Login"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))

        case .view:
            title = "Login"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
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

@available(iOS 14.0, *)
extension AutofillLoginDetailsViewController: AutofillLoginDetailsViewModelDelegate {
    func autofillLoginDetailsViewModelDidSave() {
        
    }
}

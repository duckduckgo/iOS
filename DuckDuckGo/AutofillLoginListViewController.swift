//
//  AutofillLoginListViewController.swift
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
import DuckUI

@available(iOS 14.0, *)
final class AutofillLoginListViewController: UIViewController {
    private var viewModel: AutofillLoginListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Autofill Logins"
        
        do {
            self.viewModel = try AutofillLoginListViewModel()
            installContentView(with: viewModel!)
        } catch {
            print("add error ui")
        }
        
        setupTableViewAppearance()
        setupNavigationBarAppearance()
    }
    
    private func setupNavigationBarAppearance() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.tintColor = UIColor(named: "NavigationBarTint")
    }
    
    private func setupTableViewAppearance() {
        let appearance = UITableView.appearance(whenContainedInInstancesOf: [AutofillLoginListViewController.self])
        appearance.backgroundColor = UIColor(named: "ListBackground")
    }
    
    deinit {
        print("DEINIT LIST")
    }
    
    private func installContentView(with viewModel: AutofillLoginListViewModel) {
        let contentView = AutofillLoginListView(viewModel: viewModel) { [weak self] selectedModel in
            self?.showLoginDetails(with: selectedModel.account)
        }
        let hostingController = UIHostingController(rootView: contentView)
        installChildViewController(hostingController)
    }
    
    private func showLoginDetails(with account: SecureVaultModels.WebsiteAccount) {
        let detailsController = AutofillLoginDetailsViewController(account: account)
        detailsController.delegate = self
        navigationController?.pushViewController(detailsController, animated: true)
    }
}

@available(iOS 14.0, *)
extension AutofillLoginListViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController) {
        viewModel?.update()
    }
}

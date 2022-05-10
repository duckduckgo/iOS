//
//  AutofillLoginListTableViewController.swift
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

@available(iOS 14.0, *)
class AutofillLoginListTableViewController: UITableViewController {
    private let viewModel = AutofillLoginListViewModel()
    
    init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = "Autofill Logins"
        tableView.estimatedRowHeight = 60
        tableView.registerCell(ofType: AutofillListItemTableViewCell.self)
        tableView.registerCell(ofType: EnableAutofillSettingsTableViewCell.self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .credentials(_, let items):
            let item = items[indexPath.row]
            let detailsController = AutofillLoginDetailsViewController(account: item.account)
            detailsController.delegate = self
            navigationController?.pushViewController(detailsController, animated: true)
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewModel.sections[indexPath.section] {
        case .credentials:
            return true
        default :
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .credentials(_, let items):
            if editingStyle == .delete {
                let shouldDeleteSection = items.count == 1
                viewModel.delete(at: indexPath)
                
                if shouldDeleteSection {
                    tableView.deleteSections([indexPath.section], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        default:
            break
        }
    }
    
    
    private func credentialCell(for tableView: UITableView, item: AutofillLoginListItemViewModel, indexPath: IndexPath) -> AutofillListItemTableViewCell {
        let cell = tableView.dequeueCell(ofType: AutofillListItemTableViewCell.self, for: indexPath)
        cell.viewModel = item
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func enableAutofillCell(for tableView: UITableView, indexPath: IndexPath) -> EnableAutofillSettingsTableViewCell {
        let cell = tableView.dequeueCell(ofType: EnableAutofillSettingsTableViewCell.self, for: indexPath)
        return cell
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            return 44
        case .credentials:
            return 60
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.sections[indexPath.section] {
        case .enableAutofill:
            return enableAutofillCell(for: tableView, indexPath: indexPath)
        case .credentials(_, let items):
            return credentialCell(for: tableView, item: items[indexPath.row], indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch viewModel.sections[section] {
        case .enableAutofill:
            return nil
        case .credentials(let title, _):
            return title
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        viewModel.indexes
    }
}

@available(iOS 14.0, *)
extension AutofillLoginListTableViewController: AutofillLoginDetailsViewControllerDelegate {
    func autofillLoginDetailsViewControllerDidSave(_ controller: AutofillLoginDetailsViewController) {
        viewModel.update()
        tableView.reloadData()
    }
}

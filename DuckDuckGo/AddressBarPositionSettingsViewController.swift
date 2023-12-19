//
//  AddressBarPositionSettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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

class AddressBarPositionSettingsViewController: UITableViewController {

    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    private lazy var options = AddressBarPosition.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor

        cell.tintColor = theme.buttonTintColor
        cell.textLabel?.textColor = theme.tableCellTextColor

        cell.textLabel?.text = options[indexPath.row].descriptionText
        cell.accessoryType = appSettings.currentAddressBarPosition.descriptionText == cell.textLabel?.text ? .checkmark : .none
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appSettings.currentAddressBarPosition = AddressBarPosition.allCases[indexPath.row]
        tableView.performBatchUpdates {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension AddressBarPositionSettingsViewController: Themable {

    func decorate(with theme: Theme) {

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor

        tableView.reloadData()
    }
}

enum AddressBarPosition: String, CaseIterable {
    case top
    case bottom

    var isBottom: Bool {
        self == .bottom
    }

    var descriptionText: String {
        switch self {
        case .top:
            return UserText.addressBarPositionTop
        case .bottom:
            return UserText.addressBarPositionBottom
        }
    }
}

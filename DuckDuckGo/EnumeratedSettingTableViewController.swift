//
//  EnumeratedSettingTableViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

class EnumeratedSettingTableViewController<Setting: CaseIterable & RawRepresentable>: UITableViewController {

    private let titleForSetting: (Setting) -> String
    private let settingIsSelected: (Setting) -> Bool
    private let settingSelectionHandler: (Setting) -> Void

    private let cellIdentifier = "SettingTableViewCell"

    init(titleForSetting: @escaping (Setting) -> String,
         settingIsSelected: @escaping (Setting) -> Bool,
         settingSelectionHandler: @escaping (Setting) -> Void) {
        self.titleForSetting = titleForSetting
        self.settingIsSelected = settingIsSelected
        self.settingSelectionHandler = settingSelectionHandler

        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        applyTheme(ThemeManager.shared.currentTheme)
    }

    private func setting(at targetIndex: Int) -> Setting? {
        for (index, setting) in Setting.allCases.enumerated() {
            if index == targetIndex { return setting }
        }

        return nil
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        if let setting = setting(at: indexPath.row) {
            cell.textLabel?.textColor = ThemeManager.shared.currentTheme.tableCellTextColor
            cell.textLabel?.text = titleForSetting(setting)

            cell.accessoryType = settingIsSelected(setting) ? .checkmark : .none
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let setting = setting(at: indexPath.row) {
            settingSelectionHandler(setting)
        }
    }

}

extension EnumeratedSettingTableViewController: Themable {

    func decorate(with theme: Theme) {

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor

        tableView.reloadData()

    }

}

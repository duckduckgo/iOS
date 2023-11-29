//
//  AutoClearSettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import MessageUI
import Core

class AutoClearSettingsViewController: UITableViewController {
    
    enum Sections: Int, CaseIterable {
        case toggle
        case action
        case timing
    }
    
    @IBOutlet weak var clearDataToggle: UISwitch!
    @IBOutlet var labels: [UILabel]!
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
    private var clearDataSettings: AutoClearSettingsModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearDataSettings = loadClearDataSettings()
        configureClearDataToggle()
        tableView.reloadData()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func loadClearDataSettings() -> AutoClearSettingsModel? {
        return AutoClearSettingsModel(settings: appSettings)
    }
    
    private func configureClearDataToggle() {
        clearDataToggle.isOn = clearDataSettings != nil
    }
    
    override func willMove(toParent parent: UIViewController?) {
        guard parent == nil else { return }
        storeSettingsIfChanged()
    }
    
    private func storeSettingsIfChanged() {
        let oldSettings = loadClearDataSettings()
        if oldSettings != clearDataSettings {
            store()
        }
    }
    
    private func store() {
        if let settings = clearDataSettings {
            appSettings.autoClearAction = settings.action
            appSettings.autoClearTiming = settings.timing
        } else {
            appSettings.autoClearAction = AutoClearSettingsModel.Action()
            appSettings.autoClearTiming = AutoClearSettingsModel.Timing.termination
        }
    }
    
    private func indexPathOf(action: AutoClearSettingsModel.Action) -> IndexPath {
        if action.contains(.clearData) {
            return IndexPath(row: 0, section: Sections.action.rawValue)
        }
        return IndexPath(row: 1, section: Sections.action.rawValue)
    }
    
    private func indexPathOf(timing: AutoClearSettingsModel.Timing) -> IndexPath {
        return IndexPath(row: timing.rawValue, section: Sections.timing.rawValue)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if clearDataSettings != nil {
            return Sections.allCases.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == Sections.action.rawValue {
            if indexPath.row == 0 {
                clearDataSettings?.action = [.clearTabs, .clearData]
            } else {
                clearDataSettings?.action = .clearTabs
            }
        } else if indexPath.section == Sections.timing.rawValue {
            clearDataSettings?.timing = AutoClearSettingsModel.Timing(rawValue: indexPath.row) ?? .termination
        }
        
        storeSettingsIfChanged()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor
        
        if let settings = clearDataSettings,
            indexPathOf(action: settings.action) == indexPath || indexPathOf(timing: settings.timing) == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            let theme = ThemeManager.shared.currentTheme
            view.textLabel?.textColor = theme.tableHeaderTextColor
        }
    }
    
    @IBAction func onClearDataToggled(_ sender: UISwitch) {
        if sender.isOn {
            clearDataSettings = AutoClearSettingsModel()
            tableView.insertSections(.init(integersIn: Sections.action.rawValue...Sections.timing.rawValue), with: .fade)
        } else {
            clearDataSettings = nil
            tableView.deleteSections(.init(integersIn: Sections.action.rawValue...Sections.timing.rawValue), with: .fade)
        }
        
        storeSettingsIfChanged()
    }
}

extension AutoClearSettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        clearDataToggle.onTintColor = theme.buttonTintColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}

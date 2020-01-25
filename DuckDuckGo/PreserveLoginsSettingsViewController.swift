//
//  PreserveLoginsSettingsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 23/01/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class PreserveLoginsSettingsViewController: UITableViewController {
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    var model = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = PreserveLogins.shared.allowedDomains.sorted()
        navigationItem.rightBarButtonItems = model.isEmpty ? nil : [ editButton ]
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    @IBAction func startEditing() {
        tableView.isEditing = true
        navigationItem.rightBarButtonItems = [ doneButton ]
    }
    
    @IBAction func endEditing() {
        tableView.isEditing = false
        navigationItem.rightBarButtonItems = [ editButton ]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return PreserveLogins.shared.userDecision == .preserveLogins ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return model.isEmpty ? 1 : model.count
        default: return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let theme = ThemeManager.shared.currentTheme
        let cell: UITableViewCell
        switch indexPath.section {

        case 0:
            guard let settingCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? PreserveLoginsSwitchCell else {
                fatalError("not SettingsCell")
            }
            settingCell.label.textColor = theme.tableCellTextColor
            settingCell.toggle.isOn = PreserveLogins.shared.userDecision == .preserveLogins
            settingCell.controller = self
            cell = settingCell

        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell")!
            cell.textLabel?.text = model.isEmpty ? "None" : model[indexPath.row] // TODO extract text

        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ClearAllCell")!

        }
        cell.decorate(with: theme)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Logins" : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == 0 ? "Allows you to stay logged in when you burn your data" : nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard !model.isEmpty, indexPath.section == 1 else { return .none }
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let domain = model.remove(at: indexPath.row)
        PreserveLogins.shared.remove(domain: domain)

        if model.count > 0 {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func forgetAll() {
        print("***", #function)
    }

}

extension PreserveLoginsSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)

        if #available(iOS 13.0, *) {
            overrideSystemTheme(with: theme)
        }

        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor

        tableView.reloadData()
    }

}

class PreserveLoginsSwitchCell: UITableViewCell {

    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var label: UILabel!

    weak var controller: PreserveLoginsSettingsViewController!

    @IBAction func onToggle() {
        PreserveLogins.shared.userDecision = toggle.isOn ? .preserveLogins : .forgetAll
        controller.tableView.reloadData()
        if !toggle.isOn {
            controller.forgetAll()
        }
        controller.model = PreserveLogins.shared.allowedDomains
        controller.tableView.reloadData()
    }

}

extension UITableViewCell: Themable {

    func decorate(with theme: Theme) {
        backgroundColor = theme.tableCellBackgroundColor
        textLabel?.textColor = theme.tableCellTextColor
        setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
    }

}

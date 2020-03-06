//
//  PreserveLoginsSettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

protocol PreserveLoginsSettingsDelegate: NSObjectProtocol {

    func forgetAllRequested(completion: @escaping () -> Void)

}

class PreserveLoginsSettingsViewController: UITableViewController {
    
    enum Section: Int {
        case domainList
    }
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    weak var delegate: PreserveLoginsSettingsDelegate?

    var model = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshModel()
        navigationItem.rightBarButtonItems = model.isEmpty ? [] : [ editButton ]
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch PreserveLogins.shared.userDecision {
            
        case .forgetAll:
            Pixel.fire(pixel: .preserveLoginsSettingsWhileForgetting)
            
        case .preserveLogins:
            Pixel.fire(pixel: .preserveLoginsSettingsWhilePreserving)

        case .unknown:
            Pixel.fire(pixel: .preserveLoginsSettingsNewUser)

        }
        
    }
    
    @IBAction func startEditing() {
        Pixel.fire(pixel: .preserveLoginsSettingsEdit)
        
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.setRightBarButton(doneButton, animated: true)
        
        tableView.isEditing = true
        tableView.reloadData()
    }
    
    @IBAction func endEditing() {
        navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.setRightBarButton(model.isEmpty ? nil : editButton, animated: true)
        
        tableView.isEditing = false
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableView.isEditing ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section(rawValue: section) == Section.domainList ? max(1, model.count) : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let theme = ThemeManager.shared.currentTheme
        let cell: UITableViewCell
        switch Section(rawValue: indexPath.section) {

        case .some(Section.domainList):
            if model.isEmpty {
                cell = createNoDomainCell(forTableView: tableView, withTheme: theme)
            } else {
                cell = createDomainCell(forTableView: tableView, withTheme: theme, forIndex: indexPath.row)
            }
            
        default:
            cell = createClearAllCell(forTableView: tableView, withTheme: theme)

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section) == Section.domainList ? UserText.preserveLoginsDomainListHeaderTitle : nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.isInSection(section: Section.domainList) && !model.isEmpty
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard !model.isEmpty, indexPath.isInSection(section: .domainList) else { return .none }
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        Pixel.fire(pixel: tableView.isEditing ? .preserveLoginsSettingsDeleteEditing : .preserveLoginsSettingsDeleteNotEditing)
        
        let domain = model.remove(at: indexPath.row)
        PreserveLogins.shared.remove(domain: domain)
        WebCacheManager.shared.removeCookies(forDomains: [domain]) { }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.model.isEmpty {
                self.endEditing()
            }
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && !model.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            Pixel.fire(pixel: .preserveLoginsSettingsClearAll)
            clearAll()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func createSwitchCell(forTableView tableView: UITableView, withTheme theme: Theme) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? PreserveLoginsSwitchCell else {
            fatalError()
        }
        cell.label.textColor = theme.tableCellTextColor
        cell.toggle.onTintColor = theme.buttonTintColor
        cell.toggle.isOn = PreserveLogins.shared.userDecision == .preserveLogins
        cell.toggle.isEnabled = !tableView.isEditing
        cell.controller = self
        cell.decorate(with: theme)
        return cell
    }
    
    func createDomainCell(forTableView tableView: UITableView, withTheme theme: Theme, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell") as? PreserveLoginDomainCell else {
            fatalError()
        }
        cell.label.textColor = theme.tableCellTextColor
        cell.faviconImage?.loadFavicon(forDomain: model[index])
        cell.label?.text = model[index]
        cell.decorate(with: theme)
        return cell
    }
    
    func createNoDomainCell(forTableView tableView: UITableView, withTheme theme: Theme) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoDomainsCell")!
        cell.decorate(with: theme)
        return cell
    }

    func createClearAllCell(forTableView tableView: UITableView, withTheme theme: Theme) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClearAllCell")!
        cell.decorate(with: theme)
        cell.textLabel?.textColor = theme.destructiveColor
        return cell
    }

    func clearAll() {
        guard !model.isEmpty else { return }
        
        PreserveLoginsAlert.showClearAllAlert(usingController: self, cancelled: { [weak self] in
            PreserveLogins.shared.userDecision = .preserveLogins
            self?.refreshModel()
        }, confirmed: { [weak self] in
            WebCacheManager.shared.removeCookies(forDomains: self?.model ?? []) { }
            PreserveLogins.shared.clearAll()
            self?.refreshModel()
            self?.endEditing()
        })
    }
    
    func refreshModel() {
        model = PreserveLogins.shared.allowedDomains.sorted()
        tableView.reloadData()
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
        Pixel.fire(pixel: toggle.isOn ? .preserveLoginsSettingsSwitchOn : .preserveLoginsSettingsSwitchOff)
        PreserveLogins.shared.userDecision = toggle.isOn ? .preserveLogins : .forgetAll
        controller.tableView.reloadData()
        if !toggle.isOn {
            controller.clearAll()
        } else {
            controller.refreshModel()
            controller.endEditing()
        }
    }

}

class PreserveLoginDomainCell: UITableViewCell {

    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var label: UILabel!

}

fileprivate extension IndexPath {
    
    func isInSection(section: PreserveLoginsSettingsViewController.Section) -> Bool {
        return self.section == section.rawValue
    }
    
}

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

class PreserveLoginsSettingsViewController: UITableViewController {
    
    enum Section: Int, CaseIterable {
        case info
        case toggle
        case domainList
        case removeAll
    }

    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!

    var model = [String]()
    private var shouldShowRemoveAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshModel()
        navigationItem.rightBarButtonItems = model.isEmpty ? [] : [ editButton ]
        applyTheme(ThemeManager.shared.currentTheme)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func startEditing() {
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.setRightBarButton(doneButton, animated: true)

        // Fix glitch happening when there's cell that is already in the editing state (swiped to reveal delete button) and user presses 'Edit'.
        tableView.setEditing(false, animated: true)
        tableView.setEditing(true, animated: true)
        
        shouldShowRemoveAll = true
        tableView.insertSections([Section.removeAll.rawValue], with: .fade)
    }
    
    @IBAction func endEditing() {
        navigationItem.setHidesBackButton(false, animated: true)
        navigationItem.setRightBarButton(model.isEmpty ? nil : editButton, animated: true)
        
        tableView.setEditing(false, animated: true)
        
        if shouldShowRemoveAll {
            shouldShowRemoveAll = false
            tableView.deleteSections([Section.removeAll.rawValue], with: .fade)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return shouldShowRemoveAll ? Section.allCases.count : Section.allCases.count - 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .domainList:
            return max(1, model.count)
            
        case .toggle:
            return 1
                    
        case .removeAll:
            return 1
            
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let theme = ThemeManager.shared.currentTheme
        let cell: UITableViewCell
        switch Section(rawValue: indexPath.section) {

        case .toggle:
            cell = createSwitchCell(forTableView: tableView, withTheme: theme)

        case .domainList:
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
        switch Section(rawValue: section) {
        case .some(.domainList):
            return UserText.preserveLoginsListTitle
        
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.info):
            return UserText.preserveLoginsListFooter
        
        default:
            return nil
        }
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

        let domain = model.remove(at: indexPath.row)
        PreserveLogins.shared.remove(domain: domain)
        Favicons.shared.removeFireproofFavicon(forDomain: domain)
        WebCacheManager.shared.removeCookies(forDomains: [domain]) { }
        
        if self.model.isEmpty {
            self.endEditing()
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 && !model.isEmpty
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.removeAll.rawValue {
            clearAll()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func createSwitchCell(forTableView tableView: UITableView, withTheme theme: Theme) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? PreserveLoginsSwitchCell else {
            fatalError("Cell should be dequeued")
        }
        cell.label.textColor = theme.tableCellTextColor
        cell.toggle.onTintColor = theme.buttonTintColor
        cell.toggle.isOn = PreserveLogins.shared.loginDetectionEnabled
        cell.controller = self
        cell.decorate(with: theme)
        return cell
    }
    
    func createDomainCell(forTableView tableView: UITableView, withTheme theme: Theme, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell") as? PreserveLoginDomainCell else {
            fatalError("Cell should be dequeued")
        }
        cell.label.textColor = theme.tableCellTextColor
        cell.faviconImage.loadFavicon(forDomain: model[index], usingCache: .fireproof)
        cell.label?.text = model[index].droppingWwwPrefix()
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
            self?.refreshModel()
        }, confirmed: { [weak self] in
            WebCacheManager.shared.removeCookies(forDomains: self?.model ?? []) { }
            PreserveLogins.shared.clearAll()
            self?.refreshModel()
            self?.endEditing()
        })
    }
    
    func refreshModel() {
        model = PreserveLogins.shared.allowedDomains.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.droppingWwwPrefix() < rhs.droppingWwwPrefix()
        })
        tableView.reloadData()
    }
}

extension PreserveLoginsSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)

        overrideSystemTheme(with: theme)

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
        PreserveLogins.shared.loginDetectionEnabled = toggle.isOn
    }

}

class PreserveLoginDomainCell: UITableViewCell {

    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var label: UILabel!

}

private extension IndexPath {
    
    func isInSection(section: PreserveLoginsSettingsViewController.Section) -> Bool {
        return self.section == section.rawValue
    }
    
}

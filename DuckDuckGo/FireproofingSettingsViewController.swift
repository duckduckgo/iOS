//
//  FireproofingSettingsViewController.swift
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
import WebKit

class FireproofingSettingsViewController: UITableViewController {
    
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

    private let fireproofing: Fireproofing
    private let websiteDataManager: WebsiteDataManaging

    init?(coder: NSCoder,
          fireproofing: Fireproofing,
          websiteDataManager: WebsiteDataManaging) {
        self.fireproofing = fireproofing
        self.websiteDataManager = websiteDataManager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshModel()
        navigationItem.rightBarButtonItems = model.isEmpty ? [] : [ editButton ]
        decorate()
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
            return UserText.fireproofingListTitle
        
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .some(.info):
            return UserText.fireproofingListFooter
        
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
        fireproofing.remove(domain: domain)
        Favicons.shared.removeFireproofFavicon(forDomain: domain)

        if self.model.isEmpty {
            self.endEditing()
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        Task { @MainActor in
            await websiteDataManager.removeCookies(forDomains: [domain], fromDataStore: WKWebsiteDataStore.current())
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? FireproofingSwitchCell else {
            fatalError("Cell should be dequeued")
        }
        cell.label.textColor = theme.tableCellTextColor
        cell.toggle.onTintColor = theme.buttonTintColor
        cell.toggle.isOn = fireproofing.loginDetectionEnabled
        cell.fireproofing = fireproofing
        cell.controller = self
        cell.decorate(with: theme)
        return cell
    }
    
    func createDomainCell(forTableView tableView: UITableView, withTheme theme: Theme, forIndex index: Int) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DomainCell") as? FireproofingDomainCell else {
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
        
        FireproofingAlert.showClearAllAlert(usingController: self, cancelled: { [weak self] in
            self?.refreshModel()
        }, confirmed: { [weak self] in
            Task { @MainActor in
                await self?.websiteDataManager.removeCookies(forDomains: self?.model ?? [], fromDataStore: WKWebsiteDataStore.current())
                self?.fireproofing.clearAll()
                self?.refreshModel()
                self?.endEditing()
            }
        })
    }
    
    func refreshModel() {
        model = fireproofing.allowedDomains.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.droppingWwwPrefix() < rhs.droppingWwwPrefix()
        })
        tableView.reloadData()
    }
}

extension FireproofingSettingsViewController {

    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        decorateNavigationBar(with: theme)

        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor

        tableView.reloadData()
    }

}

class FireproofingSwitchCell: UITableViewCell {

    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var label: UILabel!

    weak var controller: FireproofingSettingsViewController!
    var fireproofing: Fireproofing?

    @IBAction func onToggle() {
        fireproofing?.loginDetectionEnabled = toggle.isOn
    }

}

class FireproofingDomainCell: UITableViewCell {

    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var label: UILabel!

}

private extension IndexPath {
    
    func isInSection(section: FireproofingSettingsViewController.Section) -> Bool {
        return self.section == section.rawValue
    }
    
}

//
//  UnprotectedSitesViewController.swift
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
import Core
import BrowserServicesKit

class UnprotectedSitesViewController: UITableViewController {
    
    @IBOutlet var infoText: UILabel!
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var flexibleSpace: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    private var hiddenNavBarItem: UIBarButtonItem?
    private var hiddenNavBarItems: [UIBarButtonItem]?

    private let privacyConfig: PrivacyConfiguration = ContentBlocking.shared.privacyConfigurationManager.privacyConfig
    private let rulesManager: ContentBlockerRulesManager = ContentBlocking.shared.contentBlockingManager

    var showBackButton = false
    var enforceLightTheme = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
        
        navigationController?.setToolbarHidden(false, animated: false)
        refreshToolbarItems(animated: false)
        
        configureBackButton()
        
        let fontSize = SettingsViewController.fontSizeForHeaderView
        let text = NSAttributedString(string: infoText.text ?? "", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
        ])
        infoText.attributedText = text
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    private func refreshToolbarItems(animated: Bool) {
        if tableView.isEditing {
            setToolbarItems([flexibleSpace, doneButton], animated: animated)
        } else {
            setToolbarItems([flexibleSpace, editButton], animated: animated)
        }
        
        editButton.isEnabled = privacyConfig.userUnprotectedDomains.count > 0
    }
    
    private func configureBackButton() {
        backButton.isHidden = !showBackButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    // MARK: UITableView data source

    private var unprotectedDomains: [String] {
        return privacyConfig.userUnprotectedDomains.sorted()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = unprotectedDomains.count
        return count == 0 ? 1 : count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(forRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return unprotectedDomains.count > 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let domain = unprotectedDomains[indexPath.row]
        privacyConfig.userEnabledProtection(forDomain: domain)
        rulesManager.scheduleCompilation()

        if unprotectedDomains.count == 0 {
            if tableView.isEditing {
                // According to documentation it is inivalid to call it synchronously here.
                DispatchQueue.main.async {
                    self.endEditing()
                }
            } else {
                refreshToolbarItems(animated: true)
            }
            
            tableView.reloadData()
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK: actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func onAddPressed() {

        let title = UserText.alertDisableProtection
        let placeholder = UserText.alertDisableProtectionPlaceholder
        let confirm = UserText.actionAdd
        let cancel = UserText.actionCancel

        let addSiteBox = UIAlertController(title: title, message: "", preferredStyle: .alert)
        addSiteBox.overrideUserInterfaceStyle()
        addSiteBox.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        }
        addSiteBox.addAction(UIAlertAction.init(title: confirm, style: .default, handler: { _ in self.addSite(from: addSiteBox) }))
        addSiteBox.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(addSiteBox, animated: true, completion: nil)

    }
    
    @IBAction func onBackPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startEditing() {
        navigationItem.setHidesBackButton(true, animated: true)
        hiddenNavBarItems = navigationItem.rightBarButtonItems
        navigationItem.setRightBarButtonItems(nil, animated: true)
        
        // Fix glitch happening when there's cell that is already in the editing state (swiped to reveal delete button) and user presses 'Edit'.
        tableView.setEditing(false, animated: true)
        tableView.setEditing(true, animated: true)
        
        refreshToolbarItems(animated: true)
    }
    
    @IBAction func endEditing() {
        navigationItem.setHidesBackButton(false, animated: true)
        if let hiddenNavBarItems = hiddenNavBarItems {
            navigationItem.setRightBarButtonItems(hiddenNavBarItems, animated: true)
        }
        
        tableView.setEditing(false, animated: true)
        
        refreshToolbarItems(animated: true)
    }

    // MARK: private

    private func addSite(from controller: UIAlertController) {
        guard let field = controller.textFields?[0] else { return }
        guard let domain = domain(from: field) else { return }
        privacyConfig.userDisabledProtection(forDomain: domain)
        rulesManager.scheduleCompilation()
        tableView.reloadData()
        refreshToolbarItems(animated: true)
    }

    private func domain(from field: UITextField) -> String? {
        guard let domain = field.text?.trimmingWhitespace() else { return nil }
        guard domain.isValidHostname || domain.isValidIpHost else { return nil }
        return domain
    }

    private func createCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if unprotectedDomains.count > 0 {
            cell = createUnprotectedSiteCell(forRowAt: indexPath)
        } else {
            cell = createAllProtectedCell(forRowAt: indexPath)
        }
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        
        return cell
    }
    
    private func createAllProtectedCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let allProtectedCell = tableView.dequeueReusableCell(withIdentifier: "AllProtectedCell") as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue NoSuggestionsTableViewCell using 'AllProtectedCell'")
        }
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        allProtectedCell.label.textColor = theme.tableCellTextColor
        
        return allProtectedCell
    }
    
    private func createUnprotectedSiteCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let unprotectedItemCell = tableView.dequeueReusableCell(withIdentifier: "UnprotectedSitesItemCell") as? UnprotectedSitesItemCell else {
            fatalError("Failed to dequeue cell as UnprotectedSitesItemCell")
        }
        
        unprotectedItemCell.domain = unprotectedDomains[indexPath.row]
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        unprotectedItemCell.domainLabel.textColor = theme.tableCellTextColor
        
        return unprotectedItemCell
    }

}

class UnprotectedSitesItemCell: UITableViewCell {

    @IBOutlet weak var domainLabel: UILabel!

    var domain: String? {
        get {
            return domainLabel.text
        }
        set {
            domainLabel.text = newValue
        }
    }

}

extension UnprotectedSitesViewController: Themable {
    
    func decorate(with theme: Theme) {
        let theme = enforceLightTheme ? LightTheme() : theme
        
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        infoText.textColor = theme.tableHeaderTextColor
        
        tableView.reloadData()
        
        navigationController?.toolbar.barTintColor = navigationController?.navigationBar.barTintColor
        navigationController?.toolbar.backgroundColor = navigationController?.navigationBar.backgroundColor
        navigationController?.toolbar.tintColor = navigationController?.navigationBar.tintColor
    }
}

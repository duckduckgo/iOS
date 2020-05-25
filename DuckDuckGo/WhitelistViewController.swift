//
//  WhitelistViewController.swift
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

class WhitelistViewController: UITableViewController {
    
    @IBOutlet var infoText: UILabel!
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var flexibleSpace: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    private var hiddenNavBarItem: UIBarButtonItem?
    private var hiddenNavBarItems: [UIBarButtonItem]?
    
    let whitelistManager = WhitelistManager()
    
    var showBackButton = false
    var enforceLightTheme = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
        
        navigationController?.setToolbarHidden(false, animated: false)
        refreshToolbarItems(animated: false)
        
        configureBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    private func refreshToolbarItems(animated: Bool) {
        if tableView.isEditing {
            setToolbarItems([flexibleSpace, doneButton], animated: animated)
        } else {
            setToolbarItems([flexibleSpace, editButton], animated: animated)
        }
        
        editButton.isEnabled = whitelistManager.count > 0
    }
    
    private func configureBackButton() {
        backButton.isHidden = !showBackButton
    }
    
    // MARK: UITableView data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whitelistManager.count == 0 ? 1 : whitelistManager.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return createCell(forRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return whitelistManager.count > 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        if let domain = whitelistManager.domain(at: indexPath.row) {
            whitelistManager.remove(domain: domain)
            
            if whitelistManager.count == 0 {
                if tableView.isEditing {
                    // According to documentation it is inivalid to call it synchronously here.
                    DispatchQueue.main.async {
                        self.endEditing()
                    }
                } else {
                    refreshToolbarItems(animated: true)
                }
            }
            
            tableView.reloadData()
        }
    }

    // MARK: actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func onAddPressed() {

        let title = UserText.alertAddToWhitelist
        let placeholder = UserText.alertAddToWhitelistPlaceholder
        let add = UserText.actionAdd
        let cancel = UserText.actionCancel

        let addSiteBox = UIAlertController(title: title, message: "", preferredStyle: .alert)
        addSiteBox.overrideUserInterfaceStyle()
        addSiteBox.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.keyboardAppearance = ThemeManager.shared.currentTheme.keyboardAppearance
        }
        addSiteBox.addAction(UIAlertAction.init(title: add, style: .default, handler: { _ in self.addSite(from: addSiteBox) }))
        addSiteBox.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(addSiteBox, animated: true, completion: nil)

    }
    
    @IBAction func onBackPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func startEditing() {
        // Fix glitch happening when there's cell that is already in the editing state (swiped to reveal delete button) and user presses 'Edit'.
        tableView.isEditing = false
        tableView.isEditing = true
        tableView.reloadData()
        refreshToolbarItems(animated: true)
        
        hiddenNavBarItems = navigationItem.rightBarButtonItems
        navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    
    @IBAction func endEditing() {
        tableView.isEditing = false
        tableView.reloadData()
        
        refreshToolbarItems(animated: true)
        
        navigationItem.setRightBarButtonItems(hiddenNavBarItems, animated: true)
    }

    // MARK: private

    private func addSite(from controller: UIAlertController) {
        guard let field = controller.textFields?[0] else { return }
        guard let domain = domain(from: field) else { return }
        whitelistManager.add(domain: domain)
        tableView.reloadData()
        refreshToolbarItems(animated: true)
    }

    private func domain(from field: UITextField) -> String? {
        guard let domain = field.text?.trimWhitespace() else { return nil }
        guard URL.isValidHostname(domain) || URL.isValidIpHost(domain) else { return nil }
        return domain
    }

    private func createCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if whitelistManager.count > 0 {
            cell = createWhitelistedSiteCell(forRowAt: indexPath)
        } else {
            cell = createNoWhitelistedSitesCell(forRowAt: indexPath)
        }
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        return cell
    }
    
    private func createNoWhitelistedSitesCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let noWhitelistedSitesCell = tableView.dequeueReusableCell(withIdentifier: "NoWhitelistCell") as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue NoSuggestionsTableViewCell using 'NoWhitelistCell' identifier as ")
        }
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        noWhitelistedSitesCell.label.textColor = theme.tableCellTextColor
        
        return noWhitelistedSitesCell
    }
    
    private func createWhitelistedSiteCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let whitelistItemCell = tableView.dequeueReusableCell(withIdentifier: "WhitelistItemCell") as? WhitelistItemCell else {
            fatalError("Failed to dequeue cell as WhitelistItemCell")
        }
        
        whitelistItemCell.domain = whitelistManager.domain(at: indexPath.row)
        
        let theme = enforceLightTheme ? LightTheme() : ThemeManager.shared.currentTheme
        whitelistItemCell.domainLabel.textColor = theme.tableCellTextColor
        
        return whitelistItemCell
    }

}

class WhitelistItemCell: UITableViewCell {

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

extension WhitelistViewController: Themable {
    
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

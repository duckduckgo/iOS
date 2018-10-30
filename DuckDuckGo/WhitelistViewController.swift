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

    let whitelistManager = WhitelistManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
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
            tableView.reloadData()
        }
    }

    // MARK: actions

    @IBAction func onAddPressed() {

        let title = UserText.alertAddToWhitelist
        let placeholder = UserText.alertAddToWhitelistPlaceholder
        let add = UserText.actionAdd
        let cancel = UserText.actionCancel

        let addSiteBox = UIAlertController(title: title, message: "", preferredStyle: .alert)
        addSiteBox.addTextField { (textField) in
            textField.placeholder = placeholder
            
            switch ThemeManager.shared.currentTheme.currentImageSet {
            case .light:
                textField.keyboardAppearance = .light
            case .dark:
                textField.keyboardAppearance = .dark
            }
        }
        addSiteBox.addAction(UIAlertAction.init(title: add, style: .default, handler: { _ in self.addSite(from: addSiteBox) }))
        addSiteBox.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(addSiteBox, animated: true, completion: nil)

    }

    // MARK: private

    private func addSite(from controller: UIAlertController) {
        guard let field = controller.textFields?[0] else { return }
        guard let domain = domain(from: field) else { return }
        whitelistManager.add(domain: domain)
        tableView.reloadData()
    }

    private func domain(from field: UITextField) -> String? {
        guard let domain = field.text?.trimWhitespace() else { return nil }
        guard URL.isValidHostname(domain) || URL.isValidIpHost(domain) else { return nil }
        return domain
    }

    private func createCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard whitelistManager.count > 0 else {
            return createNoWhitelistedSitesCell(forRowAt: indexPath)
        }
        guard let whitelistItemCell = tableView.dequeueReusableCell(withIdentifier: "WhitelistItemCell") as? WhitelistItemCell else {
            fatalError("Failed to dequeue cell as WhitelistItemCell")
        }
        
        whitelistItemCell.domain = whitelistManager.domain(at: indexPath.row)
        
        let theme = ThemeManager.shared.currentTheme
        whitelistItemCell.contentView.backgroundColor = theme.tableCellBackgroundColor
        whitelistItemCell.domainLabel.textColor = theme.tableCellTintColor
        
        return whitelistItemCell
    }
    
    private func createNoWhitelistedSitesCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let noWhitelistedSitesCell = tableView.dequeueReusableCell(withIdentifier: "NoWhitelistCell") as? NoSuggestionsTableViewCell else {
            fatalError("Failed to dequeue NoSuggestionsTableViewCell using 'NoWhitelistCell' identifier as ")
        }
        
        let theme = ThemeManager.shared.currentTheme
        noWhitelistedSitesCell.contentView.backgroundColor = theme.tableCellBackgroundColor
        noWhitelistedSitesCell.label.textColor = theme.tableCellTintColor
        
        return noWhitelistedSitesCell
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
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        infoText.textColor = theme.tableHeaderTextColor
        
        tableView.reloadData()
    }
}

//
//  EmailSettingsViewController.swift
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
import BrowserServicesKit

class EmailSettingsViewController: UITableViewController {
    
    let emailManager = EmailManager()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTextView: UITextView!
    @IBOutlet weak var disableCellLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontSize = fontSizeForHeaderView()
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        let text = String(format: headerTextView.text, emailManager.userEmail ?? "")
        headerTextView.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.kern: -0.08,
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)
            ])
        
        headerTextView.backgroundColor = .clear
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableHeaderView = header
            }
        }
        
        if let footer = tableView.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            footer.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableFooterView = footer
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            emailManager.signOut()
            self.navigationController?.popViewController(animated: true)
            // JS doesn't update automatically, so dax logo will still show until page refreshed
            // we've decided not to handle for now
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
        disableCellLabel.textColor = theme.destructiveColor
        
        return cell
    }
    
    // swiftlint:disable cyclomatic_complexity
    private func fontSizeForHeaderView() -> CGFloat {
        let contentSize = UIApplication.shared.preferredContentSizeCategory
        switch contentSize {
        case .extraSmall:
            return 12
        case .small:
            return 12
        case .medium:
            return 12
        case .large:
            return 13
        case .extraLarge:
            return 15
        case .extraExtraLarge:
            return 17
        case .extraExtraExtraLarge:
            return 19
        case .accessibilityMedium:
            return 23
        case .accessibilityLarge:
            return 27
        case .accessibilityExtraLarge:
            return 33
        case .accessibilityExtraExtraLarge:
            return 38
        case .accessibilityExtraExtraExtraLarge:
            return 44
        default:
            return 13
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension EmailSettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        headerTextView.textColor = theme.tableHeaderTextColor
        headerView.backgroundColor = theme.backgroundColor

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}

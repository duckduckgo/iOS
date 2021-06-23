//
//  EmailProtectionViewController.swift
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
import BrowserServicesKit

final class EmailProtectionViewController: UITableViewController {

    private enum Constants {
        static var supportEmailAddress = URL(string: "mailto:support@duck.com")!
    }

    @IBOutlet weak var emailAccessoryText: UILabel!
    @IBOutlet weak var disableCellLabel: UILabel!
    @IBOutlet weak var footerTextView: UITextView!

    private lazy var emailManager = EmailManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        footerTextView.linkTextAttributes = textViewLinkAttributes()
        footerTextView.attributedText = createAttributedFooterText()

        applyTheme(ThemeManager.shared.currentTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureEmail()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let footer = tableView.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            footer.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableFooterView = footer
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
        disableCellLabel.textColor = theme.destructiveColor

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 0 {
            presentSignOutPrompt()
        }
    }

    private func configureEmail() {
        if emailManager.isSignedIn {
            emailAccessoryText.text = emailManager.userEmail
        } else {
            emailAccessoryText.text = UserText.emailSettingsOff
        }
    }

    private func presentSignOutPrompt() {
        let alertController = UIAlertController(title: UserText.emailSignOutAlertTitle,
                                                message: UserText.emailSignOutAlertDescription,
                                                preferredStyle: .alert)

        alertController.addAction(title: UserText.emailSignOutAlertCancel, style: .cancel)
        alertController.addAction(title: UserText.emailSignOutAlertRemove, style: .default, handler: { [weak self] in
            guard let self = self else { return }

            self.emailManager.signOut()
            self.navigationController?.popViewController(animated: true)
        })

        present(alertController, animated: true)
    }

    private func createAttributedFooterText() -> NSAttributedString {
        return createAttributedString(text: UserText.emailSettingsFooterText, highlights: [
            (text: "support@duck.com", link: Constants.supportEmailAddress.absoluteString)
        ])
    }

    private typealias HighlightedText = (text: String, link: String)

    private func createAttributedString(text: String, highlights: [HighlightedText]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        paragraphStyle.alignment = .left

        let text = text as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        for (highlightedValue, highlightURL) in highlights {
            let range = text.range(of: highlightedValue)

            if range.location == NSNotFound {
                continue
            }

            attributedString.addAttribute(.link, value: highlightURL, range: range)
            attributedString.addAttribute(.font, value: UIFont.appFont(ofSize: 14), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.emailWaitlistLinkColor, range: range)
        }

        return attributedString
    }

    private func textViewLinkAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16

        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: 16,
            NSAttributedString.Key.foregroundColor: UIColor.emailWaitlistLinkColor
        ]

        return linkAttributes
    }

}

extension EmailProtectionViewController: Themable {

    func decorate(with theme: Theme) {
        footerTextView.textColor = theme.tableHeaderTextColor
        tableView.tableFooterView?.backgroundColor = theme.backgroundColor

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor

        tableView.reloadData()
    }

}

extension EmailProtectionViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }

}

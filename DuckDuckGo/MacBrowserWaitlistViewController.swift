//
//  MacBrowserWaitlistViewController.swift
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
import Core

class MacBrowserWaitlistViewController: UIViewController {
    
    private enum Constants {
        static var showWaitlistNotificationPrompt = URL(string: "ddgAction://showWaitlistNotificationPrompt")!
    }

    static func loadFromStoryboard() -> UIViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        
        return storyboard.instantiateViewController(identifier: "MacBrowserWaitlistViewController") { (coder) -> MacBrowserWaitlistViewController? in
            return MacBrowserWaitlistViewController(
                coder: coder,
                viewModel: DeprecatedWaitlisViewModel()
            )
        }
    }

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDescriptionTextView: UITextView!
    @IBOutlet weak var inviteCodeLabel: UILabel!
    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var waitlistActionButton: UIButton!
    @IBOutlet weak var existingInviteCodeButton: UIButton!
    
    private let viewModel: DeprecatedWaitlisViewModel
    private var currentTheme: Theme?
    
    init?(coder: NSCoder, viewModel: DeprecatedWaitlisViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderCurrentWaitlistState()
    }
    
    // MARK: - User Interface
    
    private func renderCurrentWaitlistState() {
        render(state: viewModel.waitlistState)
    }
    
    private func render(state: WaitlistState) {
        switch state {
        case .notJoinedQueue:
            renderNotJoinedQueueState()
        case .joinedQueue:
            renderJoinedQueueState()
        case .inBeta:
            renderInBetaState()
        }
    }

    private func renderNotJoinedQueueState() {
        headerTitleLabel.text = UserText.macBrowserWaitlistTitle
        headerDescriptionTextView.attributedText = createAttributedWaitlistSummary()
        footerTextView.attributedText = createAttributedLearnMoreString()

        inviteCodeLabel.isHidden = true
        waitlistActionButton.isEnabled = true
        waitlistActionButton.isHidden = false
        waitlistActionButton.setTitle(UserText.emailWaitlistJoinWaitlist, for: .normal)
    }
    
    private func renderJoinedQueueState() {
        headerTitleLabel.text = UserText.emailWaitlistJoinedWaitlist

        if EmailWaitlist.shared.showWaitlistNotification {
            headerDescriptionTextView.attributedText = createAttributedWaitlistJoinedWithNotificationSummary()
        } else {
            headerDescriptionTextView.attributedText = createAttributedWaitlistJoinedWithoutNotificationSummary()
        }

        footerTextView.attributedText = createAttributedLearnMoreString()

        inviteCodeLabel.isHidden = true
        waitlistActionButton.isHidden = true
    }
    
    private func renderInBetaState() {
        headerTitleLabel.text = UserText.macBrowserWaitlistTitle
        headerDescriptionTextView.text = "Your invite is here. Please visit duck.com/browser to download the app and enter the code below."
        
        footerTextView.attributedText = createAttributedLearnMoreString()

        inviteCodeLabel.text = viewModel.inviteCode
        inviteCodeLabel.isHidden = false
        waitlistActionButton.isHidden = true
        existingInviteCodeButton.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func resetWaitlistState(_ sender: UIButton) {
        MacBrowserWaitlistKeychainStore().deleteWaitlistState()
        renderCurrentWaitlistState()
    }
    
    @IBAction func waitlistActionButtonTapped(_ sender: UIButton) {
        switch viewModel.waitlistState {
        case .notJoinedQueue: joinWaitlist()
        case .inBeta, .joinedQueue:
            assertionFailure("\(#file): No action for .joinedQueue or .inBeta")
            return
        }
    }
    
    private func joinWaitlist() {
        waitlistActionButton.isEnabled = false

        viewModel.joinWaitlist { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.renderCurrentWaitlistState()
            case .failure:
                self.waitlistActionButton.isEnabled = true
                ActionMessageView.present(message: UserText.emailWaitlistErrorJoining)
            }
        }
    }
    
    // MARK: - Strings
    
    private func createAttributedWaitlistSummary() -> NSAttributedString {
        let text = UserText.macBrowserWaitlistSummary(learnMoreString: UserText.emailWaitlistLearnMore)
        return createAttributedString(text: text, highlights: [
            (text: UserText.emailWaitlistLearnMore, link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }
    
    private func createAttributedLearnMoreString() -> NSAttributedString {
        let text = UserText.macBrowserWaitlistLearnMore(learnMoreString: UserText.emailWaitlistLearnMore)
        return createAttributedString(text: text, highlights: [
            (text: UserText.emailWaitlistLearnMore, link: AppUrls().emailPrivacyGuarantees.absoluteString)
        ])
    }
    
    private func createAttributedWaitlistJoinedWithNotificationSummary() -> NSAttributedString {
        let text = UserText.macBrowserWaitlistJoinedWithNotificationSummary(learnMoreString: UserText.emailWaitlistLearnMore)
        return createAttributedString(text: text, highlights: [
            (text: UserText.emailWaitlistLearnMore, link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }

    private func createAttributedWaitlistJoinedWithoutNotificationSummary() -> NSAttributedString {
        let text = UserText.macBrowserWaitlistJoinedWithoutNotificationSummary(
            getNotifiedString: UserText.macBrowserWaitlistGetANotification,
            learnMoreString: UserText.emailWaitlistLearnMore
        )

        return createAttributedString(text: text, highlights: [
            (text: UserText.emailWaitlistGetANotification, link: Constants.showWaitlistNotificationPrompt.absoluteString),
            (text: UserText.emailWaitlistLearnMore, link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }

    private typealias HighlightedText = (text: String, link: String)

    private func createAttributedString(text: String, highlights: [HighlightedText]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        paragraphStyle.alignment = .center

        let text = text as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: self.currentTheme?.tableHeaderTextColor ?? UIColor.secondaryLabel
        ])

        for (highlightedValue, highlightURL) in highlights {
            let range = text.range(of: highlightedValue)

            if range.location == NSNotFound {
                continue
            }

            attributedString.addAttribute(.link, value: highlightURL, range: range)
            attributedString.addAttribute(.font, value: UIFont.boldAppFont(ofSize: 16), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.emailWaitlistLinkColor, range: range)
        }

        return attributedString
    }
    
}

extension MacBrowserWaitlistViewController: Themable {
    
    func decorate(with theme: Theme) {
        self.currentTheme = theme

        view.backgroundColor = theme.backgroundColor
        headerTitleLabel.textColor = theme.navigationBarTitleColor

        renderCurrentWaitlistState()
    }

}
